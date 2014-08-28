package testframework.weaver.managerbean.ehcache;

import java.lang.management.ManagementFactory;

import javax.management.MBeanServer;

import net.sf.ehcache.CacheManager;
import net.sf.ehcache.management.ManagementService;

public aspect EhchacheManager {

    private pointcut cacheManagerConstruction(CacheManager cm) : 
        execution(CacheManager.new(..)) && this(cm); 
    
    after(CacheManager cm) returning: cacheManagerConstruction(cm) {
    	cm.getCacheNames();
//    	MBeanServer mBeanServer = ManagementFactory.getPlatformMBeanServer();
//    	ManagementService.registerMBeans(cm, mBeanServer, false, false, false, true);
    }
    
}
