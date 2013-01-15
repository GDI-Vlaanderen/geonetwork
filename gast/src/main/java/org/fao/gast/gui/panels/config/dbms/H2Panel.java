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

public class H2Panel extends DbmsPanel
{
	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	/**
	 * 
	 */
	private static final long serialVersionUID = -9139785892791080773L;

	public H2Panel()
	{
		FlexLayout fl = new FlexLayout(3,5);
		fl.setColProp(1, FlexLayout.EXPAND);
		setLayout(fl);

		add("0,0", new JLabel(Messages.getString("dbLocation")));
		add("0,1", new JLabel(Messages.getString("username")));
		add("0,2", new JLabel(Messages.getString("password")));

		add("1,0", txtDbLocation);
		add("1,1", txtUser);
		add("1,2", txtPass);

		add("2,0", new JLabel("<html><font color='red'>(REQ)</font>"));
		add("2,1", new JLabel("<html><font color='red'>(REQ)</font>"));
		add("2,2", new JLabel("<html><font color='red'>(REQ)</font>"));

		txtDbLocation.setToolTipText(Messages.getString("h2.dblocation"));
	}

	//---------------------------------------------------------------------------
	//---
	//--- DbmsPanel methods
	//---
	//---------------------------------------------------------------------------

	public String getLabel() { return "H2"; }

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

	public void retrieve()
	{
		String url = Lib.config.getDbmsURL();

		//--- cut prefix
		url = url.substring(PREFIX.length());

		txtDbLocation 	.setText(url);
		txtUser    			.setText(Lib.config.getDbmsUser());
		txtPass    			.setText(Lib.config.getDbmsPassword());
	}

	//---------------------------------------------------------------------------

	public void save(boolean createNew) throws Exception
	{

		// checks on input
		String dbLocation  = txtDbLocation .getText();
		if (StringUtils.isEmpty(dbLocation)) {
			throw new Exception(Messages.getString("dbLocationNotEmpty"));
		}

		String user = txtUser.getText();
		if (StringUtils.isEmpty(user)) {
			throw new Exception(Messages.getString("userNotEmpty"));
		}

		String pass = txtPass.getText();
		if (StringUtils.isEmpty(pass)) {
			throw new Exception(Messages.getString("passNotEmpty"));
		}

		String url = PREFIX + dbLocation;
		if (!url.contains("LOCK_TIMEOUT")) url += ";LOCK_TIMEOUT=20000";

		// save input 
		Lib.config.setupDbmsConfig(createNew, false);
		Lib.config.setDbmsDriver  ("org.h2.Driver");
		Lib.config.setDbmsURL     (url);
		Lib.config.setDbmsUser    (user);
		Lib.config.setDbmsPassword(pass);
		Lib.config.setDbmsPoolSize("33");
		Lib.config.setDbmsValidQuery("SELECT 1");
		Lib.config.removeActivator();
		Lib.config.save();
	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	private JTextField txtDbLocation  = new JTextField(25);
	private JTextField txtUser    = new JTextField(12);
	private JTextField txtPass    = new JTextField(12);

	//---------------------------------------------------------------------------

	private static final String PREFIX = "jdbc:h2:";
}

//==============================================================================

