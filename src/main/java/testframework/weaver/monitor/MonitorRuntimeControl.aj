package testframework.weaver.monitor;

import java.lang.reflect.Field;

import testframework.weaver.config.Configurator;

/**
 * This aspect is responsible for managing whether or not any given monitor is enabled at runtime.
 * 
 * 
 */
/*
 * This is a bit tricky because we register aspects for JMX management when they are constructed, but registering for JMX management
 * might invoke other monitored code, like remote calls or JDBC code. So we need to disable monitoring when the system is being configured and also whenever we haven't constructed the given aspect.
 */
public aspect MonitorRuntimeControl pertypewithin(AbstractRequestMonitor+) {
    private boolean enabled = false;
    private static boolean globallyEnabled = true;
    
    after() returning: execution(new(..)) {
        enabled = true;
    }
    
    Object around() : execution(* Configurator.config(..)) {
        globallyEnabled = false;
        Object ret = proceed();
        globallyEnabled = true;
        return ret;
    }
    
    public static final boolean AbstractRequestMonitor.isEnabled(Class clazz) {
        return globallyEnabled && aspectOf(clazz).enabled;
    }
    
    public final boolean AbstractRequestMonitor.isEnabled() {
        return isEnabled(getClass());
    }
    
    public final void AbstractRequestMonitor.setEnabled(boolean enabled) {
        aspectOf(getClass()).enabled = enabled;
    }
    
    public static boolean isGloballyEnabled() {
        return globallyEnabled;
    }
    
    public static void setGloballyEnabled(boolean enabled) {
        globallyEnabled = enabled;
    }
    
    //future: ThreadLocal to control enabling/disabling request sampling...
    //  private int sampleRate
    //  protected boolean shouldSample() { if (ctr++ % freq < lim�
   
}
