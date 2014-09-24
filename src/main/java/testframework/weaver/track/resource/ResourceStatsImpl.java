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
package testframework.weaver.track.resource;

import testframework.weaver.track.PerfStats;
import testframework.weaver.track.PerfStatsImpl;
import testframework.weaver.track.operation.OperationStats;

import java.util.HashMap;
import java.util.Map;

public class ResourceStatsImpl extends PerfStatsImpl implements ResourceStats {

    private Map/*<Object, PerfStats>*/ requestStats = new HashMap();

    public ResourceStatsImpl(Object key, PerfStats parent) {
        super(key, "resource", parent);
    }
    
    public synchronized PerfStats getRequestStats(Object requestKey) {
        PerfStats stats = (PerfStats)requestStats.get(requestKey);
        if (stats == null) {
            stats = new PerfStatsImpl(requestKey, "request", this);
            requestStats.put(requestKey, stats);
        }
        return stats;
    }
    
    /*
     * (non-Javadoc)
     * @see testframework.weaver.track.PerfStatsImpl#resetAll()
     * by Joey.he8x@qq.com
     */
    @Override
    public void resetAll() {
    	this.reset();
    	for (Object m: requestStats.entrySet()){
    		Map.Entry e = (Map.Entry) m;
    		((PerfStats)e.getValue()).reset();
    	}
    }
    
}
