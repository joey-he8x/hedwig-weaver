package testframework.weaver.monitor.operation;

import java.lang.reflect.Method;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.HandlerAdapter;
import org.springframework.web.bind.annotation.support.HandlerMethodInvoker;


public aspect SpringMvcAnnotatedMonitor extends AbstractOperationMonitor {
    
    public pointcut annotationHandlerExec() :
        execution(public ModelAndView HandlerAdapter+.handle(HttpServletRequest, HttpServletResponse,Object)) ;
    
    protected pointcut methodControllerExec(Object controller, Method method) :
    	cflow(annotationHandlerExec()) && execution(* HandlerMethodInvoker+.invokeHandlerMethod(..)) && args(method, controller, ..);
    

    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
}