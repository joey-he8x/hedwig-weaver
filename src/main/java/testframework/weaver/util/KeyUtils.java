package testframework.weaver.util;

public class KeyUtils {

    /** Concatenates keys by creating a dotted string, e.g., className.methodName. */ 
    public static String concatenatedKey(Class aClass, String methodName) {
        return (aClass.getName()+"."+methodName).intern();        
    }
    

}
