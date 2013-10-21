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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import jeeves.resources.dbms.Dbms;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MdInfo;
import org.fao.geonet.kernel.setting.SettingManager;
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
		try {

			Set<String> unchanged = new HashSet<String>();
			Set<String> changedMmetadataIdsToInformEditors = new HashSet<String>();
			Set<String> changedMmetadataIdsToInformReveiwers = new HashSet<String>();
			Set<String> changedMmetadataIdsToInformAdministrators = new HashSet<String>();

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
				boolean isTemplate = mdInfo.template
						.equals(MdInfo.Template.TEMPLATE)
						|| mdInfo.template.equals(MdInfo.Template.SUBTEMPLATE);

				// templates need not be valid, other md must be valid to change
				// status to approved
				if (!currentStatus.equals(status) && statusChangeAllowedByUser(currentStatus, status, mid) && (isTemplate || 
					!(status.equals(Params.Status.SUBMITTED_FOR_AGIV) || status.equals(Params.Status.APPROVED_BY_AGIV) ||
					 status.equals(Params.Status.APPROVED)) || statusChangeAllowed(currentStatus, status, mid))) {
					System.out.println("Change status of metadata " + mid
							+ " from " + currentStatus + " to " + status);
					if (status.equals(Params.Status.APPROVED)) {
						if (isTemplate && (session.getProfile().equals(Geonet.Profile.REVIEWER) || session.getProfile().equals(Geonet.Profile.ADMINISTRATOR))) {
							setAllOperationsForUserGroup(mid);
						} else {
							setAllOperations(mid);
						}
						dm.moveFromWorkspaceToMetadata(context, dbms, mid);
					} else if (status.equals(Params.Status.DRAFT)
							|| status.equals(Params.Status.RETIRED)
							|| status.equals(Params.Status.REJECTED)
							|| status.equals(Params.Status.REJECTED_BY_AGIV)) {
						unsetAllOperations(mid);
					}

					// --- set status, indexing is assumed to take place later
					// heikki: why later ?!
					// dm.setStatusExt(context, dbms, mid, new Integer(status),
					// changeDate, changeMessage);
					dm.setStatus(context, dbms, mid, new Integer(status),
							new ISODate().toString(), changeMessage);
					if (!(currentStatus.equals(Params.Status.UNKNOWN) && status.equals(Params.Status.APPROVED))) {
						if (status.equals(Params.Status.DRAFT)) {
							changedMmetadataIdsToInformEditors.add(mid);
						} else if (status.equals(Params.Status.SUBMITTED)) {
							changedMmetadataIdsToInformReveiwers.add(mid);
						} else if (status.equals(Params.Status.REJECTED)) {
							changedMmetadataIdsToInformEditors.add(mid);
						} else if (status.equals(Params.Status.SUBMITTED_FOR_AGIV)) {
							changedMmetadataIdsToInformAdministrators.add(mid);
						} else if (status.equals(Params.Status.REJECTED_BY_AGIV)) {
							changedMmetadataIdsToInformEditors.add(mid);
							changedMmetadataIdsToInformReveiwers.add(mid);
						} else if (status.equals(Params.Status.APPROVED)) {
							changedMmetadataIdsToInformEditors.add(mid);
							if (context.getServlet().getNodeType().equalsIgnoreCase("agiv")) {
								changedMmetadataIdsToInformReveiwers.add(mid);
							}
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
			if (changedMmetadataIdsToInformEditors.size()>0) {
				informContentUsers(changedMmetadataIdsToInformEditors, changeDate,
						changeMessage, Geonet.Profile.EDITOR, status);
			}
			if (changedMmetadataIdsToInformReveiwers.size()>0) {
				informContentUsers(changedMmetadataIdsToInformReveiwers, changeDate,
						changeMessage, Geonet.Profile.REVIEWER, status);
			}
			if (changedMmetadataIdsToInformAdministrators.size()>0) {
				informContentUsers(changedMmetadataIdsToInformAdministrators, changeDate,
						changeMessage, Geonet.Profile.ADMINISTRATOR, status);
			}
			return unchanged;
		} catch (Throwable x) {
			System.out.println("ERROR in statusChange " + x.getMessage());
			x.printStackTrace();
			throw new Exception(x);
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
			String mid) throws Exception {
		boolean changeAllowed = am.canEdit(context, mid);
		if (changeAllowed) {
			if (session.getProfile().equals(Geonet.Profile.ADMINISTRATOR)) {
				if (status.equals(Params.Status.REJECTED) || status.equals(Params.Status.SUBMITTED)) {
					changeAllowed = false;
				}
/*
				if (status.equals(Params.Status.APPROVED) && !context.getServlet().getNodeType().equalsIgnoreCase("agiv")) {
					changeAllowed = false;
*/
			}
			if (changeAllowed && session.getProfile().equals(Geonet.Profile.REVIEWER) || session.getProfile().equals(Geonet.Profile.EDITOR)) {
				if (status.equals(Params.Status.DRAFT) || status.equals(Params.Status.UNKNOWN) || currentStatus.equals(Params.Status.SUBMITTED_FOR_AGIV)) {
					changeAllowed = false;
				}
			}
			if (changeAllowed && session.getProfile().equals(Geonet.Profile.REVIEWER)) {
				if (status.equals(Params.Status.SUBMITTED)) {
					changeAllowed = false;
				}
			}
			if (changeAllowed && session.getProfile().equals(Geonet.Profile.REVIEWER) && context.getServlet().getNodeType().equalsIgnoreCase("agiv")) {
				if (status.equals(Params.Status.APPROVED) || status.equals(Params.Status.RETIRED) ||
					status.equals(Params.Status.APPROVED_BY_AGIV) || status.equals(Params.Status.REJECTED_BY_AGIV)) {
					changeAllowed = false;
				}
			} else if (session.getProfile().equals(Geonet.Profile.EDITOR)) {
				if (status.equals(Params.Status.APPROVED) || status.equals(Params.Status.RETIRED) ||
					status.equals(Params.Status.REJECTED) || status.equals(Params.Status.SUBMITTED_FOR_AGIV) ||
					status.equals(Params.Status.APPROVED_BY_AGIV) || status.equals(Params.Status.REJECTED_BY_AGIV)) {
					changeAllowed = false;
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
		boolean valid = dm.doValidate(dbms, schema, mid, doc,
				context.getLanguage(), workspace);

		boolean statusChangeAllowed = true;

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
		Set<String> groups = am.getUserGroups(dbms, session, null);
		for (Iterator i = groups.iterator(); i.hasNext();) {
			String groupId = (String) i.next();
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
	private void informContentUsers(Set<String> metadataIds,
			String changeDate, String changeMessage, String profile, String status) throws Exception {

		// --- get content reviewers (sorted on content reviewer userid)
		Element contentUsers = am.getContentUsers(dbms, metadataIds, profile);

		String subject = "Status metadata record(s) gewijzigd naar '" + dm.getStatusDes(dbms, status, context.getLanguage()) + "' door " + replyTo + " ("
					+ replyToDescr + ") op " + changeDate;

		processList(contentUsers, subject, status, changeDate, changeMessage);
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
			String changeDate, String changeMessage)
			throws Exception {

		Set<String> metadataIds = new HashSet<String>();
		String currentUserId = null;
		String userId = null;
		String currentEmail = null;
		List<Element> records = contentUsers.getChildren();
		Iterator<Element> recordsIterator = records.iterator();
		while(recordsIterator.hasNext()) {
			Element record = recordsIterator.next();
			String metadataId = record.getChildText("metadataid");
			userId = record.getChildText("userid");
			if (currentUserId==null) {
				currentUserId = userId;
				currentEmail = record.getChildText("email");
			} else if (!currentUserId.equals(userId)) {
				if (StringUtils.isNotBlank(currentEmail)) {
					sendEmail(currentEmail, subject, status, changeDate, changeMessage, metadataIds);
				}
				metadataIds.clear();
				currentUserId = userId;
				currentEmail = record.getChildText("email");
			}
			metadataIds.add(metadataId);
		}

		if (records.size() > 0) { // send out the last one
			sendEmail(currentEmail, subject, status, changeDate, changeMessage, metadataIds);
		}
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

	/**
	 * Build search link to metadata that has had a change of status.
	 * 
	 * @param metadataId
	 *            The id of the metadata
	 * @return string Search link to metadata
	 */
	private String buildMetadataLink(String metadataId) {
		// TODO: hack voor AGIV
		GeonetContext gc = (GeonetContext) this.context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		String protocol = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_PROTOCOL);
		String host = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_HOST);
		String port = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_PORT);
		return protocol + "://" + host + (port == "80" ? "" : ":" + port)
				+ this.context.getBaseUrl()
				+ "/apps/tabsearch/index_login.html?id=" + metadataId;
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

}