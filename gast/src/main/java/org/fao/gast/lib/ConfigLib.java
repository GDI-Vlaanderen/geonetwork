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

package org.fao.gast.lib;

import java.io.FileNotFoundException;
import java.io.IOException;
import jeeves.constants.ConfigFile;
import org.fao.gast.boot.Config;
import org.fao.gast.boot.Util;
import org.jdom.Attribute;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Parent;

//=============================================================================

public class ConfigLib
{
	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	public ConfigLib() throws JDOMException, IOException
	{
		config      = Lib.xml.load(Config.getConfig().getConfigXml());
		dbmsElem    = retrieveDbms(config);
	}

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------

	public boolean getDbmsJNDI()
	{
		return dbmsElem.getChildText("provider").contains("JNDI");
	}

	//---------------------------------------------------------------------------

	public String getDbmsSpatialIndexInDatabase()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("provideDataStore");
	}

	//---------------------------------------------------------------------------

	public String getDbmsResourceName()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("resourceName");
	}

	//---------------------------------------------------------------------------

	public String getDbmsContext()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("context");
	}

	//---------------------------------------------------------------------------

	public String getDbmsURL()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("url");
	}

	//---------------------------------------------------------------------------

	public String getDbmsDriver()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("driver");
	}

	//---------------------------------------------------------------------------

	public String getDbmsUser()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("user");
	}

	//---------------------------------------------------------------------------

	public String getDbmsPassword()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("password");
	}

	//---------------------------------------------------------------------------

	public String getPoolSize()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("poolSize");
	}

	//---------------------------------------------------------------------------

	public String getValidQuery()
	{
		return dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG).getChildText("validationQuery");
	}

	//---------------------------------------------------------------------------
	//--- Dbms setters
	//---------------------------------------------------------------------------

	public void setupDbmsConfig(boolean createNew, boolean isJNDI)
	{
		Element resources = (Element)dbmsElem.getParent();
		if (createNew) {
			// leave existing config in place but set enabled to false
			dbmsElem.setAttribute("enabled","false");
		} else {
			// remove existing config ready for new config
			resources.removeContent(dbmsElem);
		}

		// new resource element, enabled with name="main-db"
		Element resource = new Element(ConfigFile.Resources.Child.RESOURCE)
				.setAttribute("enabled","true")
				.addContent(new Element(ConfigFile.Resource.Child.NAME).setText("main-db"));
	
		//                       provider according to type 
		Element provider = new Element(ConfigFile.Resource.Child.PROVIDER);
		if (isJNDI) {
			provider.setText("jeeves.resources.dbms.JNDIPool");
		} else {
			provider.setText("jeeves.resources.dbms.ApacheDBCPool");
		}
		resource.addContent(provider);

		//                       empty config element 
		Element config = new Element(ConfigFile.Resource.Child.CONFIG); 
		resource.addContent(config);
	
		// add this new resource element as the first child
		resources.addContent(0, resource);
	
		dbmsElem = resource;

	}

	//---------------------------------------------------------------------------

	public void setDbmsURL(String url)
	{
		createOrSetElement("url", url);
	}

	//---------------------------------------------------------------------------

	public void setDbmsDriver(String driver)
	{
		createOrSetElement("driver",driver);
	}

	//---------------------------------------------------------------------------

	public void setDbmsUser(String user)
	{
		createOrSetElement("user",user);
	}

	//---------------------------------------------------------------------------

	public void setDbmsPassword(String password)
	{
		createOrSetElement("password",password);
	}

	//---------------------------------------------------------------------------

	public void setDbmsPoolSize(String poolSize)
	{
		createOrSetElement("poolSize",poolSize);
	}

	//---------------------------------------------------------------------------

	public void setDbmsValidQuery(String validQuery)
	{
		createOrSetElement("validationQuery",validQuery);
	}

	//---------------------------------------------------------------------------

	public void setDbmsContext(String context)
	{
		createOrSetElement("context",context);
	}

	//---------------------------------------------------------------------------

	public void setDbmsResourceName(String resourceName)
	{
		createOrSetElement("resourceName",resourceName);
	}

	//---------------------------------------------------------------------------

	public void setDbmsSpatialIndexInDatabase(String spatialIndexInDatabase)
	{
		createOrSetElement("provideDataStore",spatialIndexInDatabase);
	}

	//---------------------------------------------------------------------------
	//--- Activator
	//---------------------------------------------------------------------------

	public void addActivator()
	{
		removeActivator();

		Element activ = new Element(ConfigFile.Resource.Child.ACTIVATOR);
		activ.setAttribute("class", "org.fao.geonet.activators.McKoiActivator");

		Element config = new Element("configFile");
		config.setText("WEB-INF/db/db.conf");

		activ   .addContent(config);
		dbmsElem.addContent(activ);
	}

	//---------------------------------------------------------------------------

	public void removeActivator()
	{
		dbmsElem.removeChild(ConfigFile.Resource.Child.ACTIVATOR);
	}

	//---------------------------------------------------------------------------
	//--- Other
	//---------------------------------------------------------------------------

	public void save() throws FileNotFoundException, IOException
	{
		Lib.xml.save(Config.getConfig().getConfigXml(), config);
	}

	//---------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//---------------------------------------------------------------------------

	private Element retrieveDbms(Document config)
	{
		Element resources = config.getRootElement().getChild(ConfigFile.Child.RESOURCES);

		for (Object res : resources.getChildren(ConfigFile.Resources.Child.RESOURCE))
		{
			Element resource = (Element) res;
			String  enabled  = resource.getAttributeValue("enabled");

			if ("true".equals(enabled))
				return resource;
		}

		//--- we should not arrive here

		return null;
	}

	//---------------------------------------------------------------------------

	private void createOrSetElement(String elementName, String value) {
		Element config = dbmsElem.getChild(ConfigFile.Resource.Child.CONFIG);
		Element elem = config.getChild(elementName);
		if (elem == null) {
			config.addContent(new Element(elementName).setText(value));
		} else {
			elem.setText(value);
		}
	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	private Document config;
	private Element  dbmsElem;
}

//=============================================================================


