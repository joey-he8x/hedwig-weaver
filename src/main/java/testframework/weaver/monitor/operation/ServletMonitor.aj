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

import javax.servlet.Servlet;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspPage;
import javax.servlet.jsp.PageContext;


public aspect ServletMonitor extends AbstractOperationMonitor {
    
    /** Execution of any servlet method: typically not overridden in HttpServlets. */
    public pointcut servletService(Servlet servlet) :
        execution(void Servlet.service(..)) && this(servlet);
        
    /** Execution of any servlet request methods. */
    public pointcut httpServletDo(HttpServlet servlet) :
        execution(void HttpServlet.do*(..)) && this(servlet);
    
    /** Execution of any JSP page service method. */
    public pointcut jspService(JspPage page) : 
        execution(* _jspService(..)) && this(page);
    
    // it would be better to use the request portion of the URL for JSP name, rather than the generate Java name 

    protected pointcut classControllerExec(Object controller) :
        (servletService(*) || httpServletDo(*) || jspService(*)) && this(controller);

//    public pointcut classControllerExec(Object controller) :
//        servletService(controller) || httpServletDo(controller) || jspService(controller);

    /** Create statistics for this object: looks up Servlet context to determine application name */
    protected String getContextName(Object controller) {
        Servlet servlet = (Servlet)controller;
        ServletContext context = servlet.getServletConfig().getServletContext();
        String contextName = context.getServletContextName(); 
        if (contextName == null) {
            //TODO: look up context path from http request
//            if (request instanceof HttpServletRequest) {
//                contextName = ((HttpServletContext)context).                
//            }
            contextName = context.getRealPath("/");
        }
        return contextName;
    }
            
    /** Call of send error in the Servlet API */
    public pointcut sendingErrorResponse(HttpServletResponse response, int sc) : 
        target(response) && call(* sendError(..)) && args(sc, ..);
    
    /** Another type of error: sending an error response */
    after(HttpServletResponse response, RequestContext requestContext, int sc) returning : 
      sendingErrorResponse(response, sc) && inRequest(requestContext) {
        requestContext.setErrorContext(new Integer(sc));
    }
    
    /** Execute handle page exception in the JSP API */
    public pointcut handlePageException(PageContext pageContext, Throwable t) :
        call(* PageContext.handlePageException(*)) && target(pageContext) && args(t);

    after(PageContext pageContext, RequestContext requestContext, Throwable t) returning : 
        handlePageException(pageContext, t) && inRequest(requestContext) {
          requestContext.setErrorContext(t);
     }
    
    /** Call redirect to error page */
//    public pointcut redirectToErrorPage(HttpServletResponse response, RequestContext requestContext, int sc) : 
//        target(response) && call(* sendError(..)) && args(sc, ..) && inRequest(requestContext);

    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
}
