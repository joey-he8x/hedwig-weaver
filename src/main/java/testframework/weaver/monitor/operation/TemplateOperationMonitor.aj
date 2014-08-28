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
package testframework.weaver.monitor.operation;

import testframework.weaver.util.KeyUtils;

import org.apache.log4j.Logger;
import org.springframework.web.servlet.support.RequestContext;

/** provides standard operation bindings for XML-defined aspects to override */
// works around significant limitations in AspectJ 1.5.0 concrete aspects...
public abstract aspect TemplateOperationMonitor extends AbstractOperationMonitor {
    protected pointcut classControllerExecTarget();   
    
    Object around() : classControllerExecTarget() && monitorEnabled() {
        final Object controller = thisJoinPoint.getTarget();
        RequestContext rc = new OperationRequestContext(controller) {
            public Object doExecute() {
                return proceed();
            }
                       
            protected Object getKey() {
                return controller.getClass();
            }                        
        };
        return rc.execute();        
    }    
    
    protected pointcut methodSignatureControllerExecTarget();   
    
    Object around() : methodSignatureControllerExecTarget() && monitorEnabled() {
        final Object controller = thisJoinPoint.getTarget();
        RequestContext rc = new OperationRequestContext(controller) {
            public Object doExecute() {
                return proceed();
            }
                       
            protected Object getKey() {
                return KeyUtils.concatenatedKey(controller.getClass(), thisJoinPointStaticPart.getSignature().getName());
            }
            
        };
        return rc.execute();        
    }    

    // work around limitation in AspectJ: concrete aspects aren't woven into!
    public Logger getLogger() {
        return Logger.getLogger(getClass());
    }

    // there's no easy way to disable template operation monitors with this pattern: they are all enabled by default
    protected pointcut isMonitorEnabled() : within(*);    
    
}
