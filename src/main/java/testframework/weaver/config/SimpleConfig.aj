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

import testframework.weaver.jmx.GuiFriendlyStatsJmxNameStrategy;
import testframework.weaver.jmx.JmxManagement;
import testframework.weaver.jmx.StatsJmxManagement;
import testframework.weaver.track.PerfStatsFactoryImpl;

import java.io.IOException;
import java.rmi.AccessException;
import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.RMISocketFactory;
import java.rmi.server.UnicastRemoteObject;
import java.util.Iterator;
import java.util.Set;

import javax.management.MBeanServer;
import javax.management.ObjectName;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXConnectorServer;
import javax.management.remote.JMXConnectorServerFactory;
import javax.management.remote.JMXServiceURL;

import testframework.weaver.monitor.operation.AbstractOperationMonitor;
import testframework.weaver.monitor.resource.DataAccessFailureDetection;
import testframework.weaver.monitor.resource.JdbcStatementMonitor;

/**
 * Simple system configuration aspect. Let's one set up the system without knowing how to configure an IoC container like Spring.
 * The inspector will be migrating to using Spring for future releases... You can use
 * -Dglassbox.inspector.config.nameStrategy=CanonicalStatsJmxNameStrategy to enable the alternative standard "best practices" JMX
 * naming strategy. The default is to use a GUI friendly-strategy that I prefer. Using a GUI console like JConsole, this approach is
 * less friendly, but it's available if it works better for your tool.
 */
public class SimpleConfig extends AbstractConfigurator {
    private String NAME_STRATEGY = System.getProperty("glassbox.inspector.config.nameStrategy");
    private Registry registry;
    private MBeanServer server;
    private JMXConnectorServer connectorServer;
    
	protected void doConfig() throws Exception {
       
		server = new MBeanServerFactory().getMBeanServer();        
		
		JmxManagement.aspectOf().setMBeanServer(server);
        
//        if (CanonicalStatsJmxNameStrategy.class.getName().equals(NAME_STRATEGY)) {
//            StatsJmxManagement.aspectOf().setNameStrategy(new CanonicalStatsJmxNameStrategy());
//        } else {
            StatsJmxManagement.aspectOf().setNameStrategy(new GuiFriendlyStatsJmxNameStrategy());
//        }

        JdbcStatementMonitor.aspectOf().setFailureDetectionStrategy(new DataAccessFailureDetection());
        
        AbstractOperationMonitor.setPerfStatsFactory(new PerfStatsFactoryImpl());
        
        ensureConnectorServer(server);
	}
    
    // to shutdown we unregister the registry and stop the connector server 
    protected void doShutdown() throws Exception {
        if (registry != null) {
            UnicastRemoteObject.unexportObject(registry, true);
        }
        
        if (connectorServer != null) {
            connectorServer.stop();
        }

//        Set names = server.queryNames(null, null);
//        for (Iterator iter = names.iterator(); iter.hasNext();) {
//            ObjectName name = (ObjectName) iter.next();
//            server.unregisterMBean(name);
//        }
    }
	
	private void ensureConnectorServer(MBeanServer server) throws Exception {
        int port = 7132;
        
        getLogger().debug("Checking RMI registry");              
        if (!rmiRegistryExists(port)) {
            getLogger().info("No RMI registry exists, creating one");              
            RMISocketFactory factory = RMISocketFactory.getDefaultSocketFactory();
            registry = LocateRegistry.createRegistry(port, factory, factory);
        }

        String urlString = "service:jmx:rmi:///jndi/rmi://localhost:"+port+"/GlassboxInspector";
        JMXServiceURL url = new JMXServiceURL(urlString);
        
        try {
            getLogger().debug("Trying to use expose existing JMX server to URL "+url);              
        	JMXConnector connection = JMXConnectorFactory.connect(url);
        	connection.close();
        	// already exists
        } catch (IOException e) {
            getLogger().debug("Trying to create new JMX server for URL "+url);              
	        // Not available so create a connector server
	        connectorServer = JMXConnectorServerFactory.newJMXConnectorServer(url, null, server);
	        connectorServer.start();
        }

        getLogger().info("Started connector server at "+urlString);         		
	}

    private boolean rmiRegistryExists(int port) {
        // there ought to be a cleaner way to test if the registry is up
        try {
            LocateRegistry.getRegistry(port).lookup("zzz");
        } catch (NotBoundException ne) {
            // this is ok; it just means no object by the name exists; weird
        } catch (AccessException ae) {
            // this is ok; it just means the object with that name is inaccessible
        } catch (RemoteException e) { 
            return false;
        }
        return true;
    }
}
