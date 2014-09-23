package testframework.weaver.monitor.resource;

import org.aopalliance.intercept.MethodInvocation;

import com.yihaodian.architecture.hedwig.common.dto.ServiceProfile;

import com.yihaodian.architecture.hedwig.client.event.BaseEvent;
import com.yihaodian.architecture.hedwig.client.event.HedwigContext;
import com.yihaodian.architecture.hedwig.client.event.engine.HedwigEventEngine;

public aspect HedwigCallMonitor extends AbstractResourceMonitor {
    /** JAXM call to invoke Web service */
	public pointcut hedwigHandle(HedwigContext context, BaseEvent event):
		execution(* HedwigEventEngine.syncPoolExec(..)) && args(context, event);

    Object around(final HedwigContext context, final BaseEvent event) : 
    	hedwigHandle(context, event) && monitorEnabled() {
    	ServiceProfile sp = context.getLocator().getService();
    	MethodInvocation invocation = event.getInvocation();
    	final String method = new StringBuilder("hedwig_call:").append(sp.getServiceName()).append(".").append(invocation.getMethod().getName()).toString();
    	
        RequestContext requestContext = new ResourceRequestContext() {
            
            public Object doExecute() {
                return proceed(context, event);
            }
            
            public Object getKey() {
                return method.intern();
            }
            
        };
        return requestContext.execute();
    }
    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
}
