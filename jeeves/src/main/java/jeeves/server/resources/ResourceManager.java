//=============================================================================
//===	Copyright (C) 2001-2005 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This library is free software; you can redistribute it and/or
//===	modify it under the terms of the GNU Lesser General Public
//===	License as published by the Free Software Foundation; either
//===	version 2.1 of the License, or (at your option) any later version.
//===
//===	This library is distributed in the hope that it will be useful,
//===	but WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//===	Lesser General Public License for more details.
//===
//===	You should have received a copy of the GNU Lesser General Public
//===	License along with this library; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: GeoNetwork@fao.org
//==============================================================================

package jeeves.server.resources;

import java.util.HashMap;
import java.util.Map;

import jeeves.monitor.MonitorManager;
import jeeves.monitor.ResourceTracker;
import jeeves.monitor.timer.ResourceManagerResourceIsOpenTimer;
import jeeves.monitor.timer.ResourceManagerWaitForResourceTimer;
import jeeves.utils.Log;

import org.geotools.data.DataStore;

import com.google.common.collect.Multimap;
import com.yammer.metrics.core.Timer;
import com.yammer.metrics.core.TimerContext;

//=============================================================================

/** 
 * This class contains all resources that a service can access and delivers them
 * on demand. Resource identifier depends on provider name and thread identifier
 * in order to not to share a same resource between two different threads.
 */
public class ResourceManager
{
	private ProviderManager provManager;

	private HashMap<String, Object> htResources = new HashMap<String, Object>(10, .75f);

    private Timer resourceManagerWaitForResourceTimer;
    private Timer resourceManagerResourceIsOpenTimer;

	private ResourceTracker resourceTracker;

    //--------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//--------------------------------------------------------------------------

	public ResourceManager(MonitorManager monitorManager, ProviderManager pm)
	{
		provManager = pm;
        this.resourceManagerWaitForResourceTimer = monitorManager.getTimer(ResourceManagerWaitForResourceTimer.class);
        this.resourceManagerResourceIsOpenTimer = monitorManager.getTimer(ResourceManagerResourceIsOpenTimer.class);
        this.resourceTracker = monitorManager.getResourceTracker();
	}

	//--------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//--------------------------------------------------------------------------

	/** 
	 * Gets a resource, querying the appropriate resource provider - records
	 * the resource so that when the resourcemanager is closed the resource 
	 * will be too - This is the call used by Jeeves
	 *
	 * @param name The name of the Resource Provider to query
	 */
	public synchronized Object open(String name) throws Exception
	{

		String resourceId = name + ":" + Thread.currentThread().getId();
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug (Log.RESOURCES, "Opening: " + resourceId + " RESOURCEMANAGER: " + this.hashCode());
        }

		Object resource = htResources.get(resourceId);
		boolean bExisting = true;
		if (resource == null) {
			bExisting = false;
			ResourceProvider provider = provManager.getProvider(name);

            TimerContext timingContext = resourceManagerWaitForResourceTimer.time();
            try {
            	if(Log.isDebugEnabled(Log.RESOURCES)) {
                    Log.debug(Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-");
            	}
			    resource = provider.open();
            } finally {
                timingContext.stop();
            }

			if (resource != null) {
				htResources.put(resourceId, resource);
				//htResources.put(provider.getName(), resource);
                openMetrics(resource);
            }
		}
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug  (Log.RESOURCES, "Connection ready to use: " + resourceId + " " + resource.hashCode() + " RESOURCEMANAGER: " + this.hashCode());
        }

        resourceTracker.openResource(resource);
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug(Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-" + (bExisting ? "Cached" : "New and cached") + " resource opened");
        }
        return resource;
	}

	/** 
	 * Gets a resource, querying the appropriate resource provider but does
	 * not record the resource for closure - this must be done by explicitly
	 * calling the close or abort methods with the resource as an argument.
	 * This method should be used by threads that want a database resource
	 * and which will close the resource themselves when finished.
	 *
	 * @param name The name of the Resource Provider to query
	 *    
	 */
	public synchronized Object openDirect(String name) throws Exception
	{
		String resourceId = name + ":" + Thread.currentThread().getId();
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug (Log.RESOURCES, "Opening direct ; " + resourceId + " RESOURCEMANAGER: " + this.hashCode());
        }
		ResourceProvider provider = provManager.getProvider(name);

		Object resource;
        TimerContext timingContext = resourceManagerWaitForResourceTimer.time();
        try {
        	if(Log.isDebugEnabled(Log.RESOURCES)) {
                Log.debug  (Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-");
        	}
            resource = provider.open();
        } finally {
            timingContext.stop();
        }

        if(resource != null) {
/*
        	if (!htResources.containsKey(resourceId)) {
    			htResources.put(resourceId, resource);
        	}
*/
        	if(Log.isDebugEnabled(Log.RESOURCES)) {
                Log.debug  (Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-" + "Begin open");
        	}
            openMetrics(resource);        	
        }

        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug  (Log.RESOURCES, "Connection (open direct) ready to use: " + resourceId + " " + resource.hashCode() + " RESOURCEMANAGER: " + this.hashCode());
        }

        resourceTracker.openDirectResource(resource);
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug  (Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-New resource direct opened");
        }
        return resource;
	}

	//--------------------------------------------------------------------------
	/** Gets properties from the named resource provider
	  */

	public synchronized Map<String,String> getProps(String name) throws Exception
	{
		ResourceProvider provider = provManager.getProvider(name);
		return provider.getProps();
	}

	//--------------------------------------------------------------------------
	/** Gets statistics from the named resource provider
	  */

	public synchronized Stats getStats(String name) throws Exception
	{
		ResourceProvider provider = provManager.getProvider(name);
		return provider.getStats();
	}

    /**
     * Get a copy of the resources that were opened in 'direct' mode.  If
     * Log.Dbms.RESOURCE_TRACKING is in debug mode there will be exceptions
     * as the values of the returned Multimap.  This is for debugging only.
     *
     * The resource should not be used since they could be closed at anypoint.
     *
     * The exception are intended to give an idea of what opened the resources to
     * track down resource links.
     *
     * NEVER use the resource obtained through this method.
     *
     */
    public Multimap<Object, Exception> getDirectOpenResourceAccessTracker() {
        return resourceTracker.getDirectOpenResources();
    }


    /**
     * Get a copy of the resources that were opened in 'normal'/'tracked' mode.  If
     * Log.Dbms.RESOURCE_TRACKING is in debug mode there will be exceptions
     * as the values of the returned Multimap.  This is for debugging only.
     *
     * The resource should not be used since they could be closed at anypoint.
     *
     * The exception are intended to give an idea of what opened the resources to
     * track down resource links.
     *
     * NEVER use the resource obtained through this method.
     *
     */
    public Multimap<Object, Exception> getResourceAccessTracker() {
        return resourceTracker.getOpenResources();
    }

    //--------------------------------------------------------------------------

	public synchronized DataStore getDataStore(String name) throws Exception
	{
		ResourceProvider provider = provManager.getProvider(name);
		return provider.getDataStore();
	}

	//--------------------------------------------------------------------------
	/** Closes a resource doing a commit
	  */

	public synchronized void close(String name, Object resource) throws Exception
	{
        closeMetrics(resource); // This must be done before removing from htResource
		String resourceId = name + ":" + Thread.currentThread().getId();
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug (Log.RESOURCES, "Closing: " + resourceId + " " + resource.hashCode());
        }
        boolean bExisting = false;
		Object cachedResource = htResources.get(resourceId);
		if (cachedResource != null && cachedResource == resource) {
			bExisting = true;
			htResources.remove(resourceId);
		} else {
            if(Log.isDebugEnabled(Log.RESOURCES)) {
                Log.debug (Log.RESOURCES, "Connection to close is not in cache: " + resourceId + " " + resource.hashCode() + " RESOURCEMANAGER: " + this.hashCode());
            }
		}
		ResourceProvider provider = provManager.getProvider(name);
		int hashCode = resource.hashCode();
		provider.close(resource);
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug (Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-" + (bExisting ? "Cached" : "Uncached") + " resource closed");
        }
	}

	//--------------------------------------------------------------------------
	/** Closes a resource doing an abort
	  */

	public synchronized void abort(String name, Object resource) throws Exception
	{
        closeMetrics(resource); // This must be done before removing from htResource
		String resourceId = name + ":" + Thread.currentThread().getId();
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug (Log.RESOURCES, "Aborting connection : " + resourceId + " " + resource.hashCode() + " RESOURCEMANAGER: " + this.hashCode());
        }
		Object cachedResource = htResources.get(resourceId);
		boolean bExisting = false;
		if (cachedResource != null && cachedResource == resource) {
			bExisting = true;
			htResources.remove(resourceId);
		} else {
            if(Log.isDebugEnabled(Log.RESOURCES)) {
                Log.debug (Log.RESOURCES, "Connection to abort is not in cache: " + resourceId + " " + resource.hashCode() + " RESOURCEMANAGER: " + this.hashCode());
            }
		}
		ResourceProvider provider = provManager.getProvider(name);
		int hashCode = resource.hashCode();
		provider.abort(resource);
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug (Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-" + (bExisting ? "Cached" : "Uncached") + " resource aborted");
        }
	}

	//--------------------------------------------------------------------------
	/** Closes all resources doing a commit
	  */

	public synchronized void close() throws Exception
	{
		release(true);
	}

	//--------------------------------------------------------------------------
	/** Closes all resources doing an abort
	  */

	public synchronized void abort() throws Exception
	{
		release(false);
	}

	//--------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//--------------------------------------------------------------------------

	/** Scans all resources doing a commit/abort
	  */

	private void release(boolean commit) throws Exception
	{
		if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug (Log.RESOURCES, "Releasing of " + htResources.size() + " resources in RESOURCEMANAGER: " + this.hashCode());
        }
        
		Exception errorExc = null;
		int closed = 0;
		int aborted = 0;
		
		String threadId = "" + Thread.currentThread().getId();
		int iCount = 1;
		for (Map.Entry<String, Object> entry : htResources.entrySet()) {
            closeMetrics(entry.getValue()); // This must be done before removing from htResource
            String resourceId = entry.getKey();
            String providerName = resourceId.split(":")[0];
            if(Log.isDebugEnabled(Log.RESOURCES)) {
                Log.debug (Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-Releasing resource " + iCount++ + "/" + htResources.size());
            }
            if (!resourceId.equals(providerName + ":" + threadId)) {
    			System.out.println(this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-IMPOSSIBLE CASE");
            }
			ResourceProvider provider = provManager.getProvider(providerName);
			try
			{
				if (commit)	{
					provider.close(entry.getValue());
					if(Log.isDebugEnabled(Log.RESOURCES)) {
			            Log.debug (Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-Cached resource released by close");
					}
					closed++;
				} else {
					provider.abort(entry.getValue());
					if(Log.isDebugEnabled(Log.RESOURCES)) {
			            Log.debug (Log.RESOURCES, this.hashCode() + "-THREAD-" + Thread.currentThread().getId() + "-Cached resource released by abort");
					}
					aborted++;
				}
//    				htResources.remove(resourceId);
			}
			catch (Exception ex)
			{
				errorExc = ex;
			}
		}

		htResources.clear();

		if (errorExc != null) {
            Log.error (Log.RESOURCES, "Exception in release resources");
			throw errorExc;
		}
        if(Log.isDebugEnabled(Log.RESOURCES)) {
            Log.debug (Log.RESOURCES, "End of release resources (" + closed + " resources closed and " + aborted + " resources aborted");
        }
	}

    Map<Object, TimerContext> timerContexts = new HashMap<Object, TimerContext>();

    private void openMetrics(Object resource) {
        timerContexts.put(resource, resourceManagerResourceIsOpenTimer.time());
    }

    private void closeMetrics(Object resource) {
        TimerContext context = timerContexts.get(resource);
        if(context == null) {
            Log.error(Log.DBMSPOOL, "A resource was closed that had not been marked as opened!");
        } else {
            context.stop();
        }

        resourceTracker.removeAll(resource);
    }



}

//=============================================================================

