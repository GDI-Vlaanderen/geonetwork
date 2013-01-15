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

package org.fao.geonet.kernel.harvest.harvester;

import jeeves.resources.dbms.Dbms;
import org.jdom.Element;

import java.util.HashMap;
import java.util.List;

//=============================================================================

/** Loads all categories from the database and creates a mapping
  * (categ name) -> (categ ID)
  */

public class CategoryMapper
{
	//--------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//--------------------------------------------------------------------------

	public CategoryMapper(Dbms dbms) throws Exception
	{
		String query = "SELECT * FROM Categories";

		List idsList = dbms.select(query).getChildren();

        for (Object anIdsList : idsList) {
            Element record = (Element) anIdsList;

            String id = record.getChildText("id");
            String name = record.getChildText("name");

            add(name, id);
        }
	}

	//--------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//--------------------------------------------------------------------------

	public void add(String name, String id)
	{
		hmNameId.put(name, id);
		hmIdName.put(id, name);
	}

	//--------------------------------------------------------------------------

	/** Given a category name returns its id */

	public String getID(String name) { return hmNameId.get(name); }

	public String getName(String id) { return hmIdName.get(id); }

	public boolean exists(String id) { return hmIdName.containsKey(id); }

	//--------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//--------------------------------------------------------------------------

	private HashMap<String, String> hmNameId = new HashMap<String, String>();
	private HashMap<String, String> hmIdName = new HashMap<String, String>();
}

//=============================================================================

