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

import testframework.weaver.track.resource.ResourceStats;
import testframework.weaver.track.PerfStats;

public interface OperationStats extends PerfStats {
    ResourceStats getResourceStats(Object resourceId);
    OperationStats getOperationStats(Object key);
    
    String getContextName();
    int getLevel();    
}