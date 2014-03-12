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

package org.fao.geonet.services.login;

import java.io.File;

import javax.servlet.http.HttpSession;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.BinaryFile;

import org.jdom.Element;

//=============================================================================

/** Logout the user
  */

public class AgivLogout implements Service
{
	public void init(String appPath, ServiceConfig params) throws Exception {}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
		/*
		GeonetContext  gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        String protocol = gc.getSettingManager().getValue(Geonet.Settings.SERVER_PROTOCOL);
		String host    = gc.getSettingManager().getValue(Geonet.Settings.SERVER_HOST);
		String port    = gc.getSettingManager().getValue(Geonet.Settings.SERVER_PORT);
		String url = protocol + "://" + host + (port == "80" ? "" : ":" + port) + this.context.getBaseUrl() + "/apps/tabsearch/images/???.png;
*/
/*		
		URL url = new URL("https://auth.beta.agiv.be/sts/?wa=wsignout1.0&wreply=");
		HttpURLConnection connection = null;
		connection = (HttpsURLConnection)url.openConnection();
		connection.setRequestMethod("GET");
		int returnCode = connection.getResponseCode();
		InputStream connectionIn = null;
		if (returnCode==200) {
			connectionIn = connection.getInputStream();
		}
		else {
			connectionIn = connection.getErrorStream();
		}
		BufferedReader buffer = new BufferedReader(new InputStreamReader(connectionIn));
		String inputLine;
		while ((inputLine = buffer.readLine()) != null)
		{
			System.out.println(inputLine);
		}
		buffer.close();
		if (returnCode==200) {
			UserSession userSession = context.getUserSession();
			HttpSession httpSession = (HttpSession) userSession.getProperty("realSession");
			if (httpSession!=null) {
				httpSession.invalidate();
			}
			context.getUserSession().clear();
		} else {
			UserSession userSession = context.getUserSession();
			HttpSession httpSession = (HttpSession) userSession.getProperty("realSession");
			if (httpSession!=null) {
				httpSession.invalidate();
			}
			context.getUserSession().clear();
		}
*/
		UserSession userSession = context.getUserSession();
		HttpSession httpSession = (HttpSession) userSession.getProperty("realSession");
		if (httpSession!=null) {
			httpSession.invalidate();
		}
		userSession.clear();
		return BinaryFile.encode(200, context.getAppPath() + "/images/logout.png", "logout.png", false);
	}
}

//=============================================================================

