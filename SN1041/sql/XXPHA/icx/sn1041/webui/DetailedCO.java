/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxpha.oracle.apps.icx.sn1041.webui;

import java.io.Serializable;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAFwkConstants;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;

import oracle.jbo.domain.Number;

import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;


/**
 * Controller for ...
 */
public class DetailedCO extends OAControllerImpl {
    public static final String RCS_ID = "$Header$";
    public static final boolean RCS_ID_RECORDED = 
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

    private final String CLASS_NAME;

    public DetailedCO() {
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

        Sn1041Utils utils = Sn1041Utils.getInstance();
        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        Boolean executeQuery = Boolean.TRUE;

        //OrgID
        Long orgId = new Long(utils.getCurrentOrgId(am));
        if (orgId == -1) {
            orgId = new Long(pageContext.getOrgId());
        }
        Sn1041Utils.getInstance().writeDiagnostics(pageContext, 
                                                   CLASS_NAME + ".processRequest", 
                                                   "orgId = " + orgId, 
                                                   OAFwkConstants.PROCEDURE);

        //ItemID
        String itemIdStr = pageContext.getParameter("ItemId");
        Sn1041Utils.getInstance().writeDiagnostics(pageContext, 
                                                   CLASS_NAME + ".processRequest", 
                                                   "itemIdStr = " + itemIdStr, 
                                                   OAFwkConstants.PROCEDURE);
        long itemId = -1;
        if (itemIdStr != null && !itemIdStr.equals("")) {
            itemId = new Long(itemIdStr).longValue();

            Sn1041Utils.getInstance().writeDiagnostics(pageContext, 
                                                       CLASS_NAME + 
                                                       ".processRequest", 
                                                       "itemId = " + itemId, 
                                                       OAFwkConstants.PROCEDURE);
        }

        String curr = pageContext.getParameter("Curr");
        Sn1041Utils.getInstance().writeDiagnostics(pageContext, 
                                                   CLASS_NAME + ".processRequest", 
                                                   "curr = " + curr, 
                                                   OAFwkConstants.PROCEDURE);

        //StoreId
        String storeId = pageContext.getParameter("StoreId");
        Sn1041Utils.getInstance().writeDiagnostics(pageContext, 
                                                   CLASS_NAME + ".processRequest", 
                                                   "storeId = " + storeId, 
                                                   OAFwkConstants.PROCEDURE);

        long lStoreId = -1;
        if (storeId != null && !storeId.equals("")) {
            lStoreId = new Long(storeId).longValue();

            Sn1041Utils.getInstance().writeDiagnostics(pageContext, 
                                                       CLASS_NAME + 
                                                       ".processRequest", 
                                                       "lStoreId = " + 
                                                       lStoreId, 
                                                       OAFwkConstants.PROCEDURE);
        }


        String csId;
        long lCsId = -1;
        if ("N".equals(curr)) {
            csId = pageContext.getParameter("CsId");
            Sn1041Utils.getInstance().writeDiagnostics(pageContext, 
                                                       CLASS_NAME + 
                                                       ".processRequest", 
                                                       "csId = " + csId, 
                                                       OAFwkConstants.PROCEDURE);
            if (csId != null && !csId.equals("")) {
                lCsId = new Long(csId).longValue();

                Sn1041Utils.getInstance().writeDiagnostics(pageContext, 
                                                           CLASS_NAME + 
                                                           ".processRequest", 
                                                           "lCsId = " + lCsId, 
                                                           OAFwkConstants.PROCEDURE);
            }
        }
        /*
        if (whType != null){
            lWhType = new Long(whType).longValue();
        }


        Sn1041Utils.getInstance().writeDiagnostics(pageContext,
                                                   CLASS_NAME + ".processRequest",
                                                   "whType =" + whType,
                                                   OAFwkConstants.PROCEDURE);
        */

        Serializable[] parameters = 
        { orgId, new Long(itemId), new Long(lStoreId), new Long(lCsId), curr, 
          executeQuery };
        Class[] paramTypes = 
        { Long.class, Long.class, Long.class, Long.class, String.class, 
          Boolean.class };
        am.invokeMethod("initDetailed", parameters, paramTypes);

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
    }

}
