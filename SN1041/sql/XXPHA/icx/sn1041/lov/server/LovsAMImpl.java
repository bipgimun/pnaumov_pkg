package xxpha.oracle.apps.icx.sn1041.lov.server;

import oracle.apps.fnd.framework.server.OAApplicationModuleImpl;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class LovsAMImpl extends OAApplicationModuleImpl {
    /**This is the default constructor (do not remove)
     */
    public LovsAMImpl() {
    }

    /**Sample main for debugging Business Components code using the tester.
     */
    public static void main(String[] args) {
        launchTester("xxpha.oracle.apps.icx.sn1041.lov.server", /* package name */
      "LovsAMLocal" /* Configuration Name */);
    }

    /**Container's getter for StorListVO1
     */
    public StorListVOImpl getStorListVO1() {
        return (StorListVOImpl)findViewObject("StorListVO1");
    }

    /**Container's getter for WipEntitiesListVO1
     */
    public WipEntitiesListVOImpl getWipEntitiesListVO1() {
        return (WipEntitiesListVOImpl)findViewObject("WipEntitiesListVO1");
    }
    
    public void initStoreList(Number pOperatingUnit){
       StorListVOImpl storeList = getStorListVO1();
       storeList.initQuery(pOperatingUnit, Boolean.TRUE);
    }

    /**Container's getter for WorkOrdersVO1
     */
    public WorkOrdersVOImpl getWorkOrdersVO1() {
        return (WorkOrdersVOImpl)findViewObject("WorkOrdersVO1");
    }

    /**Container's getter for OperationsVO1
     */
    public OperationsVOImpl getOperationsVO1() {
        return (OperationsVOImpl)findViewObject("OperationsVO1");
    }

    /**Container's getter for StorListVO2
     */
    public StorListVOImpl getStorListVO2() {
        return (StorListVOImpl)findViewObject("StorListVO2");
    }
}