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


// commented out to work-around AspectJ bug as of 9 Sept. 2005
public /* workaround: should NOT be abstract */  aspect XmlParsingMonitor extends AbstractXmlProcessingMonitor {
    // debugging:
//    after() returning (Document doc) : parseCall() {
//        getLogger().debug("parsed "+doc.getDocumentURI());
//    }
    protected pointcut isMonitorEnabled() : if(aspectOf().isEnabled());
//    
//    Object around() : parseCall() && monitorEnabled() {
//        RequestContext requestContext = new XmlRequestContext() {
//            Document document;
//            public Object doExecute() {
//                document = (Document)proceed();
//                return document;
//            }
//            
//            public PerfStats lookupStats() {
//                return lookupDocumentStats(document);
//            }
//            
//        };
//        return requestContext.execute();
//    }    
}
