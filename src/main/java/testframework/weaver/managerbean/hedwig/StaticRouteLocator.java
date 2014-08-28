package testframework.weaver.managerbean.hedwig;

import java.net.URI;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import com.yihaodian.architecture.hedwig.client.locator.IServiceLocator;
import com.yihaodian.architecture.hedwig.common.dto.ServiceProfile;

public class StaticRouteLocator implements IServiceLocator<ServiceProfile>{
	private ServiceProfile serviceProfile;
	private List<ServiceProfile> container = new ArrayList<ServiceProfile>(1);
	
	public StaticRouteLocator(String serviceUrl){
		URI uri = URI.create(serviceUrl);
		ServiceProfile sp = new ServiceProfile();
		sp.setHostIp(uri.getHost());
		sp.setPort(uri.getPort());
		sp.setServiceUrl(serviceUrl);
		this.serviceProfile = sp;
		this.container.add(sp);
	}
	
	public ServiceProfile getService(){
		return serviceProfile;
	}

	public Collection<ServiceProfile> getAllService(){
		return container;
	}
}
