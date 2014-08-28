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

/** 
 * Implements the @link glassbox.inspector.track.PerfStats interface.
 * 
 * @author Ron Bodkin
 *
 */
public class PerfStatsImpl implements PerfStats {

    /** the key with which these statistics are associated */
    private Object key;

    /** a description of these statistics */
    private String description;

    /** the containing statistics object */
    private PerfStats parent;

    /** total accurmulated time in milliseconds from all execution (since last reset). */
    private int accumulatedTime = 0;

    /** the largest time for any single execution, in milliseconds (since last reset). */
    private int maxTime = 0;

    /** the number of executions recorded (since last reset). */
    private int count = 0;

    /** the number of executions that failed (since last reset). */
    private int failureCount = 0;

    public PerfStatsImpl(Object key, String description, PerfStats parent) {
        this.key = key;
        this.description = description;
        this.parent = parent;
    }

    public PerfStatsImpl(Object key, String description) {
        this(key, description, null);
    }

    public void recordExecution(long start, long end) {
        int time = (int)(end - start);
        accumulatedTime += time;
        maxTime = Math.max(time, maxTime);
        count++;
    }

    public void recordFailure(long start, long end, Object errorContext) {
        recordExecution(start, end);
        failureCount++;
    }

    public void reset() {
        accumulatedTime = 0;
        maxTime = 0;
        count = 0;
        failureCount = 0;
    }

    public int getAccumulatedTime() {
        return accumulatedTime;
    }

    public int getMaxTime() {
        return maxTime;
    }

    public int getCount() {
        return count;
    }

    public int getFailureCount() {
        return failureCount;
    }

    public Object getKey() {
        return key;
    }

    public PerfStats getParent() {
        return parent;
    }

    public String getDescription() {
        return description;
    }
}
