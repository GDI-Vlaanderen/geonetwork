package org.fao.geonet.services.metadata.validation;

import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;

/**
 *
 * @author heikki doeleman
 */
public abstract class AbstractValidationHook implements IValidationHook {

    protected ServiceContext context;
    protected AccessManager am;
    protected DataManager dm;
    protected Dbms dbms;

    /**
     * Initializes the ValidationHook class with external info from GeoNetwork.
     *
     * @param context
     * @param dbms
     */
    @Override
    public void init(ServiceContext context, Dbms dbms) {
        System.out.println("AbstractValidationHook init");
        this.context = context;
        this.dbms = dbms;

        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        am = gc.getAccessManager();
        dm = gc.getDataManager();
    }

}