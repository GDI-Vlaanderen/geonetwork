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

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.exceptions.ConcurrentUpdateEx;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MdInfo;
import org.jdom.Element;

/**
 *  For editing : update leaves information. Access is restricted.
 */
public class Update implements Service {
	private ServiceConfig config;

	//--------------------------------------------------------------------------
	//---
	//--- Init
	//---
	//--------------------------------------------------------------------------

	public void init(String appPath, ServiceConfig params) throws Exception
	{
		config = params;
	}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception {

        AjaxEditUtils ajaxEditUtils = new AjaxEditUtils(context);
		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
        ajaxEditUtils.preprocessUpdate(params, dbms);

		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager   dataMan = gc.getDataManager();
		UserSession		session = context.getUserSession();


		String id         = Util.getParam(params, Params.ID);
		String isTemplate = Util.getParam(params, Params.TEMPLATE, "n");
		MdInfo mdInfo = dataMan.getMetadataInfo(dbms, id);
		if (mdInfo!=null) {
			String publishedRecordIsTemplate = mdInfo.template.equals(MdInfo.Template.TEMPLATE) ? "y" : "n"; 
			if (!publishedRecordIsTemplate.equals(isTemplate)) {
				dataMan.setTemplateExt(dbms, id, isTemplate, null);			
				dbms.commit();
			}
            if (isTemplate.equals("y")) {
				unsetAllOperations(dataMan, dbms, context, id);
				dbms.commit();
            }
            dataMan.indexMetadata(dbms, id, false, false, true);
        }
		String showValidationErrors = Util.getParam(params, Params.SHOWVALIDATIONERRORS, "false");
//		String title      = params.getChildText(Params.TITLE);
		String data       = params.getChildText(Params.DATA);
        String minor      = Util.getParam(params, Params.MINOREDIT, "false");

		boolean finished = config.getValue(Params.FINISHED, "no").equals("yes");
		boolean forget   = config.getValue(Params.FORGET, "no").equals("yes");


		if (!forget) {
//			dataMan.setTemplateExtWorkspace(dbms, id, isTemplate, title);

			//--- use StatusActionsFactory and StatusActions class to possibly
			//--- change status as a result of this edit (use onEdit method)
			StatusActionsFactory saf = new StatusActionsFactory(gc.getStatusActionsClass());
			StatusActions sa = saf.createStatusActions(context, dbms);
			saf.onEdit(sa, id, minor.equals("true"));

            boolean validate = showValidationErrors.equals("true");
			if (data != null) {
				Element md = Xml.loadString(data, false);

                String changeDate = null;
                boolean updateDateStamp = !minor.equals("true");
                boolean ufo = true;
                boolean index = true;
				if (!dataMan.updateMetadataWorkspace(context, dbms, id, md, validate, ufo, index, context.getLanguage(), changeDate, updateDateStamp, isTemplate, true)) {
					throw new ConcurrentUpdateEx(id);
				}
			}
            else {
                ajaxEditUtils.updateContentWorkspace(params, validate, true, dbms, isTemplate, true);
			}
		}

		//-----------------------------------------------------------------------
		//--- update element and return status

		Element elResp = new Element(Jeeves.Elem.RESPONSE);
		elResp.addContent(new Element(Geonet.Elem.ID).setText(id));
		elResp.addContent(new Element(Geonet.Elem.SHOWVALIDATIONERRORS).setText(showValidationErrors));
        boolean justCreated = Util.getParam(params, Params.JUST_CREATED, null) != null ;
        if(justCreated) {
            elResp.addContent(new Element(Geonet.Elem.JUSTCREATED).setText("true"));
        }
        elResp.addContent(new Element(Params.MINOREDIT).setText(minor));
        
        //--- if finished then remove the XML from the session
		if (finished) {
			ajaxEditUtils.removeMetadataEmbedded(session, id);
            // Ext GUI: JustCreated is a md state. If Update is called with Finish and Forget, delete md in justcreated state
            if(forget) {
                String statusId = dataMan.getCurrentStatus(dbms, id);
                if(Params.Status.JUSTCREATED.equals(statusId)) {
                    dataMan.deleteFromWorkspace(dbms, id);
                    dataMan.deleteMetadata(context, dbms, id);
                } else if(Params.Status.APPROVED.equals(statusId) || Params.Status.RETIRED.equals(statusId)) {
                    AccessManager accessManager = gc.getAccessManager();
                    if(accessManager.unlockAllowed(session.getUserId(), id, dbms)) {
                        dataMan.unLockMetadata(dbms, id);
                        dataMan.deleteFromWorkspace(dbms, id);
                    }
                }
            }
		}

		return elResp;
	}

	private void unsetAllOperations(DataManager dm, Dbms dbms, ServiceContext context, String mdId) throws Exception {
		String allGroup = "1";
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_VIEW);
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_DOWNLOAD);
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_NOTIFY);
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_DYNAMIC);
		dm.unsetOperation(context, dbms, mdId+"", allGroup, AccessManager.OPER_FEATURED);
	}
}