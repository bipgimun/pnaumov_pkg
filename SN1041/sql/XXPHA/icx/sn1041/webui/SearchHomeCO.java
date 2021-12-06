/*===========================================================================+
 |   Copyright (c) 2001, 2005 Oracle Corporation, Redwood Shores, CA, USA    |
 |                         All rights reserved.                              |
 +===========================================================================+
 |  HISTORY                                                                  |
 +===========================================================================*/
package xxpha.oracle.apps.icx.sn1041.webui;

import com.sun.java.util.collections.HashMap;

import java.io.Serializable;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;

import oracle.apps.fnd.common.VersionInfo;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAFwkConstants;
import oracle.apps.fnd.framework.OAViewObject;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.webui.OAControllerImpl;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.OAQueryUtils;
import oracle.apps.fnd.framework.webui.OAWebBeanConstants;
import oracle.apps.fnd.framework.webui.beans.OABodyBean;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.form.OAFormValueBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageCheckBoxBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageLovChoiceBean;
import oracle.apps.fnd.framework.webui.beans.message.OAMessageTextInputBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;
import oracle.apps.icx.icatalog.common.IntermediaExpression;

import oracle.bali.share.util.BooleanUtils;

import oracle.jbo.Row;
import oracle.jbo.domain.Number;

import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;


/**
 * Controller for ...
 */
public class SearchHomeCO extends OAControllerImpl {
    public static final String RCS_ID = "$Header$";
    public static final boolean RCS_ID_RECORDED = 
        VersionInfo.recordClassVersion(RCS_ID, "%packagename%");

    private final String endOfLine = "{-}";
    private final String CLASS_NAME;
    private Sn1041Utils utils = Sn1041Utils.getInstance();

    public SearchHomeCO() {
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

        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processRequest", 
                               "---------- START ----------", 
                               OAFwkConstants.PROCEDURE);
        //---------------------------- DEBUG ----------------------------------------
        
        if (Sn1041Utils.DEBUG && pageContext.getUserName().equals("MAE")) {
            OAMessageTextInputBean mbSearch =
                (OAMessageTextInputBean)webBean.findChildRecursive("SearchTextInput");
            if (mbSearch != null) {
                mbSearch.setValue(pageContext, "00-272210-03090");
            }
        }
        
        //---------------------------- END DEBUG ----------------------------------------
        /*
        OAWebBean body = pageContext.getRootWebBean();
        if (body instanceof OABodyBean) {
            ((OABodyBean)body).setFirstClickPassed(true);
        }
        */

        //Обработать параметры страницы
        String wipEntityId = pageContext.getParameter("WIP_ENTITY_ID");
        String upd = pageContext.getParameter("upd");

        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        String isFirstTimeOpened = 
            (String)pageContext.getSessionValue("IsFirstTimeOpened");
        String setDefaultStore = "N";
        if (isFirstTimeOpened == null) {
            pageContext.putSessionValue("IsFirstTimeOpened", "Y");
            setDefaultStore = "Y";
        }

        //Очистить черновик
        //Sn1041Utils utils = Sn1041Utils.getInstance();
        utils.clearDraft(am);

        if (isFirstTimeOpened == null) {
            String haveDraft = (String)am.invokeMethod("haveDraft");
            if ("Y".equals(haveDraft)) {
                utils.writeDiagnostics(pageContext, 
                                       CLASS_NAME + ".processRequest", 
                                       " hasDraft != null ", 
                                       OAFwkConstants.PROCEDURE);

                utils.haveDraftConfirm(pageContext, webBean, CLASS_NAME);
            }
        }

        if (wipEntityId == null) {
            //Работа по PO            

            Serializable[] initParams = { setDefaultStore };
            Class[] initParamTypes = { String.class };

            am.invokeMethod("initSession", initParams, initParamTypes);

            //Set org_id and organization_id
            Number oeId = new Number(pageContext.getOrgId());

            Boolean executeQuery = BooleanUtils.getBoolean(true);

            Serializable[] parameters = { oeId, executeQuery };
            Class[] paramTypes = { Number.class, Boolean.class };
            am.invokeMethod("initParameters", parameters, paramTypes);

            am.invokeMethod("initSearchResults");

            //if (am1.getRequisitionItemsVO1().isExecuted()) {
            OAAdvancedTableBean table = 
                (OAAdvancedTableBean)webBean.findChildRecursive("ForRequisitionTbl");

            // When handling a user initiated search, we always need to execute
            // the query so we pass "false" to queryData().
            table.queryData(pageContext, false);
            //}


        } else {
            //Обработка из EAM            
            long lWipEntityId = Long.parseLong(wipEntityId);
            utils.writeDiagnostics(pageContext, CLASS_NAME + ".processRequest", 
                                   "lWipEntityId =" + lWipEntityId, 
                                   OAFwkConstants.PROCEDURE);

            processRequestEam(pageContext, webBean, lWipEntityId);
        }

        //Initialize ElasticSearch
        OAControllerImpl controller = new OAControllerImpl();
        OAFormValueBean frmValue1 = 
            (OAFormValueBean)controller.createWebBean(pageContext, 
                                                      OAWebBeanConstants.HIDDEN_BEAN, 
                                                      null, "fvSrvUrl");
        String servletUrl = pageContext.getProfile("XXPHA_SN1041_SERV_URL");
        frmValue1.setValue(((servletUrl == null || servletUrl.equals("")) ? 
                            "http://ksrvap678.int.corp.phosagro.ru:7011/sn1041/ep" : 
                            servletUrl) + endOfLine);
        webBean.addIndexedChild(frmValue1);

        pageContext.putJavaScriptLibrary("sn1041s", "sn1041/sn1041.js");

        OABodyBean pb = (OABodyBean)pageContext.getRootWebBean();
        pb.setOnLoad("initPage();");

        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processRequest", 
                               " - OK!", OAFwkConstants.PROCEDURE);
    }

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
                               " start", OAFwkConstants.PROCEDURE);
        super.processFormRequest(pageContext, webBean);

        String eventParam = pageContext.getParameter(EVENT_PARAM);
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processFormRequest", 
                               " eventParam = " + eventParam, 
                               OAFwkConstants.PROCEDURE);

        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        am.invokeMethod("applySession");

        OAMessageLovChoiceBean wipEntityMLC = 
            (OAMessageLovChoiceBean)webBean.findIndexedChildRecursive("WipEntity");


        //Get Orgatization value
        /* if (pageContext.isLovEvent())
        {
            Sn1041Utils.getInstance().writeDiagnostics(pageContext,
                                                       CLASS_NAME + ".processFormRequest",
                                                       " isLovEvent "+pageContext.getLovInputSourceId(),
                                                       OAFwkConstants.PROCEDURE);
            String lovid = pageContext.getLovInputSourceId();
            if("StoreName".equals(lovid))
            {
                OAMessageLovChoiceBean lovBean=(OAMessageLovChoiceBean)webBean.findIndexedChildRecursive("StoreName");
                if(lovBean != null)
                {
                    String lovvalue = (String) lovBean.getValue(pageContext);
                    System.out.println(lovvalue);
                }
            }
        }*/


        if (pageContext.getParameter("SearchButton") != null) {
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest : Parameter SearchButton != null", 
                                   "", OAFwkConstants.PROCEDURE);
            OAQueryUtils.checkSelectiveSearchCriteria(pageContext, webBean);


            String searchString = pageContext.getParameter("SearchTextInput");

            if (searchString == null || searchString.equals("")) {
                pageContext.putAttrDialogMessage(webBean, 
                                                 new OAException("XXPHA", 
                                                                 "XXPHA_SN1041_EMPTY_SEARCH"));
                return;
            }


            /*
            OAMessageLovChoiceBean lovBean =
                (OAMessageLovChoiceBean)webBean.findIndexedChildRecursive("StoreName");
            Number lovvalue;
            try {

                lovvalue = new Number((String)lovBean.getValue(pageContext));

            } catch (SQLException e) {
                throw new OAException(e.getMessage(), OAException.ERROR);
            }
            */


            /*+
                                                       " lovvalue = " +
                                                       lovvalue*/

            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest", 
                                   " : searchString = " + searchString, 
                                   OAFwkConstants.PROCEDURE);

            // All parameters passed using invokeMethod() must be serializable.

            // Note the following is required for view object initialization standards
            // around tables.
            //Boolean executeQuery = BooleanUtils.getBoolean(false);
            String useElastic = "Y";
            OAMessageCheckBoxBean cB = 
                (OAMessageCheckBoxBean)webBean.findChildRecursive("cbElasticEnabled");
            if (cB != null) {
                useElastic = (String)cB.getValue(pageContext);
            }

            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest", 
                                   " useElastic = " + useElastic, 
                                   OAFwkConstants.PROCEDURE);

            if ("N".equals(useElastic)) {
                IntermediaExpression intermediaExpr = 
                    new IntermediaExpression();

                String intExpr = null;
                intExpr = 
                        intermediaExpr.getExpression(searchString, 0, "&", (String)null);
                long orgid = -1;
                if (wipEntityMLC == null) {
                    orgid = utils.getCurrentOrgId(am);
                } else {
                    long wipEntityId = utils.getCurrentWipEntityId(am);
                    long storeId = utils.getWipOrganizationId(am, wipEntityId);
                    orgid = utils.getOrgIdByOrganizationId(am, storeId);
                }
                intExpr = 
                        intermediaExpr.join(intExpr, orgid + " within orgid", "&");
                intExpr = 
                        intermediaExpr.join(intExpr, "(RU within language)*10*10", 
                                            "&");

                utils.writeDiagnostics(pageContext, 
                                       CLASS_NAME + ".processFormRequest", 
                                       " intExpr = " + intExpr, 
                                       OAFwkConstants.PROCEDURE);
                searchString = intExpr;
            }

            Serializable[] parameters = { searchString, useElastic };

            Class[] paramTypes = { String.class, String.class };

            am.invokeMethod("doSearch", parameters, paramTypes);

            OAAdvancedTableBean table = 
                (OAAdvancedTableBean)webBean.findChildRecursive("FoundItemsTbl");

            // When handling a user initiated search, we always need to execute
            // the query so we pass "false" to queryData().
            table.queryData(pageContext, false);

        } else if (pageContext.getParameter("AddSelection") != null) {
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest", 
                                   "Parameter addSelection != null", 
                                   OAFwkConstants.PROCEDURE);


            //Если бина нет, считаем, что работаем не с EAM
            if (wipEntityMLC == null) {
                OAMessageLovChoiceBean lovBean = 
                    (OAMessageLovChoiceBean)webBean.findIndexedChildRecursive("StoreName");
                if (lovBean != null) {

                    try {
                        Number lovvalue;
                        lovvalue = 
                                new Number((String)lovBean.getValue(pageContext));
                        Serializable[] parameters = { lovvalue };
                        Class[] paramTypes = { Number.class };
                        am.invokeMethod("setOrganizationId", parameters, 
                                        paramTypes);
                        utils.writeDiagnostics(pageContext, 
                                               CLASS_NAME + ".processFormRequest : Parameter lovvalue=" + 
                                               lovvalue, "", 
                                               OAFwkConstants.PROCEDURE);

                        // am.invokeMethod("addSelectedItems");
                        // pageContext.forwardImmediatelyToCurrentPage(null, true, null);


                    } catch (SQLException e) {
                        throw new OAException(e.getMessage(), 
                                              OAException.ERROR);
                    }
                }

                else {
                    throw new OAException("Haven't chosen  Orgatization!", 
                                          OAException.ERROR);
                }
            }

            //бин есть - а это EAM!!!
            else {
                addSelectionEam(pageContext, webBean, wipEntityMLC);
            }
        }

        else if ("delete".equals(eventParam)) {
            utils.deleteLineHandler(pageContext, webBean, CLASS_NAME);
        } else if (pageContext.getParameter("DeleteYesButton") != null) {
            utils.deleteConfirmHandler(pageContext, webBean, CLASS_NAME, 
                                       "ForRequisitionTbl");

        } else if (pageContext.getParameter("DeleteDraftButton") != null) {
            utils.deleteDraftHandler(pageContext, webBean, CLASS_NAME, 
                                     "ForRequisitionTbl");

        }

        else if (pageContext.getParameter("showSelection") != null) {

            // Note that this lesson doesn't actually pass any parameters
            // to the target page, so it doesn't actually implement the
            // autoquery.  To make this work, you would need to pass 
            // something that the target controller could look at in processRequest() to 
            // determine whether it should autoquery.  If you do this,
            // you need to make sure the page doesn't autoquery every
            // time you redirect to it since any parameters that you
            // pass here will still be on the request when doing jsp
            // forwards.

            if (wipEntityMLC != null) {
                pageContext.setForwardURL("XXPHA_SN1041_SEL_ITEMS_EA", 
                                          GUESS_MENU_CONTEXT, null, null, 
                                          false, ADD_BREAD_CRUMB_NO, 
                                          OAWebBeanConstants.IGNORE_MESSAGES);
            }

            else {
                // Do not retain AM
                pageContext.setForwardURL("XXPHA_SN1041_SEL_ITEMS_VIEW", 
                                          GUESS_MENU_CONTEXT, null, null, 
                                          false, ADD_BREAD_CRUMB_NO, 
                                          OAWebBeanConstants.IGNORE_MESSAGES);
            }
        } else if ("storeChange".equals(eventParam)) {
            am.invokeMethod("storeChange");
            pageContext.forwardImmediatelyToCurrentPage(null, true, null);
        } else if ("AddAnalogToSearch".equals(eventParam)) {

        } else if (pageContext.getParameter("CreateItem") != null) {
            processCreateItem(pageContext, webBean, wipEntityMLC != null);
        } else if ("updateTbl".equals(pageContext.getParameter(EVENT_PARAM))) {
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest : updateTbl Event!", 
                                   "", OAFwkConstants.PROCEDURE);
        } else if (pageContext.getParameter("ClearSelection") != null) {
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processFormRequest : Parameter ClearSelection != null", 
                                   "", OAFwkConstants.PROCEDURE);


            am.invokeMethod("clearSearch");

            OAMessageTextInputBean searchInput = 
                (OAMessageTextInputBean)webBean.findChildRecursive("SearchTextInput");

            if (searchInput != null)
                searchInput.setValue(pageContext, "");

            pageContext.forwardImmediatelyToCurrentPage(null, true, null);
        } else if ("WipEntityChange".equals(eventParam)) {
            wipEntityChangeHandler(pageContext, webBean);
        } else if (pageContext.isLovEvent()) {
            String lovInputSourceId = pageContext.getLovInputSourceId();
            if ("WipEntity".equals(lovInputSourceId)) {
                //wipEntityChangeHandler(pageContext, webBean);
                System.out.println("!!!!!!!!!!!!!!!!!!!!!! isLovEvent handler  !!!!!!!!!!!!!!!!!!!!!!!!!!!");

                wipEntityLovChangeHandler(pageContext, webBean);
            }
        }
    }

    public void processCreateItem(OAPageContext pageContext, 
                                  OAWebBean webBean, boolean isEam) {
        utils.writeDiagnostics(pageContext, 
                               CLASS_NAME + ".processCreateItem : ", 
                               "CreateItem Event!", OAFwkConstants.PROCEDURE);

        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        //Sn1041Utils utils = Sn1041Utils.getInstance();
        //String orgName = utils.getam);

        OAViewObject vo3 = null;
        vo3 = (OAViewObject)am.findViewObject("SearchResultsVO1");
        /*
        if (vo3 == null) {
            vo3 = (OAViewObject)am.findViewObject("SN775AdvancedSearchVO");
        }
        */
        int i = vo3.getRowCount();

        utils.writeDiagnostics(pageContext, 
                               CLASS_NAME + ".processCreateItem : ", 
                               "i = " + i, OAFwkConstants.PROCEDURE);

        Row row = vo3.first();
        int k = 0;
        String[][] reqrows = new String[i][5];
        String[] actRows = new String[i];

        long orgid = -1;
        if (!isEam) {
            orgid = utils.getCurrentOrgId(am);
        } else {
            long wipEntityId = utils.getCurrentWipEntityId(am);
            long storeId = utils.getWipOrganizationId(am, wipEntityId);
            orgid = utils.getOrgIdByOrganizationId(am, storeId);
        }
        
        String orgId = Long.toString(orgid);
        utils.writeDiagnostics(pageContext, 
                               CLASS_NAME + ".processCreateItem : ", 
                               "orgId = " + orgId, OAFwkConstants.PROCEDURE);
        pageContext.putParameter("ORG_ID", orgId);

        String orgName = utils.getOperatingUnitName(am, new Long(orgId));
        pageContext.putParameter("ORG_NAME", orgName);
        utils.writeDiagnostics(pageContext, 
                               CLASS_NAME + ".processCreateItem : ", 
                               "orgName = " + orgName, 
                               OAFwkConstants.PROCEDURE);

        if (i != 0) {
            for (int j = 0; j < i; j++) {
                String selectAttr = (String)row.getAttribute("SelectedItem");

                utils.writeDiagnostics(pageContext, 
                                       CLASS_NAME + ".processCreateItem : ", 
                                       "selectAttr = " + selectAttr, 
                                       OAFwkConstants.PROCEDURE);

                if ("Y".equals(selectAttr)) {
                    Number supId = (Number)row.getAttribute("VendorId");
                    String sSupplierId = String.valueOf(supId);
                    pageContext.putParameter("SUPPLIER_ID", sSupplierId);

                    //String orgName = (String)row.getAttribute("org_name");


                    Number invId = (Number)row.getAttribute("InventoryItemId");
                    String supplierItem = 
                        (String)row.getAttribute("CatalogCode");
                    String itemDescription = 
                        (String)row.getAttribute("SupDescription");
                    /*
                    if ("1".equals(isInVs)) {
                        itemDescription =
                                (String)row.getAttribute("item_description");

                    } else {
                        itemDescription =
                                (String)row.getAttribute("DESCRIPTION");
                    }
                    */


                    String uom = (String)row.getAttribute("Uom");
                    String currencyCode = "RUR";
                    //(String)row.getAttribute("currency_code");
                    Number nn = (Number)row.getAttribute("PoLineId");
                    String PoLineId = String.valueOf(nn);

                    if (invId == null || 
                        Integer.valueOf(String.valueOf(invId)) < 0) {
                        reqrows[k][0] = supplierItem;
                        reqrows[k][1] = itemDescription;
                        reqrows[k][2] = uom;
                        reqrows[k][3] = currencyCode;
                        reqrows[k][4] = PoLineId;
                        actRows[k] = supplierItem;
                        k++;
                    }
                }
                row = vo3.next();
            }
        }
        i = k;


        utils.writeDiagnostics(pageContext, 
                               CLASS_NAME + ".processCreateItem : ", 
                               "i = " + i, OAFwkConstants.PROCEDURE);

        if (i != 0) {
            pageContext.putParameter("I", i);
            pageContext.putParameter("J", 5);
            pageContext.putParameter("REQROWS", reqrows);
            pageContext.putParameter("SN775_SEARCH_PAGE", 
                                     pageContext.getCurrentUrlForRedirect());
            pageContext.putParameter("ACTROW", actRows);

            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processCreateItem : ", 
                                   "before Forward", OAFwkConstants.PROCEDURE);

            pageContext.setForwardURL("OA.jsp?page=/xxpha/oracle/apps/xxpha/SN775/webui/SN775crItemPG", 
                                      null, 
                                      OAWebBeanConstants.KEEP_MENU_CONTEXT, 
                                      null, null, true, 
                                      OAWebBeanConstants.ADD_BREAD_CRUMB_YES, 
                                      OAWebBeanConstants.IGNORE_MESSAGES);
        } else {
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".processCreateItem : ", 
                                   "else exception", OAFwkConstants.PROCEDURE);
            OAException msg2 = 
                new OAException("XXPHA", "XXPHA_SN775_CR_ITEM_19", null, 
                                OAException.WARNING, null);
            pageContext.putDialogMessage(msg2);
        }
    }

    public String isInVs(OADBTransaction tr, String sup) {
        String stmt = 
            "begin\n" + ":1 := XXPHA_SN775_PKG.check_supp_in_vs(\n" + "p_supplier_id => :2);\n" + 
            "end;";
        CallableStatement call = null;
        String InVs = "";
        try {
            call = tr.getJdbcConnection().prepareCall(stmt);
            call.registerOutParameter(1, Types.VARCHAR);
            call.setObject(2, sup);
            call.execute();

            InVs = call.getString(1);
        } catch (Exception e) {
            throw new OAException(e.getLocalizedMessage(), OAException.ERROR);
        } finally {
            try {
                call.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
        return InVs;
    }

    public void processRequestEam(OAPageContext pageContext, OAWebBean webBean, 
                                  long pWipEntityId) {
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".processRequest", 
                               "EAM Processing!!!", OAFwkConstants.PROCEDURE);
        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        Serializable[] initSessionParams =
        /*setDefaultStore,*/ { new Long(pWipEntityId) };
        Class[] initSessionParamTypes = { Long.class };
        am.invokeMethod("initSessionEam", initSessionParams, 
                        initSessionParamTypes);

        long storeId = utils.getWipOrganizationId(am, pWipEntityId);
        long oeId = utils.getOrgIdByOrganizationId(am, storeId);

        Boolean executeQuery = Boolean.TRUE;
        Serializable[] parameters = { new Number(oeId), executeQuery };
        Class[] paramTypes = { Number.class, Boolean.class };
        am.invokeMethod("initParameters", parameters, paramTypes);

        doSearch(pageContext, webBean, pWipEntityId, storeId, oeId);

        OAAdvancedTableBean table = 
            (OAAdvancedTableBean)webBean.findChildRecursive("ForRequisitionTbl");

        // When handling a user initiated search, we always need to execute
        // the query so we pass "false" to queryData().
        table.queryData(pageContext, false);
    }

    private void wipEntityChangeHandler(OAPageContext pageContext, 
                                        OAWebBean webBean) {
        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        am.invokeMethod("applySession");

        OAMessageLovChoiceBean wipEntityMLCB = 
            (OAMessageLovChoiceBean)webBean.findChildRecursive("WipEntity");
        if (wipEntityMLCB != null) {
            String selectedEntityId = 
                (String)wipEntityMLCB.getValue(pageContext);
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".wipEntityChangeHandler", 
                                   "selectedEntityId =" + selectedEntityId, 
                                   OAFwkConstants.PROCEDURE);
            long lWipEntityId = Long.parseLong(selectedEntityId);
            /*
            pageContext.removeParameter("upd");
            pageContext.removeParameter("WIP_ENTITY_ID");
            pageContext.putParameter("upd", "Y");
            pageContext.putParameter("WIP_ENTITY_ID", lWipEntityId);
            */

            HashMap hm = new HashMap();
            hm.put("upd", "Y");
            hm.put("WIP_ENTITY_ID", lWipEntityId);
            //am.invokeMethod("wipEntityChange");

            pageContext.forwardImmediatelyToCurrentPage(hm, true, null);

            //pageContext.forwardImmediatelyToCurrentPage(null, true, null);
        }
    }

    private void wipEntityLovChangeHandler(OAPageContext pageContext, 
                                           OAWebBean webBean) {
        OAApplicationModule am = pageContext.getApplicationModule(webBean);
        am.invokeMethod("applySession");

        OAMessageLovChoiceBean wipEntityMLCB = 
            (OAMessageLovChoiceBean)webBean.findChildRecursive("WipEntity");
        if (wipEntityMLCB != null) {
            String selectedEntityId = 
                (String)wipEntityMLCB.getValue(pageContext);
            utils.writeDiagnostics(pageContext, 
                                   CLASS_NAME + ".wipEntityChangeHandler", 
                                   "selectedEntityId =" + selectedEntityId, 
                                   OAFwkConstants.PROCEDURE);
            long lWipEntityId = Long.parseLong(selectedEntityId);
            /*
                     pageContext.removeParameter("upd");
                     pageContext.removeParameter("WIP_ENTITY_ID");
                     pageContext.putParameter("upd", "Y");
                     pageContext.putParameter("WIP_ENTITY_ID", lWipEntityId);
                     */

            HashMap hm = new HashMap();
            hm.put("upd", "N");
            hm.put("WIP_ENTITY_ID", lWipEntityId);

            am.invokeMethod("wipEntityChange");

            OAAdvancedTableBean table = 
                (OAAdvancedTableBean)webBean.findChildRecursive("FoundItemsTbl");

            // When handling a user initiated search, we always need to execute
            // the query so we pass "false" to queryData().
            table.queryData(pageContext, false);

            //pageContext.forwardImmediatelyToCurrentPage(hm, true, null);

            //pageContext.forwardImmediatelyToCurrentPage(null, true, null);
        }
    }

    private void doSearch(OAPageContext pageContext, OAWebBean webBean, 
                          long pWipEntityId, long pStoreId, long pOrgId) {
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".doSearch", 
                               "--- START !!! ---", OAFwkConstants.PROCEDURE);
        utils.writeDiagnostics(pageContext, CLASS_NAME + ".doSearch", 
                               "pWipEntityId=" + pWipEntityId + ",pStoreId=" + 
                               pStoreId + ",pOrgId=" + pOrgId, 
                               OAFwkConstants.PROCEDURE);

        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        Serializable[] initWorkOrderParams = { new Long(pWipEntityId) };
        Class[] initWorkOrderParamTypes = { Long.class };
        am.invokeMethod("getWorkOrderItems", initWorkOrderParams, 
                        initWorkOrderParamTypes);
        am.invokeMethod("initSearchResultsEAM", initWorkOrderParams, 
                        initWorkOrderParamTypes);
    }

    private void addSelectionEam(OAPageContext pageContext, OAWebBean webBean, 
                                 OAMessageLovChoiceBean pWipEntityMLC) {
        long wipEntityId = 
            Long.parseLong((String)pWipEntityMLC.getValue(pageContext));
        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        if (wipEntityId > 0) {
            long storeId = utils.getWipOrganizationId(am, wipEntityId);
            try {
                Number lovvalue = new Number(storeId);
                Serializable[] parameters = { lovvalue };
                Class[] paramTypes = { Number.class };
                am.invokeMethod("setOrganizationId", parameters, paramTypes);
                utils.writeDiagnostics(pageContext, 
                                       CLASS_NAME + ".processFormRequest : Parameter lovvalue=" + 
                                       lovvalue, "", OAFwkConstants.PROCEDURE);

                // am.invokeMethod("addSelectedItems");
                // pageContext.forwardImmediatelyToCurrentPage(null, true, null);


            } catch (Exception e) {
                throw new OAException(e.getMessage(), OAException.ERROR);
            }
        }

        else {
            throw new OAException("Haven't chosen  Orgatization!", 
                                  OAException.ERROR);
        }
        utils.writeDiagnostics(pageContext, 
                               CLASS_NAME + ".processFormRequest : Parameter addSelection != null", 
                               "", OAFwkConstants.PROCEDURE);
    }
}
