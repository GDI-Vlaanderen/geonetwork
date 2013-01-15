package org.fao.geonet.services.metadata.validation;

import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

/**
 * @author heikki doeleman
 */
public class ValidationHookFactory {

    Class<? extends IValidationHook> validationHook;

    /**
     * Constructor.
     *
     * @param validationHook Class defined in WEB-INF/config.xml that defines a validation hook
     * @throws ValidationHookException hmm
     *
     */
    public ValidationHookFactory(Class<? extends IValidationHook> validationHook) throws ValidationHookException {
        try {
            this.validationHook = validationHook;
        }
        catch(Throwable x) {
            throw new ValidationHookException(x.getMessage(), x);
        }
    }

    /**
     * Creates a ValidationHook class and initializes it using reflection.
     *
     * @param context ServiceContext from Jeeves
     * @param dbms Database management system channel
     * @throws ValidationHookException hmm
     *
     */
    public IValidationHook createValidationHook(ServiceContext context, Dbms dbms) throws ValidationHookException {
        try {
            Constructor<? extends IValidationHook> ct = validationHook.getConstructor();
            IValidationHook vh = ct.newInstance();

            Method init = validationHook.getMethod("init", new Class[] {
                    ServiceContext.class, /* context */
                    Dbms.class            /* dbms channel */
            });

            init.invoke(vh, context, dbms);
            return vh;
        }
        catch(Throwable x) {
            System.err.println(x.getMessage());
            x.printStackTrace();
            throw new ValidationHookException(x.getMessage(), x);
        }
    }

    /**
     *
     * @param vh validation hook
     * @param args arguments to onValidate method
     * @throws ValidationHookException hmm
     */
    public void onValidate(IValidationHook vh, Object... args) throws ValidationHookException {
        try {
            Method onValidate = validationHook.getMethod("onValidate", new Class[]{
                    Class.forName("[Ljava.lang.Object;")
            });
            onValidate.invoke(vh, new Object[]{args});
        }
        catch(Throwable x) {
            System.out.println(x.getMessage());
            x.printStackTrace();
            throw new ValidationHookException(x.getMessage(), x);
        }
    }

}