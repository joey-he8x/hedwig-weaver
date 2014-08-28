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
package testframework.weaver.monitor.resource;

import testframework.weaver.track.PerfStats;

import java.lang.reflect.Method;
import java.rmi.Remote;
import java.rmi.RemoteException;

import javax.xml.rpc.Call;

public aspect RemoteCallMonitor extends AbstractResourceMonitor {
    /** Call to remote proxy: RMI or JAX-RPC */
    public pointcut remoteProxyCall(Object recipient) : 
        call(public * Remote+.*(..) throws RemoteException) && target(recipient) && 
        !within(glassbox.inspector..*);
    
//    private static Method endpointAddrMeth = null;
//    private static Method opNameMeth = null;
//    static {
//        try {
//            Class callClass = Class.forName("javax.xml.rpc.Call");
//            endpointAddrMeth = callClass.getMethod("wsCall.getTargetEndpointAddress", null);
//            opNameMeth = callClass.getMethod("wsCall.getOperationName", null);
//        } catch (Exception e) {
//            // no jaxrpc call class available...
//        }
//    }
    
    /** Monitor remote proxy calls based on called class and method */
    Object around(final Object recipient) : remoteProxyCall(recipient) && monitorEnabled() {
        RequestContext requestContext = new ResourceRequestContext() {
            
            public Object doExecute() {
                return proceed(recipient);
            }
            
            public Object getKey() {
                String key = "jaxrpc:"+recipient.getClass().getName()+"."+thisJoinPointStaticPart.getSignature().getName();
                return key.intern();
            }
            
        };
        return requestContext.execute();
    }
   
    /** Reflective call to invoke Web service through JAX-RPC */ 
    public pointcut jaxRpcClientCall(Object wsCallObj) :
        // work-around for AspectJ bug #116305
        call(public * javax..xml.rpc.Call.invoke*(..)) && target(wsCallObj);
        //call(public * javax.xml.rpc.Call.invoke*(..)) && target(wsCallObj);
     
    /** Monitor jax rpc reflective calls based on call metadata */
    Object around(final Object wsCallObj) : jaxRpcClientCall(wsCallObj) && monitorEnabled() {
        RequestContext requestContext = new ResourceRequestContext() {
            
            public Object doExecute() {
                return proceed(wsCallObj);
            }
            
            public Object getKey() {
                Call wsCall = ((Call)wsCallObj);
                String key = wsCall.getTargetEndpointAddress()+":"+wsCall.getOperationName().toString();
//                String key = endpointAddrMeth.invoke(wsCallObj, null)+":"+opNameMeth.invoke(wsCallObj, null);
                return key;
            }
            
        };
        return requestContext.execute();
    }
    
    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());

}
