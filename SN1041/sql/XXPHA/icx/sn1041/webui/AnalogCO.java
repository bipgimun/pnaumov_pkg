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
import oracle.apps.fnd.framework.webui.beans.OABodyBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;

import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;


/**
 * Controller for ...
 */
public class AnalogCO extends OAControllerImpl {
    public static final String RCS_ID = "$Header$";
    public static final boolean RCS_ID_RECORDED = 
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

    private final String CLASS_NAME = AnalogCO.class.getName();
    private final Sn1041Utils utils = Sn1041Utils.getInstance();

    public AnalogCO() {
        super();
        //this.CLASS_NAME = this.getClass().getName();
    }

    /**
     * Layout and page setup logic for a region.
     * @param pageContext the current OA page context
     * @param webBean the web bean corresponding to the region
     */
    public void processRequest(OAPageContext pageContext, OAWebBean webBean) {
        super.processRequest(pageContext, webBean);
        String itemId = pageContext.getParameter("ItemId");

        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processRequest", 
                               "ItemId=" + itemId, OAFwkConstants.PROCEDURE);

        String eam = pageContext.getParameter("EAM");
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processRequest", 
                               "eam=" + eam, OAFwkConstants.PROCEDURE);

        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        Serializable[] parameters = { new Long(itemId), Boolean.TRUE };
        Class[] paramTypes = { Long.class, Boolean.class };

        am.invokeMethod("Y".equals(eam) ? "initAnalogQueryEam" : 
                        "initAnalogQuery", parameters, paramTypes);

        OAAdvancedTableBean table = 
            (OAAdvancedTableBean)webBean.findChildRecursive("AnalogAdvTbl");

        // When handling a user initiated search, we always need to execute
        // the query so we pass "false" to queryData().
        table.queryData(pageContext, false);

        pageContext.putJavaScriptLibrary("sn1041s", "sn1041/sn1041_analog.js");

        OABodyBean pb = (OABodyBean)pageContext.getRootWebBean();
        pb.setOnLoad("initPage();");
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

        if (pageContext.getParameter("AddAnalogToSearch") != null) {
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest", 
                                   "AddToSearch Event !!!", 
                                   OAFwkConstants.PROCEDURE);


            ArrayList<OAException> mes = 
                (ArrayList<OAException>)am.invokeMethod("addAnalogSelectedItems");

            for (OAException m: mes) {
                pageContext.putDialogMessage(m);
            }

            //pageContext.setForwardURLToCurrentPage(null,true,null,(byte)0);
        }
    }

}
