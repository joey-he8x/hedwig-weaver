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

import java.util.Arrays;
import java.util.Timer;
import java.util.TimerTask;

import testframework.weaver.monitor.AbstractRequestMonitor;

public abstract class AbstractConfigurator implements Configurator {

    boolean uninitialized = true;
    public synchronized final void config() {
        try {
            uninitialized = false;
            doConfig();
            ensureRmiShutdown();
            getLogger().info("+++ Glassbox Inspector Started Successfully +++");
        } catch (Throwable t) {
            getLogger().error("Can't initialize Glassbox inspector", t);
        }
    }
    
    protected abstract void doConfig() throws Exception;
    
    public synchronized final void shutdown() {
        try {
            doShutdown();
            uninitialized = true;
        } catch (Exception e) {
            getLogger().warn("Exception in shutdown", e);            
        }
    }
    
    protected abstract void doShutdown() throws Exception;
    
    // this is an ugly work-around for the requirement to unregister all RMI objects before
    // system shutdown
    private final long interval = 1000; // check for shutdown once per second

    private ThreadGroup[] allThreadGroups = new ThreadGroup[200];

    private Thread[] allThreads = new Thread[500];
    private Thread lastThread; 

    protected void ensureRmiShutdown() {
        Timer checkForShutdownTimer = new Timer(true);
        checkForShutdownTimer.scheduleAtFixedRate(new TimerTask() {
            public void run() {
                if (systemShuttingDown()) {
                    shutdown();
                }
            }
        }, interval, interval);
    }

    // this method looks at all the threads in the system, to see if the system is waiting for RMI to let it shutdown 
    public boolean systemShuttingDown() {
        try {
            int threadNcount = 0;
            ThreadGroup tg = Thread.currentThread().getThreadGroup();
            while (tg.getParent() != null) {
                tg = tg.getParent();
            }

            int nGroups = tg.enumerate(allThreadGroups, true);
            if (nGroups == allThreadGroups.length) {
                // we might have more!
                return false;
            }
            for (int i = 0; i < nGroups; i++) {
                int nThreads = allThreadGroups[i].enumerate(allThreads);
                if (nThreads == allThreads.length) {
                    // we might have more!
                    clearThreads();
                    return false;
                }
                for (int j = 0; j < nThreads; j++) {
                    // Sun VM's use a thread named DestroyJavaVM...
                    if (!allThreads[j].isDaemon() && !"RMI Reaper".equals(allThreads[j].getName()) && !"DestroyJavaVM".equals(allThreads[j].getName())
                            // JRockIt seems to use Thread-## as a name... so we will shutdown if that's the only other non-deamon thread left running 
                            && (allThreads[j].getName().indexOf("Thread-")!=0 || threadNcount++ > 0)) {
                        if (getLogger().isDebugEnabled()) {
                            if (lastThread != allThreads[j]) {
                                lastThread = allThreads[j];
                                getLogger().debug("Alive: "+lastThread.getName()+", "+lastThread.isDaemon());
                            }
                        }
                        clearThreads();
                        return false;
                    }
                    //TODO: investigate what IBM/other VM's do...
                }
            }
            return true;
        } catch (SecurityException _) {
            getLogger().debug("Unable to ensure system shutdown");
        }
        return false;
    }

    private void clearThreads() {
        Arrays.fill(allThreads, null);
        Arrays.fill(allThreadGroups, null);
    }

}
