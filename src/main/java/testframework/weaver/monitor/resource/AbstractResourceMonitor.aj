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

import testframework.weaver.monitor.AbstractRequestMonitor;
import testframework.weaver.track.PerfStats;
import testframework.weaver.track.operation.OperationStats;
import testframework.weaver.track.resource.ResourceStats;
import testframework.weaver.util.KeyUtils;

public abstract aspect AbstractResourceMonitor extends AbstractRequestMonitor {
    
    protected abstract class ResourceRequestContext extends RequestContext {        
        protected ResourceStats lookupResourceStats(Object key) {
            //System.err.println("RSC lookup: "+key);
            RequestContext context = getParent();
            // this loop handles the case where one resource access is nested within another
            while (context != null && !(context.getStats() instanceof OperationStats)) {
                context = context.getParent(); 
            }
            //System.err.println("RSC ctxt: "+context);
            
            // might be null if there a resource access is caused by a request we aren't tracking or a context listener...
            if (context != null) {
                OperationStats opStats = (OperationStats)context.getStats();
                //System.err.println("RSC op stats: "+opStats);
                return opStats.getResourceStats(key);                
            }
            return null;
        }
        
        protected PerfStats lookupStats() {
            return lookupResourceStats(getKey());
        }
        
        protected abstract Object getKey();        
    }

    /** 
     * This defaults to no join points. If a concrete aspect overrides <code>classResourceReq</code> with a concrete definition,
     * then the monitor will track operations at matching join points based on the <em>class</em> of the target at this join point.
     */ 
    protected pointcut classResourceReq();
    
    Object around(final Object controller) : classResourceReq() && target(controller) && monitorEnabled() {
        RequestContext rc = new ResourceRequestContext() {
            public Object doExecute() {
                return proceed(controller);
            }
                       
            protected Object getKey() {
                return controller.getClass();
            }                        
        };
        return rc.execute();        
    }    

    // controller where the signature name at the monitored join point determines what is being executed 
    /** 
     * This defaults to no join points. If a concrete monitor overrides <code>methodSignatureControllerExec</code> with a concrete definition,
     * then it will track operations at matching join points based on the runtime class of the target object instance and the method
     * signature at the join point.
     */ 
    protected pointcut methodSignatureResourceReq(); 
    
    Object around(final Object controller) : methodSignatureResourceReq() && target(controller) && monitorEnabled() {
        RequestContext rc = new ResourceRequestContext() {
            public Object doExecute() {
                return proceed(controller);
            }
                       
            public Object getKey() {
                return KeyUtils.concatenatedKey(controller.getClass(), thisJoinPointStaticPart.getSignature().getName());
            }
            
        };
        return rc.execute();        
    }    

}
