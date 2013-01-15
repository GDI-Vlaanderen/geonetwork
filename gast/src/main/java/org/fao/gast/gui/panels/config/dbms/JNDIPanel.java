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

import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JTextField;
import org.apache.commons.lang.StringUtils;
import org.dlib.gui.FlexLayout;
import org.fao.gast.lib.Lib;
import org.fao.gast.localization.Messages;

//==============================================================================

public class JNDIPanel extends DbmsPanel
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

	public JNDIPanel()
	{
		for (String vendor : dbmsVendors) {
			cmbDbmsVendor.addItem(vendor);
		}
		cmbSpatialIndexInDatabase.addItem("true");
		cmbSpatialIndexInDatabase.addItem("false");

		FlexLayout fl = new FlexLayout(3,5);
		fl.setColProp(1, FlexLayout.EXPAND);
		setLayout(fl);

		add("0,0", new JLabel(Messages.getString("context")));
		add("0,1", new JLabel(Messages.getString("resourceName")));
		add("0,2", new JLabel(Messages.getString("databaseVendor")));
		add("0,3", new JLabel(Messages.getString("spatialIndexInDatabase")));

		add("1,0", txtContext);
		add("1,1", txtResourceName);
		add("1,2", cmbDbmsVendor);
		add("1,3", cmbSpatialIndexInDatabase);

		add("2,0", new JLabel("<html><font color='red'>(REQ)</font>"));
		add("2,1", new JLabel("<html><font color='red'>(REQ)</font>"));
		add("2,2", new JLabel("<html><font color='red'>(REQ)</font>"));

		txtContext.setToolTipText(Messages.getString("jndi.context"));
		txtResourceName.setToolTipText(Messages.getString("jndi.resourceName"));
		cmbSpatialIndexInDatabase.setToolTipText(Messages.getString("jndi.spatialIndexInDatabase"));
	}

	//---------------------------------------------------------------------------
	//---
	//--- DbmsPanel methods
	//---
	//---------------------------------------------------------------------------

	public String getLabel() { return "JNDI"; }

	//---------------------------------------------------------------------------

	public boolean matches(String url, boolean isJNDI)
	{
		return isJNDI;
	}

	//---------------------------------------------------------------------------

	public void retrieve()
	{
		txtContext        				.setText(Lib.config.getDbmsContext());
		txtResourceName   				.setText(Lib.config.getDbmsResourceName());

		String dbmsVendor = Lib.config.getDbmsURL().toLowerCase();
		cmbDbmsVendor.setSelectedItem("");
		for (String vendor : dbmsVendors) {
			if (dbmsVendor.contains(vendor)) {
				cmbDbmsVendor.setSelectedItem(vendor);
			}
		}

		cmbSpatialIndexInDatabase.setSelectedItem("false");
		cmbSpatialIndexInDatabase.setSelectedItem(Lib.config.getDbmsSpatialIndexInDatabase().toLowerCase());
	}

	//---------------------------------------------------------------------------

	public void save(boolean createNew) throws Exception
	{

		// checks on input
		String context = txtContext.getText();
		if (StringUtils.isEmpty(context)) {
			throw new Exception(Messages.getString("contextNotEmpty"));
		}

		String resourceName = txtResourceName.getText();
		if (StringUtils.isEmpty(resourceName)) {
			throw new Exception(Messages.getString("resourceNameNotEmpty"));
		}

		String vendor = (String)cmbDbmsVendor.getSelectedItem();
		if (StringUtils.isEmpty(vendor)) {
			throw new Exception(Messages.getString("vendorNotEmpty"));
		}

		// save input
		Lib.config.setupDbmsConfig(createNew, true);
		Lib.config.setDbmsContext									(context);
		Lib.config.setDbmsResourceName						(resourceName);

		Lib.config.setDbmsURL     								(vendor);
		Lib.config.setDbmsSpatialIndexInDatabase	((String)cmbSpatialIndexInDatabase.getSelectedItem());
		Lib.config.removeActivator();
		Lib.config.save();
	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	private JTextField txtContext 								= new JTextField(20);
	private JTextField txtResourceName    				= new JTextField(20);
	private JComboBox	 cmbDbmsVendor              = new JComboBox();
	private JComboBox	 cmbSpatialIndexInDatabase	= new JComboBox();

	private static String[] dbmsVendors = { "", "postgis", "db2", "oracle", "mysql", "sqlserver", "h2" };

}

//==============================================================================

