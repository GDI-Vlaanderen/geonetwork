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
import java.util.List;
import java.util.Map;

import jeeves.constants.Jeeves;
import jeeves.exceptions.NotAllowedToDeleteEx;
import jeeves.exceptions.OperationNotAllowedEx;
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

public class Delete implements Service
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
        SettingManager settingManager = gc.getSettingManager();
		DataManager dataMan = gc.getDataManager();
		AccessManager accessMan = gc.getAccessManager();
		UserSession session = context.getUserSession();
        String userId = session.getUserId();

		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

		String id = Utils.getIdentifierFromParameters(params, context);
		
		//-----------------------------------------------------------------------
		//--- check access

		MdInfo info = dataMan.getMetadataInfo(dbms, id);

		if (info == null)
			throw new IllegalArgumentException("Metadata not found --> " + id);

        boolean canEdit = accessMan.canEdit(context, id);
        if(!canEdit) {
            throw new OperationNotAllowedEx("You can not delete this because you are not authorized to edit this metadata.");
        } else if(info.isLocked && !info.lockedBy.equals(userId)) {
            throw new OperationNotAllowedEx("You can not delete this because this metadata is locked and you do not own the lock.");
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
                    throw new NotAllowedToDeleteEx();
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
                        throw new NotAllowedToDeleteEx();
    	            } else {
    	    			String currentStatus = dataMan.getCurrentStatus(dbms, id);
    	    			Map<String,String> properties = new HashMap<String,String>();
    	    			properties.put("title", dataMan.extractTitle(context, info.schemaId, id));
    	    			properties.put("currentStatus", currentStatus);
    	    			Map<String, Map<String,String>> changedMmetadataIdsToInform = new HashMap<String,Map<String,String>>();
    	    			changedMmetadataIdsToInform.put(info.uuid,properties);
    	    			List<String> emailMetadataIdList = new ArrayList<String>();
    	    			informContentUsers(context, dbms, accessMan.getContentAdmins(dbms, changedMmetadataIdsToInform.keySet()), changedMmetadataIdsToInform, new ISODate().toString(),
    	    					"", Params.Status.REMOVED, emailMetadataIdList);
    	    			informContentUsers(context, dbms, accessMan.getContentUsers(dbms, changedMmetadataIdsToInform.keySet(), Geonet.Profile.ADMINISTRATOR), changedMmetadataIdsToInform, new ISODate().toString(),
    	    					"", Params.Status.REMOVED, emailMetadataIdList);
    	            }
    			}
    		}
        }
		//-----------------------------------------------------------------------
		//--- backup metadata in 'removed' folder

		if (info.template != MdInfo.Template.SUBTEMPLATE)
			backupFile(context, id, info.uuid, MEFLib.doExport(context, info.uuid, "full", false, true, false));

		//-----------------------------------------------------------------------
		//--- remove the metadata directory including the public and private directories.
		File pb = new File(Lib.resource.getMetadataDir(context, id));
		FileCopyMgr.removeDirectoryOrFile(pb);
		
		//-----------------------------------------------------------------------
		//--- delete metadata and return status

		dataMan.deleteMetadata(context, dbms, id);
        dataMan.deleteFromWorkspace(dbms, id);

		Element elResp = new Element(Jeeves.Elem.RESPONSE);
		elResp.addContent(new Element(Geonet.Elem.ID).setText(id));

		return elResp;
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

	private void informContentUsers(ServiceContext context, Dbms dbms, Element contentUsers, Map<String,Map<String,String>> metadataMap,
			String changeDate, String changeMessage, String status, List<String> emailMetadataIdList) throws Exception {

        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        SettingManager settingManager = gc.getSettingManager();
		DataManager dataMan = gc.getDataManager();

		UserSession session = context.getUserSession();
		String replyTo = session.getEmailAddr();
		String replyToDescr = null;
		if (replyTo != null) {
			replyToDescr = session.getName() + " " + session.getSurname();
		} else {
			replyTo = settingManager.getValue("system/feedback/email");
			replyToDescr = context.getServlet().getFromDescription();
		}

		// --- get content reviewers (sorted on content reviewer userid)
		String subject = "Status metadata record(s) gewijzigd naar '" + dataMan.getStatusDes(dbms, status, context.getLanguage()) + "' door " + replyTo + " ("
					+ replyToDescr + ") op " + changeDate;

		Utils.processList(context, dbms, replyTo, replyToDescr, contentUsers, subject, status, changeDate, changeMessage, metadataMap, emailMetadataIdList);
	}

}

//=============================================================================

