/********************************************************************
 * Copyright (c) 2005 Glassbox Corporation, Contributors.
 * All rights reserved. 
 * This program and the accompanying materials are made available 
 * under the terms of the Common Public License v1.0 
 * which accompanies this distribution and is available at 
 * http://www.eclipse.org/legal/cpl-v10.html 
 *  
 * Contributors: 
 *     Ron Bodkin     initial implementation 
 *******************************************************************/
package testframework.weaver.monitor.component;

import java.lang.reflect.Method;

import javax.xml.parsers.DocumentBuilder;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

import testframework.weaver.monitor.resource.AbstractResourceMonitor;
import testframework.weaver.track.resource.ResourceStats;

public abstract aspect AbstractXmlProcessingMonitor extends AbstractResourceMonitor {
    static Method getDocUriMethod = null;
    static {
        // ignore exceptions: just don't get URI's...
        try {
            getDocUriMethod = Document.class.getMethod("getDocumentURI", null);
        } catch (NoSuchMethodException e) {
        } catch (SecurityException e) {            
        }
    }
    public pointcut parseCall() : 
        call(public * DocumentBuilder.parse(..));
    
    public pointcut domCall(Node node) : 
        call(* org.w3c.dom..*(..)) && target(node);
    
    public pointcut saxCall() :
        call(* org.xml.sax..*(..));

    protected pointcut inXmlRequestBind(RequestContext context) : 
        inRequest(context) && if(context instanceof XmlRequestContext);
    
    public pointcut inXmlRequest() : 
        inXmlRequestBind(*);

    protected abstract class XmlRequestContext extends ResourceRequestContext {
        ResourceStats lookupDocumentStats(Document doc) {
            String docUri = null;
            // Dom Level 3 only ... comes with Java 1.5
            if (doc != null && getDocUriMethod != null) {
                try {
                    docUri = (String)getDocUriMethod.invoke(doc, null);
                } catch (Exception e) {
                    // can't get URI... don't monitor
                    getLogger().warn("Can't get document URI: docUri", e);
                    return null;
                }
            }
            if (docUri == null) {
                docUri = "new";
            }
            return lookupResourceStats("xml."+docUri);
        }
    }
}
