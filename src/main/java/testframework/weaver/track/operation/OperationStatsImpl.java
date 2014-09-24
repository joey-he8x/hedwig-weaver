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
package testframework.weaver.track.operation;

import testframework.weaver.track.PerfStats;
import testframework.weaver.track.PerfStatsImpl;

import java.util.HashMap;
import java.util.Map;

import testframework.weaver.track.resource.ResourceStats;
import testframework.weaver.track.resource.ResourceStatsImpl;

public class OperationStatsImpl extends PerfStatsImpl implements OperationStats {
    private Map/*<databaseKey, ResourceStats>*/ resourceStats = new HashMap();
    private Map/*<Object, OperationStats>*/ operationStats = new HashMap();
    private String contextName;
    private int level;
    //RequestContext rc;

    public OperationStatsImpl(Object operationKey, OperationStats parent, String contextName) {
        super(operationKey, getDescription(operationKey, parent), parent);        
        if (parent == null) {
            level = 0;
        } else {
            level = parent.getLevel() + 1;
        }
        this.contextName = contextName;
    }
    
    public OperationStatsImpl(Object operationKey, String contextName) {
        this(operationKey, null, contextName);         
    }
    
    public OperationStatsImpl(Object operationKey, OperationStats parent) {
        this(operationKey, parent, null);         
    }
    
    public synchronized ResourceStats getResourceStats(Object resourceId) {
        ResourceStats stats = (ResourceStats)resourceStats.get(resourceId);
        if (stats == null) {
            stats = new ResourceStatsImpl(resourceId, this);
            resourceStats.put(resourceId, stats);
        }
        return stats;
    }
    
    public synchronized OperationStats getOperationStats(Object key) {
        OperationStats stats = (OperationStats)operationStats.get(key);
        if (stats == null) {
            stats = new OperationStatsImpl(key, this);
            operationStats.put(key, stats);
        }
        return stats;        
    }
    
    private static String getDescription(Object operationKey, OperationStats parent) {
        if (parent == null) {
            return "operation";
        } else {
            return "operation"+parent.getLevel();
        }
    }
    
    public String getContextName() {
    	return contextName;
    }
    
    public int getLevel() {
    	return level;
    }
    
    /*
     * (non-Javadoc)
     * by Joey.he8x@qq.com
     */
    @Override
    public void resetAll() {
    	this.reset();
    	for (Object m: resourceStats.entrySet()){
    		Map.Entry e = (Map.Entry) m;
    		((PerfStats)e.getValue()).reset();
    	}
    	for (Object m: operationStats.entrySet()){
    		Map.Entry e = (Map.Entry) m;
    		((PerfStats)e.getValue()).reset();
    	}
    }
    
}
