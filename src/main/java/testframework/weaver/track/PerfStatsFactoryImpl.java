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

import testframework.weaver.track.operation.OperationStats;
import testframework.weaver.track.operation.OperationStatsImpl;

public class PerfStatsFactoryImpl implements PerfStatsFactory {
    /* (non-Javadoc)
     * @see glassbox.inspector.track.PerfStatsFactory#createTopLevelOperationStats(java.lang.Object, java.lang.String)
     */
    public OperationStats createTopLevelOperationStats(Object key, String contextName) {
        return new OperationStatsImpl(key, contextName);
    }
}
