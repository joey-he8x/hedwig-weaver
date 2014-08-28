package testframework.weaver.managerbean.hedwig;

import java.util.ArrayList;
import java.util.List;

import testframework.weaver.jmx.JmxManagement.ManagedBean;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.yihaodian.architecture.hedwig.client.event.BaseEvent;
import com.yihaodian.architecture.hedwig.client.event.HedwigContext;
import com.yihaodian.architecture.hedwig.client.event.handle.BaseHandler;
import com.yihaodian.architecture.hedwig.client.locator.IServiceLocator;
import com.yihaodian.architecture.hedwig.common.dto.ServiceProfile;

privileged public aspect HedwigContextManager {
	
	public void ServiceProfile.setServiceUrl(String url){
		this.serviceUrl=url;
	}
	
	declare parents: HedwigContext implements IHedwigContextManager,ManagedBean;
	
	public pointcut hedwigDoHandler(HedwigContext h,BaseEvent e):
        execution(* BaseHandler+.doHandle(HedwigContext,BaseEvent)) && args(h,e); 
	
	
	after(HedwigContext context,BaseEvent event) returning(Object rt): hedwigDoHandler(context,event) && if(context.mock==false){
		if (rt!=null){
			getLogger().debug("set last return from: "+context.clientProfile.getServiceAppName());
			context.lastReturn=rt;
		}
	}
	
	Object around(HedwigContext context,BaseEvent event): hedwigDoHandler(context,event) && if(context.mock==true){
		try{
			Thread.sleep(context.mockSimulateTime);
		}catch (InterruptedException e){}
		return context.lastReturn;
	}
	

	/*
	 * implement ManagedBean
	 */
	public List<String> HedwigContext.getAllAvailableIps(){
		List<String> rs=new ArrayList<String>();
		if (this.locator !=null){
			IServiceLocator<ServiceProfile> l = this.locator;
			for (ServiceProfile sp :l.getAllService()){
				if (sp.isAvailable()){
					rs.add(sp.getHostIp());
				}
			}
		}
		return rs;
	}
	
	private IServiceLocator<ServiceProfile> HedwigContext._originLocator;
	
	public void HedwigContext.reset(){
		if (this._originLocator != null && this.locator != this._originLocator){
			this.locator = this._originLocator;
			this._originLocator = null;
		}
	}
	
	public void HedwigContext.setServiceUrl(String url){
		StaticRouteLocator staticlct = new StaticRouteLocator(url);
		if (this._originLocator != null){
			this._originLocator = this.locator;
		}
		this.locator = staticlct;
	}
	
	private Object HedwigContext.lastReturn;
	
	public String HedwigContext.getLastReturn(){
		return JSON.toJSONString(this.lastReturn, SerializerFeature.SkipTransientField.PrettyFormat);
	}
	
	private boolean HedwigContext.mock=false;
	//unit: ms
	private int HedwigContext.mockSimulateTime=5;
	
	public void HedwigContext.setMock(boolean mock){
		this.mock=mock;
	}
	public boolean HedwigContext.getMock(){
		return this.mock;
	}
	
	public void HedwigContext.setMockSimulateTime(int duration){
		this.mockSimulateTime=duration;
	}
	
	public int HedwigContext.getMockSimulateTime(){
		return this.mockSimulateTime;
	}
	
	/*
	 * implement ManagedBean
	 */
	
	public Class HedwigContext.getManagementInterface(){
		return IHedwigContextManager.class;
	}
	public String HedwigContext.getOperationName(){
		return "type=hedwig,pool="+this.clientProfile.getServiceAppName()+",name="+this.clientProfile.getServiceName();
	}

}
