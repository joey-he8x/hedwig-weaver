package testframework.weaver.monitor.operation;

public aspect JaxmOperationMonitor extends AbstractOperationMonitor {

    public pointcut jaxmMethodInvocation(Object listener, Object message) :
        execution(* javax.xml.messaging.ReqRespListener.onMessage(*)) && this(listener) && args(message);
    
    protected pointcut classControllerExec(Object controller) :
        jaxmMethodInvocation(controller, *);
        
    // TODO: make this depend on the message/endpoint... 
    
    protected String getContextName(Object controller) {
        return controller.getClass().getName();
    }
    
    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());

}
