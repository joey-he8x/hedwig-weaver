package com.yihaodian.testframework.weaver.managerbean.hedwig;

import java.util.ArrayList;
import java.util.List;

import com.yihaodian.architecture.hedwig.client.event.HedwigContext;
import com.yihaodian.architecture.hedwig.client.locator.IServiceLocator;
import com.yihaodian.architecture.hedwig.common.dto.ServiceProfile;
import com.yihaodian.testframework.weaver.jmx.JmxManagement.ManagedBean;

privileged public aspect HedwigContextManager {
	
	public void ServiceProfile.setServiceUrl(String url){
		this.serviceUrl=url;
	}
	
	declare parents: HedwigContext implements IHedwigContextManager,ManagedBean;
	

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
		}
	}
	
	public void HedwigContext.setServiceUrl(String url){
		StaticRouteLocator staticlct = new StaticRouteLocator(url);
		this._originLocator = this.locator;
		this.locator = staticlct;
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
