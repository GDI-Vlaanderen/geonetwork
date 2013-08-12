//=============================================================================
//===	Copyright (C) 2001-2005 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This library is free software; you can redistribute it and/or
//===	modify it under the terms of the GNU Lesser General Public
//===	License as published by the Free Software Foundation; either
//===	version 2.1 of the License, or (at your option) any later version.
//===
//===	This library is distributed in the hope that it will be useful,
//===	but WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//===	Lesser General Public License for more details.
//===
//===	You should have received a copy of the GNU Lesser General Public
//===	License along with this library; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: GeoNetwork@fao.org
//==============================================================================

package jeeves.server.sources.http;

import java.io.File;
import java.io.IOException;
import java.security.Principal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import jeeves.exceptions.FileUploadTooBigEx;
import jeeves.server.JeevesEngine;
import jeeves.server.UserSession;
import jeeves.server.sources.ServiceRequest;
import jeeves.server.sources.ServiceRequestFactory;
import jeeves.utils.Log;
import jeeves.utils.Util;

import org.apache.cxf.fediz.core.Claim;
import org.apache.cxf.fediz.core.FederationPrincipal;
import org.jdom.Element;

//=============================================================================

/** This is the main class. It handles http connections and inits the system
  */

@SuppressWarnings("serial")
public class JeevesServlet extends HttpServlet
{
	private JeevesEngine jeeves = new JeevesEngine();
	private boolean initialized = false;

	//---------------------------------------------------------------------------
	//---
	//--- Init
	//---
	//---------------------------------------------------------------------------

	public void init() throws ServletException
	{
		String appPath = getServletContext().getRealPath("/");

		String baseUrl    = "";
		
    try {
			// 2.5 servlet spec or later (eg. tomcat 6 and later)
      baseUrl = getServletContext().getContextPath();
    } catch (java.lang.NoSuchMethodError ex) {
			// 2.4 or earlier servlet spec (eg. tomcat 5.5)
			try { 
				String resource = getServletContext().getResource("/").getPath(); 
				baseUrl = resource.substring(resource.indexOf('/', 1), resource.length() - 1); 
			} catch (java.net.MalformedURLException e) { // unlikely
				baseUrl = getServletContext().getServletContextName(); 
			}
    }
		
		if (!appPath.endsWith(File.separator))
			appPath += File.separator;

		String configPath = appPath + "WEB-INF" +
                File.separator;

		jeeves.init(appPath, configPath, baseUrl, this);
		initialized = true;
	}

	//---------------------------------------------------------------------------
	//---
	//--- Destroy
	//---
	//---------------------------------------------------------------------------

	public void destroy()
	{
		jeeves.destroy();
		super .destroy();
	}

	//---------------------------------------------------------------------------
	//---
	//--- HTTP Request / Response
	//---
	//---------------------------------------------------------------------------

	public void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException
	{
		execute(req, res);
	}

	//---------------------------------------------------------------------------
	/** This is the core of the servlet. It receives http requests and invokes
	  * the proper service
	  */

	public void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException
	{
		execute(req, res);
	}

	//---------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//---------------------------------------------------------------------------

	private void execute(HttpServletRequest req, HttpServletResponse res) throws IOException
	{
		String ip = req.getRemoteAddr();
		// if we do have the optional x-forwarded-for request header then
		// use whatever is in it to record ip address of client
		String forwardedFor = req.getHeader("x-forwarded-for");
		if (forwardedFor != null) ip = forwardedFor;

		Log.info (Log.REQUEST, "==========================================================");
		Log.info (Log.REQUEST, "HTML Request (from "+ ip +") : "+ req.getRequestURI());
        if(Log.isDebugEnabled(Log.REQUEST)) {
            Log.debug(Log.REQUEST, "Method       : "+ req.getMethod());
            Log.debug(Log.REQUEST, "Content type : "+ req.getContentType());
    //		Log.debug(Log.REQUEST, "Context path : "+ req.getContextPath());
    //		Log.debug(Log.REQUEST, "Char encoding: "+ req.getCharacterEncoding());
            Log.debug(Log.REQUEST, "Accept       : "+ req.getHeader("Accept"));
    //		Log.debug(Log.REQUEST, "Server name  : "+ req.getServerName());
    //		Log.debug(Log.REQUEST, "Server port  : "+ req.getServerPort());
        }
//		for (Enumeration e = req.getHeaderNames(); e.hasMoreElements();) {
//			String theHeader = (String)e.nextElement();
//        if(Log.isDebugEnabled(Log.REQUEST)) {
//			Log.debug(Log.REQUEST, "Got header: "+theHeader);	
//			Log.debug(Log.REQUEST, "With value: "+req.getHeader(theHeader));
//        }
//		}
		HttpSession httpSession = req.getSession();
        if(Log.isDebugEnabled(Log.REQUEST)) Log.debug(Log.REQUEST, "Session id is "+httpSession.getId());
		UserSession session     = (UserSession) httpSession.getAttribute("session");

		//------------------------------------------------------------------------
		//--- create a new session if doesn't exist

		if (session == null)
		{
			//--- create session

			session = new UserSession();
			httpSession.setAttribute("session", session);
            if(Log.isDebugEnabled(Log.REQUEST)) Log.debug(Log.REQUEST, "Session created for client : " + ip);
		}

		session.setProperty("realSession", httpSession);
    	//------------------------------------------------------------------------
		//--- build service request

		ServiceRequest srvReq = null;

		//--- create request

		try {
			srvReq = ServiceRequestFactory.create(req, res, jeeves.getUploadDir(), jeeves.getMaxUploadSize());
		} catch (FileUploadTooBigEx e) {
			StringBuffer sb = new StringBuffer();
			sb.append("File upload too big - exceeds "+jeeves.getMaxUploadSize()+" Mb\n");
			sb.append("Error : " +e.getClass().getName() +"\n");
			res.sendError(400, sb.toString());

			// now stick the stack trace on the end and log the whole lot
			sb.append("Stack :\n");
			sb.append(Util.getStackTrace(e));
			Log.error(Log.REQUEST,sb.toString());
			return;
		} catch (Exception e) {
			StringBuffer sb = new StringBuffer();

			sb.append("Cannot build ServiceRequest\n");
			sb.append("Cause : " +e.getMessage() +"\n");
			sb.append("Error : " +e.getClass().getName() +"\n");
			res.sendError(400, sb.toString());

			// now stick the stack trace on the end and log the whole lot
			sb.append("Stack :\n");
			sb.append(Util.getStackTrace(e));
			Log.error(Log.REQUEST,sb.toString());
			return;
		}
		
		if ("user.agiv.login".equals(srvReq.getService())) {
			if (srvReq.getParams()!=null && srvReq.getParams().getChild("wa")!=null && srvReq.getParams().getChild("wa").getTextTrim().equals("wsignoutcleanup1.0")) {
				srvReq.setService("user.agiv.logout");
			} else {
		        Principal p = req.getUserPrincipal();
		        if (p != null && p instanceof FederationPrincipal/* && SecurityTokenThreadLocal.getToken()==null*/) {
		            FederationPrincipal fp = (FederationPrincipal)p;
	            	/*
	                emailaddress: wim.vandebriel@gim.be
	                daliid: 141fcd6b-d13a-47a9-8d29-7e125a635f06
	                organisationpath: 1/2
	                name: wim.vandebriel
	                givenname: Wim
	                surname: Vanebriel
	                language: nl-BE
	                contactid: 1757
	                organisationpublicid: int:Citizens
	                organisationid: 2
	    */
		            for (Claim c: fp.getClaims()) {
		                System.out.println(c.getClaimType().toString() + ":" + (c.getValue()!=null ? c.getValue().toString() : ""));            	
		            }
	                Map<String,String> roleProfileMapping = new HashMap<String,String>();
	                String profile = null;
	/*
	                These profiles are configured in strings.xml for each language:
	                
	            	<profileChoice value="Administrator">Beheerder</profileChoice>
	            	<profileChoice value="Editor">Editor</profileChoice>
	            	<profileChoice value="RegisteredUser">Geregistreerde gebruiker</profileChoice>
	            	<profileChoice value="Reviewer">Content reviewer</profileChoice>
	            	<profileChoice value="UserAdmin">Gebruikers beheerder</profileChoice>
	            	<profileChoice value="Monitor">System Monitor</profileChoice>
	*/
	                roleProfileMapping.put("Authenticated","RegisteredUser");
	                roleProfileMapping.put("GIM Metadata Admin", "Administrator");
	                roleProfileMapping.put("GIM Metadata Editor", "Editor");
	                roleProfileMapping.put("GIM Metadata Hoofdeditor", "Reviewer");
	                roleProfileMapping.put("GDI Metadata Admin", "Administrator");
	                roleProfileMapping.put("GDI Metadata Editor", "Editor");
	                roleProfileMapping.put("GDI Metadata Hoofdeditor", "Reviewer");
	                roleProfileMapping.put("AGIV Metadata Admin", "Administrator");
	                roleProfileMapping.put("AGIV Metadata Editor", "Editor");
	                roleProfileMapping.put("AGIV Metadata Hoofdeditor", "Reviewer");
	                List<String> roleListToCheck = Arrays.asList("Authenticated","GIM Metadata Editor","GIM Metadata Admin", "GIM Metadata Hoofdeditor","GDI Metadata Editor","GDI Metadata Admin", "GDI Metadata Hoofdeditor", "AGIV Metadata Editor","AGIV Metadata Admin","AGIV Metadata Hoofdeditor");
	                for (String item: roleListToCheck) {
	                	if (req.isUserInRole(item)) {
	                		profile = roleProfileMapping.get(item);
	                		break;
	                	}
	                }
	                String contactid = Util.getClaimValue(fp,"contactid"); 
	                session.authenticate(contactid,contactid + "_" + Util.getClaimValue(fp,"name"), Util.getClaimValue(fp,"givenname"), Util.getClaimValue(fp,"surname"), profile!=null ? profile : "RegisteredUser", Util.getClaimValue(fp,"emailaddress"));
	                List<Map<String,String>> groups = new ArrayList<Map<String,String>>();
	                Map<String,String> group = new HashMap<String,String>();
	                group.put("name", Util.getClaimValue(fp,"organisationid") + "_" + Util.getClaimValue(fp,"organisationpublicid"));
	                group.put("description", Util.getClaimValue(fp,"organisationdisplayname"));
	                groups.add(group);                		
	                session.setProperty("groups", groups);
		        } else {
		            System.out.println("Principal is not instance of FederationPrincipal");
		        }
			}
		}

		//--- execute request

		jeeves.dispatch(srvReq, session);
	}

	public boolean isInitialized() { return initialized; }
}

//=============================================================================


