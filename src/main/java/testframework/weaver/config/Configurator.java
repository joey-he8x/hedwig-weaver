package testframework.weaver.config;

public interface Configurator {
    public void shutdown() throws Exception;
    public void config() throws Exception;
}
