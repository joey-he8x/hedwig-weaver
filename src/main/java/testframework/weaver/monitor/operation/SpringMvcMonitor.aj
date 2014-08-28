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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.mvc.multiaction.MultiActionController;

public aspect SpringMvcMonitor extends AbstractOperationMonitor {
    /** marker interface that allows explicitly _excluding_ classes from this monitor: not used by default */
    public interface NotMonitoredController {}
    
    public pointcut springControllerExec() :
        execution(public ModelAndView Controller+.*(HttpServletRequest, HttpServletResponse)) &&
        !within(NotMonitoredController+);

    protected pointcut classControllerExec(Object controller) :
        springControllerExec() && execution(* handleRequest(..)) && this(controller);

    protected pointcut methodSignatureControllerExec(Object controller) :
        springControllerExec() && execution(* MultiActionController+.*(..)) && this(controller);    
    
    protected pointcut methodNameControllerExec(Object controller, String methodName) :
        execution(* MultiActionController.invokeNamedMethod(..)) && args(methodName, ..) && this(controller);

    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
}