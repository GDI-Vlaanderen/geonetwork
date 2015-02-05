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

package org.fao.geonet.services.mef;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.mef.MEFLib;
import org.jdom.Element;

import java.io.File;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Import MEF file.
 * 
 */
public class Import implements Service {
	private String stylePath;

	public void init(String appPath, ServiceConfig params) throws Exception {
		this.stylePath = appPath + Geonet.Path.IMPORT_STYLESHEETS;
	}

	/**
	 * Service to import MEF File.
	 * 
	 * 
	 * @param params
	 *            List of parameters:
	 *            <ul>
	 *            <li>mefFile: file to upload</li>
	 *            <li>file_type: "single" for loading a single XML file, "mef" to
	 *            load MEF file (version 1 or 2). "mef" is the default value.</li>
	 *            </ul>
	 * 
	 * @return List of imported ids.
	 * 
	 */
	public Element exec(Element params, ServiceContext context)
			throws Exception {
		String mefFile = Util.getParam(params, "mefFile");
        String fileType = Util.getParam(params, "file_type", "mef");
		String uploadDir = context.getUploadDir();

		File file = new File(uploadDir, mefFile);

        boolean validate = Util.getParam(params, Params.VALIDATE, "off").equals("on");

        Map<String, Set<String>> schemaSchematronMap = new HashMap<String, Set<String>>();
        if(validate) {
            schemaSchematronMap = getSchemaSchematronMapping(params);
        }
		List<String> id = MEFLib.doImport(params, schemaSchematronMap, context, file, stylePath);
        String ids = "";

        Iterator<String> iter = id.iterator();
        while (iter.hasNext()) {
            String item = (String) iter.next();
            ids += item + ";";

        }

        file.delete();

		Element result = null;

        if (context.getService().equals("mef.import")) {

            result = new Element("id");
            result.setText(ids);

        } else {

            result = new Element(Jeeves.Elem.RESPONSE);
            if ((fileType.equals("single") && (id.size() == 1))) {
                result.addContent(new Element(Params.ID).setText(id.get(0) +""));
        		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);               DataManager dm = gc.getDataManager();
                Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
                result.addContent(new Element(Params.UUID).setText(String.valueOf(dm.getMetadataUuid(dbms, id.get(0) +""))));
            } else {
                result.addContent(new Element("records").setText(id.size() +""));

            }

        }

		// --- return success with all metadata id
		return result;
	}

    /**
     * TODO this method is duplicated in ImportFromDir.
     *
     * @param params
     * @return
     */
    private Map<String, Set<String>> getSchemaSchematronMapping(Element params) {
        //
        // create a mapping to know which schemas should be invoking which of their schematrons as indicated by the user
        //
        Map<String, String> schematronsParams = Util.getParamsByPrefix(params, "schematron-");
        System.out.println("found # " + schematronsParams.size() + " sctr params" );
        Map<String, Set<String>> schemaSchematronMap = new HashMap<String, Set<String>>();
        for(String param: schematronsParams.keySet()) {
            // strip prefix 'schematron-'
            param = param.substring("schematron-".length());
            int firstHyphen = param.indexOf('-');
            if(firstHyphen < 0) {
                System.out.println("WARNING: unexpected schematron parameter seen in ImportFromDir, ignoring it: " + param);
            }
            else {
                String schemaName = param.substring(0, firstHyphen);
                String schematronName = param.substring(++firstHyphen);
                System.out.println("found schematronparameter for schema " + schemaName + " with sctr name " + schematronName );
                Set<String> schematronsForSchema = schemaSchematronMap.get(schemaName);
                if(schematronsForSchema == null) {
                    schematronsForSchema = new HashSet<String>();
                }
                schematronsForSchema.add(schematronName);
                schemaSchematronMap.put(schemaName, schematronsForSchema);
            }
        }
        return schemaSchematronMap;
    }
}

// =============================================================================

