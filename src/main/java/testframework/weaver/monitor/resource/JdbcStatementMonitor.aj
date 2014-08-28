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

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Map;

import testframework.weaver.track.operation.OperationStats;
import testframework.weaver.track.resource.ResourceStats;

/**
 * Monitor performance for executing JDBC statements, and track the connections
 * used to create them, and the (sanitized) underlying SQL string being executed.
 * 
 * N.B.: the JDBC connection monitor must be enabled to enable this monitor to function.
 */
public aspect JdbcStatementMonitor extends AbstractResourceMonitor {

    /** Matches any execution of a JDBC statement */
    public pointcut statementExec(Statement statement) : 
        call(* java.sql..*.execute*(..)) && target(statement);

    /**
     * Store the sanitized SQL for dynamic statements. 
     */
    before(Statement statement, String sql): statementExec(statement) && args(sql, ..) && monitorEnabled() {
        sql = stripAfterWhere(sql);
        setUpStatement(statement, sql);
    }

    /** Monitor performance for executing a JDBC statement. */
    Object around(final Statement statement) : statementExec(statement) && monitorEnabled()  {
        RequestContext requestContext = new StatementRequestContext() {
            public Object doExecute() {
            	curStatement = statement;
                //if (isDebugEnabled()) { getLogger().debug("exec stmt "+statement+" at "+thisJoinPoint.getThis()); }
                return proceed(statement);
            }
        	protected String getRequestType() { return "execute"; }            
        };
        return requestContext.execute();
    }

    /** 
     * Call to create a Statement.
     * @param connection the connection called to create the statement, which is bound to track the statement's origin 
     */
    public pointcut callCreateStatement(Connection connection):
        call(Statement+ Connection.*(..)) && target(connection);

    /** Track origin of statements, to properly associate statistics even in the presence of wrapped connections */
    // Order matters here: this after advice needs to register the connection before trying to look it up after completing the call to prepare the 
    // statement in the monitoring around advice. So we place this advice first to ensure it has has higher precedence 
    after(Connection connection) returning (Statement statement): callCreateStatement(connection) && monitorEnabled() {
        synchronized (JdbcStatementMonitor.this) {
        	statementCreators.put(statement, connection);
        }
    }
    
    /** 
     * A call to prepare a statement.
     * @param sql The SQL string prepared by the statement. 
     */
    public pointcut callCreatePreparedStatement(String sql):
        call(PreparedStatement+ Connection.*(String, ..)) && args(sql, ..);

    /** Monitor time to prepare statement. Also tracks SQL used to prepare it. */
    Object around(final String sql) : callCreatePreparedStatement(sql) && monitorEnabled()  {
        RequestContext requestContext = new StatementRequestContext() {
            public Object doExecute() {
            	curStatement = (PreparedStatement)proceed(sql);
            	//if (isDebugEnabled()) { getLogger().debug("prepared "+sql+" at "+thisJoinPoint.getSourceLocation()); }
                setUpStatement(curStatement, sql);
                return curStatement;
            }
        	protected String getRequestType() { return "prepare"; }            
        };
        return requestContext.execute();
    }
        
    protected abstract class StatementRequestContext extends RequestContext {
    	public Statement curStatement;
    	protected abstract String getRequestType();

        /** Find statistics for this statement, looking for its SQL string in the parent request's statistics context */
        protected PerfStats lookupStats() {
            if (getParent() != null) {
                Connection connection = null;
                String sql = null;

                synchronized (JdbcStatementMonitor.this) {
                    connection = (Connection) statementCreators.get(curStatement);
                    sql = (String) statementSql.get(curStatement);
                }

                if (connection != null) {
                    String databaseName = JdbcConnectionMonitor.aspectOf().getDatabaseName(connection);
                    if (databaseName != null && sql != null) {
                        OperationStats opStats = (OperationStats) getParent().getStats();
                        if (opStats != null) {
                            ResourceStats dbStats = opStats.getResourceStats(databaseName);
                            
//                          // if (isDebugEnabled()) { getLogger().debug("looking up stats for "+getRequestType()+"^"+sql); }

                            //better:
                            //return dbStats.getRequestStats(sql).getRequestStats(getRequestType());
                            return dbStats.getRequestStats(sql+"^"+getRequestType());
                        }
                    }
                }
            }
            return null;
        }    	
    }
    
    /** 
     * to group sensibly and to avoid recording sensitive data, I don't record the where clause (only used for dynamic SQL since parameters aren't included in prepared statements)
     * @return subset of passed SQL up to the where clause
     */
    public static String stripAfterWhere(String sql) {
        for (int i = 0; i < sql.length() - 4; i++) {
            if (sql.charAt(i) == 'w' || sql.charAt(i) == 'W') {
                if (sql.substring(i + 1, i + 5).equalsIgnoreCase("here")) {
                    sql = sql.substring(0, i);
                }
            }
        }
        return sql;
    }
    
    private synchronized void setUpStatement(Statement statement, String sql) {
        statementSql.put(statement, sql);
    }

    /** associate statements with the connections called to create them */
    private Map/* <Statement,Connection> */statementCreators = new WeakIdentityHashMap();
    
    /** associate statements with the underlying string they execute */
    private Map/* <Statement,String> */statementSql = new WeakIdentityHashMap();
    
    // the JDBC statement monitor relies on the JDBC connection monitor to do its work... so it can't be enabled if the
    // the latter isn't
    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled()) && if(JdbcConnectionMonitor.aspectOf().isEnabled());
}
