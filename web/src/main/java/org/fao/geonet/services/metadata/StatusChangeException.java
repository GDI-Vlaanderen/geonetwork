package org.fao.geonet.services.metadata;

/**
 * @author heikki doeleman
 */
public class StatusChangeException extends Exception {
    public StatusChangeException() {
    }

    public StatusChangeException(String message) {
        super(message);
    }

    public StatusChangeException(String message, Throwable cause) {
        super(message, cause);
    }

    public StatusChangeException(Throwable cause) {
        super(cause);
    }
}