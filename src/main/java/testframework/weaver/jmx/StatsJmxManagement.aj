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

import java.lang.reflect.Method;

import org.springframework.jmx.export.assembler.InterfaceBasedMBeanInfoAssembler;
import org.springframework.jmx.export.assembler.MBeanInfoAssembler;

import testframework.weaver.jmx.JmxManagement.ManagedBean;
import testframework.weaver.track.PerfStats;
import testframework.weaver.util.logging.LogManagement;

/** Applies JMX management to performance statistics beans. */
public aspect StatsJmxManagement {
    /** Management interface for performance statistics. A subset of @link glassbox.inspector.track.PerfStats */
    public interface PerfStatsMBean extends ManagedBean {
        int getAccumulatedTime();
        int getMaxTime();
        int getCount();
        int getFailureCount();
        void reset();
        //add by Joey.he8x@qq.com
        void resetAll();
    }
    
    /** Make the @link PerfStats interface extend @link PerfStatsMBean, so all instances can be managed */
    declare parents: PerfStats extends PerfStatsMBean;

    private String PerfStats.cachedOperationName;
    
    /** Determine JMX operation name for this performance statistics bean. */    
    public String PerfStats.getOperationName() {
        if (cachedOperationName != null) {
            return cachedOperationName;
        }
        if (getKey() == null) {
//            getLogger().warn("trying to register null key", new IllegalStateException());
            return null;
        }
        
        StringBuffer buffer = new StringBuffer();
        appendOperationName(buffer);
        String operationName = buffer.toString();
        cachedOperationName = operationName; 
        return operationName;
    }
    
    /** Determine JMX operation name for this performance statistics bean. */    
    public void PerfStats.appendOperationName(StringBuffer buffer) {
        if (cachedOperationName != null) {
            buffer.append(cachedOperationName);
        } else {
            aspectOf().nameStrategy.appendOperationName(this, buffer);
        }
    }   
    
    public void PerfStats.appendName(StringBuffer buffer) {
        buffer.append('"');
        int pos = buffer.length();
        Object key = getKey();
        if (key instanceof Class) {
            buffer.append(((Class)key).getName());
        } else if (key instanceof Method){
            buffer.append(((Method)key).getName());
        } else {
            buffer.append(key);
        }

        JmxManagement.jmxEncode(buffer, pos);
        buffer.append('"');
    }

    public Class PerfStats.getManagementInterface() {
        return PerfStatsMBean.class;
    }    
    
    public StatsJmxNameStrategy getNameStrategy() {
        return nameStrategy;
    }
    
    public void setNameStrategy(StatsJmxNameStrategy nameStrategy) {
        this.nameStrategy = nameStrategy;
    }
    
    private StatsJmxNameStrategy nameStrategy;
}
