package testframework.weaver.monitor.resource;

import testframework.weaver.monitor.FailureDetectionStrategy;

import org.aspectj.lang.JoinPoint.StaticPart;
//import org.springframework.dao.ConcurrencyFailureException;
//import org.springframework.dao.DataIntegrityViolationException;

/** 
 * Conservative detection strategy: failures from SQL that often
 * indicate valid business conditions are not flagged as failures.
 */
public class DataAccessFailureDetection implements FailureDetectionStrategy {
  public boolean isFailure(Throwable t, StaticPart staticPart) {
//      return !(t instanceof ConcurrencyFailureException) ||
//          !(t instanceof DataIntegrityViolationException);
	  return true;
  }
}
