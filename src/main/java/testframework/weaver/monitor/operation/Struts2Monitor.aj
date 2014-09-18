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

import java.lang.reflect.Method;
import javax.servlet.http.HttpServletRequest;
import com.opensymphony.xwork2.DefaultActionInvocation;
import org.apache.struts2.views.freemarker.FreemarkerResult;
import org.apache.struts2.dispatcher.Dispatcher;


// note that these concrete monitors could be defined in XML without compilation in AspectJ 5
public aspect Struts2Monitor extends AbstractOperationMonitor {
    /** marker interface that allows explicitly _excluding_ classes from this monitor: not used by default */
    public interface NotMonitoredAction {}
            
    protected pointcut methodControllerExec(Object controller, Method method) :
    	withincode(* DefaultActionInvocation.invokeAction(..)) && call(* Method.invoke(..)) && args(controller,..) &&target(method);
    
    //freemarker execute
    protected pointcut methodNameControllerExec(Object controller, String methodName) :
    	execution(public void FreemarkerResult.doExecute(..)) && args(methodName,..)  &&this(controller);

    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
    
    protected pointcut strutsDispatcherExec(HttpServletRequest request):
    	execution(* Dispatcher.serviceAction(..)) && args(request,..);
    
    Object around(final Object controller,final HttpServletRequest request) : 
    	strutsDispatcherExec(request) && this(controller) && monitorEnabled() {
    	final String url = request.getRequestURI();
    	
          RequestContext rc = new OperationRequestContext(controller) {
              public Object doExecute() {
                  return proceed(controller, request);
              }
                         
              protected Object getKey() {
                  return url.intern();
              }
          };
          return rc.execute();        
      }
    
}
