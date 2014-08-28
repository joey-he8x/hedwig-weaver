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
package testframework.weaver.jmx;

import testframework.weaver.track.operation.OperationStats;
import testframework.weaver.track.PerfStats;

public class GuiFriendlyStatsJmxNameStrategy implements StatsJmxNameStrategy {
    
    public void appendOperationName(PerfStats stats, StringBuffer buffer) {        
        PerfStats parent = stats.getParent(); 
        if (parent != null) {
            appendOperationName(parent, buffer);
            buffer.append(',');
        } else {
            if (stats instanceof OperationStats) {
                OperationStats opStats = (OperationStats)stats;
                String contextName = opStats.getContextName();
                if (contextName != null) {
                    buffer.append("application=\"");
                    int pos = buffer.length();
                    buffer.append(contextName);
                    JmxManagement.jmxEncode(buffer, pos);
                    buffer.append("\",");
                }
            }
        }
        buffer.append(stats.getDescription());
        buffer.append('=');
        stats.appendName(buffer);
    }
}
