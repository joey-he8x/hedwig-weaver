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
package testframework.weaver.track;

/** Holds performance statistics for a given topic of interest (e.g., a join point. */ 
public interface PerfStats {
    /** 
     * Record that a single execution occurred.
     * @param start time request began, in milliseconds
     * @param end time request completed, in milliseconds
     */
    void recordExecution(long start, long end);
    
    /** 
     * Record that an execution occurred and that it failed. Call this instead of @link #recordExecution(long, long)
     * @param start time request began, in milliseconds
     * @param end time request failed, in milliseconds
     * @param errorContext object describing the error; often a <code>Exception</code>
     */
    void recordFailure(long start, long end, Object errorContext);

    /**
     * Reset these statistics back to zero. Useful to track statistics during an interval.
     */
    void reset();
    
    void resetAll();
    
    /**
     * @return total accurmulated time in milliseconds from all execution (since last reset).  
     */
    int getAccumulatedTime();
    
    /**
     * @return the largest time for any single execution, in milliseconds (since last reset).  
     */
    int getMaxTime();
    
    /**
     * @return the number of executions recorded (since last reset).  
     */
    int getCount();
    
    /**
     * @return fraction of total time spent in the parent spent in this statistic  
     */
    //double getPercentage(); //TODO
    
    /**
     * @return the number of executions that failed (since last reset).  
     */
    int getFailureCount();
    
    /**
     * @return the key with which these statistics are associated  
     */
    Object getKey();
    
    /**
     * @return the containing statistics object  
     */
    PerfStats getParent();
    
    /**
     * @return the type of statistics (e.g., Servlet, Database)
     */
    String getDescription();
    
}
