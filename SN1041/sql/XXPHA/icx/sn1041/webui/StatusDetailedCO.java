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

import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;

/**
 * Controller for ...
 */
public class StatusDetailedCO extends OAControllerImpl {
    public static final String RCS_ID = "$Header$";
    public static final boolean RCS_ID_RECORDED = 
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

    private final String CLASS_NAME;

    public StatusDetailedCO() {
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

        long orgid = -1;
        long wipEntityId = utils.getCurrentWipEntityId(am);
        if (wipEntityId <= 0) {
            orgid = utils.getCurrentOrgId(am);
        } else {            
            long storeId = utils.getWipOrganizationId(am, wipEntityId);
            orgid = utils.getOrgIdByOrganizationId(am, storeId);
        }
        //OrgID
        Long orgId = new Long(orgid);
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

        Serializable[] parameters = 
        /*new Long(lStoreId), new Long(lCsId), curr*/ { orgId, 
                                                        new Long(itemId), 
                                                        executeQuery };
        Class[] paramTypes = { Long.class, Long.class, Boolean.class };
        am.invokeMethod("initStatusDetailed", parameters, paramTypes);
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
