package org.fao.geonet.services.metadata.validation;

import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;

/**
 * Contract for hooks that can be invoked at the end of a validation.
 *
 * @author heikki doeleman
 */
public interface IValidationHook {

    /**
     * Invoked when validation has finished. The variable length Object arguments should accommodate any required
     * input among different implementations.
     *
     * @param args zero or more implementation-dependent arguments
     * @throws ValidationHookException hmm
     */
    public void onValidate(Object... args) throws ValidationHookException;

    /**
     * Initializes validation hook.
     *
     * @param context
     * @param dbms
     * @throws ValidationHookException
     */
    public void init(ServiceContext context, Dbms dbms) throws ValidationHookException;
}