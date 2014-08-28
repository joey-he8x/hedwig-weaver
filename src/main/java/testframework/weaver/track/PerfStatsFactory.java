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

public interface PerfStatsFactory {

    /**
     * Create top level operation statistics.
     *  
     * @param key The key for the statistics.
     * @param contextName The context name (typically an application name)
     * 
     * @return a new instance of <code>OperationStats</code>
     */
    OperationStats createTopLevelOperationStats(Object key, String contextName);

}