/********************************************************************
 * Copyright (c) 2005 Glassbox Corporation, Contributors.
 * All rights reserved. 
 * This program and the accompanying materials are made available 
 * under the terms of the Common Public License v1.0 
 * which accompanies this distribution and is available at 
 * http://www.eclipse.org/legal/cpl-v10.html 
 *  
 * Contributors: 
 *     Ron Bodkin     initial implementation 
 *******************************************************************/
package testframework.weaver.util.logging;

import org.apache.log4j.Logger;

public aspect LogManagement pertypewithin(LogOwner+) {
    declare parents: testframework.weaver..* && !testframework.weaver.util.logging..*+ && !testframework.weaver.inspector.error.* implements LogOwner;

    private Logger logger;
    
    void around(String msg) : call(static final Logger LogManagement.debug(String)) && args(msg) {
        logger.debug(msg);
    }

    void around(String msg, Throwable t) : call(static final Logger LogManagement.debug(String, Throwable)) && args(msg, t) {
        logger.debug(msg, t);
    }

    after() returning: staticinitialization(*) {
        if (logger != null) {
            System.err.println("warning: reinitializing logger for "+this);
        }
        logger = Logger.getLogger(thisJoinPointStaticPart.getSignature().getDeclaringType());
    }

    Logger around() : execution(Logger LogOwner.getLogger()) {
        if (logger != null) {
            // already cached
            return logger;
        }
        
        return proceed();
    }
    
    static aspect Acessor {
        public Logger LogOwner.getLogger() {
            // used if not initialized yet!
            return Logger.getLogger(getClass());
        }
    }

    public interface AllowedToPrint {
    }

    public pointcut printing(): get(* System.err) || get(* System.out) || call(* Throwable.printStackTrace(..));

//    declare warning: printing() && !within(LogManagement) && !within(AllowedToPrint+): 
//        "don't print, use the logger";
}
