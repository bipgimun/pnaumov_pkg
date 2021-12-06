/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxpha.oracle.apps.icx.sn1041.webui;

import com.sun.java.util.collections.HashMap;

import java.io.Serializable;

import java.util.Date;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAFwkConstants;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OABodyBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OAFormValueBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageDateFieldBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageLovInputBean;
import oracle.apps.fnd.framework.webui.beans.nav.OALinkBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;

import oracle.apps.icx.por.common.webui.ClientUtil;

import oracle.jbo.Row;
import oracle.jbo.domain.Number;

import xxpha.oracle.apps.icx.sn1041.lov.server.SubInvVOImpl;
import xxpha.oracle.apps.icx.sn1041.server.ActiveCartVOImpl;
import xxpha.oracle.apps.icx.sn1041.server.SearchAMImpl;
import xxpha.oracle.apps.icx.sn1041.utils.ResultForInvoce;
import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;


///


/**
 * Controller for ...
 */
public class Table5CO extends OAControllerImpl {
    public static final String RCS_ID = "$Header$";
    public static final boolean RCS_ID_RECORDED = 
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

    public final String CLASS_NAME;

    private Sn1041Utils utils = Sn1041Utils.getInstance();

    public Table5CO() {
        super();
        this.CLASS_NAME = this.getClass().getName();
    }

    /**
     * Layout and page setup logic for a region.
     * @param pageContext the current OA page context
     * @param webBean the web bean corresponding to the region
     */
    public void processRequest(OAPageContext pageContext, OAWebBean webBean) {
        SearchAMImpl am = 
            (SearchAMImpl)pageContext.getApplicationModule(webBean);

        if (((OADBTransaction)am.getTransaction()).getDialogMessages() != 
            null) {
            ((OADBTransaction)am.getTransaction()).getDialogMessages().clear();
        }

        Sn1041Utils utils = Sn1041Utils.getInstance();
        //run refresh proc
        am.invokeMethod("refreshTable5VO");

        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processRequest", 
                               "start", OAFwkConstants.PROCEDURE);

        super.processRequest(pageContext, webBean);

        pageContext.putJavaScriptLibrary("sn1041s", "sn1041/sn1041_req.js");
        OABodyBean pb = (OABodyBean)pageContext.getRootWebBean();
        pb.setOnLoad("initPage();");

        OAAdvancedTableBean table = 
            (OAAdvancedTableBean)webBean.findChildRecursive("Table5");
        // When handling a user initiated search, we always need to execute
        // the query so we pass "false" to queryData().
        table.queryData(pageContext, false);


        OAFormValueBean organizationId = 
            (OAFormValueBean)webBean.findChildRecursive("organizationId");


        //Set NeedByDate
        OAMessageDateFieldBean needByDateBean = 
            (OAMessageDateFieldBean)webBean.findIndexedChildRecursive("NeedByDate");
        if (needByDateBean != null) {
            if (needByDateBean.getValue(pageContext) == null && 
                utils.getNeedByDate() != null) {
                utils.writeDiagnostics(pageContext, 
                                       CLASS_NAME + ".processRequest", 
                                       "get  NeedByDate " + 
                                       needByDateBean.getValue(), 
                                       OAFwkConstants.PROCEDURE);
                needByDateBean.setValue(pageContext, utils.getNeedByDate());
            }
        }

        String wipEntityId = pageContext.getParameter("WIP_ENTITY_ID");

        long lWipEntityId = utils.getCurrentWipEntityId(am);

        if (wipEntityId == null && lWipEntityId == -1) {
            //Set SubInv
            if (organizationId != null) {
                organizationId.setValue(pageContext, 
                                        utils.getCurrentStoreId(am));

                SubInvVOImpl vo = am.getSubInvVO2();

                vo.setWhereClause("SECONDARY_INVENTORY_NAME in (:1, :2) and ORGANIZATION_ID = :3 and rownum = 1");
                vo.setWhereClauseParam(0, 
                                       pageContext.getProfile("XXPHA_SN775_USER_WORKSHOP_INV"));
                vo.setWhereClauseParam(1, 
                                       pageContext.getProfile("POR_DEFAULT_SUBINVENTORY"));
                vo.setWhereClauseParam(2, 
                                       Sn1041Utils.getInstance().getCurrentStoreId(am));

                utils.writeDiagnostics(am, CLASS_NAME + ".processRequest", 
                                       "XXPHA_SN775_USER_WORKSHOP_INV  =" + 
                                       pageContext.getProfile("XXPHA_SN775_USER_WORKSHOP_INV") + 
                                       " POR_DEFAULT_SUBINVENTORY  =" + 
                                       pageContext.getProfile("POR_DEFAULT_SUBINVENTORY") + 
                                       " getCurrentStoreId  =" + 
                                       Sn1041Utils.getInstance().getCurrentStoreId(am), 
                                       OAFwkConstants.PROCEDURE);


                vo.executeQuery();
                String subInv = null;

                while (vo.hasNext()) {
                    subInv = 
                            (String)vo.next().getAttribute("SecondaryInventoryName");
                }


                //Get SubinvBean           
                utils.writeDiagnostics(am, CLASS_NAME + ".processRequest", 
                                       "subInv =" + subInv, 
                                       OAFwkConstants.PROCEDURE);

                OAMessageLovInputBean lovBean = 
                    (OAMessageLovInputBean)webBean.findChildRecursive("subInvLov");

                if (subInv != null) {
                    lovBean.setValue(pageContext, subInv);
                } else if (utils.getSubInv() != null) {
                    lovBean.setValue(pageContext, utils.getSubInv());
                }
            }
        } else {
            Serializable[] initSessionParams =
            /*setDefaultStore,*/ { new Long(lWipEntityId) };
            Class[] initSessionParamTypes = { Long.class };
            am.invokeMethod("initSessionEam", initSessionParams, 
                            initSessionParamTypes);
            //long lWipEntityId = Long.parseLong(wipEntityId);
            String wipSubinventory = 
                utils.getDefaultWipSubinventory(am, lWipEntityId);
            OAMessageLovInputBean lovBean = 
                (OAMessageLovInputBean)webBean.findChildRecursive("subInvLov");

            if (wipSubinventory != null) {
                lovBean.setValue(pageContext, wipSubinventory);
            }

            OAFormValueBean wipOrganizationIdFormValue = 
                (OAFormValueBean)webBean.findChildRecursive("wipOrganizationId");
            if (wipOrganizationIdFormValue != null) {
                long wipOrganizationId = 
                    utils.getWipOrganizationId(am, lWipEntityId);
                wipOrganizationIdFormValue.setValue(pageContext, 
                                                    wipOrganizationId);
            }

            String linkURL = 
                "OA.jsp?page=/xxpha/oracle/apps/icx/sn1041/webui/SearchHomeEAMPG&retainAM=Y&WIP_ENTITY_ID=" + 
                lWipEntityId;
            OALinkBean ret1 = 
                (OALinkBean)webBean.findChildRecursive("ReturnTo");
            if (ret1 != null) {
                ret1.setDestination(linkURL);
            }

            OALinkBean ret2 = 
                (OALinkBean)webBean.findChildRecursive("ReturnTo2");
            if (ret2 != null) {
                ret2.setDestination(linkURL);
            }

            /*
            long lDefaultLocator =
                utils.getDefaultWipLocatorId(am, lWipEntityId);
            */

        }

        am.invokeMethod("markUnselectRows");

    }
    //Table5SourceVO1.isReadOnly
    //${oa.Table5SourceVO1.isReadOnly} 

    /**
     * Procedure to handle form submissions for form elements in
     * a region.
     * @param pageContext the current OA page context
     * @param webBean the web bean corresponding to the region
     */
    public void processFormRequest(OAPageContext pageContext, 
                                   OAWebBean webBean) {
        //Sn1041Utils utils = Sn1041Utils.getInstance();
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processFormRequest", 
                               "start", OAFwkConstants.PROCEDURE);

        OAMessageDateFieldBean needByDateBean = 
            (OAMessageDateFieldBean)webBean.findIndexedChildRecursive("NeedByDate");
        OAMessageLovInputBean lovBean = 
            (OAMessageLovInputBean)webBean.findChildRecursive("subInvLov");


        if (needByDateBean != null) {
            if (needByDateBean.getValue(pageContext) != null) {
                utils.setNeedByDate((Date)needByDateBean.getValue(pageContext));
                utils.writeDiagnostics(pageContext, 
                                       CLASS_NAME + ".processFormRequest", 
                                       "set  NeedByDate " + 
                                       needByDateBean.getValue(), 
                                       OAFwkConstants.PROCEDURE);
            }
        }
        if (lovBean.getValue(pageContext) != null) {
            utils.setSubInv((String)lovBean.getValue(pageContext));
        }


        super.processFormRequest(pageContext, webBean);
        SearchAMImpl am = 
            (SearchAMImpl)pageContext.getApplicationModule(webBean);
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processFormRequest", 
                               "PFR " + pageContext.toString() + "-" + 
                               webBean.toString() + "-" + am.toString(), 
                               OAFwkConstants.PROCEDURE);
        am.getTransaction().commit();

        String openCart = pageContext.getParameter("openCartEAM");
        if (openCart != null) {
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest", 
                                   "openCartEAM event!", 
                                   OAFwkConstants.PROCEDURE);
        }

        if ("delete".equals(pageContext.getParameter(EVENT_PARAM))) {
            utils.deleteLineHandler(pageContext, webBean, CLASS_NAME);
        } else if (pageContext.getParameter("DeleteYesButton") != null) {
            utils.deleteConfirmHandler(pageContext, webBean, CLASS_NAME, 
                                       "Table5");
            //Добавил обработку кнопки для EAM
        } else if (pageContext.getParameter("toCart") != null || 
                   pageContext.getParameter("toCartEAM") != null) {
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest", 
                                   pageContext.toString() + "-" + 
                                   webBean.toString() + "-" + am.toString(), 
                                   OAFwkConstants.PROCEDURE);
            am.invokeMethod("applyChanges");

            OAException message =
                /*tokens*/new OAException("XXPHA", 
                                          "XXPHA_SN1041_CHANGES_SAVED", null, 
                                          OAException.CONFIRMATION, null);

            pageContext.putDialogMessage(message);

            utils.writeDiagnostics(pageContext, CLASS_NAME + ".toCart", 
                                   "start", OAFwkConstants.PROCEDURE);


            String subInv = null;
            Date needByDate = null;
            //для EAM
            String EAMFlag = 
                (pageContext.getParameter("toCartEAM") != null) ? "Y" : "N";

            if (lovBean != null) {
                subInv = (String)lovBean.getValue(pageContext);
            }

            if (needByDateBean != null) {
                needByDate = (Date)needByDateBean.getValue(pageContext);
            }

            Serializable[] parameters = 
            { subInv, needByDate, EAMFlag }; //для EAM
            Class[] paramTypes = 
            { String.class, Date.class, String.class }; //для EAM
            ResultForInvoce res = 
                (ResultForInvoce)am.invokeMethod("createReq", parameters, 
                                                 paramTypes);

            String resType = res.getResType();
            String resDescr = res.getResDescr();

            utils.writeDiagnostics(pageContext, CLASS_NAME + ".createReq", 
                                   "resType = " + resType + ", resDescr = " + 
                                   resDescr, OAFwkConstants.PROCEDURE);


            if (resType.equals("1")) {
                OAException msg = 
                    new OAException(resDescr, OAException.CONFIRMATION);
                pageContext.putDialogMessage(msg);
            } else {
                throw new OAException(resDescr, OAException.ERROR);
            }

        } else if (pageContext.getParameter("openCart2") != null || 
                   ((pageContext.getParameter("openCartEAM") != null))) {

            am.invokeMethod("initActiveCart");

            ActiveCartVOImpl vo = am.getActiveCartVO1();
            vo.executeQuery();
            Row cart = vo.first();
            if (cart == null) {
                throw new OAException("XXPHA", "XXPHA_SN1041_NOT_ACTIV_CART", 
                                      null, (byte)0, null);
            } else {
                HashMap hm = new HashMap();
                hm.put("SN1041", "Y");

                if (pageContext.getParameter("openCart2") != null) {
                    pageContext.putSessionValue("XX_SN1041_CALL_BACK", "Y");


                    Number reqHeaderId = 
                        (Number)cart.getAttribute("RequisitionHeaderId");
                    if (reqHeaderId != null) {
                        //System.out.println("reqHeaderId=" + reqHeaderId);

                        ClientUtil.getPorAppsContext(pageContext).setCurrentReqHeaderId(reqHeaderId);
                    } else {
                        //System.out.println("reqHeaderId=" + reqHeaderId);
                    }
                } else if (pageContext.getParameter("openCartEAM") != null) {
                    long lWipEntityID = utils.getCurrentWipEntityId(am);
                    hm.put("EntID", lWipEntityID);
                    pageContext.putSessionValue("XX_SN1041_EAM_CALL_BACK", 
                                                "Y");
                }
                //"OA.jsp?page=/oracle/apps/icx/por/req/webui/ShoppingCartPopupRN",


                /*
            pageContext.setForwardURL("OA.jsp?page=/oracle/apps/icx/por/req/webui/EditSubmitPG&SN1041=Y",
                                      null,
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT,
                                      null, null, false,
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_NO,
                                      OAWebBeanConstants.IGNORE_MESSAGES);
                                      */

                pageContext.setForwardURL("OA.jsp?page=/oracle/apps/icx/por/req/webui/EditSubmitPG", 
                                          null, 
                                          OAWebBeanConstants.KEEP_MENU_CONTEXT, 
                                          null, hm, false, 
                                          OAWebBeanConstants.ADD_BREAD_CRUMB_NO, 
                                          OAWebBeanConstants.IGNORE_MESSAGES);
            }
        } else if (pageContext.getParameter("selectSameTypeItem") != null) {
            am.invokeMethod("selectSameTypeItem");


        }

        //***************************************************   

        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processFormRequest", 
                               "end", OAFwkConstants.PROCEDURE);

    }
}


