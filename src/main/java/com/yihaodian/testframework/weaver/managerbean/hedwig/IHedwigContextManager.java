package com.yihaodian.testframework.weaver.managerbean.hedwig;

import java.util.List;

import com.yihaodian.testframework.weaver.jmx.JmxManagement.ManagedBean;

public interface IHedwigContextManager {
	//public String getServiceUrl();
	List<String> getAllAvailableIps();
	void reset();
	void setServiceUrl(String url);
}
