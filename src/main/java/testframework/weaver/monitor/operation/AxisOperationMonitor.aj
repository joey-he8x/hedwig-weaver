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
//import java.lang.reflect.Method;
//
//import org.apache.axis.providers.java.RPCProvider;
//
//public aspect AxisOperationMonitor extends AbstractOperationMonitor {
//
//    public pointcut axisRpcMethodInvocation(Object receiver, Method method) :
//        execution(* invokeMethod(..)) && within(org.apache.axis.providers.java.RPCProvider+) && args(*, method, receiver, ..);
//        // this is better but requires including the library or ignoring lots of errors
////        execution(* invokeMethod(..)) && this(RPCProvider) && args(*, method, receiver, ..);
//    
//    protected pointcut methodControllerExec(Object controller, Method method) :
//        axisRpcMethodInvocation(controller, method);
//    
//    //TODO: test - not useful: should be the port name, not the operation
//    protected String getContextName(Object controller) {
//        return ((RPCProvider)controller).getName();
////        Method getNameMeth = controller.getClass().getMethod("getName", null);
////        return (String)getNameMeth.invoke(controller, null);
//    }
//    
////    before(Object receiver, Method method) : axisRpcMethodInvocation(receiver, method) {
////        System.out.println("calling "+method+" on "+receiver);
////    }
////
////    before() : execution(* *..*Service.*(..)) && within(samples..*) {
////        System.out.println("samples execution "+thisJoinPointStaticPart);
////        //Thread.dumpStack();
////    }
//    
//    // ... similar for MsgProvider messages
//    // an alternative is to write application-specific pointcut(s) for service execution
//    
//    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
//
//}
