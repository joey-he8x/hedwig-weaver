package testframework.weaver.monitor.resource;

import com.yihaodian.architecture.hedwig.client.event.BaseEvent;
import com.yihaodian.architecture.hedwig.client.event.HedwigContext;

public aspect HedwigCallMonitor extends AbstractResourceMonitor {
    /** JAXM call to invoke Web service */
	public pointcut hedwigHandle(HedwigContext context, BaseEvent event):
		
    public pointcut hessianCall(Object soapConnection, Object msg, Object endPoint) : 
        withincode(* BaseHandler+.doHandle(..)) && call(public * javax.xml.soap.SOAPConnection.call*(..)) && target(soapConnection) && args(msg, endPoint);

    /** Monitor jax rpc reflective calls based on call metadata */
    Object around(final Object soapConnection, final Object msg, final Object endPoint) : 
            jaxmCall(soapConnection, msg, endPoint) && monitorEnabled() {
        RequestContext requestContext = new ResourceRequestContext() {
            
            public Object doExecute() {
                return proceed(soapConnection, msg, endPoint);
            }
            
            public Object getKey() {
                return endPoint.toString();
            }
            
        };
        return requestContext.execute();
    }
    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
}
