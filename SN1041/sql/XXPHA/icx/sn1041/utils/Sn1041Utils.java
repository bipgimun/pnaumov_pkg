package xxpha.oracle.apps.icx.sn1041.utils;

import java.io.FileWriter;
import java.io.IOException;
import java.io.Serializable;

import java.sql.Connection;

import java.util.Date;

import oracle.apps.fnd.common.MessageToken;
import oracle.apps.fnd.framework.OAApplicationModule;
import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAFwkConstants;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.apps.fnd.framework.webui.OADialogPage;
import oracle.apps.fnd.framework.webui.OAPageContext;
import oracle.apps.fnd.framework.webui.beans.OAWebBean;
import oracle.apps.fnd.framework.webui.beans.table.OAAdvancedTableBean;

import oracle.jdbc.OracleCallableStatement;
import oracle.jdbc.OraclePreparedStatement;
import oracle.jdbc.OracleResultSet;
import oracle.jdbc.OracleTypes;

import java.util.Date;

import oracle.apps.fnd.framework.server.OADBTransaction;

import oracle.jbo.domain.Number;

import oracle.sql.NUMBER;


public class Sn1041Utils {
    public static final boolean DEBUG = true;

    private static final String LOG_PATH = "/home/devop/mae/sn1041/";

    private static volatile Sn1041Utils instance;

    private final String CLASS_NAME;

    private String subInv;
    private Date needByDate;


    public void log(String source, String p, boolean is_debug) {
        if (is_debug) {
            try {
                Date d = new Date();
                String osName = System.getProperty("os.name");
                String sV = source + ": " + d + " >> " + p + "\n";
                System.out.println("Log.(Sop): " + sV);

                FileWriter fr = null;
                if (osName.indexOf("Windows") >= 0) {
                    fr = new FileWriter("c:/Test/sn1041.log", true);
                } else {
                    fr = new FileWriter(LOG_PATH + "sn1041.log", true);
                }
                fr.write(sV);
                fr.flush();
                fr.close();
            } catch (IOException e) {
                // e.printStackTrace();
            }
        }
    }

    private Sn1041Utils() {
        super();
        this.CLASS_NAME = this.getClass().getName();
    }

    public static Sn1041Utils getInstance() {
        Sn1041Utils localInstance = instance;
        if (instance == null) {
            synchronized (Sn1041Utils.class) {
                localInstance = instance;
                if (localInstance == null)
                    instance = localInstance = new Sn1041Utils();
            }
        }
        return localInstance;
    }

    public String getMethodName(final int depth) {
        final StackTraceElement[] ste = Thread.currentThread().getStackTrace();
        return ste[2 + depth].toString();
    }

    public void writeDiagnostics(OAPageContext paramOAPageContext, 
                                 String methodName, String msg, int lvl) {
        if (paramOAPageContext.isLoggingEnabled(lvl)) {
            paramOAPageContext.writeDiagnostics(methodName, msg, lvl);
        }

        if (DEBUG) {
            log(methodName, msg, DEBUG);
            System.out.println(methodName + ": " + msg);
        }
    }

    public void writeDiagnostics(OAApplicationModuleImpl am, String methodName, 
                                 String msg, int lvl) {
        if (am.isLoggingEnabled(lvl)) {
            am.writeDiagnostics(am, msg, lvl);
        }

        if (DEBUG) {
            log(methodName, msg, DEBUG);
            System.out.println(methodName + ": " + msg);
        }
    }

    public void deleteLineHandler(OAPageContext pageContext, OAWebBean webBean, 
                                  String className) {
        writeDiagnostics(pageContext, className + ".processRequest", 
                         " delete caught!", OAFwkConstants.PROCEDURE);

        // The user has clicked a "Delete" icon so we want to display a "Warning"
        // dialog asking if she really wants to delete the PO.  Note that we 
        // configure the dialog so that pressing the "Yes" button submits to 
        // this page so we can handle the action in this processFormRequest( ) method.            
        String lineNum = pageContext.getParameter("LineNum");
        MessageToken[] tokens = { new MessageToken("LINE_NUM", lineNum) };
        OAException mainMessage = 
            new OAException("XXPHA", "XXPHA_SN1041_DEL_LINE_CONFIRM", tokens);

        // Note that even though we're going to make our Yes/No buttons submit a
        // form, we still need some non-null value in the constructor's Yes/No  
        // URL parameters for the buttons to render, so we just pass empty 
        // Strings for this.            
        OADialogPage dialogPage = 
            new OADialogPage(OAException.WARNING, mainMessage, null, "", "");

        // Always use Message Dictionary for any Strings you want to display.            
        String yes = pageContext.getMessage("AK", "FWK_TBX_T_YES", null);
        String no = pageContext.getMessage("AK", "FWK_TBX_T_NO", null);

        dialogPage.setOkButtonItemName("DeleteYesButton");

        // Настроить Yes/No            
        dialogPage.setOkButtonToPost(true);
        dialogPage.setNoButtonToPost(true);
        dialogPage.setPostToCallingPage(true);

        dialogPage.setOkButtonLabel(yes);
        dialogPage.setNoButtonLabel(no);

        // Необходимо сохранить LineNum в OADialogPage             
        java.util.Hashtable formParams = new java.util.Hashtable(1);
        formParams.put("lineNum", lineNum);
        dialogPage.setFormParameters(formParams);

        pageContext.redirectToDialogPage(dialogPage);
    }

    public void haveDraftConfirm(OAPageContext pageContext, OAWebBean webBean, 
                                 String className) {
        writeDiagnostics(pageContext, className + ".processRequest", 
                         " Draft found!", OAFwkConstants.PROCEDURE);

        MessageToken[] tokens = null;

        OAException mainMessage = 
            new OAException("XXPHA", "XXPHA_SN1041_HAVE_DRAFT", tokens);

        OADialogPage dialogPage = 
            new OADialogPage(OAException.WARNING, mainMessage, null, "", "");

        String yes = 
            pageContext.getMessage("XXPHA", "XXPHA_SN1041_DEL_DRAFT_Y", null);
        String no = 
            pageContext.getMessage("XXPHA", "XXPHA_SN1041_DEL_DRAFT_N", null);

        dialogPage.setOkButtonItemName("DeleteDraftButton");

        // Настроить Yes/No            
        dialogPage.setOkButtonToPost(true);
        dialogPage.setNoButtonToPost(true);
        dialogPage.setPostToCallingPage(true);

        dialogPage.setOkButtonLabel(yes);
        dialogPage.setNoButtonLabel(no);

        pageContext.redirectToDialogPage(dialogPage);
    }

    public void deleteDraftHandler(OAPageContext pageContext, 
                                   OAWebBean webBean, String className, 
                                   String tableName) {
        // User has confirmed that she wants to delete this line.
        // Invoke a method on the AM to set the current row in the VO and 
        // call remove() on this row. 
        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        //String lineNum = pageContext.getParameter("lineNum");
        //Serializable[] parameters = { lineNum };
        //Serializable[] parameters = null;

        boolean rowDeleted = false;

        rowDeleted = ((Boolean)am.invokeMethod("deleteDraft")).booleanValue();

        if (rowDeleted) {

            OAAdvancedTableBean table = 
                (OAAdvancedTableBean)webBean.findChildRecursive(tableName);

            // When handling a user initiated search, we always need to execute
            // the query so we pass "false" to queryData().
            table.queryData(pageContext, false);

            // Now, redisply the page with a confirmation message at the top.  Note
            // that the deletePurchaseOrder( ) method in the AM commits, and our code
            // won't get this far if any exceptions are thrown.

        }

    }

    public void deleteConfirmHandler(OAPageContext pageContext, 
                                     OAWebBean webBean, String className, 
                                     String tableName) {
        // User has confirmed that she wants to delete this line.
        // Invoke a method on the AM to set the current row in the VO and 
        // call remove() on this row. 
        OAApplicationModule am = pageContext.getApplicationModule(webBean);

        String lineNum = pageContext.getParameter("lineNum");
        Serializable[] parameters = { lineNum };

        boolean rowDeleted = false;

        rowDeleted = 
                ((Boolean)am.invokeMethod("deleteSelectedLine", parameters)).booleanValue();

        if (rowDeleted) {

            OAAdvancedTableBean table = 
                (OAAdvancedTableBean)webBean.findChildRecursive(tableName);

            // When handling a user initiated search, we always need to execute
            // the query so we pass "false" to queryData().
            table.queryData(pageContext, false);

            // Now, redisply the page with a confirmation message at the top.  Note
            // that the deletePurchaseOrder( ) method in the AM commits, and our code
            // won't get this far if any exceptions are thrown.


            MessageToken[] tokens = { new MessageToken("LINE_NUM", lineNum) };
            OAException message = 
                new OAException("XXPHA", "XXPHA_SN1041_DEL_LINE_CONF", tokens, 
                                OAException.CONFIRMATION, null);

            pageContext.putDialogMessage(message);


        } else // Row was not found, display a warning
        {
            // WARNING -- NEVER hard-code a message like this!
            OAException message = 
                new OAException("This row has already been deleted.", 
                                OAException.WARNING);

            pageContext.putDialogMessage(message);

        }
    }

    public long getCurrentOrgId(OAApplicationModule pAM) {
        long orgId = pAM.getOADBTransaction().getMultiOrgCurrentOrgId();
        if (orgId <= 0) {
            orgId = pAM.getOADBTransaction().getOrgId();
        }
        return orgId;
    }

    public long getCurrentStoreId(OAApplicationModule pAM) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.Get_Cur_Ses_Store_ID; end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);

            ocs.registerOutParameter(1, OracleTypes.NUMBER);

            long storeId = -1;

            ocs.execute();
            storeId = ocs.getNUMBER(1).intValue();

            if (storeId == -1) {
                storeId = getProfileStoreId(pAM);
            }

            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getCurrentStoreId", 
                                                       "storeId = " + storeId, 
                                                       OAFwkConstants.PROCEDURE);

            return storeId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public long getCurrentWipEntityId(OAApplicationModule pAM) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.Get_Cur_Wip_Entity_ID; end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);

            ocs.registerOutParameter(1, OracleTypes.NUMBER);

            long wipEntityId = -1;

            ocs.execute();
            NUMBER n = ocs.getNUMBER(1);
            if (n != null)
                wipEntityId = n.intValue();


            getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                           CLASS_NAME + 
                                           ".getCurrentWipEntityId", 
                                           "wipEntityId = " + wipEntityId, 
                                           OAFwkConstants.PROCEDURE);

            return wipEntityId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public String getStoreName(OAApplicationModule pAM, long orgId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.Get_Organization_name(:2); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);

            ocs.registerOutParameter(1, OracleTypes.VARCHAR);
            ocs.setNUMBER(2, new Number(orgId));

            ocs.execute();
            String storeName = ocs.getString(1);

            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getStoreName", 
                                                       "storeName = " + 
                                                       storeName, 
                                                       OAFwkConstants.PROCEDURE);

            return storeName;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public long getProfileStoreId(OAApplicationModule pAM) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        String profileOrganizationCode = 
            ((OADBTransaction)pAM.getTransaction()).getProfile("XXPHA_SN775_USER_WORKSHOP_ORG");
        long profileOrganizationId = -1;

        if (profileOrganizationCode != null) {
            try {
                connect = pAM.getOADBTransaction().getJdbcConnection();
                String sql = 
                    "BEGIN :1 := XXPHA_SN1041_PKG.Get_Organization_Id(p_organization_code => :2); end; ";
                ocs = (OracleCallableStatement)connect.prepareCall(sql);

                ocs.registerOutParameter(1, OracleTypes.NUMBER);
                ocs.setString(2, profileOrganizationCode);

                ocs.execute();
                NUMBER orgID = ocs.getNUMBER(1);
                if (orgID != null)
                    profileOrganizationId = orgID.longValue();


                Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                           CLASS_NAME + 
                                                           ".getProfileStoreName", 
                                                           "profileOrganizationId = " + 
                                                           profileOrganizationId, 
                                                           OAFwkConstants.PROCEDURE);


            } catch (Exception e) {
                throw new OAException(e.getMessage(), OAException.ERROR);
            } finally {
                try {
                    ocs.close();
                    //connect.close();
                } catch (Exception e) {
                    throw new OAException(e.getLocalizedMessage(), 
                                          OAException.ERROR);
                }
            }
        }
        return profileOrganizationId;
    }


    public long getCurrentCSId(OAApplicationModule pAM) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = "BEGIN :1 := XXPHA_SN1041_PKG.Get_CS_ID(:2); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.NUMBER);
            long orgId = pAM.getOADBTransaction().getOrgId();
            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getCurrentCSId", 
                                                       "orgId = " + orgId, 
                                                       OAFwkConstants.PROCEDURE);
            ocs.setLong(2, orgId);

            int storeId = -1;

            ocs.execute();
            storeId = ocs.getNUMBER(1).intValue();


            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getCurrentCSId", 
                                                       "storeId = " + storeId, 
                                                       OAFwkConstants.PROCEDURE);

            return storeId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public long getCurrentCSId(OAApplicationModule pAM, long pStoreId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = "BEGIN :1 := XXPHA_SN1041_PKG.Get_CS_ID(:2); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.NUMBER);
            long orgId = pAM.getOADBTransaction().getOrgId();
            if (orgId < 0) {
                orgId = getOrgIdByOrganizationId(pAM, pStoreId);
            }
            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getCurrentCSId (2)", 
                                                       "orgId = " + orgId, 
                                                       OAFwkConstants.PROCEDURE);
            ocs.setLong(2, orgId);

            int storeId = -1;

            ocs.execute();
            storeId = ocs.getNUMBER(1).intValue();


            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getCurrentCSId  (2)", 
                                                       "storeId = " + storeId, 
                                                       OAFwkConstants.PROCEDURE);

            return storeId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public long getPriceListId(OAApplicationModule pAM) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := to_number(fnd_profile.value_specific(name => 'XXPHA_PRICELIST_4_INT_REQ',\n" + 
                "org_id => :2)); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.NUMBER);
            long orgId = pAM.getOADBTransaction().getOrgId();
            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getCurrentCSId", 
                                                       "orgId = " + orgId, 
                                                       OAFwkConstants.PROCEDURE);
            ocs.setLong(2, orgId);

            long priceId = -1;

            ocs.execute();
            priceId = ocs.getNUMBER(1).longValue();


            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getCurrentCSId", 
                                                       "storeId = " + priceId, 
                                                       OAFwkConstants.PROCEDURE);

            return priceId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public long getPriceListId(OAApplicationModule pAM, long pOrgId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := to_number(fnd_profile.value_specific(name => 'XXPHA_PRICELIST_4_INT_REQ',\n" + 
                "org_id => :2)); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.NUMBER);
            long orgId = pOrgId;
            writeDiagnostics((OAApplicationModuleImpl)pAM, 
                             CLASS_NAME + ".getCurrentCSId", 
                             "orgId = " + orgId, OAFwkConstants.PROCEDURE);
            ocs.setLong(2, orgId);

            long priceId = -1;

            ocs.execute();
            priceId = ocs.getNUMBER(1).longValue();


            writeDiagnostics((OAApplicationModuleImpl)pAM, 
                             CLASS_NAME + ".getCurrentCSId", 
                             "storeId = " + priceId, OAFwkConstants.PROCEDURE);

            return priceId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public String getOperatingUnitName(OAApplicationModule pAM, long orgId) {
        String sSQL = 
            "select name from hr_operating_units ou where 1=1\n" + "and nvl(ou.date_to, sysdate) >= sysdate\n" + 
            "and ou.organization_id = :1";

        Connection connect = null;
        OraclePreparedStatement ops = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();

            ops = (OraclePreparedStatement)connect.prepareCall(sSQL);
            ops.setLong(1, orgId);

            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getOperatingUnitName", 
                                                       "orgId = " + orgId, 
                                                       OAFwkConstants.PROCEDURE);

            OracleResultSet rs = (OracleResultSet)ops.executeQuery();
            rs.next();

            String name = rs.getString(1);


            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getOperatingUnitName", 
                                                       "name = " + name, 
                                                       OAFwkConstants.PROCEDURE);

            return name;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ops.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public void setSubInv(String subInv) {
        this.subInv = subInv;
    }

    public String getSubInv() {
        return subInv;
    }

    public void setNeedByDate(Date needByDate) {
        this.needByDate = needByDate;
    }

    public Date getNeedByDate() {
        return needByDate;
    }

    public void clearDraft(OAApplicationModule pAM) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = "BEGIN XXPHA_SN1041_PKG.Clear_Draft; end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);
            ocs.execute();

            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".clearDraft", " - OK", 
                                                       OAFwkConstants.PROCEDURE);

        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public long getWipOrganizationId(OAApplicationModule pAM, 
                                     long pWipEntityId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.Get_Wip_Organization_ID(:2); end; ";

            ocs = (OracleCallableStatement)connect.prepareCall(sql);

            ocs.registerOutParameter(1, OracleTypes.NUMBER);
            ocs.setNUMBER(2, new Number(pWipEntityId));

            long storeId = -1;

            ocs.execute();
            storeId = ocs.getNUMBER(1).longValue();


            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getWipOrganizationId", 
                                                       "storeId = " + storeId, 
                                                       OAFwkConstants.PROCEDURE);

            return storeId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public long getOrgIdByOrganizationId(OAApplicationModule pAM, 
                                         long pOrganizationId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.Get_Org_Id_By_Organization_ID(:2); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.NUMBER);
            ocs.setLong(2, pOrganizationId);

            long orgId = -1;

            ocs.execute();
            orgId = ocs.getNUMBER(1).longValue();


            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getOrgIdByOrganizationId", 
                                                       "orgId = " + orgId, 
                                                       OAFwkConstants.PROCEDURE);

            return orgId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public String getDefaultWipSubinventory(OAApplicationModule pAM, 
                                            long pWipEntityId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.Get_Default_Wip_Subinventory(:2); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.VARCHAR);
            ocs.setLong(2, pWipEntityId);

            ocs.execute();
            String defaultWipSubinventory = ocs.getString(1);

            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getDefaultWipSubinventory", 
                                                       "defaultWipSubinventory = " + 
                                                       defaultWipSubinventory, 
                                                       OAFwkConstants.PROCEDURE);

            return defaultWipSubinventory;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public long getDefaultWipLocatorId(OAApplicationModule pAM, 
                                       long pWipEntityId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.Get_Default_Wip_Locator_Id(:2); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.NUMBER);
            ocs.setLong(2, pWipEntityId);

            ocs.execute();
            long defaultLocatorId = ocs.getNUMBER(1).longValue();

            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getDefaultWipLocatorId", 
                                                       "defaultLocatorId=" + 
                                                       defaultLocatorId, 
                                                       OAFwkConstants.PROCEDURE);

            return defaultLocatorId;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public Date getWipScheduledStartDate(OAApplicationModule pAM, 
                                         long pWipEntityId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.Get_Wip_Sheduled_Start_Date(:2); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.DATE);
            ocs.setLong(2, pWipEntityId);

            ocs.execute();
            Date sheduledStartDate = ocs.getDate(1);

            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getWipScheduledStartDate", 
                                                       "sheduledStartDate=" + 
                                                       sheduledStartDate, 
                                                       OAFwkConstants.PROCEDURE);

            return sheduledStartDate;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }

    }
    
    public NUMBER getPairCSQuantity(OAApplicationModule pAM, 
                                         long pCSId, long pItemId) {
        Connection connect = null;
        OracleCallableStatement ocs = null;

        try {
            connect = pAM.getOADBTransaction().getJdbcConnection();
            String sql = 
                "BEGIN :1 := XXPHA_SN1041_PKG.get_pair_available_qant(:2, :3); end; ";
            ocs = (OracleCallableStatement)connect.prepareCall(sql);


            ocs.registerOutParameter(1, OracleTypes.NUMBER);
            ocs.setLong(2, pCSId);
            ocs.setLong(3, pItemId);

            ocs.execute();
            NUMBER pairCSQuantity = ocs.getNUMBER(1);

            Sn1041Utils.getInstance().writeDiagnostics((OAApplicationModuleImpl)pAM, 
                                                       CLASS_NAME + 
                                                       ".getPairCSQuantity", 
                                                       "pairCSQuantity=" + 
                                                       pairCSQuantity, 
                                                       OAFwkConstants.PROCEDURE);

            return pairCSQuantity;
        } catch (Exception e) {
            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                ocs.close();
                //connect.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }

    }
}
