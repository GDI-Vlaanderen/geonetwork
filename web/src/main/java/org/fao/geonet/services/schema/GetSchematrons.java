//=============================================================================
//===	Copyright (C) 2001-2012 Food and Agriculture Organization of the
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

package org.fao.geonet.services.schema;

import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.csw.common.util.Xml;
import org.fao.geonet.kernel.SchemaManager;
import org.jdom.Element;

/**
 * Returns list of schemas and associated schematron files in this catalog.
 *
 * Example:
 *
 * <response>
 *     <schemas>
 *         <schema>
 *             <schemaname>iso19115</schemaname>
 *             <schematronname>schematron-rules-none.xsl</schematronname>
 *         </schema>
 *         <schema>
 *             <schemaname>fgdc-std</schemaname>
 *             <schematronname>schematron-rules-none.xsl</schematronname>
 *         </schema>
 *         <schema>
 *             <schemaname>iso19139</schemaname>
 *             <schematronname>schematron-rules-geonetwork.xsl</schematronname>
 *             <schematronname>schematron-rules-inspire.xsl</schematronname>
 *             <schematronname>schematron-rules-iso.xsl</schematronname>
 *         </schema>
 *         <schema>
 *             <schemaname>csw-record</schemaname>
 *             <schematronname>schematron-rules-none.xsl</schematronname>
 *         </schema>
 *         <schema>
 *             <schemaname>iso19110</schemaname>
 *             <schematronname>schematron-rules-none.xsl</schematronname>
 *         </schema>
 *         <schema>
 *             <schemaname>dublin-core</schemaname>
 *             <schematronname>schematron-rules-none.xsl</schematronname>
 *         </schema>
 *     </schemas>
 * </response>
 *
 * @author heikki doeleman
 */
public class GetSchematrons implements Service {

    /**
     *
     * @param appPath
     * @param params
     * @throws Exception
     */
	public void init(String appPath, ServiceConfig params) throws Exception {}

    /**
     *
     * @param params
     * @param context
     * @return
     * @throws Exception
     */
	public Element exec(Element params, ServiceContext context) throws Exception {
		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
		SchemaManager scm = gc.getSchemamanager();
		Element response = new Element("response");
        Element schemasAndSchematrons = scm.getSchemasAndTheirSchematrons();
        response.addContent(schemasAndSchematrons);
        if(context.isDebug()) {
            context.debug("GetSchematrons returns:\n" + Xml.getString(response));
        }
        return response;
	}

}