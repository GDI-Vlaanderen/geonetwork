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

import static org.quartz.JobKey.jobKey;

import java.lang.reflect.Method;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import jeeves.exceptions.BadInputEx;
import jeeves.exceptions.BadParameterEx;
import jeeves.exceptions.JeevesException;
import jeeves.exceptions.OperationAbortedEx;
import jeeves.interfaces.Logger;
import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import jeeves.server.resources.ResourceManager;
import jeeves.utils.Log;
import jeeves.utils.QuartzSchedulerUtils;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.jms.ClusterConfig;
import org.fao.geonet.jms.ClusterException;
import org.fao.geonet.jms.Producer;
import org.fao.geonet.jms.message.harvest.HarvestMessage;
import org.fao.geonet.jms.message.harvest.HarvesterActivateMessage;
import org.fao.geonet.jms.message.harvest.HarvesterDeactivateMessage;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MetadataIndexerProcessor;
import org.fao.geonet.kernel.harvest.Common.OperResult;
import org.fao.geonet.kernel.harvest.Common.Status;
import org.fao.geonet.kernel.harvest.harvester.csw.CswHarvester;
import org.fao.geonet.kernel.harvest.harvester.geonet.GeonetHarvester;
import org.fao.geonet.kernel.harvest.harvester.geonet20.Geonet20Harvester;
import org.fao.geonet.kernel.harvest.harvester.localfilesystem.LocalFilesystemHarvester;
import org.fao.geonet.kernel.harvest.harvester.oaipmh.OaiPmhHarvester;
import org.fao.geonet.kernel.harvest.harvester.ogcwxs.OgcWxSHarvester;
import org.fao.geonet.kernel.harvest.harvester.thredds.ThreddsHarvester;
import org.fao.geonet.kernel.harvest.harvester.webdav.WebDavHarvester;
import org.fao.geonet.kernel.harvest.harvester.wfsfeatures.WfsFeaturesHarvester;
import org.fao.geonet.kernel.harvest.harvester.z3950.Z3950Harvester;
import org.fao.geonet.kernel.harvest.harvester.z3950Config.Z3950ConfigHarvester;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.monitor.harvest.AbstractHarvesterErrorCounter;
import org.fao.geonet.util.ISODate;
import org.jdom.Element;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;

//=============================================================================

public abstract class AbstractHarvester
{
    private static final String SCHEDULER_ID = "abstractHarvester";
    public static final String HARVESTER_GROUP_NAME = "HARVESTER_GROUP_NAME";

	//---------------------------------------------------------------------------
	//---
	//--- Static API methods
	//---
	//---------------------------------------------------------------------------

	public static void staticInit(ServiceContext context) throws Exception
	{
		register(context, GeonetHarvester  .class);
		register(context, Geonet20Harvester.class);
		register(context, WebDavHarvester  .class);
		register(context, CswHarvester     .class);
		register(context, Z3950Harvester   .class);
		register(context, Z3950ConfigHarvester   .class);
		register(context, OaiPmhHarvester  .class);
		register(context, OgcWxSHarvester  .class);
		register(context, ThreddsHarvester .class);
		register(context, LocalFilesystemHarvester	.class);
		register(context, WfsFeaturesHarvester  .class);
		register(context, LocalFilesystemHarvester      .class);
	}

	//---------------------------------------------------------------------------

	private static void register(ServiceContext context, Class<?> harvester) throws Exception
	{
		try
		{
			Method initMethod = harvester.getMethod("init", context.getClass());
			initMethod.invoke(null, context);

			AbstractHarvester ah = (AbstractHarvester) harvester.newInstance();

			hsHarvesters.put(ah.getType(), harvester);
		}
		catch(Exception e)
		{
			throw new Exception("Cannot register harvester : "+harvester, e);
		}
	}

	//---------------------------------------------------------------------------

	public static AbstractHarvester create(String type, ServiceContext context,
														SettingManager sm, DataManager dm)
														throws BadParameterEx, OperationAbortedEx
	{
		//--- raises an exception if type is null

		if (type == null)
			throw new BadParameterEx("type", type);

		Class<?> c = hsHarvesters.get(type);

		if (c == null)
			throw new BadParameterEx("type", type);

		try
		{
			AbstractHarvester ah = (AbstractHarvester) c.newInstance();

			ah.context    = context;
			ah.settingMan = sm;
			ah.dataMan    = dm;
			return ah;
		}
		catch(Exception e)
		{
			throw new OperationAbortedEx("Cannot instantiate harvester", e);
		}
	}


	//--------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//--------------------------------------------------------------------------

    /**
     *
     * @param dbms
     * @param node
     * @throws BadInputEx
     * @throws SQLException
     */
	public void add(Dbms dbms, Element node) throws BadInputEx, SQLException {
		status   = Status.INACTIVE;
		error    = null;
		id       = doAdd(dbms, node);
        nodeId = ClusterConfig.getClientID();
	}

    /**
     *
     * @param node
     * @throws BadInputEx
     */
	public void init(Element node) throws BadInputEx, SchedulerException {
		id       = node.getAttributeValue("id");
		status = Status.parse(node.getChild("options").getChildText("status"));
		error    = null;
        nodeId = node.getChild("site").getChildText("nodeId");

        //--- init harvester

		doInit(node);

		if (status == Status.ACTIVE) {
		    doSchedule();
		}
	}

    private void doSchedule() throws SchedulerException {
    	Scheduler scheduler = getScheduler();
    	if(ClusterConfig.isEnabled()) {
            if (getNodeId().equals(ClusterConfig.getClientID())) {
                JobDetail jobDetail = getParams().getJob();
                Trigger trigger = getParams().getTrigger();
                if (scheduler.checkExists(jobDetail.getKey())) {
            		scheduler.deleteJob(jobDetail.getKey());
                }
            	scheduler.scheduleJob(jobDetail, trigger);
            } else {
                try {
                	HarvesterActivateMessage message = new HarvesterActivateMessage();
                    message.setId(getID());
                    message.setSenderClientID(ClusterConfig.getClientID());
                    Producer harvesterProducer = ClusterConfig.get(Geonet.ClusterMessageTopic.HARVESTER_ACTIVATE);
                    harvesterProducer.produce(message);
                }
                catch (ClusterException x) {
                    Log.error(Geonet.HARVESTER, x.getMessage());
                    x.printStackTrace();
                }
            }
    	} else {
    		if (context.getServlet().getStartHarvesterJobs().equals("1")) {
	    		JobDetail jobDetail = getParams().getJob();
	            Trigger trigger = getParams().getTrigger();
	            if (scheduler.checkExists(jobDetail.getKey())) {
	        		scheduler.deleteJob(jobDetail.getKey());
	            }
	           	scheduler.scheduleJob(jobDetail, trigger);
    		}
    	}
    }

    private void doUnschedule() throws SchedulerException {
		String scheduletime = new ISODate(System.currentTimeMillis()).toString();
		String nodeName = getParams().name +" ("+ getClass().getSimpleName() +")";
    	if(ClusterConfig.isEnabled()) {
            if (getNodeId().equals(ClusterConfig.getClientID())) {
            	System.out.println("Unscheduling harvester with uuid " + getParams().uuid + " at " + scheduletime + " on node " + nodeName  + " with id " + getNodeId());
        		getScheduler().deleteJob(jobKey(getParams().uuid, HARVESTER_GROUP_NAME));
            } else {
                try {
                	HarvesterDeactivateMessage message = new HarvesterDeactivateMessage();
                    message.setId(getID());
                    message.setSenderClientID(ClusterConfig.getClientID());
                    Producer harvesterProducer = ClusterConfig.get(Geonet.ClusterMessageTopic.HARVESTER_DEACTIVATE);
                    harvesterProducer.produce(message);
                }
                catch (ClusterException x) {
                    Log.error(Geonet.HARVESTER, x.getMessage());
                    x.printStackTrace();
                }
            }
    	} else {
        	System.out.println("Unscheduling harvester with uuid " + getParams().uuid + " at " + scheduletime + " on node " + nodeName  + " with id " + getNodeId());
    		getScheduler().deleteJob(jobKey(getParams().uuid, HARVESTER_GROUP_NAME));
    	}
    }

    public static Scheduler getScheduler() throws SchedulerException {
        return QuartzSchedulerUtils.getScheduler(SCHEDULER_ID,true);
	}

    /**
     * Called when the application is shutdown.
     */
	public void shutdown()throws SchedulerException {
		getScheduler().deleteJob(jobKey(getParams().uuid, HARVESTER_GROUP_NAME));
	}

    public static void shutdownScheduler() throws SchedulerException {
        getScheduler().shutdown(false);
    }

    /**
     * Called when the harvesting entry is removed from the system. It is used to remove harvested metadata.
     * @param dbms
     * @throws Exception
     */
	public synchronized void destroy(Dbms dbms) throws Exception {

                doUnschedule();

		//--- remove all harvested metadata

		String getQuery = "SELECT id FROM Metadata WHERE harvestUuid=?";

		for (Object o : dbms.select(getQuery, getParams().uuid).getChildren()) {
			Element el = (Element) o;
			String  id = el.getChildText("id");

			dataMan.deleteMetadata(context, dbms, id);
//			dbms.commit();
		}

		doDestroy(dbms);
	}

    /**
     *
     * @param dbms
     * @return
     * @throws SQLException
     */
	public synchronized OperResult start(Dbms dbms) throws SQLException, SchedulerException {
/*
		if (status != Status.INACTIVE) {
            return OperResult.ALREADY_ACTIVE;
        }
*/
        // if clustering is enabled, the periodic execution does not run the harvester but rather sends a message that
        // any of the peer GN nodes can pick up; one node (the first to get the message) will actually run the
        // harvester. Therefore, set status to ACTIVE only if we're NOT clustering, otherwise the message handler that
        // does HarvestManager.invoke() won't really run the harvester because its status is already active.
        if(!ClusterConfig.isEnabled()) {
            settingMan.setValue(dbms, "harvesting/id:"+id+"/options/status", Status.ACTIVE);
            status = Status.ACTIVE;
        }
        else {
            settingMan.setValue(dbms, "harvesting/id:"+id+"/options/status", Status.ACTIVE);
            status = Status.ACTIVE;
        }

		error = null;
		doSchedule();

		return OperResult.OK;
	}

    /**
     *
     * @param dbms
     * @return
     * @throws SQLException
     */
	public synchronized OperResult stop(Dbms dbms) throws SQLException, SchedulerException {
/*
		if (status != Status.ACTIVE)
			return OperResult.ALREADY_INACTIVE;
*/
		settingMan.setValue(dbms, "harvesting/id:"+id+"/options/status", Status.INACTIVE);

		doUnschedule();
		status = Status.INACTIVE;

		return OperResult.OK;
	}

    /**
     *
     * @param dbms
     * @return
     * @throws SQLException
     */
	public synchronized OperResult run(Dbms dbms) throws SQLException, SchedulerException, Exception {
		if (running) {
            return OperResult.ALREADY_RUNNING;
        }

		if (status == Status.INACTIVE) {
            start(dbms);
        }

    	ResourceManager rm = new ResourceManager(context.getMonitorManager(), context.getProviderManager());
        Dbms dbms2 = (Dbms) rm.openDirect(Geonet.Res.MAIN_DB);
        boolean bException = false;
        try {

        	String lastRun = new ISODate(System.currentTimeMillis()).toString();
			Map<String, Object> values = new HashMap<String, Object>();
//			values.put("harvesting/id:"+ id +"/info/lastRun", lastRun);
			values.put("harvesting/id:"+ id +"/info/clusterRunning", "true");
			settingMan.setValues(dbms2, values);
        // Set clusterRunning = true before send harvest message to avoid issues with ClusterConfig (see SettingManager.setValues finally block)
	        if(ClusterConfig.isEnabled() && !getNodeId().equals(ClusterConfig.getClientID())) {
	            try {
	                Log.info(Geonet.HARVESTER, "clustering enabled, creating harvest message");
	                HarvestMessage message = new HarvestMessage();
	                message.setId(getID());
	                message.setSenderClientID(ClusterConfig.getClientID());
	                Producer harvestProducer = ClusterConfig.get(Geonet.ClusterMessageQueue.HARVEST);
	                harvestProducer.produce(message);
	        		return OperResult.OK;
	            }
	            catch (ClusterException x) {
	                System.err.println(x.getMessage());
	                x.printStackTrace();
	                // todo what ?
	            }
	        } else {
        		getScheduler().triggerJob(jobKey(getParams().uuid, HARVESTER_GROUP_NAME));
        		return OperResult.OK;
	        }
    	} catch (Exception e) {
        	bException = true;
            e.printStackTrace();
            if (dbms2 != null) {
                try {
                	rm.abort(Geonet.Res.MAIN_DB, dbms2);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (!bException && dbms2 != null) {
                try {
                    rm.close(Geonet.Res.MAIN_DB, dbms2);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
		}
		return OperResult.ERROR;
	}

	//--------------------------------------------------------------------------

	public synchronized OperResult invoke(ResourceManager rm) {
        running  = true;
        System.out.println("** HARVESTER INVOKE");
		// Cannot do invoke if this harvester was started (iei active)
        if(!ClusterConfig.isEnabled()) {
            if (status != Status.INACTIVE) {
                return OperResult.ALREADY_ACTIVE;
            }
        }
		Logger logger = Log.createLogger(Geonet.HARVESTER);
		String nodeName = getParams().name +" ("+ getClass().getSimpleName() +")";
		OperResult result = OperResult.OK;

		try {
			if(ClusterConfig.isEnabled()) {
                status = Status.ACTIVE;
                }
            else {
                status = Status.ACTIVE;
            }
            System.out.println("Started harvesting at " + (new Date()).toString() +  " from node : " + nodeName);
            HarvestWithIndexProcessor h = new HarvestWithIndexProcessor(dataMan, logger, rm);
            h.processWithFastIndexing();
            System.out.println("Ended harvesting at " + (new Date()).toString() +  " from node : " + nodeName);

			rm.close();
		}
		catch(Throwable t) {
                        context.getMonitorManager().getCounter(AbstractHarvesterErrorCounter.class).inc();
			result = OperResult.ERROR;
			logger.warning("Raised exception while harvesting from : "+ nodeName);
			logger.warning(" (C) Class   : "+ t.getClass().getSimpleName());
			logger.warning(" (C) Message : "+ t.getMessage());
			error = t;
			t.printStackTrace();

			try
			{
				rm.abort();
			}
			catch (Exception ex)
			{
				logger.warning("CANNOT ABORT EXCEPTION");
				logger.warning(" (C) Exc : "+ ex);
			}
		}
        finally {
	        running  = false;
			status = Status.INACTIVE;
		}

		return result;
	}

    /**
     *
     * @param dbms
     * @param node
     * @throws BadInputEx
     * @throws SQLException
     */
	public synchronized void update(Dbms dbms, Element node) throws BadInputEx, SQLException, SchedulerException
	{
		boolean reschedule = false;
		if (status == Status.ACTIVE) {
			reschedule = true;
		}

		doUnschedule();

		doUpdate(dbms, id, node);

		error      = null;

		if (reschedule) {
			status = Status.ACTIVE;
			doSchedule();
		}
	}

	//--------------------------------------------------------------------------

	public String getID() { return id; }


    /**
     * Adds harvesting result information to each harvesting entry.
     * @param node
     */
	public void addInfo(Element node) {
		Element info = node.getChild("info");

		//--- 'running'

    	info.removeChild("clusterRunning");
        if (ClusterConfig.isEnabled()) {
        	if (getNodeId().equals(ClusterConfig.getClientID())) {
                info.addContent(new Element("clusterRunning").setText(running+""));
        	} else {
                info.addContent(new Element("clusterRunning").setText(settingMan.getValueAsBool("harvesting/id:"+id+"/info/clusterRunning")+""));
        	}
        } else {
            info.addContent(new Element("running").setText(running+""));
        }

		//--- harvester specific info

		doAddInfo(node);

		//--- add error information

		if (error != null)
			node.addContent(JeevesException.toElement(error));
	}

    /**
     * Adds harvesting information to each metadata element. Some sites can generate url for thumbnails.
     * @param info
     * @param id
     * @param uuid
     */
	public void addHarvestInfo(Element info, String id, String uuid) {
		info.addContent(new Element("type").setText(getType()));
	}

	//---------------------------------------------------------------------------
	//---
	//--- Package methods (called by Executor)
	//---
	//---------------------------------------------------------------------------

    /**
     * Nested class to handle harvesting with fast indexing.
     */
	public class HarvestWithIndexProcessor extends MetadataIndexerProcessor {
		ResourceManager rm;
		Logger logger;

		public HarvestWithIndexProcessor(DataManager dm, Logger logger, ResourceManager rm) {
			super(dm);
			this.logger = logger;
			this.rm = rm;
		}

		@Override
		public void process() throws Exception {
			String nodeName = getParams().name +" ("+ getClass().getSimpleName() +")";

			error = null;

			String lastRun = new ISODate(System.currentTimeMillis()).toString();

			boolean bException = false;
			Dbms dbms = null;
			try
			{
				dbms = (Dbms) rm.open(Geonet.Res.MAIN_DB);
				//--- update lastRun
				Map<String, Object> values = new HashMap<String, Object>();
				values.put("harvesting/id:"+ id +"/info/lastRun", lastRun);
				values.put("harvesting/id:"+ id +"/info/clusterRunning", "true");
				settingMan.setValues(dbms, values);
            	System.out.println("Started harvester with uuid " + getParams().uuid + " at " + lastRun + " on node " + nodeName  + " with id " + getNodeId());
            	doHarvest(logger, rm);
            } catch (Exception ex) {
            	error = ex;
                throw ex;
            } finally {
                if(ClusterConfig.isEnabled()) {
                    try {
                    	settingMan.setValue(dbms, "harvesting/id:"+id+"/info/clusterRunning", "false") ;
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            	System.out.println("Ended harvester with uuid " + getParams().uuid + " at " + lastRun + " on node " + nodeName  + " with id " + getNodeId());
				Dbms dbms2 = null;
				try {
					dbms2 = (Dbms) rm.openDirect(Geonet.Res.MAIN_DB);
					if (getParams().oneRunOnly)
						stop(dbms2);
					Element result = getResult();
					if (error != null) result = JeevesException.toElement(error);
					HarvesterHistoryDao.write(dbms2, getType(), getParams().name, getParams().uuid, lastRun, getParams().node, result);
		        } catch (Exception e) {
		        	bException = true;
					logger.warning("Raised exception while attempting to store harvest history from : "+ nodeName);
					e.printStackTrace();
					logger.warning(" (C) Exc   : "+ e);
		            if (dbms2 != null) {
		            	try {
			            	context.getResourceManager().abort(Geonet.Res.MAIN_DB, dbms2);
						} catch (Exception dbe) {
							dbe.printStackTrace();
							logger.error("Raised exception while attempting to ABORT dbms connection to harvest history table");
							logger.error(" (C) Exc   : "+ dbe);
						}
		            }
		        } finally {
		            if (!bException && dbms2 != null) {
						try {
							rm.close(Geonet.Res.MAIN_DB, dbms2);
						} catch (Exception dbe) {
							dbe.printStackTrace();
							logger.error("Raised exception while attempting to close dbms connection to harvest history table");
							logger.error(" (C) Exc   : "+ dbe);
						}
		            }
		        }
            }
		}
	}

    /**
     *
     */
	void harvest() {
	    running = true;
    	ResourceManager rm = new ResourceManager(context.getMonitorManager(), context.getProviderManager());
		Logger logger = Log.createLogger(Geonet.HARVESTER);
	    boolean bException = false;
	    try {
			HarvestWithIndexProcessor h = new HarvestWithIndexProcessor(dataMan, logger, rm);
			h.processWithFastIndexing();
	    } catch(Throwable t) {
	    	bException = true;
			try{
				rm.abort();
			}
			catch (Exception ex)
			{
				logger.warning("CANNOT ABORT EXCEPTION");
				logger.warning(" (C) Exc : "+ ex);
			}
        } finally {
            if (!bException) {
				try {
	            	rm.close();
				} catch (Exception dbe) {
					dbe.printStackTrace();
					logger.error("Raised exception while attempting to close dbms connection to settings table");
					logger.error(" (C) Exc   : "+ dbe);
				}
            }
	        running  = false;
	    }
	}

	//---------------------------------------------------------------------------
	//---
	//--- Abstract methods that must be overridden
	//---
	//---------------------------------------------------------------------------

	public abstract String getType();

	public abstract AbstractParams getParams();

	protected abstract void doInit(Element entry) throws BadInputEx;

	protected abstract void doDestroy(Dbms dbms) throws SQLException;

	protected abstract String doAdd(Dbms dbms, Element node)
											throws BadInputEx, SQLException;

	protected abstract void doUpdate(Dbms dbms, String id, Element node)
											throws BadInputEx, SQLException;

	protected abstract Element getResult();

	protected abstract void doAddInfo(Element node);
	protected abstract void doHarvest(Logger l, ResourceManager rm) throws Exception;

	//---------------------------------------------------------------------------
	//---
	//--- Protected storage methods
	//---

    /**
     *
     * @param dbms
     * @param params
     * @param path
     * @throws SQLException
     */
	protected void storeNode(Dbms dbms, AbstractParams params, String path) throws SQLException {
		String siteId    = settingMan.add(dbms, path, "site",    "", false);
		String optionsId = settingMan.add(dbms, path, "options", "", false);
		String infoId    = settingMan.add(dbms, path, "info",    "", false);
		String contentId = settingMan.add(dbms, path, "content", "", false);

		//--- setup site node ----------------------------------------

		settingMan.add(dbms, "id:"+siteId, "name",     params.name, false);
		settingMan.add(dbms, "id:"+siteId, "uuid",     params.uuid, false);

        settingMan.add(dbms, "id:"+siteId, "nodeId", StringUtils.isNotBlank(getNodeId()) ? getNodeId() : ClusterConfig.getClientID(), false);

		String useAccId = settingMan.add(dbms, "id:"+siteId, "useAccount", params.useAccount, false);

		settingMan.add(dbms, "id:"+useAccId, "username", params.username, false);
		settingMan.add(dbms, "id:"+useAccId, "password", params.password, false);

		//--- setup options node ---------------------------------------

		settingMan.add(dbms, "id:"+optionsId, "every",      params.every, false);
		settingMan.add(dbms, "id:"+optionsId, "oneRunOnly", params.oneRunOnly, false);
		settingMan.add(dbms, "id:"+optionsId, "status",     status, false);

		//--- setup content node ---------------------------------------

		settingMan.add(dbms, "id:"+contentId, "importxslt", params.importXslt, false);
		settingMan.add(dbms, "id:"+contentId, "validate",   params.validate, false);

        storeSchematrons(dbms, params, "id:"+contentId) ;

		//--- setup stats node ----------------------------------------

		settingMan.add(dbms, "id:"+infoId, "lastRun", "", false);
		settingMan.add(dbms, "id:"+infoId, "clusterRunning", "", false);

		//--- store privileges and categories ------------------------

		storePrivileges(dbms, params, path);
		storeCategories(dbms, params, path);

		storeNodeExtra(dbms, params, path, siteId, optionsId);
	}

    /**
     * Override this method with an empty body to avoid schematrons storage.
     * @param dbms
     * @param params
     * @param path
     * @throws SQLException
     */
    protected void storeSchematrons(Dbms dbms, AbstractParams params, String path) throws SQLException {
        String schematronsId = settingMan.add(dbms, path, "schematrons", "", false);

        for (Schematron s : params.getSchematrons()) {
            String schematronId = settingMan.add(dbms, "id:"+ schematronsId, "schematron", "", false);

            settingMan.add(dbms, "id:"+ schematronId, "schemaId", s.getSchemaId(), false);
            settingMan.add(dbms, "id:"+ schematronId, "schematron", s.getSchematron(), false);

        }
    }

    /**
     * Override this method with an empty body to avoid privileges storage.
     * @param dbms
     * @param params
     * @param path
     * @throws SQLException
     */
	protected void storePrivileges(Dbms dbms, AbstractParams params, String path) throws SQLException {
		String privId = settingMan.add(dbms, path, "privileges", "", false);

		for (Privileges p : params.getPrivileges()) {
			String groupId = settingMan.add(dbms, "id:"+ privId, "group", p.getGroupId(), false);
			for (String oper : p.getOperations())
				settingMan.add(dbms, "id:"+ groupId, "operation", oper, false);
		}
	}

    /**
     * Override this method with an empty body to avoid categories storage.
     * @param dbms
     * @param params
     * @param path
     * @throws SQLException
     */
    protected void storeCategories(Dbms dbms, AbstractParams params, String path) throws SQLException {
		String categId = settingMan.add(dbms, path, "categories", "", false);

		for (String id : params.getCategories())
			settingMan.add(dbms, "id:"+ categId, "category", id, false);
	}

    /**
     * Override this method to store harvesting node's specific settings.
     * @param dbms
     * @param params
     * @param path
     * @param siteId
     * @param optionsId
     * @throws SQLException
     */
	protected void storeNodeExtra(Dbms dbms, AbstractParams params, String path, String siteId, String optionsId) throws SQLException {}

    /**
     *
     * @param values
     * @param path
     * @param el
     * @param name
     */
	protected void setValue(Map<String, Object> values, String path, Element el, String name) {
		if (el == null)
			return ;

		String value = el.getChildText(name);

		if (value != null)
			values.put(path, value);
	}

	//---------------------------------------------------------------------------

	protected void add(Element el, String name, int value)
	{
		el.addContent(new Element(name).setText(Integer.toString(value)));
	}

	//--------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//--------------------------------------------------------------------------


    public String getNodeId() {
        return nodeId;
    }

    private String id;
	private Status status;

	private Throwable error;
        private boolean running = false;
    private String nodeId;

	protected ServiceContext context;
	protected SettingManager settingMan;
	protected DataManager    dataMan;

	private static Map<String, Class> hsHarvesters = new HashMap<String, Class>();
}
