//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.BinaryFile;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MdInfo;
import org.fao.geonet.kernel.SelectionManager;
import org.fao.geonet.kernel.mef.MEFLib;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.services.Utils;
import org.fao.geonet.util.FileCopyMgr;
import org.fao.geonet.util.ISODate;
import org.jdom.Element;

//=============================================================================

/** Removes a metadata from the system
  */

public class BatchDelete implements Service
{
	public void init(String appPath, ServiceConfig params) throws Exception {}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager   dataMan   = gc.getDataManager();
		AccessManager accessMan = gc.getAccessManager();
		UserSession   session   = context.getUserSession();

		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

		Set<String> metadata = new HashSet<String>();
		Set<String> notFound = new HashSet<String>();
		Set<String> notDeletedByRights = new HashSet<String>();

        if(context.isDebug())
		context.debug("Get selected metadata");
		SelectionManager sm = SelectionManager.getManager(session);
		Map<String, Map<String,String>> changedMmetadataIdsToInform = new HashMap<String,Map<String,String>>();

		synchronized(sm.getSelection("metadata")) {
			for (Iterator<String> iter = sm.getSelection("metadata").iterator(); iter.hasNext();) {
				String uuid = (String) iter.next();
	            if(context.isDebug())
	            	context.debug("Deleting metadata with uuid:"+ uuid);
	
				String id   = dataMan.getMetadataId(dbms, uuid);
				//--- Metadata may have been deleted since selection
				if (id != null) {
					//-----------------------------------------------------------------------
					//--- check access
		
					MdInfo info = dataMan.getMetadataInfo(dbms, id);
		
					if (info == null) {
						notFound.add(id);
	    				continue;
					} else if (!accessMan.isOwner(context, id)) {
						notDeletedByRights.add(id);
	    				continue;
			        } else if(info.isLocked && !info.lockedBy.equals(session.getUserId())) {
			        	notDeletedByRights.add(id);
	    				continue;
			        } else if (context.getServlet().getNodeType().equalsIgnoreCase("agiv") && (Geonet.Profile.EDITOR.equals(session.getProfile()) || Geonet.Profile.REVIEWER.equals(session.getProfile()))){
			            boolean isAlreadyApproved = false; 
			    		List<Element> kids = dataMan.getStatus(dbms, id).getChildren();
			    		for (Element kid : kids) {
			    			if (kid.getChildText("statusid").equals(Params.Status.APPROVED)) {
			    				isAlreadyApproved = true;
			    				break;
			    			}
			    		}
			    		if (isAlreadyApproved) {
			    			if (Geonet.Profile.EDITOR.equals(session.getProfile())) {
			    				notDeletedByRights.add(id);
			    				continue;
			    			} else {  // is reviewer
			    				boolean isAllowed = false;
			    	            List<String> userGroups = gc.getAccessManager().getUserGroups(dbms, session, context.getIpAddress());
			    	            String[] canDeleteGroupIds = context.getServlet().getCanDeleteGroupIds().split(",");
			    	            for (String canDeleteGroupId : canDeleteGroupIds) {
			    	            	if (!StringUtils.isEmpty(canDeleteGroupId) && userGroups.contains(canDeleteGroupId)) {
			    	            		isAllowed = true;
			    	            		break;
			    	            	}
			    	            }
			    	            if (!isAllowed) {
			    	            	notDeletedByRights.add(id);
				    				continue;
			    	            } else {
			    	    			String currentStatus = dataMan.getCurrentStatus(dbms, id);
			    	    			Map<String,String> properties = new HashMap<String,String>();
			    	    			properties.put("title", dataMan.extractTitle(context, info.schemaId, id));
			    	    			properties.put("currentStatus", currentStatus);
			    	    			changedMmetadataIdsToInform.put(info.uuid,properties);
			    	            }
			    			}
			    		}
					}
					//--- backup metadata in 'removed' folder
					if (info.template != MdInfo.Template.SUBTEMPLATE) {
						backupFile(context, id, info.uuid, MEFLib.doExport(context, info.uuid, "full", false, true, false));
					}
			
					//--- remove the metadata directory
					File pb = new File(Lib.resource.getMetadataDir(context, id));
					FileCopyMgr.removeDirectoryOrFile(pb);
	
					//--- delete metadata and return status
					dataMan.deleteMetadata(context, dbms, id);
	                if(context.isDebug())
	                	context.debug("  Metadata with id " + id + " deleted.");
					metadata.add(id);
				} else {
		            if(context.isDebug())
						context.debug("  Metadata not found in db:"+ uuid);
					notFound.add(id);
				}
			}
		}
		// Clear the selection after delete
		SelectionManager.updateSelection("metadata", session, params.addContent(new Element("selected").setText("remove-all")), context);
		
		List<String> emailMetadataIdList = new ArrayList<String>();
		if (changedMmetadataIdsToInform.size()>0) {
			informContentUsers(context, dbms, changedMmetadataIdsToInform, new ISODate().toString(),
					"", session.getProfile(), Params.Status.REMOVED, emailMetadataIdList);
			informContentUsers(context, dbms, changedMmetadataIdsToInform, new ISODate().toString(),
					"", session.getProfile(), Params.Status.REMOVED, emailMetadataIdList);
		}
		// -- for the moment just return the sizes - we could return the ids
		// -- at a later stage for some sort of result display
		return new Element(Jeeves.Elem.RESPONSE)
			.addContent(new Element("done")    .setText(metadata.size()+""))
			.addContent(new Element("notFound").setText(notFound.size()+""))
			.addContent(new Element("notDeletedByRights").setText(notDeletedByRights.size()+""));
	}

	//--------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//--------------------------------------------------------------------------

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

	private void informContentUsers(ServiceContext context, Dbms dbms, Map<String,Map<String,String>> metadataMap,
			String changeDate, String changeMessage, String profile, String status, List<String> emailMetadataIdList) throws Exception {

        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        SettingManager settingManager = gc.getSettingManager();
		DataManager dm = gc.getDataManager();
		AccessManager am = gc.getAccessManager();

		// --- get content reviewers (sorted on content reviewer userid)
		Element contentUsers;
		if (profile.equals(Geonet.Profile.ADMINISTRATOR)) {
			contentUsers = am.getContentAdmins(dbms, metadataMap.keySet());
		} else {
			contentUsers = am.getContentUsers(dbms, metadataMap.keySet(), profile);
		}

		UserSession session = context.getUserSession();
		String replyTo = session.getEmailAddr();
		String replyToDescr = null;
		if (replyTo != null) {
			replyToDescr = session.getName() + " " + session.getSurname();
		} else {
			replyTo = settingManager.getValue("system/feedback/email");
			replyToDescr = context.getServlet().getFromDescription();
		}

		String subject = "Status metadata record(s) gewijzigd naar '" + dm.getStatusDes(dbms, status, context.getLanguage()) + "' door " + replyTo + " ("
					+ replyToDescr + ") op " + changeDate;

		Utils.processList(context, dbms, replyTo, replyToDescr, contentUsers, subject, status, changeDate, changeMessage, metadataMap, emailMetadataIdList);
	}
}

//=============================================================================

