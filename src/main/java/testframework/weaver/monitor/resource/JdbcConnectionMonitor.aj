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
package testframework.weaver.monitor.resource;

import edu.emory.mathcs.util.collections.WeakIdentityHashMap;
import testframework.weaver.track.PerfStats;

import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Map;

import javax.sql.DataSource;

import testframework.weaver.track.resource.ResourceStats;

/** Monitor performance for JDBC connections, and track database connection information associated with them. */ 
public aspect JdbcConnectionMonitor extends AbstractResourceMonitor {

    /** A call to establish a connection using a <code>DataSource</code> */
    public pointcut dataSourceConnectionCall(DataSource dataSource) : 
        call(Connection+ DataSource.getConnection(..)) && target(dataSource);

    /** A call to establish a connection using a URL string */
    public pointcut directConnectionCall(String url) :
        (call(Connection+ Driver.connect(..))  || call(Connection+ DriverManager.getConnection(..))) && args(url, ..);

    /** A database connection call nested beneath another one (common with proxies). */
    public pointcut nestedConnectionCall() : 
        cflow(execution(* doExecute()) && this(ConnectionRequestContext)); //cflowbelow(dataSourceConnectionCall(*) || directConnectionCall(*));
    
    /** Monitor data source connection calls using the worker object pattern */
    Connection around(final DataSource dataSource) : 
      dataSourceConnectionCall(dataSource) && !nestedConnectionCall() && monitorEnabled()  {
        RequestContext requestContext = new ConnectionRequestContext() {
            public Object doExecute() {
            	// set up stats early, in case we are tracking an error...
            	accessingConnection(dataSource);
                
                Connection connection = proceed(dataSource);

                return addConnection(connection);
            }
            
        };
        return (Connection)requestContext.execute();
    }

    /** Monitor url connections using the worker object pattern */
    Connection around(final String url) : 
      directConnectionCall(url) && !nestedConnectionCall() && monitorEnabled()  {
        RequestContext requestContext = new ConnectionRequestContext() {
            public Object doExecute() {
            	accessingConnection(url);
            	
                Connection connection = proceed(url);
                
                return addConnection(connection);
            }
        };
        return (Connection)requestContext.execute();
    }

    /** Get stored name associated with this data source. */ 
    public String getDatabaseName(Connection connection) {
        synchronized (connections) {
            return (String)connections.get(connection);
        }
    }

    /** Use common accessors to return meaningful name for the resource accessed by this data source. */
    public String getNameForDataSource(DataSource ds) {
        // names are listed in descending preference order 
        String possibleNames[] = { "getDatabaseName", "getDatabasename", "getUrl", "getURL", "getDataSourceName", "getDescription" };
        String name = null;
        for (int i=0; name == null && i<possibleNames.length; i++) {
            try {            
                Method method = ds.getClass().getMethod(possibleNames[i], null);
                name = (String)method.invoke(ds, null);
                if (name!=null && !name.toLowerCase().startsWith("jdbc")) {
                    name = "database:"+name;                    
                }
            } catch (Exception e) {
                // keep trying
            }
        }
        return (name != null) ? name : "unknown";
    }    

    /** Holds JDBC connection-specific context information: a database name and statistics */
    protected abstract class ConnectionRequestContext extends ResourceRequestContext {
        private ResourceStats dbStats;
        private String databaseName;
        
        /** set up context statistics for accessing this data source */ 
        protected void accessingConnection(final DataSource dataSource) {
            accessingConnection(getNameForDataSource(dataSource));
        }
        
        /** set up context statistics for accessing this database */ 
        protected void accessingConnection(String databaseName) {
            this.databaseName = databaseName;
            
            dbStats = lookupResourceStats(databaseName);
        }

        /** record the database name for this database connection */ 
        protected Connection addConnection(final Connection connection) {
            synchronized(connections) {
                connections.put(connection, databaseName);
            }
            return connection;
        }
        
        protected PerfStats lookupStats() {
            return dbStats;
        }
        
        protected Object getKey() {
            return databaseName;
        }

    };

    /** Associates connections with their database names */    
    private Map/*<Connection,String>*/ connections = new WeakIdentityHashMap();
    
    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());

}
