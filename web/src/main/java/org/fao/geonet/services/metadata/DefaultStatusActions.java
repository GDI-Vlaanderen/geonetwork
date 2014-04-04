//=============================================================================
//===	Copyright (C) 2001-2011 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.services.metadata;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import jeeves.resources.dbms.Dbms;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.BinaryFile;
import jeeves.utils.Log;
import jeeves.utils.Xml;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MdInfo;
import org.fao.geonet.kernel.mef.MEFLib;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.util.FileCopyMgr;
import org.fao.geonet.util.ISODate;
import org.fao.geonet.util.MailSender;
import org.jdom.Document;
import org.jdom.Element;

public class DefaultStatusActions implements StatusActions {

	private String host, port, from, fromDescr, replyTo, replyToDescr;
	private ServiceContext context;
	private AccessManager am;
	private DataManager dm;
	private Dbms dbms;
	private String siteUrl;
	private UserSession session;
	private boolean emailNotes = true;

	private String allGroup = "1";
	private String stylePath;
	private static String FS = File.separator;

	/**
	 * Constructor.
	 */
	public DefaultStatusActions() {
	}

	/**
	 * Initializes the StatusActions class with external info from GeoNetwork.
	 *
	 * @param context
	 * @param dbms
	 */
	public void init(ServiceContext context, Dbms dbms) {

		this.context = context;
		this.dbms = dbms;

		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		SettingManager sm = gc.getSettingManager();
		am = gc.getAccessManager();

		host = sm.getValue("system/feedback/mailServer/host");
		port = sm.getValue("system/feedback/mailServer/port");
		from = sm.getValue("system/feedback/email");

		if (host.length() == 0) {
			context.error("Mail server host not configured, email notifications won't be sent.");
			emailNotes = false;
		}

		if (port.length() == 0) {
			context.error("Mail server port not configured, email notifications won't be sent.");
			emailNotes = false;
		}

		if (from.length() == 0) {
			context.error("Mail feedback address not configured, email notifications won't be sent.");
			emailNotes = false;
		}

		fromDescr = context.getServlet().getFromDescription();

		session = context.getUserSession();
		replyTo = session.getEmailAddr();
		if (replyTo != null) {
			replyToDescr = session.getName() + " " + session.getSurname();
		} else {
			replyTo = from;
			replyToDescr = fromDescr;
		}

		dm = gc.getDataManager();
		siteUrl = dm.getSiteURL();
		stylePath = context.getAppPath() + FS + Geonet.Path.STYLESHEETS + FS;
	}

	/**
	 * Called when a metadata is created.
	 *
	 * @param id
	 *            the id of the metadata
	 */
	public void onCreate(String id) throws Exception {
		String changeMessage = "GeoNetwork gebruiker " + session.getUserId()
				+ " (" + session.getUsername()
				+ ") heeft metadata record met id " + id + " gecrëeerd.";
		dm.setStatus(context, dbms, id, new Integer(Params.Status.JUSTCREATED),
				new ISODate().toString(), changeMessage);
	}

	/**
	 * Called when a record is edited to set/reset status.
	 *
	 * @param id
	 *            The metadata id that has been edited.
	 * @param minorEdit
	 *            If true then the edit was a minor edit.
	 */
	public void onEdit(String id, boolean minorEdit) throws Exception {

		// AGIV change
		// if (!minorEdit && dm.getCurrentStatus(dbms,
		// id).equals(Params.Status.APPROVED)) {
		if (!minorEdit
				&& !dm.getCurrentStatus(dbms, id).equals(Params.Status.DRAFT)) {

			// String changeMessage =
			// "GeoNetwork user "+session.getUserId()+" ("+session.getUsername()+") edited metadata record "+id;
			String changeMessage = "GeoNetwork gebruiker "
					+ session.getUserId() + " (" + session.getUsername()
					+ ") heeft metadata record met id " + id + " bewerkt.";
			// unsetAllOperations(id);
			dm.setStatus(context, dbms, id, new Integer(Params.Status.DRAFT),
					new ISODate().toString(), changeMessage);
		} else if (minorEdit) {
			// System.out.println("*** minorEdit, not setting status to DRAFT");
		} else {
			// System.out.println("*** current status is not APPROVED: "+
			// dm.getCurrentStatus(dbms, id));
		}
	}

	public void onCancelEdit(String id) throws Exception {

		if (dm.getCurrentStatus(dbms, id).equals(Params.Status.DRAFT)) {

			// String changeMessage =
			// "GeoNetwork user "+session.getUserId()+" ("+session.getUsername()+") canceled edit session for metadata record "+id;
			String changeMessage = "GeoNetwork gebruiker "
					+ session.getUserId() + " (" + session.getUsername()
					+ ") heeft de editeersessie van metadata record met id "
					+ id + " geannuleerd.";
			// unsetAllOperations(id);
			String revertToThisStatus = dm.getLastBeforeCurrentStatus(dbms, id);
			if (StringUtils.isEmpty(revertToThisStatus)) {
				revertToThisStatus = Params.Status.UNKNOWN;
			}
			dm.setStatus(context, dbms, id, new Integer(revertToThisStatus),
					new ISODate().toString(), changeMessage);
		}

	}

	/**
	 * Called when need to set status on a set of metadata records.
	 *
	 * @param status
	 *            The status to set.
	 * @param metadataIds
	 *            The set of metadata ids to set status on.
	 * @param changeDate
	 *            The date the status was changed.
	 * @param changeMessage
	 *            The message explaining why the status has changed.
	 */
	public Set<String> statusChange(String status, Set<String> metadataIds,
			String changeDate, String changeMessage) throws Exception {
		System.out.println("Starting statusChange to " + status + " for #"
				+ metadataIds.size() + " metadata");
		Map<String,String> recordsToBeDeleted = new HashMap<String,String>();
		try {

			Set<String> unchanged = new HashSet<String>();
//			Map<String, Map<String,String>> changedMmetadataIdsToInformOwner = new HashMap<String,Map<String,String>>();
			Map<String, Map<String,String>> changedMmetadataIdsToInformEditors = new HashMap<String,Map<String,String>>();
			Map<String, Map<String,String>> changedMmetadataIdsToInformReviewers = new HashMap<String,Map<String,String>>();
			Map<String, Map<String,String>> changedMmetadataIdsToInformAdministrators = new HashMap<String,Map<String,String>>();
			// -- process the metadata records to set status
			for (String mid : metadataIds) {
				String currentStatus = dm.getCurrentStatus(dbms, mid);

				// --- if the status is already set to value of status then do
				// nothing
				if (status.equals(currentStatus)) {
					if (context.isDebug())
						context.debug("Metadata " + mid
								+ " already has status " + mid);
					unchanged.add(mid);
				}

				// check if this is a template
				MdInfo mdInfo = dm.getMetadataInfo(dbms, mid);
				boolean isWorkspace = dm.existsMetadataInWorkspace(dbms, mid);
				boolean isTemplate = mdInfo.template
						.equals(MdInfo.Template.TEMPLATE)
						|| mdInfo.template.equals(MdInfo.Template.SUBTEMPLATE);

				// templates need not be valid, other md must be valid to change
				// status to approved
				if (!currentStatus.equals(status) && statusChangeAllowedByUser(currentStatus, status, mid, isWorkspace) && (isTemplate ||
					!(status.equals(Params.Status.SUBMITTED_FOR_AGIV) || status.equals(Params.Status.APPROVED_BY_AGIV) ||
					 status.equals(Params.Status.APPROVED)) || statusChangeAllowed(currentStatus, status, mid))) {
					System.out.println("Change status of metadata " + mid
							+ " from " + currentStatus + " to " + status);
					if (status.equals(Params.Status.APPROVED)) {
						if (isTemplate && (session.getProfile().equals(Geonet.Profile.REVIEWER) || session.getProfile().equals(Geonet.Profile.ADMINISTRATOR))) {
//							setAllOperationsForUserGroup(mid);
							setAllOperations(mid);
						} else {
							setAllOperations(mid);
						}
						dm.moveFromWorkspaceToMetadata(context, dbms, mid);
					} else if (/*status.equals(Params.Status.DRAFT)
							|| */status.equals(Params.Status.RETIRED)/*
							|| status.equals(Params.Status.REJECTED)
							|| status.equals(Params.Status.REJECTED_BY_AGIV)*/) {
						unsetAllOperations(mid);
					}
					if (status.equals(Params.Status.REJECTED_FOR_RETIRE) || status.equals(Params.Status.REJECTED_FOR_REMOVE)) {
						dm.setStatus(context, dbms, mid, new Integer("2"),
								new ISODate().toString(), changeMessage);
					} else {
						// --- set status, indexing is assumed to take place later
						// heikki: why later ?!
						// dm.setStatusExt(context, dbms, mid, new Integer(status),
						// changeDate, changeMessage);
						dm.setStatus(context, dbms, mid, new Integer(status),
								new ISODate().toString(), changeMessage);
					}
					if (!(currentStatus.equals(Params.Status.UNKNOWN) && status.equals(Params.Status.APPROVED))) {
						Map<String,String> properties = new HashMap<String,String>();
						properties.put("title", dm.extractTitle(context, mdInfo.schemaId, mid));
						properties.put("currentStatus", currentStatus);
						switch(Integer.parseInt(status)) {
							case 0: //UNKNOWN
								break;
							case 1: //DRAFT
/*
								if (StringUtils.isNotBlank(lockedBy)) {
									properties.put("lockedBy", mdInfo.lockedBy);
					            	changedMmetadataIdsToInformOwner.put(mid,properties);
					            }
*/
								changedMmetadataIdsToInformEditors.put(mid,properties);
								break;
							case 2: //APPROVED
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								changedMmetadataIdsToInformAdministrators.put(mid,properties);
								break;
							case 3: //RETIRED
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								if (context.getServlet().getNodeType().equalsIgnoreCase("agiv")) {
									changedMmetadataIdsToInformAdministrators.put(mid,properties);
								}
								break;
							case 4: //SUBMITTED
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								break;
							case 5: //REJECTED
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								break;
							case 6: //JUSTCREATED
								break;
							case 7: //SUBMITTED_FOR_AGIV
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								changedMmetadataIdsToInformAdministrators.put(mid,properties);
								break;
							case 8: //APPROVED_BY_AGIV
								if (session.getProfile().equals(Geonet.Profile.ADMINISTRATOR) && currentStatus.equals(Params.Status.DRAFT)) {
									changedMmetadataIdsToInformEditors.put(mid,properties);
									changedMmetadataIdsToInformReviewers.put(mid,properties);
								}
								changedMmetadataIdsToInformAdministrators.put(mid,properties);
								break;
							case 9: //REJECTED_BY_AGIV
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								changedMmetadataIdsToInformAdministrators.put(mid,properties);
								break;
							case 10: //RETIRED_FOR_AGIV
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								changedMmetadataIdsToInformAdministrators.put(mid,properties);
								break;
							case 11: //REMOVED_FOR_AGIV
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								changedMmetadataIdsToInformAdministrators.put(mid,properties);
								break;
							case 12: //REMOVED
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								if (context.getServlet().getNodeType().equalsIgnoreCase("agiv")) {
									changedMmetadataIdsToInformAdministrators.put(mid,properties);
								}
								recordsToBeDeleted.put(mid, mdInfo.uuid);
								break;
							case 13: //REJECTED_FOR_RETIRE
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								changedMmetadataIdsToInformAdministrators.put(mid,properties);
								break;
							case 14: //REJECTED_FOR_REMOVE
								changedMmetadataIdsToInformEditors.put(mid,properties);
								changedMmetadataIdsToInformReviewers.put(mid,properties);
								changedMmetadataIdsToInformAdministrators.put(mid,properties);
								break;
							default:
								break;
						}
					}
				} else {
					if (currentStatus.equals(status)) {
						unchanged.add(mid);
					} else {
						unchanged.add("!" + mid);
					}
					System.out
							.println("Status change not allowed for metadata "
									+ mid + " from " + currentStatus + " to "
									+ status);
				}
			}
			List<String> emailMetadataIdList = new ArrayList<String>();
			if (changedMmetadataIdsToInformAdministrators.size()>0) {
				informContentUsers(changedMmetadataIdsToInformAdministrators, changeDate,
						changeMessage, Geonet.Profile.ADMINISTRATOR, status, emailMetadataIdList);
			}
			if (changedMmetadataIdsToInformReviewers.size()>0) {
				informContentUsers(changedMmetadataIdsToInformReviewers, changeDate,
						changeMessage, Geonet.Profile.REVIEWER, status, emailMetadataIdList);
			}
			if (changedMmetadataIdsToInformEditors.size()>0) {
				informContentUsers(changedMmetadataIdsToInformEditors, changeDate,
						changeMessage, Geonet.Profile.EDITOR, status, emailMetadataIdList);
			}
/*
			if (changedMmetadataIdsToInformOwner.size()>0) {
				String styleSheet = stylePath + Geonet.File.STATUS_CHANGE_EMAIL;
				for (String metadataId : changedMmetadataIdsToInformOwner.keySet()) { 
					String lockedBy = changedMmetadataIdsToInformOwner.get(metadataId).get("lockedBy");
		            if (!StringUtils.isBlank(lockedBy)) {
						List<Element> userList = dbms.select("SELECT email FROM Users WHERE id = '" + lockedBy + "'").getChildren();
		        		Element user = (Element) userList.get(0);
			            if (user!=null) {
			        		user.detach();
			        		String email = user.getChildText("email");
				            if (!StringUtils.isBlank(lockedBy) && !emailMetadataIdList.contains(email + "_" + metadataId)) {
				        		Element root = getNewRootElement(Params.Status.DRAFT, context.getServlet().getFromDescription(), session.getUserId());
				    			Element metadata = new Element("metadata");
				    			root.addContent(metadata);
				    			metadata.addContent(new Element("url").setText(buildMetadataLink(metadataId)));
								metadata.addContent(new Element("title").setText(changedMmetadataIdsToInformOwner.get(metadataId).get("title")));
								metadata.addContent(new Element("currentStatus").setText(changedMmetadataIdsToInformOwner.get(metadataId).get("currentStatus")));
								sendEmail(email, Xml.transform(root, styleSheet));
				            }
			            }
		            }
				}
			}
*/
			return unchanged;
		} catch (Throwable x) {
			System.out.println("ERROR in statusChange " + x.getMessage());
			x.printStackTrace();
			throw new Exception(x);
		} finally {
			try {
				for (String mid : recordsToBeDeleted.keySet()) {
					String uuid = recordsToBeDeleted.get(mid);
					backupFile(context, mid, uuid, MEFLib.doExport(context, uuid, "full", false, true, false));
					File pb = new File(Lib.resource.getMetadataDir(context, mid));
					FileCopyMgr.removeDirectoryOrFile(pb);
					dm.deleteMetadata(context, dbms, mid);
				}
			} catch (Exception e) {
				System.out.println("ERROR in statusChange during delete metadata " + e.getMessage());
			}			
		}
	}

	/**
	 *
	 * @param currentStatus
	 * @param status
	 * @param mid
	 * @return
	 * @throws Exception
	 */
	private boolean statusChangeAllowedByUser(String currentStatus, String status,
			String mid, boolean isWorkspace) throws Exception {
		boolean changeAllowed = am.canEdit(context, mid);
		if (changeAllowed) {
			if (session.getProfile().equals(Geonet.Profile.ADMINISTRATOR)) {
				switch(Integer.parseInt(status)) {
					case 0: //UNKNOWN
						break;
					case 1: //DRAFT
						if (currentStatus.equals(Params.Status.SUBMITTED) || currentStatus.equals(Params.Status.SUBMITTED_FOR_AGIV) || currentStatus.equals(Params.Status.REJECTED) || currentStatus.equals(Params.Status.APPROVED_BY_AGIV) || currentStatus.equals(Params.Status.REJECTED_BY_AGIV) || currentStatus.equals(Params.Status.RETIRED_FOR_AGIV) || currentStatus.equals(Params.Status.REMOVED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					case 2: //APPROVED
						if (currentStatus.equals(Params.Status.SUBMITTED) || currentStatus.equals(Params.Status.REJECTED) || currentStatus.equals(Params.Status.REJECTED_BY_AGIV) || currentStatus.equals(Params.Status.RETIRED_FOR_AGIV) || currentStatus.equals(Params.Status.REMOVED_FOR_AGIV) || currentStatus.equals(Params.Status.REJECTED_FOR_RETIRE) || currentStatus.equals(Params.Status.REJECTED_FOR_REMOVE)) {
							changeAllowed = false;
						}
						break;
					case 3: //RETIRED
						if (context.getServlet().getNodeType().equalsIgnoreCase("agiv") && !currentStatus.equals(Params.Status.RETIRED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					case 4: //SUBMITTED
//						if (context.getServlet().getNodeType().equalsIgnoreCase("agiv")) {
							changeAllowed = false;
//						}
						break;
					case 5: //REJECTED
						changeAllowed = false;
						break;
					case 6: //JUSTCREATED
						break;
					case 7: //SUBMITTED_FOR_AGIV
						if (!currentStatus.equals(Params.Status.DRAFT)) {
							changeAllowed = false;
						}
						break;
					case 8: //APPROVED_BY_AGIV
						if (!currentStatus.equals(Params.Status.DRAFT) && !currentStatus.equals(Params.Status.SUBMITTED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					case 9: //REJECTED_BY_AGIV
						if (currentStatus.equals(Params.Status.DRAFT) || currentStatus.equals(Params.Status.APPROVED) || currentStatus.equals(Params.Status.RETIRED) || currentStatus.equals(Params.Status.SUBMITTED) || currentStatus.equals(Params.Status.REJECTED) ||
							currentStatus.equals(Params.Status.APPROVED_BY_AGIV) || currentStatus.equals(Params.Status.RETIRED_FOR_AGIV) || currentStatus.equals(Params.Status.REMOVED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					case 10: //RETIRED_FOR_AGIV
						if (isWorkspace || currentStatus.equals(Params.Status.RETIRED) || currentStatus.equals(Params.Status.REMOVED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					case 11: //REMOVED_FOR_AGIV
						if (isWorkspace || currentStatus.equals(Params.Status.RETIRED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					case 12: //REMOVED
						if (context.getServlet().getNodeType().equalsIgnoreCase("agiv") && !currentStatus.equals(Params.Status.REMOVED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					case 13: //REJECTED_FOR_RETIRE
						if (!currentStatus.equals(Params.Status.RETIRED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					case 14: //REJECTED_FOR_REMOVE
						if (!currentStatus.equals(Params.Status.REMOVED_FOR_AGIV)) {
							changeAllowed = false;
						}
						break;
					default:
						break;
				}
			} else if (session.getProfile().equals(Geonet.Profile.REVIEWER)) {
				if (currentStatus.equals(Params.Status.SUBMITTED_FOR_AGIV) || currentStatus.equals(Params.Status.APPROVED_BY_AGIV) || currentStatus.equals(Params.Status.RETIRED_FOR_AGIV) || currentStatus.equals(Params.Status.REMOVED_FOR_AGIV) ) {
					changeAllowed = false;
				} else {
					switch(Integer.parseInt(status)) {
						case 0: //UNKNOWN
							changeAllowed = false;
							break;
						case 1: //DRAFT
							changeAllowed = false;
							break;
						case 2: //APPROVED
							if (context.getServlet().getNodeType().equalsIgnoreCase("agiv")) {
								changeAllowed = false;
							}
							break;
						case 3: //RETIRED
							changeAllowed = false;
							break;
						case 4: //SUBMITTED
							if (currentStatus.equals(Params.Status.APPROVED) || currentStatus.equals(Params.Status.RETIRED)) {
								changeAllowed = false;
							}/* else if (am.isLockedBy(context, mid)) {
								changeAllowed = false;
							}*/
							break;
						case 5: //REJECTED
							if (currentStatus.equals(Params.Status.APPROVED) || currentStatus.equals(Params.Status.RETIRED)) {
								changeAllowed = false;
							}
							break;
						case 6: //JUSTCREATED
							changeAllowed = false;
							break;
						case 7: //SUBMITTED_FOR_AGIV
							if (currentStatus.equals(Params.Status.APPROVED) || currentStatus.equals(Params.Status.RETIRED)) {
								changeAllowed = false;
							}
							break;
						case 8: //APPROVED_BY_AGIV
							changeAllowed = false;
							break;
						case 9: //REJECTED_BY_AGIV
							changeAllowed = false;
							break;
						case 10: //RETIRED_FOR_AGIV
							if (isWorkspace || currentStatus.equals(Params.Status.RETIRED) || currentStatus.equals(Params.Status.REMOVED_FOR_AGIV)) {
								changeAllowed = false;
							}
							break;
						case 11: //REMOVED_FOR_AGIV
							if (isWorkspace || currentStatus.equals(Params.Status.RETIRED_FOR_AGIV)) {
								changeAllowed = false;
							}
							break;
						case 12: //REMOVED
							changeAllowed = false;
							break;
						case 13: //REJECTED_FOR_RETIRE
							changeAllowed = false;
							break;
						case 14: //REJECTED_FOR_REMOVE
							changeAllowed = false;
							break;
						default:
							break;
					}
				}
			} else if (session.getProfile().equals(Geonet.Profile.EDITOR)) {
				if (!am.isOwner(context, mid) || currentStatus.equals(Params.Status.SUBMITTED) || currentStatus.equals(Params.Status.SUBMITTED_FOR_AGIV)) {
					changeAllowed = false;
				} else {
					switch(Integer.parseInt(status)) {
						case 0: //UNKNOWN
							changeAllowed = false;
							break;
						case 1: //DRAFT
							changeAllowed = false;
							break;
						case 2: //APPROVED
							changeAllowed = false;
							break;
						case 3: //RETIRED
							changeAllowed = false;
							break;
						case 4: //SUBMITTED
							if (!(currentStatus.equals(Params.Status.DRAFT) || currentStatus.equals(Params.Status.REJECTED) || currentStatus.equals(Params.Status.REJECTED_BY_AGIV))) {
								changeAllowed = false;
							}
							break;
						case 5: //REJECTED
							changeAllowed = false;
							break;
						case 6: //JUSTCREATED
							changeAllowed = false;
							break;
						case 7: //SUBMITTED_FOR_AGIV
							changeAllowed = false;
							break;
						case 8: //APPROVED_BY_AGIV
							changeAllowed = false;
							break;
						case 9: //REJECTED_BY_AGIV
							changeAllowed = false;
							break;
						case 10: //RETIRED_FOR_AGIV
							changeAllowed = false;
							break;
						case 11: //REMOVED_FOR_AGIV
							changeAllowed = false;
							break;
						case 12: //REMOVED
							changeAllowed = false;
							break;
						case 13: //REJECTED_FOR_RETIRE
							changeAllowed = false;
							break;
						case 14: //REJECTED_FOR_REMOVE
							changeAllowed = false;
							break;
						default:
							break;
					}
				}
			}
		}
		return changeAllowed;
	}

	/**
	 *
	 * @param currentStatus
	 * @param status
	 * @param mid
	 * @return
	 * @throws Exception
	 */
	private boolean statusChangeAllowed(String currentStatus, String status,
			String mid) throws Exception {
		//
		// AGIV: trigger validation when status is changed. If one of the
		// validations fails, the change is not allowed (depending on which
		// logical node this is).
		//
		// heikki: use non-boolean doValidate, to get errorreport in session (we
		// need to know which validation failed exactly)
		// OR use the other doValidate and then here retrieve validationresult
		// from db <-- better because errorreport is too detailed, we want the
		// summary here

		// the workspace md should be validated if the current status is draft
		// or rejected and the status to be set is submitted; OR
		// if the current status is submitted and the status to be set is
		// approved
		boolean workspace;
/*
		if (((currentStatus.equals(Params.Status.DRAFT) || currentStatus.equals(Params.Status.REJECTED)) && status.equals(Params.Status.SUBMITTED)) ||
			(currentStatus.equals(Params.Status.SUBMITTED) && status.equals(Params.Status.APPROVED))) {
			workspace = true;
		} else {
			workspace = false;
		}
		if (((currentStatus.equals(Params.Status.DRAFT) || currentStatus.equals(Params.Status.REJECTED) || currentStatus.equals(Params.Status.REJECTED_BY_AGIV)) && status.equals(Params.Status.SUBMITTED)) ||
			(currentStatus.equals(Params.Status.SUBMITTED) && (status.equals(Params.Status.APPROVED_BY_AGIV) || status.equals(Params.Status.APPROVED))) ||
			(currentStatus.equals(Params.Status.APPROVED_BY_AGIV) && status.equals(Params.Status.APPROVED))) {
			workspace = true;
		} else {
			workspace = false;
		}
*/
		if (!(currentStatus.equals(Params.Status.APPROVED) || currentStatus.equals(Params.Status.RETIRED) || currentStatus.equals(Params.Status.JUSTCREATED) || currentStatus.equals(Params.Status.UNKNOWN))) {
			workspace = true;
		} else {
			workspace = false;
		}
		// retrieve md as Document
		Document doc;
		Element mdE;
		if (workspace) {
			mdE = dm.getMetadataFromWorkspaceNoInfo(context, mid);
			if (mdE==null) {
				mdE = dm.getMetadataNoInfo(context, mid);
				workspace=false;
			}
		} else {
			mdE = dm.getMetadataNoInfo(context, mid);
		}
		doc = new Document(mdE);

		// the md schema
		String schema = dm.getMetadataSchema(dbms, mid);
		// validate
		boolean valid = dm.doValidate(context, dbms, schema, mid, doc,
				context.getLanguage(), workspace);

//		boolean statusChangeAllowed = true;

		// if the md is not valid, analyze why not and allow or disallow status
		// change depending on what exactly was not valid and which logical node
		// this is
		if (!valid) {
			// retrieve validationreport from db
			// this is a list of <record> Elements with <valtype>, <status>,
			// <tested>, and <failed> child elements
			List<Element> validationStatus = validationStatus = dm
					.getValidationStatus(dbms, mid, workspace);
			// if this is AGIV Edit or the AGIV View Node:
			// Only when the metadata validates against the ISO schemas and
			// schematrons, it can be set to
			// "Submitted to AGIV",
			// "Submitted to the Principal Editor", and
			// "Approved by AGIV" states.
			// In case these validations do not succeed, the metadata is
			// returned to the "Draft" state and the
			// user informed.
			// Even if a metadata record does not validate against the INSPIRE
			// and GDI-Vlaanderen Best Practices
			// schematrons, it can be set to the above mentioned states (these
			// both checks are not blocking).

			// GDI Vlaanderen Node:
			// Only be set to "Submitted" or "Approved" when the metadata
			// validates against the ISO schemas and
			// schematrons. If a metadata record's status is changed, the
			// metadata validation (all measures)
			// will be triggered. Metadata records only get the "Approved" or
			// "Submitted" status if the ISO XSD
			// and schematron validation was performed OK.
			// INSPIRE and GDI-Vlaanderen Best Practices validity are given for
			// information only, metadata can
			// be saved and set to the above mentioned states even in case that
			// the validation for these 2
			// measures was not successful.

			// INSPIRE Node:
			// only gets its metadata through Harvesting. INSPIRE compliance is
			// enforced by the validation in
			// the CSW INSPIRE harvester.

			// heikki: so in short, the status change is only allowed if ISO XSD
			// and schematron validation has
			// passed; the same for all logical nodes !

			for (Element record : validationStatus) {
				// check that xsd validation succeeded
				if (record.getChildText("valtype").equals("xsd")) {
					if (!record.getChildText("status").equals("1")/*
							&& (status
									.equals(Params.Status.SUBMITTED_FOR_AGIV) || status
									.equals(Params.Status.APPROVED_BY_AGIV) || status
									.equals(Params.Status.APPROVED))*/) {
						System.out.println("Metadata with id " + mid
								+ " failed XSD validation: status change not "
								+ "allowed");
						return false;
					}
				}
				// check that iso schematron validation succeeded
				if (record.getChildText("valtype").equals(
						"schematron-rules-iso") || record.getChildText("valtype").equals("schematron-rules-inspire")) {
					if (!record.getChildText("status").equals("1")/*
							&& (status
									.equals(Params.Status.SUBMITTED_FOR_AGIV) || status
									.equals(Params.Status.APPROVED_BY_AGIV) || status
									.equals(Params.Status.APPROVED))*/) {
						System.out
								.println("Metadata with id "
										+ mid
										+ " failed ISO Schematron and/of INSPIRE Schematron validation: status change not allowed");
						return false;
					}
				}
			}
		}
		return true;
	}

	// -------------------------------------------------------------------------
	// Private methods
	// -------------------------------------------------------------------------

	/**
	 * Set all operations on 'All' Group. Used when status changes from
	 * submitted to approved.
	 *
	 * @param mdId
	 *            The metadata id to set privileges on
	 */
	private void setAllOperations(String mdId) throws Exception {
		String allGroup = "1";
		dm.setOperation(context, dbms, mdId, allGroup, AccessManager.OPER_VIEW);
		dm.setOperation(context, dbms, mdId, allGroup,
				AccessManager.OPER_DOWNLOAD);
		dm.setOperation(context, dbms, mdId, allGroup,
				AccessManager.OPER_NOTIFY);
		dm.setOperation(context, dbms, mdId, allGroup,
				AccessManager.OPER_DYNAMIC);
		dm.setOperation(context, dbms, mdId, allGroup,
				AccessManager.OPER_FEATURED);
	}

	/**
	 * Set all operations on 'All' Group. Used when status changes from
	 * submitted to approved.
	 *
	 * @param mdId
	 *            The metadata id to set privileges on
	 */
	private void setAllOperationsForUserGroup(String mdId) throws Exception {
		List<String> groups = am.getUserGroups(dbms, session, null);
		for (Iterator<String> i = groups.iterator(); i.hasNext();) {
			String groupId = i.next();
	        if(!(groupId.equals("-1") || groupId.equals("0") || groupId.equals("1"))) {
				dm.setOperation(context, dbms, mdId, groupId,
						AccessManager.OPER_VIEW);
				dm.setOperation(context, dbms, mdId, groupId,
						AccessManager.OPER_DOWNLOAD);
				dm.setOperation(context, dbms, mdId, groupId,
						AccessManager.OPER_NOTIFY);
				dm.setOperation(context, dbms, mdId, groupId,
						AccessManager.OPER_DYNAMIC);
				dm.setOperation(context, dbms, mdId, groupId,
						AccessManager.OPER_FEATURED);
	        }
		}
	}

	/**
	 * Unset all operations on 'All' Group. Used when status changes from
	 * approved to something else.
	 *
	 * @param mdId
	 *            The metadata id to unset privileges on
	 */
	private void unsetAllOperations(String mdId) throws Exception {
		String allGroup = "1";
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_VIEW);
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_DOWNLOAD);
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_NOTIFY);
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_DYNAMIC);
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_FEATURED);
	}

	/**
	 * Inform content users of metadata records in list
	 *
	 * @param metadata
	 *            The selected set of metadata records
	 * @param changeDate
	 *            The date that of the change in status
	 * @param changeMessage
	 *            Message supplied by the user that set the status
	 * @param status
	 *            New status
	 * @param profile
	 *            Profile of users to be informed
	 */
	private void informContentUsers(Map<String,Map<String,String>> metadataMap,
			String changeDate, String changeMessage, String profile, String status, List<String> emailMetadataIdList) throws Exception {

		// --- get content reviewers (sorted on content reviewer userid)
		Element contentUsers;
		if (profile.equals(Geonet.Profile.ADMINISTRATOR)) {
			contentUsers = am.getContentAdmins(dbms, metadataMap.keySet());
		} else {
			contentUsers = am.getContentUsers(dbms, metadataMap.keySet(), profile);
		}

		String subject = "Status metadata record(s) gewijzigd naar '" + dm.getStatusDes(dbms, status, context.getLanguage()) + "' door " + replyTo + " ("
					+ replyToDescr + ") op " + changeDate;

		processList(contentUsers, subject, status, changeDate, changeMessage, metadataMap, emailMetadataIdList);
	}

	/**
	 * Process the users and metadata records for emailing notices.
	 *
	 * @param records
	 *            The selected set of records
	 * @param subject
	 *            Subject to be used for email notices
	 * @param status
	 *            The status being set
	 * @param changeDate
	 *            Datestamp of status change
	 */
	@SuppressWarnings("unchecked")
	private void processList(Element contentUsers, String subject, String status,
			String changeDate, String changeMessage, Map<String,Map<String,String>> metadataMap, List<String> emailMetadataIdList)
			throws Exception {

		String styleSheet = stylePath + Geonet.File.STATUS_CHANGE_EMAIL;
		Set<String> metadataIds = new HashSet<String>();
		String currentUserId = null;
		String userId = null;
		String currentEmail = null;
		List<Element> records = contentUsers.getChildren();
		Iterator<Element> recordsIterator = records.iterator();
		Element root = null;
		Element metadata = null;
		while(recordsIterator.hasNext()) {
			Element record = recordsIterator.next();
			String metadataId = record.getChildText("metadataid");
			userId = record.getChildText("userid");
			if (currentUserId==null) {
				currentUserId = userId;
				currentEmail = record.getChildText("email");
				if (currentEmail!=null) {
					currentEmail = currentEmail.toLowerCase();
				}
				root = getNewRootElement(status, changeMessage, context.getUserSession().getUserId());
			} else if (!currentUserId.equals(userId)) {
				if (StringUtils.isNotBlank(currentEmail) && metadataIds.size()>0) {
					sendEmail(currentEmail, Xml.transform(root, styleSheet));
//					sendEmail(currentEmail, subject, status, changeDate, changeMessage, metadataIds);
					metadataIds.clear();
				}
				currentUserId = userId;
				currentEmail = record.getChildText("email");
				if (currentEmail!=null) {
					currentEmail = currentEmail.toLowerCase();
				}
				root = getNewRootElement(status, changeMessage, context.getUserSession().getUserId());
			}
			if (StringUtils.isNotBlank(currentEmail) && !emailMetadataIdList.contains(currentEmail + "_" + metadataId)) {
				emailMetadataIdList.add(currentEmail + "_" + metadataId);
				metadataIds.add(metadataId);
				metadata = new Element("metadata");
				root.addContent(metadata);
				metadata.addContent(new Element("url").setText(buildMetadataLink(metadataId)));
				metadata.addContent(new Element("title").setText(metadataMap.get(metadataId).get("title").toString()));
				metadata.addContent(new Element("currentStatus").setText(metadataMap.get(metadataId).get("currentStatus").toString()));
			}
		}

		if (StringUtils.isNotBlank(currentEmail) && metadataIds.size()>0) {
			sendEmail(currentEmail, Xml.transform(root, styleSheet));
//			sendEmail(currentEmail, subject, status, changeDate, changeMessage, metadataIds);
		}
	}

	private Element getNewRootElement(String status, String changeMessage, String userId) throws SQLException {
		Element root = new Element("root");
		List<Element> userList = dbms.select("SELECT surname, name FROM Users WHERE id = '" + userId + "'").getChildren();
		Element user = (Element) userList.get(0);
		user.detach();
		user.setName("user");
		root.addContent(user);
		List<Element> groupList = dbms.select("SELECT description FROM groups as g, usergroups as ug WHERE ug.userid = '" + userId + "' AND ug.groupid = g.id").getChildren();
		for (Element group : groupList) {
			root.addContent(new Element("group").setText(group.getChildText("description")));
		}
		root.addContent(new Element("node").setText(context.getServlet().getNodeType().toLowerCase()));
		root.addContent(new Element("siteUrl").setText(getContextUrl()));
		root.addContent(new Element("metadatacenter").setText(context.getServlet().getFromDescription()));
		root.addContent(new Element("status").setText(status));
		root.addContent(new Element("changeMessage").setText(changeMessage));
		return root;
	}
	/**
	 * Send the email message about change of status on a group of metadata
	 * records.
	 *
	 * @param sendTo
	 *            The recipient email address
	 * @param subject
	 *            Subject to be used for email notices
	 * @param status
	 *            The status being set on the records
	 * @param changeDate
	 *            Datestamp of status change
	 * @param changeMessage
	 *            The message indicating why the status has changed
	 */
	private void sendEmail(String sendTo, String subject, String status,
			String changeDate, String changeMessage, Set<String> metadataIds)
			throws Exception {

		if (metadataIds.size() > 1) {
			changeMessage += "\n\nDe metadatarecords zijn beschikbaar via de volgende URL's:\n";
		} else {
			changeMessage += "\n\nHet metadatarecord is beschikbaar via de volgende URL:\n";
		}
		for (String metadataId : metadataIds) {
			changeMessage += "\n" + buildMetadataLink(metadataId);
		}

		if (!emailNotes) {
			context.info("Would send email with message:\n" + changeMessage);
		} else {
			MailSender sender = new MailSender(context);
			sender.sendWithReplyTo(host, Integer.parseInt(port), from,
					fromDescr, sendTo, null, replyTo, replyToDescr, subject,
					changeMessage);
		}
	}

	private void sendEmail(String sendTo, Element emailElement)
			throws Exception {
		MailSender sender = new MailSender(context);
		sender.sendWithReplyTo(host, Integer.parseInt(port), from,
				fromDescr, sendTo, null, replyTo, replyToDescr, emailElement.getChildText("subject"),
				emailElement.getChildText("message"));
	}
	/**
	 * Build search link to metadata that has had a change of status.
	 *
	 * @param metadataId
	 *            The id of the metadata
	 * @return string Search link to metadata
	 */
	private String buildMetadataLink(String metadataId) {
		// TODO: hack voor AGIV
		return getContextUrl()
//				+ "/apps/tabsearch/index_login.html?id=" + metadataId;
				+ "/apps/tabsearch/index.html?id=" + metadataId + "&external=true";
	}

	private String getContextUrl() {
		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		String protocol = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_PROTOCOL);
		String host = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_HOST);
		String port = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_PORT);
		return /*protocol + */"https://" + host + ((port.equals("80") || port.equals("443")) ? "" : ":" + port)
				+ context.getBaseUrl();
	}

	/**
	 * Build search link to metadata that has had a change of status.
	 *
	 * @param status
	 *            The status of the metadata
	 * @param changeDate
	 *            The date the status has been set on the metadata
	 * @return string Search link to metadata
	 */
	private String buildMetadataSearchLink(String status, String metadataId,
			String changeDate) {
		// FIXME : hard coded link to main.search
		return siteUrl + "/main.search?_status=" + status
				+ "&_statusChangeDate=" + changeDate;
	}

	private void backupFile(ServiceContext context, String id, String uuid, String file)
	{
		String outDir = Lib.resource.getRemovedDir(context, id);
		String outFile= outDir + uuid +".mef";

		new File(outDir).mkdirs();

		try
		{
			FileInputStream  is = new FileInputStream(file);
			FileOutputStream os = new FileOutputStream(outFile);

			BinaryFile.copy(is, os, true, true);
		}
		catch(Exception e)
		{
			context.warning("Cannot backup mef file : "+e.getMessage());
			e.printStackTrace();
		}

		new File(file).delete();
	}
}