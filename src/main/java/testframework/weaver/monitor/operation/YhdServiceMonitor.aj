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



// note that these concrete monitors could be defined in XML without compilation in AspectJ 5
public aspect YhdServiceMonitor extends AbstractOperationMonitor {
    /** marker interface that allows explicitly _excluding_ classes from this monitor: not used by default */
    public interface NotMonitoredAction {}
    
    protected pointcut methodSignatureControllerExec(Object controller):
    	cflow(execution(* org.apache.catalina.connector.CoyoteAdapter.service())) && execution(public * com.y*h*d*..service..*(..))  && this(controller);
            

    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
    
    
}
