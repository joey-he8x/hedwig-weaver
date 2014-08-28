package testframework.weaver.config;

import testframework.weaver.monitor.AbstractRequestMonitor;

public aspect Initialization {
    /**
     * Use -Dglassbox.inspector.config.Configurator to override the default of using the simple configurator.
     * We use the Simple configurator to avoid issues from classloader resolution in Spring apps that deploy their 
     * own version of Spring to WEB-INF/lib due to resolving some classes with the non-delegating Web app classloader and 
     * others with the shared loader.
     *  
     * We plan resolve this in future by doing configuration in a separate environment (e.g., a Web app).
     */
    private static String configurationClass = System.getProperty("glassbox.inspector.config.Configurator");
    private static AbstractConfigurator configurator = makeConfigurator(configurationClass);
    
    protected pointcut initializationPoint() : 
        execution(AbstractRequestMonitor+.new(..)) && if(configurator.uninitialized); 
    
    protected pointcut startup() : 
        (initializationPoint() && !cflowbelow(initializationPoint())) || staticinitialization(javax.servlet.Servlet+);
    
    after() returning: startup() {
    	System.out.println("doConfig");
    	getLogger().error("doConfig");
        configurator.config();
    }
    
    private static AbstractConfigurator makeConfigurator(String configurationClass) {
        try {
            return (AbstractConfigurator)Class.forName(configurationClass).newInstance();
        } catch (Exception e) {
            return new SimpleConfig();            
        }
    }

    public static void setInitialized(boolean initialized) {
        configurator.uninitialized = !initialized;
    }

    public static boolean isInitialized() {
        return !configurator.uninitialized;
    }

}
