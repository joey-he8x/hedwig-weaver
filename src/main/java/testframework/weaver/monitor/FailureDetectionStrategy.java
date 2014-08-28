package testframework.weaver.monitor;

import org.aspectj.lang.JoinPoint.StaticPart;

public interface FailureDetectionStrategy {
    boolean isFailure(Throwable t, StaticPart staticPart);
}
