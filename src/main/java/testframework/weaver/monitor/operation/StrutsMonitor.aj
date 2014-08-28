///********************************************************************
// * Copyright (c) 2005 Glassbox Corporation, Contributors.
// * All rights reserved. 
// * This program and the accompanying materials are made available 
// * under the terms of the Common Public License v1.0 
// * which accompanies this distribution and is available at 
// * http://www.eclipse.org/legal/cpl-v10.html 
// *  
// * Contributors: 
// *     Ron Bodkin     initial implementation 
// *******************************************************************/
//package testframework.weaver.monitor.operation;
//
//import javax.servlet.ServletRequest;
//import javax.servlet.ServletResponse;
//
//import org.apache.struts.action.Action;
//import org.apache.struts.action.ActionForm;
//import org.apache.struts.action.ActionForward;
//import org.apache.struts.action.ActionMapping;
//import org.apache.struts.actions.DispatchAction;
//
//// note that these concrete monitors could be defined in XML without compilation in AspectJ 5
//public aspect StrutsMonitor extends AbstractOperationMonitor {
//    /** marker interface that allows explicitly _excluding_ classes from this monitor: not used by default */
//    public interface NotMonitoredAction {}
//    
//    /** 
//     * Matches execution of any method defined on a Struts action, or any subclass, which has the right
//     * signature for an action execute (or perform) method, including methods dispatched to in a DispatchAction
//     * or template methods with the same signature.
//     */ 
//    public pointcut actionMethodExec() : 
//        execution(public ActionForward Action+.*(ActionMapping, ActionForm, ServletRequest+, ServletResponse+)) &&
//        !within(NotMonitoredAction);
//
//    /** 
//     * Matches execution of an action execute (or perform) method for a Struts action. Supports the Struts 1.0 API (using the perform method)
//     * as well as the Struts 1.1 API (using the execute method)
//     */ 
//    public pointcut rootActionExec() : 
//        actionMethodExec() && (execution(* Action.execute(..)) || execution(* Action.perform(..)));
//    
//    protected pointcut classControllerExec(Object controller) :
//        rootActionExec() && this(controller);
//
////    protected pointcut methodNameControllerExec(Object controller, String methodName) :
////        execution(* DispatchAction.dispatchMethod(..)) && args(.., methodName) && this(controller);    
//    // better: match based on the method being executed at the join point... not coupled to impl details
// 
//    protected pointcut dispatchActionMethodExec() :
//        actionMethodExec() && execution(* DispatchAction+.*(..));
//
//    protected pointcut methodSignatureControllerExec(Object controller) :
//        dispatchActionMethodExec() && this(controller);
//    
//    // TODO: handle tiles
//
//    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
//}
