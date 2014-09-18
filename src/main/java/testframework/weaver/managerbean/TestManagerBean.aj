//package testframework.weaver.managerbean;
//
//import testframework.weaver.jmx.JmxManagement.ManagedBean;
//
//import com.mycompany.jmx.test1.jmx.PlainTestPojo;
//
//public aspect TestManagerBean {
//	declare parents: com.mycompany.jmx.test1.jmx.PlainTestPojo implements ManagedBean;
//	public Class PlainTestPojo.getManagementInterface(){
//		return com.mycompany.jmx.test1.jmx.StandardMBeanTestMBean.class;
//	}
//	public String PlainTestPojo.getOperationName(){
//		return "name=TestManagerBean";
//	}
//}
