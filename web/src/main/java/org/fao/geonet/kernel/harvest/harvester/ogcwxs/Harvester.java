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

package org.fao.geonet.kernel.harvest.harvester.ogcwxs;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URL;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import jeeves.interfaces.Logger;
import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import jeeves.utils.BinaryFile;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import jeeves.utils.XmlRequest;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.csw.common.ElementSetName;
import org.fao.geonet.csw.common.requests.CatalogRequest;
import org.fao.geonet.csw.common.requests.GetRecordByIdRequest;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.harvest.harvester.CategoryMapper;
import org.fao.geonet.kernel.harvest.harvester.GroupMapper;
import org.fao.geonet.kernel.harvest.harvester.Privileges;
import org.fao.geonet.kernel.harvest.harvester.UUIDMapper;
import org.fao.geonet.kernel.schema.MetadataSchema;
import org.fao.geonet.kernel.setting.SettingInfo;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.services.metadata.validation.agiv.AGIVValidation;
import org.fao.geonet.services.thumbnail.Set;
import org.fao.geonet.util.FileCopyMgr;
import org.fao.geonet.util.IDFactory;
import org.fao.geonet.util.ISODate;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import org.jdom.xpath.XPath;


//=============================================================================
/** 
 * A OgcWxSHarvester is able to generate metadata for data and service
 * from a GetCapabilities documents. Metadata for layers are generated
 * using layer information contained in the GetCapabilities document
 * or using a xml document pointed by the metadataUrl attribute of layer
 * element.
 * 
 * OGC services supported are : 
 * <ul>
 * 	<li>WMS</li>
 * 	<li>WFS</li>
 * 	<li>WCS</li>
 * 	<li>WPS</li>
 * 	<li>SOS</li>
 * </ul>
 * 
 * Metadata produced are :
 * <ul>
 * 	<li>ISO19119 for service's metadata</li>
 * 	<li>ISO19139 for data's metadata</li>
 * </ul>
 * 
 *  Note : Layer stands for "Layer" for WMS, "FeatureType" for WFS
 *  and "Coverage" for WCS.
 *  
 * <pre>  
 * <nodes>
 *  <node type="ogcwxs" id="113">
 *    <site>
 *      <name>TEST</name>
 *      <uuid>c1da2928-c866-49fd-adde-466fe36d3508</uuid>
 *      <account>
 *        <use>true</use>
 *        <username />
 *        <password />
 *      </account>
 *      <url>http://localhost:8080/geoserver/wms</url>
 *      <ogctype>WMS111</ogctype>
 *      <icon>default.gif</icon>
 *    </site>
 *    <options>
 *      <every>90</every>
 *      <oneRunOnly>false</oneRunOnly>
 *      <status>active</status>
 *      <lang>eng</lang>
 *      <useLayer>true</useLayer>
 *      <useLayerMd>false</useLayerMd>
 *      <datasetCategory></datasetCategory>
 *    </options>
 *    <privileges>
 *      <group id="1">
 *        <operation name="view" />
 *      </group>
 *    </privileges>
 *    <categories>
 *      <category id="3" />
 *    </categories>
 *    <info>
 *      <lastRun>2007-12-05T16:17:20</lastRun>
 *      <running>false</running>
 *    </info>
 *  </node>
 * </nodes>
 * </pre>
 * 
 * @author fxprunayre
 *   
 */
class Harvester
{
	
	
	/** 
     * Constructor
     *  
     * @param log		
     * @param context		Jeeves context
     * @param dbms 			Database
     * @param params	Information about harvesting configuration for the node
     * 
     * @return null
     */
	public Harvester(Logger log, 
						ServiceContext context, 
						Dbms dbms, 
						OgcWxSParams params) {
		this.log    = log;
		this.context= context;
		this.dbms   = dbms;
		this.params = params;

		result = new OgcWxSResult ();
		
		GeonetContext gc = (GeonetContext) context.getHandlerContext (Geonet.CONTEXT_NAME);
		dataMan = gc.getDataManager ();
		schemaMan = gc.getSchemamanager ();
		SettingInfo si = new SettingInfo(context);


    }

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------
	/** 
     * Start the harvesting of a WMS, WFS or WCS node.
     */
	public OgcWxSResult harvest() throws Exception {
        Element xml;

        log.info("Retrieving remote metadata information for : " + params.name);
        
		// Clean all before harvest : Remove/Add mechanism
        // If harvest failed (ie. if node unreachable), metadata will be removed, and
        // the node will not be referenced in the catalogue until next harvesting.
        // TODO : define a rule for UUID in order to be able to do an update operation ?
        UUIDMapper localUuids = new UUIDMapper(dbms, params.uuid);


        String requestParams = "SERVICE=" + params.ogctype.substring(0,params.ogctype.length()-5) + "&VERSION=" + params.ogctype.substring(params.ogctype.length()-5) + "&REQUEST=" + GETCAPABILITIES;
        // Try to load capabilities document
		this.capabilitiesUrl = getBaseUrl(params.url) + requestParams;
		
        System.out.println("Retrieving capabilities: " + this.capabilitiesUrl);
        if(log.isDebugEnabled()) log.debug("GetCapabilities document: " + this.capabilitiesUrl);
		
        XmlRequest req = new XmlRequest();
        req.setUrl(new URL(this.capabilitiesUrl));
        req.setMethod(XmlRequest.Method.GET);
        Lib.net.setupProxy(context, req);

        if (params.useAccount) {
            req.setCredentials(params.username, params.password);
        }

        xml = req.execute();

		//-----------------------------------------------------------------------
		//--- remove old metadata
		for (String uuid : localUuids.getUUIDs())
		{
			String id = localUuids.getID (uuid);

            if(log.isDebugEnabled()) log.debug ("  - Removing old metadata before update with id: " + id);

			// Remove thumbnails
			unsetThumbnail (id);
			
			// Remove metadata
			dataMan.deleteMetadata (context, dbms, id);
			
			result.locallyRemoved ++;
		}
		
		if (result.locallyRemoved > 0)
			dbms.commit ();
		
        // Convert from GetCapabilities to ISO19119
        addMetadata (xml);
        
        dbms.commit ();
            
        result.total = result.added + result.layer;
    
		return result;
	}
	
	

	/** 
     * Add metadata to the node for a WxS service
     *  
	 *  1.Use GetCapabilities Document
	 *  2.Transform using XSLT to iso19119
	 *  3.Loop through layers
	 *  4.Create md for layer
	 *  5.Add operatesOn elem with uuid
	 *  6.Save all
     *	
     * @param capa      GetCapabilities document
     *                   
     */
	 private void addMetadata (Element capa) throws Exception
	 {
		if (capa == null)
			return;

		//--- Loading categories and groups
		localCateg 	= new CategoryMapper (dbms);
		localGroups = new GroupMapper (dbms);

		// md5 the full capabilities URL
		String uuid = Util.scramble (this.capabilitiesUrl); // is the service identifier

         // heikki for AGIV: make this string look a bit more like a UUID by inserting some hyphens
         if(StringUtils.isNotEmpty(uuid)) {
             if(uuid.length() > 8) {
                 uuid = uuid.substring(0, 8) + '-' + uuid.substring(8);
             }
             if(uuid.length() > 13) {
                 uuid = uuid.substring(0, 13) + '-' + uuid.substring(13);
             }
             if(uuid.length() > 18) {
                 uuid = uuid.substring(0, 18) + '-' + uuid.substring(18);
             }
             if(uuid.length() > 23) {
                 uuid = uuid.substring(0, 23) + '-' + uuid.substring(23);
             }
             if(uuid.length() > 28) {
                 uuid = uuid.substring(0, 28) + '-' + uuid.substring(28);
             }
             if(uuid.length() > 33) {
                 uuid = uuid.substring(0, 33) + '-' + uuid.substring(33);
             }
             if(uuid.length() > 38) {
                 uuid = uuid.substring(0, 38) + '-' + uuid.substring(38);
             }
         }


		//--- Loading stylesheet
		String styleSheet = schemaMan.getSchemaDir(params.outputSchema) + 
							Geonet.Path.CONVERT_STYLESHEETS
							+ "/OGCWxSGetCapabilitiesto19119/" 
							+ "/OGC"
							+ (params.ogctype.startsWith("WMTS") ? "WMS" : params.ogctype.substring(0,3))
							+ "GetCapabilities-to-ISO19119_ISO19139.xsl";

         if(log.isDebugEnabled()) log.debug ("  - XSLT transformation using " + styleSheet);
		
		Map<String, String> param = new HashMap<String, String>();
		param.put("lang", params.lang);
//		param.put("topic", params.topic);
		param.put("ogctype", params.ogctype);
		param.put("uuid", uuid);
		
		Element md = Xml.transform (capa, styleSheet, param);
		
		String schema = dataMan.autodetectSchema (md); // ie. iso19139; 

		if (schema == null) {
			log.warning("Skipping metadata with unknown schema.");
			result.unknownSchema ++;
		}


		//--- Create metadata for layers only if user ask for
//		if (params.useLayer || params.useLayerMd) {			
			// Load CRS
			// TODO
			
			//--- Select layers, featureTypes and Coverages (for layers having no child named layer = not take group of layer into account) 
			// and add the metadata
			XPath xp = XPath.newInstance ("//Layer[count(./*[name(.)='Layer'])=0] | //wmts:Layer[count(./*[local-name(.)='Layer'])=0] | " + 
											"//wms:Layer[count(./*[name(.)='Layer'])=0] | " +
											"//wfs:FeatureType | " +
											"//wcs:CoverageOfferingBrief | " +
											"//sos:ObservationOffering");
			xp.addNamespace("wfs", "http://www.opengis.net/wfs");
			xp.addNamespace("wcs", "http://www.opengis.net/wcs");
			xp.addNamespace("wms", "http://www.opengis.net/wms");
			xp.addNamespace("wmts", "http://www.opengis.net/wmts/1.0");
			xp.addNamespace("sos", "http://www.opengis.net/sos/1.0");
										
			List<Element> layers = xp.selectNodes(capa);
			if (layers.size()>0) {
				log.info("  - Number of layers, featureTypes or Coverages found : " + layers.size());
			
				List<String> nonExistingMetadata = new ArrayList<String>();
				for (Element layer : layers) {
					WxSLayerRegistry s = addLayerMetadata (layer, capa, params.useLayer || params.useLayerMd, nonExistingMetadata);
					if (s != null)
						layersRegistry.add(s);
				}       
				for (String layer : nonExistingMetadata) {
					log.error("Non existing metadataUrl : " + layer);
				}
				// Update ISO19119 for data/service links creation (ie. operatesOn element)
				// The editor will support that but it will make quite heavy XML.
				md = addOperatesOnUuid (md, layersRegistry);
			}
//		}	

		String codeListUpdateStyleSheet = dataMan.getSchemaDir(schema) + Geonet.File.UPDATE_HARVEST_INFO;
		md = Xml.transform(md, codeListUpdateStyleSheet);

        if ("iso19139".equals(schema)) {
//        	if (context.getServlet().getNodeType().toLowerCase().equals("agiv") || context.getServlet().getNodeType().toLowerCase().equals("geopunt")) {
                MetadataSchema metadataSchema = dataMan.getSchema(schema);
                String[] schematronFilenames = {AGIVValidation.INSPIRE_SCHEMATRON_KEY + ".xsl", AGIVValidation.AGIV_SCHEMATRON_KEY + ".xsl"};
                Map <String, Integer[]> valTypeAndStatus = new HashMap<String, Integer[]>();
                try {
    			    dataMan.getEditLib().enumerateTree(md);
                    Element schematronError = dataMan.getSchemaTronXmlReport(metadataSchema, schematronFilenames, md, context.getLanguage(), valTypeAndStatus);
        	        // remove editing info added by enumerateTree
                    dataMan.getEditLib().removeEditingInfo(md);
        			md = new AGIVValidation(context).addConformKeywords(md, valTypeAndStatus, schema);
                } catch (Exception e) {
                    log.error("Ignoring schematron erros for AGIVValidation with metadata with uuid " + uuid /*+ " : " + ex*/);
                }
//        	}
        }
        // Save iso19119 metadata in DB
		log.info("Adding metadata for services with " + uuid);
		DateFormat df = new SimpleDateFormat ("yyyy-MM-dd'T'HH:mm:ss");
		Date date = new Date();

        //
        // insert metadata
        //
        String userid = "1";
        String group = null, isTemplate = null, docType = null, title = null, category = null;
        boolean ufo = false, indexImmediate = false;
         String id = IDFactory.newID();
        dataMan.insertMetadata(context, dbms, schema, md, id, uuid, userid, group, params.uuid, isTemplate, docType,
                title, category, df.format(date), df.format(date), ufo, indexImmediate);

		addPrivileges(id);
		addCategories(id);
		
		dataMan.setHarvestedExt(dbms, id, params.uuid, params.url);
		dataMan.setStatusExt(context, dbms, id, new Integer(Params.Status.APPROVED),
				new ISODate().toString(), "Status veranderd na harvesting");
		dataMan.setTemplate(dbms, id, "n", null);
		
		dbms.commit();
		//dataMan.indexMetadata(dbms, id); setTemplate update the index
		
		result.added ++;
		
		// Add Thumbnails only after metadata insertion to avoid concurrent transaction
		// and loaded thumbnails could eventually failed anyway.
		if (params.ogctype.startsWith("WMS") && params.createThumbnails) {
        	for (WxSLayerRegistry layer : layersRegistry) {
        		if (layer.id!=null) {
                    loadThumbnail (layer);
        		}
            }
        }
	}
	
	
	
	/** 
     * Add OperatesOn elements on an ISO19119 metadata
     *  
     *  <srv:operatesOn>
	 *		<gmd:MD_DataIdentification uuidref=""/>
	 *	</srv:operatesOn>
     *	
     * @param md                    iso19119 metadata
     * @param layersRegistry		uuid to be added as an uuidref attribute
     *                   
     */
	 private Element addOperatesOnUuid (Element md, List<WxSLayerRegistry> layersRegistry) {
				
		Namespace gmd 	= Namespace.getNamespace("gmd", "http://www.isotc211.org/2005/gmd");
		Namespace gco 	= Namespace.getNamespace("gco", "http://www.isotc211.org/2005/gco");
		Namespace srv 	= Namespace.getNamespace("srv", "http://www.isotc211.org/2005/srv");
        Namespace xlink = Namespace.getNamespace("xlink", "http://www.w3.org/1999/xlink");

        Element root 	= md.getChild("identificationInfo", gmd)
							.getChild("SV_ServiceIdentification", srv);


        /*
           * TODO
           *
              For each queryable layer queryable = "1" et /ROOT/Capability/Request/*[name()!='getCapabilities']
                  or queryable = "0" et /ROOT/Capability/Request/*[name()!='getCapabilities' and name!='GetFeatureInfo']
              should do
                  srv:coupledResource/srv:SV_CoupledResource/srv:OperationName = /ROOT/Capability/Request/child::name()
                  srv:coupledResource/srv:SV_CoupledResource/srv:identifier = UUID of the data metadata
                  srv:coupledResource/srv:SV_CoupledResource/gco:ScopedName = Layer/Name
              But is this really useful in ISO19119 ?
           */
		
		if (root != null) {
            if(log.isDebugEnabled()) log.debug("Add SV_CoupledResource and OperatesOnUuid");
			
			Element couplingType = root.getChild("couplingType", srv);
			int coupledResourceIdx = root.indexOf(couplingType);
			
			for (WxSLayerRegistry layer : layersRegistry)
			{
				// Create coupled resources elements to register all layername
				// in service metadata. This information could be used to add
				// interactive map button when viewing service metadata.
				Element coupledResource = new Element ("coupledResource", srv);
				Element scr = new Element ("SV_CoupledResource", srv);
				
				
				// Create operation according to service type
				Element operation = new Element ("operationName", srv);
				Element operationValue = new Element ("CharacterString", gco);
				
				if (params.ogctype.startsWith("WMS") || params.ogctype.startsWith("WMTS"))
					operationValue.setText("GetMap"); 
				else if (params.ogctype.startsWith("WFS"))
					operationValue.setText("GetFeature");
				else if (params.ogctype.startsWith("WCS"))
					operationValue.setText("GetCoverage");
				else if (params.ogctype.startsWith("SOS"))
					operationValue.setText("GetObservation");
				operation.addContent(operationValue);
				
				// Create identifier (which is the metadata identifier)
				Element id = new Element ("identifier", srv);
				Element idValue = new Element ("CharacterString", gco);
				if (StringUtils.isNotEmpty(layer.mduuid)) {
					idValue.setText(layer.mduuid);
				}
				id.addContent(idValue);
				
				// Create scoped name element as defined in CSW 2.0.2 ISO profil
				// specification to link service metadata to a layer in a service.
				Element scopedName = new Element ("ScopedName", gco);
				scopedName.setText(layer.name);
				
				scr.addContent(operation);
				scr.addContent(id);
				scr.addContent(scopedName);
				coupledResource.addContent(scr);
				
				// Add coupled resource before coupling type element
				root.addContent(coupledResourceIdx, coupledResource);
				
				
		
				// Add operatesOn element at the end of identification section.
				Element op = new Element ("operatesOn", srv);
				op.setAttribute("uuidref", StringUtils.isNotEmpty(layer.mduuid) ? layer.mduuid : "");

				if (StringUtils.isNotEmpty(layer.uuid)) {
//					String hRefLink =  dataMan.getSiteURL() + "/csw?Service=CSW&amp;version=2.0.2&amp;Request=GetRecordById&amp;outputschema=http://www.isotc211.org/2005/gmd&amp;elementSetName=full&amp;id=" + layer.uuid;
					String hRefLink =  dataMan.getSiteURL() + "/csw?Service=CSW&version=2.0.2&Request=GetRecordById&outputschema=http://www.isotc211.org/2005/gmd&elementSetName=full&id=" + layer.uuid;
					op.setAttribute("href", hRefLink, xlink);
				}

				
				root.addContent(op);
				
			}
		}

		
		return md;
	}

	
	/** 
     * Add metadata for a Layer/FeatureType/Coverage element of a GetCapabilities document.
     * This function search for a metadataUrl element (with @type = TC211 and format = text/xml) 
     * and try to load the XML document. 
     * If failed, then an XSLT is used for creating metadata from the 
     * Layer/FeatureType/Coverage element.
     * If loaded document contain an existing uuid, metadata will not be loaded in the catalogue.
     *  
     * @param layer     Layer/FeatureType/Coverage element
     * @param capa		GetCapabilities document
     *  
     * @return          uuid 
     *                   
     */
	private WxSLayerRegistry addLayerMetadata (Element layer, Element capa, boolean insertMetadata, List<String> nonExistingMetadata) throws JDOMException
	{
		
		DateFormat df 		= new SimpleDateFormat ("yyyy-MM-dd'T'HH:mm:ss");
		Date dt 			= new Date ();
		WxSLayerRegistry reg= new WxSLayerRegistry ();
		String schema;
		String mdXml;
		String date 		= df.format (dt);
		//--- Loading stylesheet
		String styleSheet 	= schemaMan.getSchemaDir(params.outputSchema) + 
								Geonet.Path.CONVERT_STYLESHEETS +
								"/OGCWxSGetCapabilitiesto19119/" + 
								"/OGC" +
								(params.ogctype.startsWith("WMTS") ? "WMS" : params.ogctype.substring(0,3)) + 
								"GetCapabilitiesLayer-to-19139.xsl";
		Element xml 		= null;
		
		String existingMdId;
		boolean loaded 		= false;
		
		if (params.ogctype.substring(0,3).equals("WMS")) {

			if (params.ogctype.substring(3,8).equals("1.3.0")) {
				Namespace wms = Namespace.getNamespace("http://www.opengis.net/wms");
				reg.name 	= layer.getChild ("Name", wms).getValue ();
			} else {
				reg.name 	= layer.getChild ("Name").getValue ();
			}
		} else if (params.ogctype.startsWith("WMTS")) {
			Namespace ows11 = Namespace.getNamespace("http://www.opengis.net/ows/1.1");
			Element identifierElement = layer.getChild("Identifier", ows11);
			if (identifierElement==null) {
				Namespace ows = Namespace.getNamespace("http://www.opengis.net/ows");
				identifierElement = layer.getChild("Identifier", ows);
			}
			reg.name = identifierElement.getValue();
		} else if (params.ogctype.substring(0,3).equals("WFS")) {
			Namespace wfs = Namespace.getNamespace("http://www.opengis.net/wfs");
			reg.name 	= layer.getChild ("Name", wfs).getValue ();
		} else if (params.ogctype.substring(0,3).equals("WCS")) {
			Namespace wcs = Namespace.getNamespace("http://www.opengis.net/wcs");
			reg.name 	= layer.getChild ("name", wcs).getValue ();
		} else if (params.ogctype.substring(0,3).equals("SOS")) {
			Namespace gml = Namespace.getNamespace("http://www.opengis.net/gml");
			reg.name 	= layer.getChild ("name", gml).getValue ();
		}
		
		log.info ("Loading layer: " + reg.name);
		
		//--- md5 the full capabilities URL + the layer, coverage or feature name
		reg.uuid = Util.scramble (this.capabilitiesUrl+"#"+reg.name); // the dataset identifier
	
		//--- Trying loading metadataUrl element
		if (params.useLayerMd && !params.ogctype.substring(0,3).equals("WMS")) {
			log.info("MetadataUrl harvester only supported for WMS layers.");
		}
		
		boolean bIsWMTS = params.ogctype.startsWith("WMTS");
		boolean bIsWMS = params.ogctype.substring(0,3).equals("WMS");
		boolean bIsWFS = params.ogctype.substring(0,3).equals("WFS");
		if (/*params.useLayerMd && */ bIsWMS || bIsWFS || bIsWMTS) {
			
			Namespace xlink 	= Namespace.getNamespace ("http://www.w3.org/1999/xlink");
			
			// Get metadataUrl xlink:href
			// TODO : add support for WCS & WFS metadataUrl element.

			Element onLineSrc = null;
			Element identifier = null;
			if (bIsWMTS) {
				identifier = getMetadataIdentifier(layer);
			} else {
				onLineSrc = getMetadataURL(layer, bIsWMS, bIsWFS);
			}
			
            if (onLineSrc != null || identifier!=null) {
				org.jdom.Attribute href = null;

				if (bIsWMS) {
					href = onLineSrc.getAttribute ("href", xlink);
				}

				if ((bIsWMS && href != null) || (bIsWFS && onLineSrc.getValue()!=null) || bIsWMTS) {
					if(log.isDebugEnabled()) log.debug("===Processing layer " + reg.name);
					mdXml = (bIsWMTS ? dataMan.getSiteURL() + "/csw?Service=CSW&version=2.0.2&Request=GetRecordById&outputschema=http://www.isotc211.org/2005/gmd&elementSetName=full&id=" + identifier.getValue() : (bIsWMS ? href.getValue() : onLineSrc.getValue()));
					try {
						GetRecordByIdRequest request = new GetRecordByIdRequest(this.context);
						request.setElementSetName(ElementSetName.FULL);
						request.setUrl(new URL(mdXml));
						request.setMethod(CatalogRequest.Method.GET);
						if (params.useAccount) {
							request.setCredentials(params.username, params.password);
						}	
//						xml = Xml.loadFile (new URL(mdXml));
//						xml = new XmlRequest(new URL(mdXml)).execute();
						if(log.isDebugEnabled()) log.debug("===Loading MetadataUrl " + mdXml);
						xml = request.execute();

                        // If url is CSW GetRecordById remove envelope
                        if (xml.getName().equals("GetRecordByIdResponse")) {
                            xml = (Element) xml.getChildren().get(0);
                        }

						schema = dataMan.autodetectSchema (xml); // ie. iso19115 or 139 or DC
						// Extract uuid from loaded xml document
						// FIXME : uuid could be duplicate if metadata already exist in catalog
						reg.uuid = dataMan.extractUUID(schema, xml);
						existingMdId = dataMan.getMetadataId(dbms, reg.uuid);
						
						if (existingMdId!=null) {
							Element md = dataMan.getMetadata(dbms,existingMdId);
							reg.mduuid = dataMan.extractMetadataUUID(dataMan.autodetectSchema (md), md);
/*
							String query = "INSERT INTO Relations (id, relatedId) " + "VALUES (?, ?)";
							dbms.execute(query, parentId, childId);
*/
//							log.warning("    Metadata uuid already exist in the catalogue. Metadata will not be loaded.");
							result.layerUuidExist ++;
							// FIXME : return null, service and metadata will not be linked by default.
//							return null;
						}
						
						if (schema == null) {
							log.warning("===Failed to detect schema from metadataUrl file. Use GetCapabilities document instead for that layer.");
							result.unknownSchema ++;
							loaded = false;
						} else { 
							log.info("===Load layer metadataUrl document ok: " + mdXml);
							
							loaded = true;
							result.layerUsingMdUrl ++;
						}
					// TODO : catch other exception
					}catch (Exception e) {
						log.error("  - Failed to load layer using metadataUrl attribute : " + e.getMessage());
						nonExistingMetadata.add(reg.name);
						loaded = false;
					}
				} else {
					log.info("  - No metadataUrl attribute with format text/xml found for that layer");
					nonExistingMetadata.add(reg.name);
					loaded = false;
				}
			} else {
				log.info("  - No OnlineResource found for that layer");
				nonExistingMetadata.add(reg.name);
				loaded = false;
			}
		}
		
		
		//--- using GetCapabilities document
		if (!loaded){
			try {
				//--- set XSL param to filter on layer and set uuid
				Map<String, String> param = new HashMap<String, String>();
				param.put("uuid", reg.uuid);
				param.put("Name", reg.name);
				param.put("lang", params.lang);
//				param.put("topic", params.topic);
				
				xml = Xml.transform (capa, styleSheet, param);
                if(log.isDebugEnabled()) log.debug("  - Layer loaded using GetCapabilities document.");
				
			} catch (Exception e) {
				log.warning("  - Failed to do XSLT transformation on Layer element : " + e.getMessage());
			}
		}
		
		
        if (insertMetadata) {
    		// Insert in db
    		try {

	            //
	            //  insert metadata
	            //
	            String userid = "1";
	            String group = null, isTemplate = null, docType = null, title = null, category = null;
	            boolean ufo = false, indexImmediate = false;
            
            	schema = dataMan.autodetectSchema (xml);
			
                reg.id = IDFactory.newID();
	            dataMan.insertMetadata(context, dbms, schema, xml, reg.id, reg.uuid, userid, group, params.uuid,
	                         isTemplate, docType, title, category, date, date, ufo, indexImmediate);
				
				xml = dataMan.updateFixedInfo(schema, reg.id, params.uuid, xml, null, DataManager.UpdateDatestamp.no, dbms, false);
				
				if(log.isDebugEnabled()) log.debug("    - Layer loaded in DB.");
				if(log.isDebugEnabled()) log.debug("    - Set Privileges and category.");
				addPrivileges(reg.id);
				if (params.datasetCategory!=null && !params.datasetCategory.equals(""))
					dataMan.setCategory (context, dbms, reg.id, params.datasetCategory);
				
				if(log.isDebugEnabled()) log.debug("    - Set Harvested.");
				dataMan.setHarvestedExt(dbms, reg.id, params.uuid, params.url); // FIXME : harvestUuid should be a MD5 string
			
				dbms.commit();
	
	            boolean workspace = false;
	            dataMan.indexMetadataGroup(dbms, reg.id, workspace, true);
			
				result.layer ++;
				log.info("  - metadata loaded with uuid: " + reg.uuid + "/internal id: " + reg.id);
			} catch (Exception e) {
				log.warning("  - Failed to load layer metadata : " + e.getMessage());
				result.unretrievable ++;
				return null;
			}
        }
		try {
			// Load bbox info for later use (eg. WMS thumbnails creation)
			Namespace gmd 	= Namespace.getNamespace("http://www.isotc211.org/2005/gmd");
			Namespace gco 	= Namespace.getNamespace("http://www.isotc211.org/2005/gco");
			
			Iterator<Element> bboxes = xml.getDescendants(
					new ElementFilter ("EX_GeographicBoundingBox", gmd)
					);
			
			while (bboxes.hasNext()) {
				Element box = bboxes.next();
				// FIXME : Could be null. Default bbox if from root layer
				reg.minx = Double.valueOf(box.getChild("westBoundLongitude", gmd).getChild("Decimal", gco).getText());
				reg.miny = Double.valueOf(box.getChild("southBoundLatitude", gmd).getChild("Decimal", gco).getText());
				reg.maxx = Double.valueOf(box.getChild("eastBoundLongitude", gmd).getChild("Decimal", gco).getText());
				reg.maxy = Double.valueOf(box.getChild("northBoundLatitude", gmd).getChild("Decimal", gco).getText());
				
			}
		}  catch (Exception e) {
            log.warning("  - Failed to extract layer bbox from metadata : " + e.getMessage());
        }

				
		return reg;
	}
	

	/** 
     * Call GeoNetwork service to load thumbnails and create small and 
     * big ones. 
     *  
     *  
     * @param layer   layer for which the thumbnail needs to be generated
     *                   
     */
	private void loadThumbnail (WxSLayerRegistry layer){
        if(log.isDebugEnabled())
		log.debug("  - Creating thumbnail for layer metadata: " + layer.name + " id: " + layer.id);
		Set s = new org.fao.geonet.services.thumbnail.Set ();
		
		try {
			String filename = getMapThumbnail(layer);
			
			if (filename != null) {
                if(log.isDebugEnabled()) log.debug("  - File: " + filename);
				
				Element par = new Element ("request");
				par.addContent(new Element ("id").setText(layer.id));
				par.addContent(new Element ("version").setText("10"));
				par.addContent(new Element ("type").setText("large"));
				
				Element fname = new Element ("fname").setText(filename);
				fname.setAttribute("content-type", "image/png");
				fname.setAttribute("type", "file");
				fname.setAttribute("size", "");
				
				par.addContent(fname);
				par.addContent(new Element ("add").setText("Add"));
				par.addContent(new Element ("createSmall").setText("on"));
				par.addContent(new Element ("smallScalingFactor").setText("180"));
				par.addContent(new Element ("smallScalingDir").setText("width"));
				
				// Call the services 
				s.execOnHarvest(par, context, dbms, dataMan);
				dbms.commit();
				result.thumbnails ++;
			} else
				result.thumbnailsFailed ++;
		} catch (Exception e) {
			log.warning("  - Failed to set thumbnail for metadata: " + e.getMessage());
			e.printStackTrace();
			result.thumbnailsFailed ++;
		}
		
	}
	
	/** 
     * Remove thumbnails directory for all metadata
     * FIXME : Do this only for existing one !
     *  
     * @param id   layer for which the thumbnail needs to be generated
     *                   
     */
	private void unsetThumbnail (String id){
        if(log.isDebugEnabled()) log.debug("  - Removing thumbnail for layer metadata: " + id);

		try {
			String file = Lib.resource.getDir(context, Params.Access.PUBLIC, id);
			FileCopyMgr.removeDirectoryOrFile(new File(file));
		} catch (Exception e) {
			log.warning("  - Failed to remove thumbnail for metadata: " + id + ", error: " + e.getMessage());
		}
	}

	/** 
     * Get the MetadataURL to be used for getting de identifier of the dataset
     *  
     * @param layer		layer xml element
     * @param bIsWMS	check for WMS harvesting
     * @param bIsWFS	check for WFS harvesting
	 * @throws JDOMException 
     *                   
     */
	private Element getMetadataURL (Element layer, boolean bIsWMS, boolean bIsWFS) throws JDOMException {
		Element onLineSrc = null;
        String dummyNsPrefix = "";
        boolean addNsPrefix = !layer.getNamespace().equals(Namespace.NO_NAMESPACE);
        if (addNsPrefix) dummyNsPrefix = "x:";
	    XPath mdUrlXPath = null;
	    String[] preferedFormatOrder = {"text/xml","application/xml","text/plain","text/html"};
	    for (String format : preferedFormatOrder)
	    {
		    if (bIsWMS) {
		    	mdUrlXPath = XPath.newInstance ("./" + dummyNsPrefix + "MetadataURL[(@type='TC211' or @type='FGDC' or @type='ISO19115:2005' or @type='ISO19115:2003') and " + dummyNsPrefix + "Format='" + format + "']/" + dummyNsPrefix + "OnlineResource");
		    } else if (bIsWFS) {
		    	mdUrlXPath = XPath.newInstance ("./" + dummyNsPrefix + "MetadataURL[(@type='TC211' or @type='FGDC' or @type='19115' or @type='19139') and " + dummyNsPrefix + "Format='" + format + "']");
		    }
		    if (addNsPrefix) mdUrlXPath.addNamespace("x", layer.getNamespace().getURI());
		    onLineSrc = (Element) mdUrlXPath.selectSingleNode (layer);
		    if (onLineSrc!=null) {
		    	break;
		    }
	    }
	    return onLineSrc;
	}

	/** 
     * Get the identifier
     *  
     * @param layer		layer xml element
	 * @throws JDOMException 
     *                   
     */
	private Element getMetadataIdentifier (Element layer) throws JDOMException {
		Element identifierElement = null;
        String dummyNsPrefix = "";
//        boolean addNsPrefix = !layer.getNamespace().equals(Namespace.NO_NAMESPACE);
//        if (addNsPrefix) dummyNsPrefix = "x:";
	    XPath identifierXPath = XPath.newInstance ("./ows:DatasetDescriptionSummary/ows:Identifier|./ows11:DatasetDescriptionSummary/ows11:Identifier");
//	    if (addNsPrefix) identifierXPath.addNamespace("x", layer.getNamespace().getURI());
	    identifierXPath.addNamespace("ows11", "http://www.opengis.net/ows/1.1");
	    identifierXPath.addNamespace("ows", "http://www.opengis.net/ows");
	    identifierElement = (Element) identifierXPath.selectSingleNode (layer); 
	    if (identifierElement==null) {
		    identifierXPath = XPath.newInstance ("./ows:Identifier|./ows11:Identifier");
//		    if (addNsPrefix) identifierXPath.addNamespace("x", layer.getNamespace().getURI());
		    identifierXPath.addNamespace("ows11", "http://www.opengis.net/ows/1.1");
		    identifierXPath.addNamespace("ows", "http://www.opengis.net/ows");
		    identifierElement = (Element) identifierXPath.selectSingleNode (layer); 
	    }
	    return identifierElement;
	}

	/** 
     * Load thumbnails making a GetMap operation.
     * Width is 300px. Ratio is computed for height using LatLongBoundingBoxElement.
     *  
     *  
     * @param layer   layer for which the thumbnail needs to be generated
     *                   
     */
	private String getMapThumbnail (WxSLayerRegistry layer) {
		String filename = layer.uuid + ".png";
		String dir = context.getUploadDir();
		Double r = WIDTH / 
						(layer.maxx - layer.minx) * 
						(layer.maxy - layer.miny);
		
		
        // Usual GetMap url tested with mapserver and geoserver
		// http://localhost:8080/geoserver/wms?service=WMS&request=GetMap&VERSION=1.1.1&
		// 		LAYERS=gn:world&WIDTH=200&HEIGHT=200&FORMAT=image/png&BBOX=-180,-90,180,90&STYLES=
		String url = 
        		getBaseUrl(params.url) +
        		"&SERVICE=" + params.ogctype.substring(0,params.ogctype.length() - 5) +
        		"&VERSION=" + params.ogctype.substring(params.ogctype.length() - 5) +
        		"&REQUEST=" + GETMAP + 
        		"&FORMAT=" + IMAGE_FORMAT + 
        		"&WIDTH=" + WIDTH +
        		"&SRS=EPSG:4326" + 
        		"&HEIGHT=" + r.intValue() +
        		"&LAYERS=" + layer.name + 
        		"&STYLES=" +
        		"&BBOX=" + 
        			layer.minx + "," +
        			layer.miny + "," +
        			layer.maxx + "," +
        			layer.maxy
        		;
		// All is in Lat/Long epsg:4326
		
		HttpClient httpclient = new HttpClient ();
        GetMethod req = new GetMethod (url);
		
        if(log.isDebugEnabled()) log.debug ("Retrieving remote document: " + url);

		// set proxy from settings manager
		Lib.net.setupProxy(context, httpclient);
		
		try {
		    // Connect
			int result = httpclient.executeMethod (req);
            if(log.isDebugEnabled()) log.debug("   Get " + result);

			if (result == 200) {
			    // Save image document to temp directory
				// TODO: Check OGC exception
                OutputStream fo = new FileOutputStream (dir + filename);
			    BinaryFile.copy (req.getResponseBodyAsStream(),
						    		fo, 
						    		true,
						    		true);
			} else {
				log.info (" Http error connecting");
				return null;
			}
		} catch (HttpException he) {
			log.info (" Http error connecting to '" + httpclient.toString() + "'");
			log.info (he.getMessage());
			return null;
		} catch (IOException ioe){
			log.info (" Unable to connect to '" + httpclient.toString() + "'");
			log.info (ioe.getMessage());
			return null;
		} finally {
		    // Release current connection to the connection pool once you are done
		    req.releaseConnection ();
		}
		
		return filename;
	}


    /**
     * Add categories according to harvesting configuration
     *   
     * @param id		GeoNetwork internal identifier
     * 
     */
	private void addCategories (String id) throws Exception
	{
		for(String catId : params.getCategories ())
		{
			String name = localCateg.getName (catId);

			if (name == null) {
                if(log.isDebugEnabled()) log.debug ("    - Skipping removed category with id:"+ catId);
			}else {
				dataMan.setCategory (context, dbms, id, catId);
			}
		}
	}

	/** 
     * Add privileges according to harvesting configuration
     *   
     * @param id		GeoNetwork internal identifier
     * 
     */
	private void addPrivileges (String id) throws Exception
	{
		for (Privileges priv : params.getPrivileges ())
		{
			String name = localGroups.getName( priv.getGroupId ());

			if (name == null) {
                if(log.isDebugEnabled()) log.debug ("    - Skipping removed group with id:"+ priv.getGroupId ());
			}
			else
			{
				for (String opId: priv.getOperations ()) {
					name = dataMan.getAccessManager().getPrivilegeName(opId);

					//--- allow only: view, dynamic, featured
					if (opId.equals("0") || opId.equals("5") || opId.equals("6"))
					{
						dataMan.setOperation(context, dbms, id, priv.getGroupId(), opId +"");
					}
					else
                    if(log.isDebugEnabled()) log.debug("       --> "+ name +" (skipped)");
				}
			}
		}
	}


	/** 
     * Add '?' or '&' if required to url so that parameters can just be 
     * appended to it 
     *   
     * @param url		Url to which parameters are going to be appended
     * 
     */
	private String getBaseUrl(String url) {
		if (url.endsWith("?")) {
			return url;
		} else if (url.contains("?")) {
			return url+"&";
		} else {
			return url+"?";
		}
	}

	//---------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//---------------------------------------------------------------------------

	private Logger         log;
	private ServiceContext context;
	private Dbms           dbms;
	private OgcWxSParams   params;
	private DataManager    dataMan;
	private SchemaManager  schemaMan;
	private CategoryMapper localCateg;
	private GroupMapper    localGroups;
    private OgcWxSResult   result;

    /**
	 * Store the GetCapabilities operation URL. This URL is scrambled
	 * and used to uniquelly identified the service. The idea of generating
	 * a uuid based on the URL instead of a randomuuid is to be able later
	 * to do an update of the service metadata (which could have been updated
	 * in the catalogue) instead of a delete/insert operation.
	 */
	private String capabilitiesUrl;
    private static final int WIDTH = 900;
	private static final String GETCAPABILITIES = "GetCapabilities";
	private static final String GETMAP = "GetMap";
    private static final String IMAGE_FORMAT = "image/png";
    private List<WxSLayerRegistry> layersRegistry = new ArrayList<WxSLayerRegistry>();
	
	private class WxSLayerRegistry {
		public String uuid;
		public String mduuid;
		public String id;
		public String name;
		public String url; 		// FIXME : if params.url is not the same as the GetMap Online link
		public Double minx = -180.0;
		public Double miny = -90.0;
		public Double maxx = 180.0;
		public Double maxy = 90.0;
	}

}

//=============================================================================

