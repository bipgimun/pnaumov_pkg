/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxpha.oracle.apps.icx.sn1041.webui;

import java.io.Serializable;

import java.util.ArrayList;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAFwkConstants;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.jbo.domain.Number;

import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;

/**
 * Controller for ...
 */
public class SearchResultsEAMCO extends OAControllerImpl {
    public static final String RCS_ID = "$Header$";
    public static final boolean RCS_ID_RECORDED = 
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

    public final String CLASS_NAME;    
    private Sn1041Utils utils = Sn1041Utils.getInstance();

    public SearchResultsEAMCO() {
        super();
        this.CLASS_NAME = this.getClass().getName();
    }

    /**
     * Layout and page setup logic for a region.
     * @param pageContext the current OA page context
     * @param webBean the web bean corresponding to the region
     */
    public void processRequest(OAPageContext pageContext, OAWebBean webBean) {
        super.processRequest(pageContext, webBean);
    }

    /**
     * Procedure to handle form submissions for form elements in
     * a region.
     * @param pageContext the current OA page context
     * @param webBean the web bean corresponding to the region
     */
    public void processFormRequest(OAPageContext pageContext, 
                                   OAWebBean webBean) {
        super.processFormRequest(pageContext, webBean);                

        if (pageContext.getParameter("AddSelection") != null) {
            addItemsHandler(pageContext, webBean);
        }
    }

    private void addItemsHandler(OAPageContext pageContext, 
                                 OAWebBean webBean) {
        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        utils.writeDiagnostics(pageContext, 
                               CLASS_NAME + ".processFormRequest : ", 
                               "AddSelection Event!", 
                               OAFwkConstants.PROCEDURE);

        long wipEntityId = utils.getCurrentWipEntityId(am);
        utils.writeDiagnostics(pageContext, 
                               CLASS_NAME + ".addItemsHandler : ", 
                               "wipEntityId = " + wipEntityId, 
                               OAFwkConstants.PROCEDURE);
        
        Serializable[] params = { new Long(wipEntityId) };
        Class[] paramTypes = { Long.class };
        
        ArrayList<OAException> mes = 
            (ArrayList<OAException>)am.invokeMethod("addSelectedItems", 
                                                    params, paramTypes);

        for (OAException m: mes) {
            pageContext.putDialogMessage(m);
        }

        pageContext.forwardImmediatelyToCurrentPage(null, true, null);
    }
}
