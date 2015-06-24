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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;

import jeeves.utils.Log;

import org.fao.geonet.constants.Geonet;

//=============================================================================

public class LDAPUtil
{
	//--------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//--------------------------------------------------------------------------

	public static DirContext openContext(String url, String username, String password) throws NamingException
	{
		try
		{
			Log.info(Geonet.LDAP, "LDAP search with full userDN " + username + " on " + url);
			Log.info(Geonet.LDAP, "Opening LDAP context on :"+ url);

			Hashtable<String,String> env = new Hashtable<String,String>();

			env.put(Context.SECURITY_PRINCIPAL,   username);
			env.put(Context.SECURITY_CREDENTIALS, password);

			DirContext dc = new InitialDirContext(env);

			return (DirContext) dc.lookup(url);
		}
		catch(NamingException e)
		{
			Log.warning(Geonet.LDAP, "Cannot open context on : "+ url);
			Log.warning(Geonet.LDAP, " (C) Reason : "+ e.getMessage());
			throw e;
		}
	}

	public static String findUserDN(String url, String uidFilter, String userDN) throws NamingException
	{
		DirContext connection = null;
		SearchControls ctls = null;
		try
		{
			Hashtable<String,String> env = new Hashtable<String,String>();
		    String securityPrincipal = InitialContext.doLookup("java:comp/env/zoekdienstLDAPReaderUsername");
		    String securityCredential = InitialContext.doLookup("java:comp/env/zoekdienstLDAPReaderPassword");
		    if (securityCredential!=null && securityPrincipal!=null) {
				Log.info(Geonet.LDAP, "LDAP with system user used");
			    env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
			    env.put(Context.PROVIDER_URL, url);
			    env.put(Context.SECURITY_PRINCIPAL, securityPrincipal); 
			    env.put(Context.SECURITY_CREDENTIALS, securityCredential); 
			    connection = new InitialDirContext(env);
				ctls = new SearchControls();
				ctls.setSearchScope(SearchControls.SUBTREE_SCOPE);
		    } else {
				Log.info(Geonet.LDAP, "LDAP without system user used");
				DirContext dc = new InitialDirContext(env);
				connection = (DirContext) dc.lookup(url);
		    }		    	
			NamingEnumeration<SearchResult> results = connection.search(userDN, uidFilter, ctls);
			String usersRealDN = "";
			int counter=0;
			while (results.hasMoreElements()) {
				usersRealDN = (results.nextElement().getNameInNamespace());
				Log.info(Geonet.LDAP, "User found with DN:" + usersRealDN);
				counter++;
			}
			switch (counter) {
				case 0:
					Log.info(Geonet.LDAP, "No user found");
					break;
				case 1:
					Log.info(Geonet.LDAP, "One user found");
					return usersRealDN;
				default:
					Log.info(Geonet.LDAP, "More users found");
			}
			return null;
		}
		catch(NamingException e)
		{
			e.printStackTrace();
			throw e;
		}
		finally {
			if (connection!=null) {
				connection.close();
			}
		}
	}


	//--------------------------------------------------------------------------

	public static Map<String, ? extends List<Object>> getNodeInfo(DirContext dc,
																			  String dname) throws NamingException
	{
		try
		{
			Log.warning(Geonet.LDAP, "Retrieving information for :"+ dname);

			//--- retrieve all attributes

			Attributes attrs = dc.getAttributes(dname);

			NamingEnumeration<? extends Attribute> en = attrs.getAll();

			Map<String, ArrayList<Object>> info = new HashMap<String, ArrayList<Object>>();

			//--- scan all attributes

			while (en.hasMore())
			{
				Attribute attr = en.next();

				String id = attr.getID();

				//--- retrieve attrib's list of values (create it if the case)

				ArrayList<Object> values = info.get(id);

				if (values == null)
				{
					values = new ArrayList<Object>();
					info.put(id, values);
				}

				//--- loop on all attribute's values

				NamingEnumeration valueEnum = attr.getAll();

				while (valueEnum.hasMore())
					values.add(valueEnum.next());
			}

			return info;
		}
		catch(NamingException e)
		{
			Log.warning(Geonet.LDAP, "Cannot retrieve node info for : "+ dname);
			Log.warning(Geonet.LDAP, " (C) Reason : "+ e.getMessage());
			throw e;
		}
	}
}

//=============================================================================


