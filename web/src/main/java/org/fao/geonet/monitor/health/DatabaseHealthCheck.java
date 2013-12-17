package org.fao.geonet.monitor.health;

import com.yammer.metrics.core.HealthCheck;
import jeeves.monitor.HealthCheckFactory;
import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import org.fao.geonet.constants.Geonet;

/**
 * Checks to ensure that the database is accessible and readable
 * <p/>
 * User: jeichar
 * Date: 3/26/12
 * Time: 9:01 AM
 */
public class DatabaseHealthCheck implements HealthCheckFactory {
    public HealthCheck create(final ServiceContext context) {
        return new HealthCheck("Database Connection") {
            @Override
            protected Result check() throws Exception {
            	boolean bException = false;
                Dbms dbms = null;
                try {
                    // TODO add timeout
                    dbms = (Dbms) context.getResourceManager().openDirect(Geonet.Res.MAIN_DB);
                    dbms.select("SELECT id from Metadata LIMIT 1");
                    return Result.healthy();
                } catch (Throwable e) {
                	bException = true;
    	            if (dbms != null) {
    	            	context.getResourceManager().abort(Geonet.Res.MAIN_DB, dbms);
    	            }
                    return Result.unhealthy(e);
                } finally {
                    if (!bException && dbms != null)
                        context.getResourceManager().close(Geonet.Res.MAIN_DB, dbms);
                }

            }
        };
    }
}
