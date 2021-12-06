package xxpha.oracle.apps.icx.sn1041.server;

import java.util.ArrayList;

import oracle.apps.fnd.framework.OAException;
import oracle.apps.fnd.framework.OAFwkConstants;
import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;

import oracle.jbo.RowSetIterator;
import oracle.jbo.domain.Number;

import oracle.jdbc.OracleCallableStatement;
import oracle.jdbc.OracleConnection;
import oracle.jdbc.OracleTypes;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.NUMBER;

import xxpha.oracle.apps.icx.sn1041.utils.Sn1041Utils;


// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class AnalogAMImpl extends OAApplicationModuleImpl {
    private final String CLASS_NAME = AnalogAMImpl.class.getName();
    private final Sn1041Utils utils = Sn1041Utils.getInstance();

    /**This is the default constructor (do not remove)
     */
    public AnalogAMImpl() {
        super();
        //this.CLASS_NAME = this.getClass().getName();
    }

    /**Sample main for debugging Business Components code using the tester.
     */
    public static void main(String[] args) { /* package name */
        /* Configuration Name */launchTester("xxpha.oracle.apps.icx.sn1041.server", 
                                             "AnalogAMLocal");
    }


    public void initQuery(Long itemId, Boolean executeQuery) {
        long currentStoreId = utils.getCurrentStoreId(this);
        long currentCSId = Sn1041Utils.getInstance().getCurrentCSId(this);

        utils.writeDiagnostics(this, CLASS_NAME + ".initQuery", 
                               " currentStoreId = " + currentStoreId, 
                               OAFwkConstants.PROCEDURE);

        utils.writeDiagnostics(this, CLASS_NAME + ".initQuery", 
                               " currentCSId = " + currentCSId, 
                               OAFwkConstants.PROCEDURE);

        //getAnalogVO1().initQuery(itemId.longValue(), currentStoreId, currentCSId, 
        //                         executeQuery);
    }


    public ArrayList<OAException> addAnalogSelectedItems() {
        boolean flagSelectRow = false;
        AnalogVOImpl searchRes = getAnalogVO1();

        RowSetIterator rsIter = searchRes.getRowSetIterator();
        rsIter.reset();

        //ArrayList<String> messList = new ArrayList<String>();
        ArrayList<OAException> returnMesList = new ArrayList<OAException>();

        ArrayList<Number> itemIds = new ArrayList<Number>();
        ArrayList<String> itemCodes = new ArrayList<String>();
        ArrayList<String> itemDesriptions = new ArrayList<String>();
        ArrayList<String> UOMs = new ArrayList<String>();
        ArrayList<Number> availableCS = new ArrayList<Number>();


        while (rsIter.hasNext()) {
            AnalogVORowImpl r = (AnalogVORowImpl)rsIter.next();
            String isSelected = r.getSelected();
            utils.writeDiagnostics(this, 
                                   CLASS_NAME + ".addAnalogSelectedItems", 
                                   "isSelected  = " + isSelected, 
                                   OAFwkConstants.PROCEDURE);

            if ("Y".equals(isSelected)) {
                flagSelectRow = true;
                itemIds.add(r.getRelatedItemId());
                itemCodes.add(r.getSegment1());
                itemDesriptions.add(r.getRelatedItemDescription());
                UOMs.add(r.getPrimaryUnitOfMeasure());
                availableCS.add(r.getCsAvailQty());
            }
        }

        rsIter.closeRowSetIterator();

        String stmt = 
            "begin\n" + ":1:= XXPHA_SN1041_PKG.Add_Analog(p_item_ids=>:2, p_item_codes=>:3," + 
            " p_item_descriptions=>:4," + " p_uom=>:5, " + 
            "p_cs_available_quantity =>:6," + " p_oe_id=>:7," + 
            " p_organization_id=>:8," + " p_wip_entity_id=>:9," + 
            " x_out_messages=>:10" + ");\n" + "end;";

        OracleCallableStatement call = null;

        long wipEntityId = utils.getCurrentWipEntityId(this);
        utils.writeDiagnostics(this, CLASS_NAME + ".addAnalogSelectedItems", 
                               "wipEntityId=" + wipEntityId, 
                               OAFwkConstants.PROCEDURE);

        Number orgatizationId = null;
        Number orgId = null;

        if (wipEntityId > 0) {
            orgatizationId = 
                    new Number(utils.getWipOrganizationId(this, wipEntityId));
            orgId = 
                    new Number(utils.getOrgIdByOrganizationId(this, orgatizationId.longValue()));

        } else {
            orgatizationId = new Number(utils.getCurrentStoreId(this));
            orgId = new Number(getOADBTransaction().getOrgId());
        }

        try {
            OracleConnection conn = 
                (OracleConnection)getOADBTransaction().getJdbcConnection();


            Number[] ids = new Number[itemIds.size()];
            ids = itemIds.toArray(ids);
            ArrayDescriptor desIds = 
                ArrayDescriptor.createDescriptor("FND_TABLE_OF_NUMBER", conn);
            ARRAY ids_array = new ARRAY(desIds, conn, ids);

            String[] codes = new String[itemCodes.size()];
            codes = itemCodes.toArray(codes);
            ArrayDescriptor desCodes = 
                ArrayDescriptor.createDescriptor("FND_TABLE_OF_VARCHAR2_30", 
                                                 conn);
            ARRAY codes_array = new ARRAY(desCodes, conn, codes);

            String[] descriptions = new String[itemDesriptions.size()];
            descriptions = itemDesriptions.toArray(descriptions);
            ArrayDescriptor desDescription = 
                ArrayDescriptor.createDescriptor("FND_TABLE_OF_VARCHAR2_4000", 
                                                 conn);
            ARRAY descriptions_array = 
                new ARRAY(desDescription, conn, descriptions);

            String[] saUOMs = new String[UOMs.size()];
            saUOMs = UOMs.toArray(saUOMs);
            ArrayDescriptor desUOMs = 
                ArrayDescriptor.createDescriptor("FND_TABLE_OF_VARCHAR2_30", 
                                                 conn);
            ARRAY UOMS_array = new ARRAY(desUOMs, conn, saUOMs);


            Number[] aAvailableCS = new Number[availableCS.size()];
            aAvailableCS = availableCS.toArray(aAvailableCS);
            ArrayDescriptor desAvailableCS = 
                ArrayDescriptor.createDescriptor("FND_TABLE_OF_NUMBER", conn);
            ARRAY arrAvailableCS = 
                new ARRAY(desAvailableCS, conn, aAvailableCS);


            call = (OracleCallableStatement)conn.prepareCall(stmt);

            call.registerOutParameter(1, OracleTypes.NUMBER);
            call.setARRAY(2, ids_array);
            call.setARRAY(3, codes_array);
            call.setARRAY(4, descriptions_array);
            call.setARRAY(5, UOMS_array);
            call.setARRAY(6, arrAvailableCS);
            call.setNUMBER(7, orgId);
            call.setNUMBER(8, orgatizationId);
            call.setNUMBER(9, new NUMBER(wipEntityId));
            call.registerOutParameter(10, OracleTypes.ARRAY, 
                                      "FND_TABLE_OF_VARCHAR2_4000");

            call.execute();

            ARRAY messageArr = call.getARRAY(10);
            String[] receivedArray = (String[])messageArr.getArray();
            for (int i = 0; i < receivedArray.length; i++)
                returnMesList.add(new OAException(receivedArray[i], 
                                                  receivedArray[i].startsWith("Позиция") && 
                                                  receivedArray[i].endsWith("добавлена") ? 
                                                  OAException.INFORMATION : 
                                                  OAException.ERROR));
        } catch (Exception e) {
            e.printStackTrace();

            utils.writeDiagnostics(this, 
                                   CLASS_NAME + ".addAnalogSelectedItems", 
                                   " Error!" + e.getMessage(), 
                                   OAFwkConstants.PROCEDURE);


            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                call.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }

        return returnMesList;
    }

    public void addToSearch() {
        utils.writeDiagnostics(this, CLASS_NAME + ".addToSearch", 
                               " Start !!! ", OAFwkConstants.PROCEDURE);

        String stmt = 
            "begin\n" + ":1:= XXPHA_SN1041_PKG.Add_Analog;\n" + "end;";
        OracleCallableStatement call = null;

        try {
            OracleConnection conn = 
                (OracleConnection)getOADBTransaction().getJdbcConnection();
            call = (OracleCallableStatement)conn.prepareCall(stmt);
            call.registerOutParameter(1, OracleTypes.NUMBER);
            call.execute();
        } catch (Exception e) {
            e.printStackTrace();

            utils.writeDiagnostics(this, CLASS_NAME + ".addToSearch", 
                                   " Error!" + e.getMessage(), 
                                   OAFwkConstants.PROCEDURE);


            throw new OAException(e.getMessage(), OAException.ERROR);
        } finally {
            try {
                call.close();
            } catch (Exception e) {
                throw new OAException(e.getLocalizedMessage(), 
                                      OAException.ERROR);
            }
        }
    }

    public void initAnalogQuery(Long itemId, Boolean executeQuery) {
        long currentStoreId = utils.getCurrentStoreId(this);
        long currentCSId = utils.getCurrentCSId(this);
        long priceListId = utils.getPriceListId(this);

        utils.writeDiagnostics(this, CLASS_NAME + ".initAnalogQuery", 
                               " currentStoreId = " + currentStoreId, 
                               OAFwkConstants.PROCEDURE);

        utils.writeDiagnostics(this, CLASS_NAME + ".initAnalogQuery", 
                               " currentCSId = " + currentCSId, 
                               OAFwkConstants.PROCEDURE);

        getAnalogVO1().initQuery(itemId.longValue(), currentStoreId, 
                                 currentCSId, priceListId, executeQuery);
    }

    public void initAnalogQueryEam(Long itemId, Boolean executeQuery) {

        long wipEntityId = utils.getCurrentWipEntityId(this);
        long currentStoreId = utils.getWipOrganizationId(this, wipEntityId);
        long currentCSId = utils.getCurrentCSId(this, currentStoreId);
        long orgId = utils.getOrgIdByOrganizationId(this, currentStoreId);
        long priceListId = utils.getPriceListId(this, orgId);

        utils.writeDiagnostics(this, CLASS_NAME + ".initAnalogQueryEam", 
                               "wipEntityId=" + wipEntityId + 
                               ",currentStoreId=" + currentStoreId + 
                               ",currentCSId=" + currentCSId + 
                               ",priceListId=" + priceListId, 
                               OAFwkConstants.PROCEDURE);


        getAnalogVO1().initQuery(itemId.longValue(), currentStoreId, 
                                 currentCSId, priceListId, executeQuery);
    }

    /**Container's getter for AnalogVO1
     */
    public AnalogVOImpl getAnalogVO1() {
        return (AnalogVOImpl)findViewObject("AnalogVO1");
    }
}
