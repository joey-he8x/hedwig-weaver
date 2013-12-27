package com.yihaodian.testframework.weaver.jmx;

import org.springframework.core.NestedRuntimeException;

public class RegistrationFailureException extends NestedRuntimeException {

    public RegistrationFailureException(String msg, Throwable t) {
        super(msg, t);
    }

    public RegistrationFailureException(String msg) {
        super(msg);
    }
    
    private static final long serialVersionUID = 1;
}
