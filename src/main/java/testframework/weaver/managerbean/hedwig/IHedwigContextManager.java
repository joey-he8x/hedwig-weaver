package testframework.weaver.managerbean.hedwig;

import java.util.List;

import testframework.weaver.jmx.JmxManagement.ManagedBean;

public interface IHedwigContextManager {
	//public String getServiceUrl();
	List<String> getAllAvailableIps();
	void reset();
	void setServiceUrl(String url);
	String getLastReturn();
	void setMock(boolean mock);
	boolean getMock();
	void setMockSimulateTime(int mockSimulateTime);
	int getMockSimulateTime();
}
