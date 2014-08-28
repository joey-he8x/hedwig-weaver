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

import testframework.weaver.track.PerfStats;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

public abstract aspect AbstractXmlCallMonitor extends AbstractXmlProcessingMonitor {
    // monitoring arbitrary DOM or Sax calls is too fine-grained to do in general
    // if you WANT to monitor them in some context, then extend this abstract aspect
    // to supply a concrete scope for these
    protected pointcut scope();
    Object around(final Node node) : domCall(node) && !inXmlRequest() && monitorEnabled() {
        RequestContext requestContext = new XmlRequestContext() {           
            public Object doExecute() {
                return proceed(node);
            }
            
            public Object getKey() {
                Document doc;
                if (node instanceof Document) {
                    doc = (Document)node;
                } else {
                    doc = node.getOwnerDocument();
                }
                return doc;
            }
            
        };
        return requestContext.execute();
    }
}
