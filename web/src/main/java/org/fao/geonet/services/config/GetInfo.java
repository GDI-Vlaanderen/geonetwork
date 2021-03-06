//=============================================================================
//===	Copyright (C) 2010 Food and Agriculture Organization of the
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
package org.fao.geonet.services.config;

import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.server.resources.Stats;
import jeeves.utils.TransformerFactoryFactory;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.jms.ClusterConfig;
import org.fao.geonet.jms.Producer;
import org.fao.geonet.jms.message.sysconfig.NodeConfigurations;
import org.fao.geonet.jms.message.sysconfig.SystemConfigurationMessage;
import org.fao.geonet.kernel.search.SearchManager;
import org.jdom.Element;

import javax.xml.transform.TransformerFactory;
import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;
import java.util.Set;

/**
 * Retrieve various type of information about the system (eg. Java version, XSLT
 * transformer factory, Lucene index properties). Usually these properties could not
 * be set from the web interface and some of them could be updated in configuration
 * file.
 *
 * @author francois
 *
 */
public class GetInfo implements Service {
    private HashMap<String, String> catProperties = new HashMap<String, String>();
    private HashMap<String, String> indexProperties = new HashMap<String, String>();
    private HashMap<String, String> systemProperties = new HashMap<String, String>();
    private HashMap<String, String> databaseProperties = new HashMap<String, String>();
    private SearchManager sm;
    private Dbms dbms;
    String appPath;

    final Properties properties = System.getProperties();

    public void init(String appPath, ServiceConfig params) throws Exception {
        this.appPath = appPath;
    }

    public Element exec(Element params, ServiceContext context)
            throws Exception {
        Element info;

        if(ClusterConfig.isEnabled()) {
            String clusterExecutionValue = params.getChildText("clusterExecution");
            boolean clusterExecution;
            if(StringUtils.isEmpty(clusterExecutionValue)) {
                clusterExecution = true;
            }
            else {
                clusterExecution = Boolean.parseBoolean(clusterExecutionValue);
            }
            if(clusterExecution) {
                synchronized(this) {
                    info = new Element("clusterinfo");

                    // clear existing cluster configuration
                    NodeConfigurations clusterConfiguration = NodeConfigurations.getInstance();
                    clusterConfiguration.clear();

                    // publish message to instruct peer nodes to populate cluster configuration
                    SystemConfigurationMessage message = new SystemConfigurationMessage();
                    message.setSenderClientID(ClusterConfig.getClientID());
                    Producer systemConfigurationProducer = ClusterConfig.get(Geonet.ClusterMessageTopic.SYSTEM_CONFIGURATION);
                    systemConfigurationProducer.produce(message);

                    // wait some time
                    long time0, time1;
                    time0 = System.currentTimeMillis();
                    do{
                        time1 = System.currentTimeMillis();
                    }
                    while( (time1 - time0) < 3 * 1000);

                    // return aggregated system configuration from each peer node that has responded.
                    Set<Element> nodeConfigs = clusterConfiguration.getNodeConfigurations();
                    for(Iterator<Element> i = nodeConfigs.iterator(); i.hasNext() ;  ) {
                        Element nodeConfig = i.next();
                        nodeConfig = (Element)nodeConfig.clone();
                        info.addContent(nodeConfig);
                    }
                    return info;
                }
            }
            else {
                return regularExecution(context);
            }
        }
        else {
            return regularExecution(context);
        }


    }


    private Element regularExecution(ServiceContext context) throws Exception {
        GeonetContext gc = (GeonetContext) context
                .getHandlerContext(Geonet.CONTEXT_NAME);
        sm = gc.getSearchmanager();
        dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

        String luceneDir = gc.getHandlerConfig().getMandatoryValue(
                Geonet.Config.LUCENE_DIR);
        loadSystemInfo();
        loadCatalogueInfo(gc);
        loadIndexInfo(luceneDir);
        loadDatabaseInfo(context);

        Element system = gc.getSettingManager().get("system", -1);

        // bizarre structure used by Settings XML representation
        Element nodeId = new Element("nodeId");
        Element value = new Element("value");
        value.setText(ClusterConfig.getClientID());
        nodeId.addContent(value);
        system.getChild("children").addContent(nodeId);

        Element main = new Element("main");
        addToElement(main, systemProperties);

        Element index = new Element("index");
        addToElement(index, indexProperties);

        Element cat = new Element("catalogue");
        addToElement(cat, catProperties);

        Element db = new Element("database");
        addToElement(db, databaseProperties);

        Element info = new Element("info");
        info.addContent(system);
        info.addContent(cat);
        info.addContent(main);
        info.addContent(index);
        info.addContent(db);

        return info;
    }


    /**
     * Load catalogue properties
     *
     * @param gc
     */
    private void loadCatalogueInfo(GeonetContext gc) {
        ServiceConfig sc = gc.getHandlerConfig();
        String[] props = {Geonet.Config.DATA_DIR, Geonet.Config.CODELIST_DIR, Geonet.Config.CONFIG_DIR,
                Geonet.Config.SCHEMAPLUGINS_DIR, Geonet.Config.SUBVERSION_PATH, Geonet.Config.RESOURCES_DIR};
        for (String prop : props) {
            catProperties.put("data." + prop, sc.getValue(prop));
        }
    }


    /**
     * Compute information about the current system.
     */
    private void loadSystemInfo() {
        systemProperties.put("java.version",
                properties.getProperty("java.version"));
        systemProperties.put("java.vm.name",
                properties.getProperty("java.vm.name"));
        systemProperties.put("java.vm.vendor",
                properties.getProperty("java.vm.vendor"));

        systemProperties.put("os.name", properties.getProperty("os.name"));
        systemProperties.put("os.arch", properties.getProperty("os.arch"));

        try {
            TransformerFactory transFact = TransformerFactoryFactory.getTransformerFactory();
            systemProperties.put("xslt.factory", transFact.getClass().getName());
        } catch (Exception e) {
            systemProperties.put("xslt.factory", "Exception:" + e.getMessage());
        }

        long freeMem = Runtime.getRuntime().freeMemory() / 1024;
        long totMem = Runtime.getRuntime().totalMemory() / 1024;
        systemProperties.put("mem.free", "" + freeMem);
        systemProperties.put("mem.total", "" + totMem);

    }

    /**
     * Compute information about Lucene index.
     *
     * @param luceneDir
     */
    private void loadIndexInfo(String luceneDir) {
        indexProperties.put("index.path", luceneDir);
        File dir = new File(luceneDir);
        File lDir = new File(luceneDir + SearchManager.NON_SPATIAL_DIR);
        if (dir.exists()) {
            long size = FileUtils.sizeOfDirectory(dir) / 1024;
            indexProperties.put("index.size", "" + size); // lucene + Shapefile
            // if exist
            if (lDir.exists()) {
                size = FileUtils.sizeOfDirectory(lDir) / 1024;
                indexProperties.put("index.size.lucene", "" + size);
            }
        }
        indexProperties.put("index.lucene.config", sm.getCurrentLuceneConfiguration().toString());
    }

    /**
     * Compute information about database.
     *
     * @param context
     */
    private void loadDatabaseInfo(ServiceContext context) {
        String dbURL = dbms.getURL();
        databaseProperties.put("db.url", dbURL);

        Dbms dbms = null;
        try {
            dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
            databaseProperties.put("db.openattempt", "Database Opened Successfully");
        } catch (Exception e) {
            databaseProperties.put("db.openattempt", "Failed to open database connection, Check config.xml db file configuration. Error is: " + e.getMessage());
        }

        try {
            Stats dbStats = context.getResourceManager().getStats(Geonet.Res.MAIN_DB);
            databaseProperties.put("db.numactive", Integer.toString(dbStats.numActive));
            databaseProperties.put("db.numidle", Integer.toString(dbStats.numIdle));
            databaseProperties.put("db.maxactive", Integer.toString(dbStats.maxActive));
        } catch (Exception e) {
            databaseProperties.put("db.statserror", "Failed to get stats on database connections. Error is: "+e.getMessage());
        }
    }


    /**
     * Add HashMap content to an Element.
     *
     * @param el
     * @param h
     */
    private void addToElement(Element el, HashMap<String, String> h) {
        for (String key : h.keySet()) {
            el.addContent(new Element(key).setText(h.get(key)));
        }
    }
}
