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
 
import edu.emory.mathcs.util.collections.WeakIdentityHashMap;
import testframework.weaver.monitor.AbstractRequestMonitor;
import testframework.weaver.track.PerfStats;
import testframework.weaver.track.PerfStatsFactory;
import testframework.weaver.util.KeyUtils;

import java.lang.reflect.Method;
import java.util.Map;

import testframework.weaver.track.operation.OperationStats;

/** Monitors performance timing and execution counts for <code>HttpServlet</code> operations */
public abstract aspect AbstractOperationMonitor extends AbstractRequestMonitor {  
      
    protected abstract class OperationRequestContext extends RequestContext {
        public OperationRequestContext(Object controller) { this.controller = controller; }
        /**
         * Find the appropriate statistics collector object for this operation.
         * @param operation an instance of the operation being monitored
         */
        public PerfStats lookupStats() {                
            if (getParent() != null) {
                // nested operation
                if (getLogger().isDebugEnabled()) {
                    getLogger().debug("Getting parent context:  "+getParent()+" for "+getKey());
                }
                
                OperationStats parentStats = (OperationStats)getParent().getStats();
                return parentStats.getOperationStats(getKey());
            }
            return getTopLevelStats(getKey());
        }
        
        /**
         * Determine the top-level statistics for a given operation key. 
         * This also looks up the context name for the application from the operation monitor: 
         * @see AbstractOperationMonitor#getContextName(Object)
         * For a Web application, top-level statistics are normally all servlets, and the key is the servlet name. 
         * @param key An object that uniquely identifies the operation being performed.
         */
        protected OperationStats getTopLevelStats(Object key) {
            OperationStats stats;
            synchronized(topLevelOperations) {
                stats = (OperationStats)topLevelOperations.get(key);
                if (stats == null) {                
                    stats = perfStatsFactory.createTopLevelOperationStats(key, getContextName(controller));
                    topLevelOperations.put(key, stats);
                }
            }
            if (getLogger().isDebugEnabled()) {
                getLogger().debug("Top level stats for "+key+" in context "+getContextName(controller));
            }
            return stats;        
        }
        
        /** @return An object that uniquely identifies the operation being performed. */
        protected abstract Object getKey();     
        
        /** The current controller object executing, if any. */
        protected Object controller;
    };

    /** @return the context associated with this controller. Defaults to null. */
    protected String getContextName(Object controller) {
        return null;
    }
    
    // common templates for easy extension - pointcuts default to matching nothing... override where relevant
    // controller where the class determines what is being executed
    /** 
     * This defaults to no join points. If a concrete aspect overrides <code>classControllerExec</code> with a concrete definition,
     * then the monitor will track operations at matching join points based on the <em>class</em> of the controller object.
     */ 
    protected pointcut classControllerExec(Object controller);
    
    Object around(final Object controller) : classControllerExec(controller) && monitorEnabled() {
        RequestContext rc = new OperationRequestContext(controller) {
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
     * then it will track operations at matching join points based on the runtime class of the executing controller instance and the method
     * signature at the join point.
     */ 
    protected pointcut methodSignatureControllerExec(Object controller);   
    
    Object around(final Object controller) : methodSignatureControllerExec(controller) && monitorEnabled() {
        RequestContext rc = new OperationRequestContext(controller) {
            public Object doExecute() {
                return proceed(controller);
            }
                       
            protected Object getKey() {
                return KeyUtils.concatenatedKey(controller.getClass(), thisJoinPointStaticPart.getSignature().getName());
            }
            
        };
        return rc.execute();        
    }    
    // this works even with a template method for method controllers - since the class will be different
    
    // controller where the method name as a string (in an argument) determines what is being executed
    /** 
     * This defaults to no join points. If a concrete monitor overrides <code>methodNameControllerExec</code> with a concrete definition,
     * then it will track operations at matching join points based on the methodName
     * @param methodName a String name of a method.
     */ 
    protected pointcut methodNameControllerExec(Object controller, String methodName);
    
    Object around(final Object controller, final String methodName) : 
      methodNameControllerExec(controller, methodName) && monitorEnabled() {
        RequestContext rc = new OperationRequestContext(controller) {
            public Object doExecute() {
                return proceed(controller, methodName);
            }
                       
            protected Object getKey() {
                // in practice these are always nested beneath a higher-level controller, so it's
                // better to have the controller class be a parent than to have a dotted name 
                return methodName;
                //return concatenatedKey(controller.getClass(), methodName);
            }
            
        };
        return rc.execute();        
    }    

    /** 
     * This defaults to no join points. If a concrete monitor overrides <code>methodControllerExec</code> with a concrete definition,
     * then it will track operations at matching join points based on the runtime class of the executing controller instance and the passed method.
     * @param method a reflective definition of a Java method
     */ 
    protected pointcut methodControllerExec(Object controller, Method method);
    
    Object around(final Object controller, final Method method) : 
      methodControllerExec(controller, method) && monitorEnabled() {
        RequestContext rc = new OperationRequestContext(controller) {
            public Object doExecute() {
                return proceed(controller, method);
            }
                       
            protected Object getKey() {
                return KeyUtils.concatenatedKey(controller.getClass(), method.getName());
            }
            
        };
        return rc.execute();        
    }    

    public static void setPerfStatsFactory(PerfStatsFactory aPerfStatsFactory) {
        perfStatsFactory = aPerfStatsFactory;
    }

    public static PerfStatsFactory getPerfStatsFactory() {
        return perfStatsFactory;
    }
    
    /** track top-level operations */ 
    protected Map/*<Object,OperationStats>*/ topLevelOperations = new WeakIdentityHashMap();
    private static PerfStatsFactory perfStatsFactory;
}
