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

package org.fao.geonet.kernel.harvest.harvester.oaipmh;

import jeeves.exceptions.BadInputEx;
import jeeves.exceptions.BadParameterEx;
import jeeves.utils.Util;
import org.fao.geonet.util.ISODate;
import org.jdom.Element;

//=============================================================================

class Search
{
	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	private Search() {}

	//---------------------------------------------------------------------------

	public Search(Element search) throws BadInputEx
	{
		from       = Util.getParam(search, "from",       "");
		until      = Util.getParam(search, "until",      "");
		set        = Util.getParam(search, "set",        "");
		prefix     = Util.getParam(search, "prefix",     "oai_dc");
		stylesheet = Util.getParam(search, "stylesheet", "");

		//--- check from parameter

		ISODate fromDate = null;
		ISODate untilDate= null;

		try
		{
			if (!from.equals(""))
			{
				fromDate = new ISODate(from);
				from     = fromDate.getDate();
			}

		}
		catch(Exception e)
		{
			throw new BadParameterEx("from", from);
		}

		//--- check until parameter

		try
		{
			if (!until.equals(""))
			{
				untilDate = new ISODate(until);
				until     = untilDate.getDate();
			}
		}
		catch(Exception e)
		{
			throw new BadParameterEx("until", until);
		}

		//--- check from <= until

		if (fromDate != null && untilDate != null)
			if (fromDate.sub(untilDate) > 0)
				throw new BadParameterEx("from greater than until", from +">"+ until);
	}

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------

	public Search copy()
	{
		Search s = new Search();

		s.from       = from;
		s.until      = until;
		s.set        = set;
		s.prefix     = prefix;
		s.stylesheet = stylesheet;

		return s;
	}

	//---------------------------------------------------------------------------

	public static Search createEmptySearch() throws BadInputEx
	{
		Search s = new Search();

		s.from       = "";
		s.until      = "";
		s.set        = "";
		s.prefix     = "oai_dc";
		s.stylesheet = "";

		return s;
	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	public String from;
	public String until;
	public String set;
	public String prefix;
	public String stylesheet;
}

//=============================================================================


