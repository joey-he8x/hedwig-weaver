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

import testframework.weaver.jmx.JmxManagement.ManagedBean;
import testframework.weaver.monitor.AbstractRequestMonitor;

/** 
 * Applies JMX management to monitors. 
 */
public aspect MonitorJmxManagement {
    /** Management interface for request monitors: allow enabling and disabling. */
    public interface RequestMonitorMBean extends ManagedBean {
        public boolean isEnabled();
        public void setEnabled(boolean enabled);
    }
    
    /** Make the @link AbstractRequestMonitor aspect implement @link RequestMonitorMBean, so all instances can be managed */
    declare parents: AbstractRequestMonitor implements RequestMonitorMBean;

    public String AbstractRequestMonitor.getOperationName() {
        return "control=monitor,type="+getClass().getName();
    }
    
    public Class AbstractRequestMonitor.getManagementInterface() {
        return RequestMonitorMBean.class;
    }    
}
