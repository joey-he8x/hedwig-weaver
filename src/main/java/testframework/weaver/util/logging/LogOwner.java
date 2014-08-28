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
package testframework.weaver.util.logging;

import org.apache.log4j.Logger;

/** 
 * Interface of operations that an object that owns a log can perform on that log.
 * Really just a convenience method for looking up the class-level logger. 
 */
public interface LogOwner {
	Logger getLogger();
}
