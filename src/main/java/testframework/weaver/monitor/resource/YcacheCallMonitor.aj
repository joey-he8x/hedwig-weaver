package testframework.weaver.monitor.resource;

import com.ycache.danga.MemCached.MemCachedClient;

public aspect YcacheCallMonitor extends AbstractResourceMonitor {
    
	public pointcut memcachedOp():
		execution(public * MemCachedClient.*(String,..));

    Object around() : 
    	memcachedOp() && monitorEnabled() {
    	final String op = "ycached:"+thisJoinPointStaticPart.getSignature().getName();
    	
        RequestContext requestContext = new ResourceRequestContext() {
            
            public Object doExecute() {
                return proceed();
            }
            
            public Object getKey() {
                return op.intern();
            }
            
        };
        return requestContext.execute();
    }
    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
}
