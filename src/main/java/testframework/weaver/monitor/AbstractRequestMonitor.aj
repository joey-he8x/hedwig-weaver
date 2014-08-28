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
package testframework.weaver.monitor;

import testframework.weaver.track.PerfStats;

import org.aspectj.lang.JoinPoint.StaticPart;

/** Base aspect for monitoring functionality. Uses the worker object pattern. */
public abstract aspect AbstractRequestMonitor {
   
    /** This interface allows us to start up before any monitored operation has been executed... */ 
    public static interface MonitoredType {}
    
    /** Matches execution of the worker object for a monitored request. */
    public pointcut requestExecution(RequestContext requestContext) :
        execution(* RequestContext.execute(..)) && this(requestContext);

    /** In the control flow of a monitored request, i.e., of the execution of a worker object for a monitored request. */
    public pointcut inRequest(RequestContext requestContext) :
        cflow(requestExecution(requestContext));

    /** establish parent relationships for request context objects. */
    // use of call is cleaner since constructors are called once but executed many times
    // These advices should run *exactly once* so we define a concrete static inner aspect . See AspectJ bug #103268
    
    static aspect TrackParents {
        private AbstractRequestMonitor RequestContext.owningMonitor;
        
        after(RequestContext parentContext, AbstractRequestMonitor callingMonitor) returning (RequestContext childContext) : 
          call(RequestContext+.new(..)) && inRequest(parentContext) && this(callingMonitor) {
            childContext.setParent(parentContext);
            childContext.owningMonitor = callingMonitor;
        }
        
        /** Record an error if this request exited by throwing a Throwable */
        after(RequestContext requestContext) throwing (Throwable t) : requestExecution(requestContext) {
//            getLogger().info("exiting request context with exception ", t);
            PerfStats stats = requestContext.getStats();
            if (stats != null) {
                if (requestContext.owningMonitor.getFailureDetectionStrategy().isFailure(t, thisJoinPointStaticPart)) {
                    requestContext.recordFailure(t);
                } else {
                    requestContext.recordEnd();
                }
            }
        }        
    }

    public long getTime() {
        return System.currentTimeMillis();
        //        return System.nanoTime() / 1000000L; // More accurate Java 5 option...
    }

    /** Worker object that holds context information for a monitored request. */
    public abstract class RequestContext {
        /** Containing request context, if any. Maintained by @link AbstractRequestMonitor */
        protected RequestContext parent = null;

        /** Associated performance statistics. Used to cache results of @link #lookupStats() */
        protected PerfStats stats;

        /** Start time for monitored request. */
        protected long startTime;

        /** Error context, if any error (e.g., an unrecoverable exception) was encountered. */
        protected Object errorContext = null;

        /** 
         * Record execution and elapsed time for each monitored request.
         * Relies on @link #doExecute() to proceed with original request. 
         */
        public final Object execute() {
            startTime = getTime();

            Object result = doExecute();

            PerfStats stats = getStats();
            if (stats != null) {
                if (getErrorContext() == null) {
                    stats.recordExecution(startTime, getTime());
                } else {
                    stats.recordFailure(startTime, getTime(), getErrorContext());
                }
            } else {
//                getLogger().warn("no stats for " + this + ", " + parent + ", " + AbstractRequestMonitor.this);
            }

            return result;
        }

        /** template method: proceed with original request */
        public abstract Object doExecute();

        /** template method: determines appropriate performance statistics for this request */
        protected abstract PerfStats lookupStats();

        /** returns performance statistics for this method */
        public PerfStats getStats() {
            if (stats == null) {
                stats = lookupStats(); // get from cache, if available
            }
            return stats;
        }

        public RequestContext getParent() {
            return parent;
        }

        public void setParent(RequestContext parent) {
            this.parent = parent;
        }

        public void setErrorContext(Object errorContext) {
            this.errorContext = errorContext;
        }
        
        public Object getErrorContext() {
            return errorContext;
        }

        public void recordFailure(Object failureContext) {
            stats.recordFailure(startTime, getTime(), failureContext);
        }
        
        public void recordEnd() {
            stats.recordExecution(startTime, getTime());
        }
    }
    
    protected pointcut scope() : within(*);//if(true);

    public void setFailureDetectionStrategy(FailureDetectionStrategy failureDetectionStrategy) { 
        this.failureDetectionStrategy = failureDetectionStrategy;
    }
    
    public FailureDetectionStrategy getFailureDetectionStrategy() {
        return failureDetectionStrategy;
    }
    
    protected FailureDetectionStrategy failureDetectionStrategy =
        new FailureDetectionStrategy() {
          public boolean isFailure(Throwable t, StaticPart staticPart) {
              return true;
          }
        };
   
    protected pointcut monitorEnabled() : scope() && isMonitorEnabled();
    protected abstract pointcut isMonitorEnabled();// define as : if(aspectOf().isEnabled())
}
