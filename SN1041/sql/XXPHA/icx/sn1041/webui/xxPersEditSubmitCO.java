package xxpha.oracle.apps.icx.sn1041.webui;

import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAFwkConstants;
import oracle.apps.fnd.framework.server.OADBTransaction;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.nav.OALinkBean;
import oracle.apps.icx.por.common.webui.ClientUtil;

import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;
import xxpha.oracle.apps.xxpha.custom.util.XxphaCustomization;
import xxpha.oracle.apps.xxpha.custom.util.XxphaCustomizationContext;
import xxpha.oracle.apps.xxpha.utils.xxDebug;


public class xxPersEditSubmitCO extends XxphaCustomization {
    private Sn1041Utils utils = Sn1041Utils.getInstance();
    private final String CLASS_NAME = xxPersEditSubmitCO.class.getName();

    public xxPersEditSubmitCO() {
    }

    public static final String RCS_ID = 
        "$Header: xxPersEditSubmitCO.java 120.01 PNaumov $";
    public static final String DIAGNOSTIC_CAPTION = 
        xxPersEditSubmitCO.class.getName();

    // ${oa.Table5SourceVO1.isReadOnly}

    // ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ

    private static void writeLogStatement(OAPageContext pageContext, 
                                          String methodName, String msg) {
        xxDebug.writeLogStatement(pageContext, methodName, msg, 
                                  OAFwkConstants.STATEMENT);
        System.out.println(methodName + ": " + msg);
    }


    // СТАНДАРТНЫЕ МЕТОДЫ

    private void beforeProcessRequest(OAPageContext pageContext, 
                                      OAWebBean webBean) {
        String METHOD_NAME = DIAGNOSTIC_CAPTION + ".BeforeProcessRequest";


        if (pageContext.getParameter("SN1041") != null && 
            pageContext.getParameter("SN1041").equals("Y")) {

            OAApplicationModule am = pageContext.getApplicationModule(webBean);
            String wipEntityId = pageContext.getParameter("EntID");
            if (wipEntityId != null) {
                long lWipEntityId = Long.parseLong(wipEntityId);
                long lStoreId = utils.getWipOrganizationId(am, lWipEntityId);
                long lOrgId = utils.getOrgIdByOrganizationId(am, lStoreId);
                utils.writeDiagnostics(pageContext, 
                                       CLASS_NAME + ".beforeProcessRequest", 
                                       "lWipEntityId=" + lWipEntityId + 
                                       ";lStoreId=" + lStoreId + ";lOrgId=" + 
                                       lOrgId, OAFwkConstants.PROCEDURE);

                OADBTransaction tr = (OADBTransaction)am.getTransaction();
                tr.setMultiOrgPolicyContext("S", lOrgId);
                tr.setOrgId((int)lOrgId);
            }

            writeLogStatement(pageContext, METHOD_NAME, "start");
            ClientUtil.resetPorAppsContext(pageContext);
            writeLogStatement(pageContext, METHOD_NAME, "reset");
            //System.out.println("REFIND = Y");
        }

    }


    private void afterProcessRequest(OAPageContext pageContext, 
                                     OAWebBean webBean) {
        String METHOD_NAME = DIAGNOSTIC_CAPTION + ".afterProcessRequest";


        if (pageContext.getParameter("SN1041") != null && 
            pageContext.getParameter("SN1041").equals("Y")) {
            writeLogStatement(pageContext, METHOD_NAME, "start");

            OALinkBean returnLink = 
                (OALinkBean)webBean.findChildRecursive("ReturnToShoppingLink");

            String var11 = 
                pageContext.getSessionValue("XX_SN1041_EAM_CALL_BACK") != 
                null ? 
                "OA.jsp?page=/xxpha/oracle/apps/icx/sn1041/webui/RequisitionItemsListEamPG" : 
                "OA.jsp?page=/xxpha/oracle/apps/icx/sn1041/webui/RequisitionItemsListPG";
            returnLink.setDestination(var11);
            returnLink.setText(pageContext.getMessage("XXPHA", 
                                                      "XXPHA_SN1041_RETURN_TO", 
                                                      null));
            writeLogStatement(pageContext, METHOD_NAME, "end");
        }

        /*OAApplicationModule am = pageContext.getApplicationModule(webBean);
        PoRequisitionHeadersVOImpl vo = (PoRequisitionHeadersVOImpl)am.findViewObject("PoRequisitionHeadersVO");

        writeLogStatement(pageContext,METHOD_NAME,"1 vo.getCurrentRow() = "+vo.getCurrentRow());

        if (vo.getCurrentRow()==null){
            writeLogStatement(pageContext,METHOD_NAME,"vo.getRowCount() = "+vo.getRowCount());
            if (vo.getRowCount()==1) {
                vo.setCurrentRowAtRangeIndex(0);
            }
        }
        writeLogStatement(pageContext,METHOD_NAME,"2 vo.getCurrentRow() = "+vo.getCurrentRow());*/

    }


    public void processCustomization() {
        /* Обрабатываем вызов до оригинального метода */
        XxphaCustomizationContext ctx = getCustomizationContext();
        if (BEFORE_SUPER_CALL.equals(ctx.getCallTime())) {
            //OAPageContext pageContext = ctx.getPageContext();
            //OAWebBean webBean = ctx.getWebBean();
            if (ctx.getPageContext() != null) {
                OAPageContext pageContext = ctx.getPageContext();
                OAWebBean webBean = ctx.getWebBean();

                if ("processRequest".equals(ctx.getCallingMethodName())) {
                    beforeProcessRequest(pageContext, webBean);
                } else if ("processFormRequest".equals(ctx.getCallingMethodName())) {
                }
            }
        } else if (AFTER_SUPER_CALL.equals(ctx.getCallTime())) {
            if (ctx.getPageContext() != null) {
                OAPageContext pageContext = ctx.getPageContext();
                OAWebBean webBean = ctx.getWebBean();
                if ("processRequest".equals(ctx.getCallingMethodName())) {
                    afterProcessRequest(pageContext, webBean);
                } else if ("processFormRequest".equals(ctx.getCallingMethodName())) {

                }
            }
        }
    }


}
