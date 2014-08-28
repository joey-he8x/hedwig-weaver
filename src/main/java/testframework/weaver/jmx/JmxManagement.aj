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

import java.util.Iterator;
import java.util.WeakHashMap;
import java.lang.management.ManagementFactory;

import javax.management.*;
import javax.management.modelmbean.ModelMBeanInfo;
import javax.management.modelmbean.RequiredModelMBean;

import org.springframework.jmx.export.assembler.InterfaceBasedMBeanInfoAssembler;
import org.springframework.jmx.export.assembler.MBeanInfoAssembler;

/** Reusable aspect that automatically registers beans for management */
//XXX fix: ensure that we can deregister the monitored objects from JMX, e.g., when undeploying an app   
public aspect JmxManagement {
    
    /** Defines the MBeanServer with which beans are auto-registered */
    private MBeanServer server;

    private boolean ManagedBean.hasRegistered;
    
    private WeakHashMap deferredRegistration = new WeakHashMap();

    /** Defines classes to be managed and defines basic management operation */
    public interface ManagedBean {
        /** Define a JMX operation name for this bean. Not to be confused with a Web request operation. */
//        Map getAttributes();
        String getOperationName();
        
        ObjectName getObjectName() throws MalformedObjectNameException;
        /** Returns the underlying JMX MBean that provides management information for this bean (POJO).. */
        Object getMBean();
        /** Get the interface type used as the management interface */
        Class getManagementInterface();
    }
    
    private pointcut managedBeanConstruction(ManagedBean bean) : 
        execution(ManagedBean+.new(..)) && this(bean); 
    
    private pointcut topLevelManagedBeanConstruction(ManagedBean bean) : 
        managedBeanConstruction(bean) && if(thisJoinPointStaticPart!=null && thisJoinPointStaticPart.getSignature().getDeclaringType() == bean.getClass() && !bean.hasRegistered); 
        
    public ObjectName ManagedBean.getObjectName() throws MalformedObjectNameException {        
        return new ObjectName("infiltrator:"+getOperationName());
    }
    
    /** After constructing an instance of <code>ManagedBean</code>, register it */
    // advise top-level executions of constructors; this lets us advise construction of classes and of aspects too, exactly once
    after(ManagedBean bean) returning: topLevelManagedBeanConstruction(bean) {
        if (getMBeanServer() == null) {
            // JMX isn't ready yet: enqueue
        	getLogger().debug("deferredRegistration MBean: "+bean); 
            deferredRegistration.put(bean, null);
        } else {
            register(bean);
        }
    }
    
    private void register(ManagedBean bean) {        
        bean.hasRegistered = true;
        
        ObjectName objectName ;
        try {
            objectName = bean.getObjectName();
            getLogger().debug("registering MBean: "+objectName);     
        } catch (MalformedObjectNameException e) { 
            getLogger().error("Can't register bean for "+bean+": bad object name", e);
            return;
        }

        Object mBean = bean.getMBean();
        if (mBean != null) {
            try {
                try {
                    server.registerMBean(mBean, objectName);
                } catch (InstanceAlreadyExistsException e) {
                    // can be caused when redeploying a managed application... we simply unregister & retry once more
                    // in future, I would like to unregister all the beans with a listener for when a servlet context dies  
                    server.unregisterMBean(objectName);
                    server.registerMBean(mBean, objectName);
                }
                getLogger().debug("registered: "+objectName);
            } catch (Throwable t) {
                getLogger().error("Can't register bean "+objectName, t);
            }
        } else {
            getLogger().error("Null MBean!");
        }
    }

    /** Creates a JMX MBean to represent this instance. */ 
    public Object ManagedBean.getMBean() {
        return getDefaultMBean();
    }
    
    // one version of protected ITD access:
    declare error: call(* ManagedBean.getDefaultMBean()) && !withincode (* ManagedBean+.*(..)): 
        "only call default mbean from implementors of ManagedBean";
    
    // we can't use super.getMBean() with ITD's, so we expose the super implementation explicitly...
    public final Object ManagedBean.getDefaultMBean() {
        try {
            String operationName = getOperationName();
            if (operationName == null) {
                getLogger().warn("Unexpected null bean for operation: " + operationName);
                return null;
            }
            
            RequiredModelMBean mBean = new RequiredModelMBean();
            mBean.setModelMBeanInfo(getMBeanInfo(operationName));
            getLogger().debug("mBean: "+mBean.getMBeanInfo());            
            mBean.setManagedResource(this, "ObjectReference");
            return mBean;

            // the use of a StandardMBean would be easier but would break backward
            // compatibility with Weblogic 8.1
            //return new StandardMBean(this, getManagementInterface());
        } catch (Throwable t) {
            /* This is safe because @link glassbox.inspector.error.ErrorHandling will resolve it as described later! */
            throw new RegistrationFailureException("can't register bean ", t);
        }
    }
    
    public ModelMBeanInfo ManagedBean.getMBeanInfo(String operationName) throws JMException {
        try {
            return makeAssembler(getManagementInterface()).getMBeanInfo(this, operationName);        
        } catch (NoClassDefFoundError e) {
            // this is an expected condition if you try to register a monitor that refers to types that
            // don't exist ... thus far the only case that applies is the servlet monitor where we won't
            // register it outside of a container
            getLogger().info("Unable to register bean due to missing type "+e.getMessage()+" for "+operationName);
            getLogger().debug("Stack trace", e);
            throw new RegistrationFailureException("can't register bean ", e);
        }
    }

    /** 
     * Utility method to encode a JMX key name, escaping illegal characters.
     * @param jmxName unescaped string buffer of form JMX keyname=key 
     * @param attrPos position of key in String
     */ 
    public static StringBuffer jmxEncode(StringBuffer jmxName, int attrPos) {
        // translate illegal JMX characters
        for (int i=attrPos; i<jmxName.length(); i++) {
            if (jmxName.charAt(i)==',' ) {
                jmxName.setCharAt(i, ';');
            } else if (jmxName.charAt(i)=='?' || jmxName.charAt(i)=='*' || jmxName.charAt(i)=='\\' ) {
                jmxName.insert(i, '\\');
                i++;
            } else if (jmxName.charAt(i)=='\n') {
                jmxName.insert(i, '\\');
                i++;
                jmxName.setCharAt(i, 'n');
            }
        }
        return jmxName;
    }
    
//    public static String jmxEncode(String jmxName) {
//        return jmxEncode(new StringBuffer(jmxName), 0).toString();
//    }
    
    public void setMBeanServer(MBeanServer server) {
        this.server = server;
        if (!deferredRegistration.isEmpty()) {
            for (Iterator it = deferredRegistration.keySet().iterator(); it.hasNext();) {
                ManagedBean bean = (ManagedBean)it.next();
                register(bean);
            }
        }
    }
    
    public MBeanServer getMBeanServer() {
    	if (server == null){
    		setMBeanServer(ManagementFactory.getPlatformMBeanServer());
    	}
    	return server;
    }

    public static MBeanInfoAssembler makeAssembler(Class interfaze) {      
        Class[] managedInterfaces = new Class[] { interfaze };
        InterfaceBasedMBeanInfoAssembler anAssembler = new InterfaceBasedMBeanInfoAssembler();
        anAssembler.setManagedInterfaces(managedInterfaces);
        return anAssembler;
    }    
}
