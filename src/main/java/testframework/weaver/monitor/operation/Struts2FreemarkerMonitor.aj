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

import org.apache.struts2.views.freemarker.FreemarkerResult;

public aspect Struts2FreemarkerMonitor extends AbstractOperationMonitor {
    public interface NotMonitoredAction {}
    
    protected pointcut methodNameControllerExec(Object controller, String methodName) :
    	execution(public void FreemarkerResult.doExecute(..)) && args(methodName,..)  &&this(controller);

    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
}
