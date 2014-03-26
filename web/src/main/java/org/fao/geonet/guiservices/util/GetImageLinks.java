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

package org.fao.geonet.guiservices.util;

import java.io.File;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import jeeves.exceptions.BadParameterEx;
import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.services.Utils;
import org.jdom.Element;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import org.jdom.xpath.XPath;

//=============================================================================

/** This service returns some usefull information about GeoNetwork
  */

public class GetImageLinks implements Service
{
	public void init(String appPath, ServiceConfig params) throws Exception {}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		Vector<Namespace> namespaces = new Vector<Namespace>();
		namespaces.add(Namespace.getNamespace("gco","http://www.isotc211.org/2005/gco"));
		namespaces.add(Namespace.getNamespace("gmd","http://www.isotc211.org/2005/gmd"));
		Element root = new Element("imageLinks");

		List<Element> nodes = (List<Element>) Xml.selectNodes(params, "gmd:identificationInfo/gmd:MD_DataIdentification/gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString", namespaces);
		for (Element node: nodes) {
			try {
				URL url = new URL(node.getText());
				Map<String, String> parameters = new HashMap<String, String>();
				if (url.getQuery() != null) {
					for (String keyvalue: url.getQuery().split("&")) {
						if (keyvalue.contains("=")) {
							String[] parts = keyvalue.split("=");
							parameters.put(parts[0], parts[1]);
						}
					}
					String fname = parameters.get("fname");
					String uuid = parameters.get("uuid");
					String access = Params.Access.PUBLIC;
					
					
					Element request = new Element("request");
					request.addContent(new Element(Params.UUID).setText(uuid));
					request.addContent(new Element(Params.FNAME).setText(fname));
					
					String id = Utils.getIdentifierFromParameters(request, context);
		
					if (fname.contains("..")) {
						throw new BadParameterEx("Invalid character found in resource name.", fname);
					}
					
					if (access.equals(Params.Access.PRIVATE))
					{
						Lib.resource.checkPrivilege(context, id, AccessManager.OPER_DOWNLOAD);
					}
	
					// Build the response
					File dir = new File(Lib.resource.getDir(context, access, id));
					File file= new File(dir, fname);
					
					Element fileMap = new Element("link");
					fileMap.setAttribute("url", url.toString());
					fileMap.setText(file.getAbsolutePath());
					root.addContent(fileMap);
				}
			} catch (Exception e) {
				// File could not be found, don't put it in the list of mapped urls
			}
		}

		return root;
	}
}

//=============================================================================

