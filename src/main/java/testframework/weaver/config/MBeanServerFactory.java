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
package testframework.weaver.config;

import java.lang.reflect.Method;
import java.util.ArrayList;

import javax.management.MBeanServer;
import javax.management.ObjectName;

public class MBeanServerFactory {

    private static final String JMX_HTML_ADAPTOR_CLASSNAME = "com.sun.jdmk.comm.HtmlAdaptorServer";
    private static final String NO_JMX_HTML_MSG = "No JMX HTML Adapter available: this is harmless, but if you add " + JMX_HTML_ADAPTOR_CLASSNAME +
            "to your classpath, you will be able to access JMX data from a Web browser.";

    public MBeanServer getMBeanServer() throws Exception {
        MBeanServer server;
        synchronized(javax.management.MBeanServerFactory.class) {
            ArrayList servers = javax.management.MBeanServerFactory.findMBeanServer(null);
            if (servers.size() == 0) {
                getLogger().info("created mbean server");
                server = javax.management.MBeanServerFactory.createMBeanServer();
            } else {
                getLogger().info("reusing mbean server");
                server = (MBeanServer)servers.get(0); // use the first one, arbitrarly
            }
        }

        enableHtmlManagerIfAny(server);
        
        return server;
    }
    
    // optional code to allow use of an HTML interface to manage
    // if the appropriate class is available, this will be exposed
    private void enableHtmlManagerIfAny(MBeanServer server) {
        try {
            Class htmlAdaptorClass = Class.forName(JMX_HTML_ADAPTOR_CLASSNAME);
            
            Object htmlServer = htmlAdaptorClass.newInstance();
            ObjectName htmlAdapterName = new ObjectName("Adaptor:name=html,port=8082");
            server.registerMBean(htmlServer, htmlAdapterName);
            Method startMethod = htmlAdaptorClass.getMethod("start", null);
            startMethod.invoke(htmlServer, null);
        } catch (Throwable t) {
            // ignore any errors - this is just an optional feature
            getLogger().debug(NO_JMX_HTML_MSG);
            getLogger().debug("Reason", t);
        }
    }

}
