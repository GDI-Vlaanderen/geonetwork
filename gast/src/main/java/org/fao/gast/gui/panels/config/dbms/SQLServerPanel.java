//==============================================================================
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

package org.fao.gast.gui.panels.config.dbms;

import java.util.StringTokenizer;
import javax.swing.JLabel;
import javax.swing.JTextField;
import org.apache.commons.lang.StringUtils;
import org.dlib.gui.FlexLayout;
import org.fao.gast.lib.Lib;
import org.fao.gast.localization.Messages;

//==============================================================================

public class SQLServerPanel extends DbmsPanel
{
	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	/**
	 * 
	 */
	private static final long serialVersionUID = 776417193492019459L;

	public SQLServerPanel()
	{
		FlexLayout fl = new FlexLayout(3,5);
		fl.setColProp(1, FlexLayout.EXPAND);
		setLayout(fl);

		add("0,0", new JLabel(Messages.getString("server")));
		add("0,1", new JLabel(Messages.getString("database")));
		add("0,2", new JLabel(Messages.getString("username")));
		add("0,3", new JLabel(Messages.getString("password")));

		add("1,0", txtServer);
		add("1,1", txtDatabase);
		add("1,2", txtUser);
		add("1,3", txtPass);

		add("2,0", new JLabel("<html><font color='red'>(REQ)</font>"));
		add("2,1", new JLabel("<html><font color='red'>(REQ)</font>"));
	}

	//---------------------------------------------------------------------------
	//---
	//--- DbmsPanel methods
	//---
	//---------------------------------------------------------------------------

	public String getLabel() { return "SQLServer"; }

	//---------------------------------------------------------------------------

	public boolean matches(String url, boolean isJNDI)
	{
		if (!isJNDI) {
			return url.startsWith(PREFIX);
		} else {
			return false;
		}
	}

	//---------------------------------------------------------------------------
	//--- jdbc:sqlserver://SERVER;database=NAME;integratedSecurity=false;

	public void retrieve()
	{
		String url = Lib.config.getDbmsURL();

		//--- cut prefix +'@'
		url = url.substring(PREFIX.length() +1);

		StringTokenizer st = new StringTokenizer(url, ";");

		String server   = st.nextToken();
		String database = st.hasMoreTokens() ? st.nextToken() : "";
		database = StringUtils.substringAfter(database, "=");

		txtServer  	.setText(server);
		txtDatabase	.setText(database);
		txtUser  		.setText(Lib.config.getDbmsUser());
		txtPass  		.setText(Lib.config.getDbmsPassword());
	}

	//---------------------------------------------------------------------------

	public void save(boolean createNew) throws Exception
	{

		// checks on input
		String server = 		txtServer.getText();
		String database =		txtDatabase.getText();

		if (StringUtils.isBlank(server)) {
			throw new Exception(Messages.getString("serverNotEmpty"));
		}

		if (StringUtils.isBlank(database)) {
			throw new Exception(Messages.getString("databaseNotEmpty"));
		}

		String url = PREFIX +"//"+ server +";database="+ database;
		if (!url.contains("integratedSecurity")) {
			url += ";integratedSecurity=false;";
		}

		// save input
		Lib.config.setupDbmsConfig(createNew, false);
		Lib.config.setDbmsDriver  ("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		Lib.config.setDbmsURL     (url);
		Lib.config.setDbmsUser    (txtUser.getText());
		Lib.config.setDbmsPassword(txtPass.getText());
		Lib.config.setDbmsPoolSize("10");
		Lib.config.setDbmsValidQuery("SELECT 1");
		Lib.config.removeActivator();
		Lib.config.save();
	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	private JTextField txtServer 		= new JTextField(15);
	private JTextField txtDatabase	= new JTextField(12);
	private JTextField txtUser   		= new JTextField(12);
	private JTextField txtPass   		= new JTextField(12);

	//---------------------------------------------------------------------------

	private static final String PREFIX = "jdbc:sqlserver:";

}

//==============================================================================

