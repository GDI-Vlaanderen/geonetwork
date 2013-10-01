//=============================================================================
//===	Copyright (C) 2001-2005 Food and Agriculture Organization of the
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
//===	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: GeoNetwork@fao.org
//==============================================================================

package org.fao.geonet.services.crs;

import java.io.File;
import java.util.Iterator;
import java.util.List;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Xml;

import org.fao.geonet.constants.Geonet;
import org.jdom.Element;
import org.jdom.xpath.XPath;

/**
 * Get all Coordinate Reference System types.
 * 
 * @author francois
 */
public class GetCRSTypes implements Service {
    /** the Element doc containing I18N strings, got from the current app language */
    private Element i18nStrings;
    
    /** the full path to the application directory */
    private  String appDir;
    
    /** the current language */
    private String lang;

    public void init(String appPath, ServiceConfig params) throws Exception {
        this.appDir = appPath;
        this.lang = "eng";
        this.i18nStrings = loadStrings(appPath + "loc" + File.separator + this.lang + File.separator  + "xml" + File.separator + "strings.xml");
	}

	public Element exec(Element params, ServiceContext context)
			throws Exception {
        if (! this.lang.equalsIgnoreCase(context.getLanguage()) ) {
            // user changed the language, must reload strings file to get translated values
            this.lang = context.getLanguage();
            this.i18nStrings = loadStrings(appDir + "loc" +
                    File.separator +
                    this.lang +
                    File.separator  + 
                    "xml" +
                    File.separator +
                    "strings.xml");
        }

		Element crsTypes = new Element("crsTypes");
        List crsTypeList = Xml.selectNodes(this.i18nStrings, "crsType");
        for (Object crsType : crsTypeList) {
			Element type = new Element("type");
			type.addContent(new Element("id").setText(((Element)crsType).getAttributeValue("value")));
			type.addContent(new Element("label").setText(((Element)crsType).getText()));
			crsTypes.addContent(type);
        }
/*
        Iterator<String> iterator = Constant.CRSType.keySet().iterator();

		while (iterator.hasNext()) {
			Element type = new Element("type");
			type.addContent(new Element("id").setText(iterator.next()));
			crsTypes.addContent(type);
		}
*/
		return crsTypes;
	}

	private Element loadStrings(String filePath) {
        if(Log.isDebugEnabled(Geonet.SEARCH_LOGGER)) Log.debug(Geonet.SEARCH_LOGGER,"loading file: " + filePath);
        File f = new File(filePath);
        Element xmlDoc = null;
        Element ret = null;

        if ( f.exists() ) {
            try {
                xmlDoc = Xml.loadFile(f);
            } catch (Exception ex) {
                if(Log.isDebugEnabled(Geonet.SEARCH_LOGGER))
        		Log.debug(Geonet.SEARCH_LOGGER,"Cannot load file: " + filePath + ": " + ex.getMessage());
                return ret;
            }
            ret = xmlDoc;
        }
        return ret;
    }
}