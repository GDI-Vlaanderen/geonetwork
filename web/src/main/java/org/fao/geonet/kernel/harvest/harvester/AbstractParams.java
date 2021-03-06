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

import static org.quartz.JobBuilder.newJob;

import java.util.*;

import jeeves.exceptions.BadInputEx;
import jeeves.exceptions.BadParameterEx;
import jeeves.exceptions.MissingParameterEx;
import jeeves.utils.QuartzSchedulerUtils;
import jeeves.utils.Util;

import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.lib.Lib;
import org.jdom.Element;
import org.quartz.JobDetail;
import org.quartz.Trigger;

//=============================================================================

public abstract class AbstractParams
{
	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	public AbstractParams(DataManager dm)
	{
		this.dm = dm;
	}

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------

	public void create(Element node) throws BadInputEx
	{
		Element site    = node.getChild("site");
		Element opt     = node.getChild("options");
		Element content = node.getChild("content");

		Element account = (site == null) ? null : site.getChild("account");

		name       = Util.getParam(site, "name", "");
		uuid       = Util.getParam(site, "uuid", UUID.randomUUID().toString());

		useAccount = Util.getParam(account, "use",      false);
		username   = Util.getParam(account, "username", "");
		password   = Util.getParam(account, "password", "");

		every      = Util.getParam(opt, "every",      "0 0 0 * * ?" );
		
		oneRunOnly = Util.getParam(opt, "oneRunOnly", false);

		getTrigger();

		importXslt = Util.getParam(content, "importxslt", "none");
		validate = Util.getParam(content, "validate", false);

        addSchematrons(content.getChild("schematrons"));

		addPrivileges(node.getChild("privileges"));
		addCategories(node.getChild("categories"));

		this.node = node;
	}

	//---------------------------------------------------------------------------

	public void update(Element node) throws BadInputEx
	{
		Element site    = node.getChild("site");
		Element opt     = node.getChild("options");
		Element content = node.getChild("content");

		Element account = (site == null) ? null : site.getChild("account");
		Element privil  = node.getChild("privileges");
        Element categ   = node.getChild("categories");
        Element schematrons = content.getChild("schematrons");

        name       = Util.getParam(site, "name", name);

		useAccount = Util.getParam(account, "use",      useAccount);
		username   = Util.getParam(account, "username", username);
		password   = Util.getParam(account, "password", password);

		every      = Util.getParam(opt, "every",      every);
		oneRunOnly = Util.getParam(opt, "oneRunOnly", oneRunOnly);

		getTrigger();
		
		importXslt = Util.getParam(content, "importxslt", importXslt);
		validate = Util.getParam(content, "validate", validate);


        if (schematrons != null)
            addSchematrons(schematrons);

		if (privil != null)
			addPrivileges(privil);

		if (categ != null)
			addCategories(categ);

		this.node = node;
	}

	//---------------------------------------------------------------------------

    public Iterable<Schematron> getSchematrons() { return alSchematrons; }
	public Iterable<Privileges> getPrivileges() { return alPrivileges; }
	public Iterable<String>     getCategories() { return alCategories; }

	//---------------------------------------------------------------------------
	//---
	//--- Protected methods
	//---
	//---------------------------------------------------------------------------

	protected void copyTo(AbstractParams copy)
	{
		copy.name       = name;
		copy.uuid       = uuid;

		copy.useAccount = useAccount;
		copy.username   = username;
		copy.password   = password;

		copy.every      = every;
		copy.oneRunOnly = oneRunOnly;

		copy.importXslt = importXslt;
		copy.validate   = validate;

		for (Privileges p : alPrivileges)
			copy.alPrivileges.add(p.copy());

        for (Schematron p : alSchematrons)
            copy.alSchematrons.add(p.copy());

        // Store HashMap with key=schemaId and values the set of related schematrons
        copy.buildSchemaSchematronMap();

		for (String s : alCategories)
			copy.alCategories.add(s);

		copy.node = node;
	}

	public JobDetail getJob() {
    	return newJob(HarvesterJob.class).withIdentity(uuid, AbstractHarvester.HARVESTER_GROUP_NAME).usingJobData(HarvesterJob.ID_FIELD, uuid).build();
    }

    public Trigger getTrigger() {
    	return QuartzSchedulerUtils.getTrigger(uuid, AbstractHarvester.HARVESTER_GROUP_NAME, every, MAX_EVERY);
	}

	//---------------------------------------------------------------------------

	protected void checkPort(int port) throws BadParameterEx
	{
		if (port <1 || port > 65535)
			throw new BadParameterEx("port", port);
	}

	//---------------------------------------------------------------------------
	//---
	//--- Privileges and categories API methods
	//---
	//---------------------------------------------------------------------------

	/** Fills a list with Privileges that reflect the input 'privileges' element.
	  * The 'privileges' element has this format:
	  *
	  *   <privileges>
	  *      <group id="...">
	  *         <operation name="...">
	  *         ...
	  *      </group>
	  *      ...
	  *   </privileges>
	  *
	  * Operation names are: view, download, edit, etc... User defined operations are
	  * taken into account.
	  */

	private void addPrivileges(Element privil) throws BadInputEx
	{
		alPrivileges.clear();

		if (privil == null)
			return;

        for (Object o : privil.getChildren("group")) {
            Element group = (Element) o;
            String groupID = group.getAttributeValue("id");

            if (groupID == null) {
                throw new MissingParameterEx("attribute:id", group);
            }

            Privileges p = new Privileges(groupID);

            for (Object o1 : group.getChildren("operation")) {
                Element oper = (Element) o1;
                String op = getOperationId(oper);

                p.add(op);
            }

            alPrivileges.add(p);
        }
	}

	//---------------------------------------------------------------------------
    /** Fills a list with Schematrons that reflect the input 'schematrons' element.
     * The 'schematrons' element has this format:
     *
     *   <schematrons>
     *      <schematron schemaId="..." schematron="..."/ >
     *      ...
     *   </schematrons>
     *
     */

    private void addSchematrons(Element schematrons) throws BadInputEx
    {
        alSchematrons.clear();


        if (schematrons == null)
            return;

        for (Object o : schematrons.getChildren("schematron")) {
            Element schematron = (Element) o;
            String schemaId = schematron.getAttributeValue("schemaId");
            String schematronId  = schematron.getAttributeValue("schematron");
            
            if (schemaId == null) {
                throw new MissingParameterEx("attribute:schemaId", schematron);
            }

            if (schematronId == null) {
                throw new MissingParameterEx("attribute:schematron", schematron);
            }

            Schematron s = new Schematron(schemaId, schematronId);

            alSchematrons.add(s);
        }

        // Store HashMap with key=schemaId and values the set of related schematrons
        buildSchemaSchematronMap();
    }

    /**
     *
     * Create a mapping to know which schemas should be invoking which of their schematrons as indicated by the user.
     *
     */
    private void buildSchemaSchematronMap() {
        schemaSchematronMap = new HashMap<String, Set<String>>();

        for(Schematron sch: alSchematrons) {
            // strip prefix 'schematron-'

                String schemaName = sch.getSchemaId();
                String schematronName = sch.getSchematron();
                System.out.println("found schematronparameter for schema " + schemaName + " with sctr name " + schematronName );
                Set<String> schematronsForSchema = schemaSchematronMap.get(schemaName);
                if(schematronsForSchema == null) {
                    schematronsForSchema = new HashSet<String>();
                }
                schematronsForSchema.add(schematronName);
                schemaSchematronMap.put(schemaName, schematronsForSchema);

        }
    }

    //---------------------------------------------------------------------------

	private String getOperationId(Element oper) throws BadInputEx
	{
		String operName = oper.getAttributeValue("name");

		if (operName == null)
			throw new MissingParameterEx("attribute:name", oper);

		String operID = dm.getAccessManager().getPrivilegeId(operName);

		if (operID.equals("-1"))
			throw new BadParameterEx("attribute:name", operName);

		if (operID.equals("2") || operID.equals("4"))
			throw new BadParameterEx("attribute:name", operName);

		return operID;
	}

	//---------------------------------------------------------------------------
	/** Fills a list with category identifiers that reflect the input 'categories' element.
	  * The 'categories' element has this format:
	  *
	  *   <categories>
	  *      <category id="..."/>
	  *      ...
	  *   </categories>
	  */

	private void addCategories(Element categ) throws BadInputEx
	{
		alCategories.clear();

		if (categ == null)
			return;

        for (Object o : categ.getChildren("category")) {
            Element categElem = (Element) o;
            String categId = categElem.getAttributeValue("id");

            if (categId == null) {
                throw new MissingParameterEx("attribute:id", categElem);
            }

            if (!Lib.type.isInteger(categId)) {
                throw new BadParameterEx("attribute:id", categElem);
            }

            alCategories.add(categId);
        }
	}

    public Map<String, Set<String>> getSchemaSchematronMap() {
        //
        // create a mapping to know which schemas should be invoking which of their schematrons as indicated by the user
        //
        return schemaSchematronMap;
    }

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	public String  name;
	public String  uuid;

	public boolean useAccount;
	public String  username;
	public String  password;

	String  every;
	public boolean oneRunOnly;

	public boolean validate;
	public String importXslt;

	public Element node;

	//---------------------------------------------------------------------------

	protected DataManager dm;

    private ArrayList<Schematron> alSchematrons = new ArrayList<Schematron>();
	private ArrayList<Privileges> alPrivileges = new ArrayList<Privileges>();
	private ArrayList<String>     alCategories = new ArrayList<String>();

    private Map<String, Set<String>> schemaSchematronMap = new HashMap<String, Set<String>>();

	//---------------------------------------------------------------------------

	private static final long MAX_EVERY = Integer.MAX_VALUE;
}

//=============================================================================

