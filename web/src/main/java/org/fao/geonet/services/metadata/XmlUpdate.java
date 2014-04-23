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
import jeeves.exceptions.BadParameterEx;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.mef.Importer;
import org.fao.geonet.util.ISODate;
import org.jdom.Element;
import org.jdom.Namespace;
import org.tuckey.web.filters.urlrewrite.utils.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

//=============================================================================

/** Inserts a new metadata to the system (data is validated)
  */

public class XmlUpdate implements Service
{
	//--------------------------------------------------------------------------
	//---
	//--- Init
	//---
	//--------------------------------------------------------------------------

    private String stylePath;

	public void init(String appPath, ServiceConfig params) throws Exception
    {
        this.stylePath = appPath + Geonet.Path.UPDATE_STYLESHEETS;
    }

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		Element response = new Element(Jeeves.Elem.RESPONSE);
		Element modifiedRecords = new Element("modified");
		response.addContent(modifiedRecords);
		Element unchangedRecords = new Element("unchanged");
		Element unchangedByErrorRecords = new Element("unchangedbyerror");
		response.addContent(unchangedRecords);
		Element lockedbyRecords = new Element("lockedby");
		response.addContent(lockedbyRecords);
		String style      = Util.getParam(params, Params.STYLESHEET, "_none_");
		String scope      = Util.getParam(params, "scope", "0");
        if (!style.equals("_none_") && !StringUtils.isBlank(scope) && (scope.equals("0") || scope.equals("1"))) {

    		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);

    		DataManager dataMan = gc.getDataManager();

			DataManager dm = gc.getDataManager();
	        Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
	        String[] tableNames = {"Metadata","Workspace"};
            Element result = dbms.select("SELECT id, uuid, lockedby FROM " + tableNames[Integer.parseInt(scope)] + " where istemplate='n' and schemaid = 'iso19139' ORDER BY id ASC");
            for(int i = 0; i < result.getContentSize(); i++) {
                Element record = (Element) result.getContent(i);
                String id = record.getChildText("id");
                String uuid = record.getChildText("uuid");
                String lockedby = record.getChildText("lockedby");
                if (!StringUtils.isBlank(lockedby) && scope.equals("0")) {
                    lockedbyRecords.addContent(new Element(Params.UUID).setText(uuid));
                }
            	try {
                    Element md = (scope.equals("0") ? dm.getMetadataNoInfo(context, id) : dm.getMetadataFromWorkspaceNoInfo(context, id));
    	            if (md == null) {
    	                continue;
    	            }
    	            md.detach();
    	            int oldLength = Xml.getString(md).length();
    	            md = Xml.transform(md, stylePath +"/"+ style);
    	            int newLength = Xml.getString(md).length();
    	            if (newLength != oldLength) {
	            		System.out.println("Updating record with uuid" + uuid);
	            		if (scope.equals("0")) {
	    	                dm.getXmlSerializer().update(dbms, id, md, null, false, context);
	            		} else {
	    	                dm.getXmlSerializer().updateWorkspace(dbms, id, md, null, false, context, null, false);
	            		}
    	                dbms.commit();
	                    modifiedRecords.addContent(new Element(Params.UUID).setText(uuid + " (Aantal bytes gewijzigd van " + oldLength +  " naar " + newLength + ")"));
    	            } else {
	            		unchangedRecords.addContent(new Element(Params.UUID).setText(uuid));
    	            }
                    //dm.indexInThreadPoolIfPossible(dbms, metadataId, workspace);
            	} catch (Exception e) {
            		unchangedByErrorRecords.addContent(new Element(Params.UUID).setText(uuid));
            	}
            }
        }
		return response;
	};

}

//=============================================================================


