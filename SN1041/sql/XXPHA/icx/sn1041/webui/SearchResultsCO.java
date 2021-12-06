/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================+
 |Контроллер таблицы FoundItemsTbl страница                                  |
 |/xxpha/oracle/ |
 +===========================================================================+
 */
package xxpha.oracle.apps.icx.sn1041.webui;

import java.io.Serializable;

import java.sql.CallableStatement;
import java.sql.Types;

import java.util.ArrayList;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAFwkConstants;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;

import oracle.jbo.Row;
import oracle.jbo.domain.Number;

import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;


/**
 * Controller for ...
 */
public class SearchResultsCO extends OAControllerImpl {
    public static final String RCS_ID = "$Header$";
    public static final boolean RCS_ID_RECORDED = 
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

    public final String CLASS_NAME;
    private Sn1041Utils utils = Sn1041Utils.getInstance();

    public /*static*/String isInVs = "";

    public SearchResultsCO() {
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


        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        //System.out.println(am.getOADBTransaction().getMultiOrgCurrentOrgId());

        //Очистить черновик
        //Sn1041Utils utils = Sn1041Utils.getInstance();
        utils.clearDraft(am);

        OAAdvancedTableBean table = (OAAdvancedTableBean)webBean;

        // When handling a user initiated search, we always need to execute
        // the query so we pass "false" to queryData().
        table.queryData(pageContext, false);
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

        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        if (pageContext.getParameter("AddSelection") != null) {

            utils.writeDiagnostics(pageContext, 
                                                       CLASS_NAME + 
                                                       ".processFormRequest : ", 
                                                       "AddSelection Event!", 
                                                       OAFwkConstants.PROCEDURE);

            long storeId = Sn1041Utils.getInstance().getCurrentStoreId(am);
            Number nStoreId = new Number(storeId);

            Serializable[] parameters = { nStoreId };
            Class[] paramTypes = { Number.class };


            utils.writeDiagnostics(pageContext, 
                                                       CLASS_NAME + 
                                                       ".processFormRequest : ", 
                                                       "Parameter nStoreId " + 
                                                       nStoreId, 
                                                       OAFwkConstants.PROCEDURE);

            ArrayList<OAException> mes = 
                (ArrayList<OAException>)am.invokeMethod("addSelectedItems", 
                                                        parameters, 
                                                        paramTypes);

            for (OAException m: mes) {
                pageContext.putDialogMessage(m);
            }


            pageContext.forwardImmediatelyToCurrentPage(null, true, null);
        }
        
        else if (pageContext.getParameter("AddSelectionEam") != null) {
            addItemsHandler(pageContext, webBean);
        }

        else if (pageContext.getParameter("RefreshPrice") != null) {
            refreshPrice(pageContext, webBean);
        }

    }

    void refreshPrice(OAPageContext pageContext, OAWebBean webBean) {
        Sn1041Utils utils = Sn1041Utils.getInstance();
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".refreshPrice", 
                               "Start", OAFwkConstants.PROCEDURE);
        OAApplicationModule oa = pageContext.getApplicationModule(webBean);
        ArrayList<OAException> mes = 
            (ArrayList<OAException>)oa.invokeMethod("refreshPrice");
        for (OAException m: mes) {
            pageContext.putDialogMessage(m);
        }
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".refreshPrice", "OK", 
                               OAFwkConstants.PROCEDURE);
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
