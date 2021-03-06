package xxpha.oracle.apps.icx.sn1041.server;

import oracle.apps.fnd.framework.server.OAViewRowImpl;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;

import xxpha.oracle.apps.icx.sn1041.server.common.SearchResultsVORow;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class SearchResultsVORowImpl extends OAViewRowImpl implements SearchResultsVORow {
    public static final int SCORE = 0;
    public static final int INVENTORYITEMID = 1;
    public static final int ITEMCODE = 2;
    public static final int CATALOGCODE = 3;
    public static final int DESCRIPTION = 4;
    public static final int SUPDESCRIPTION = 5;
    public static final int PRICE = 6;
    public static final int UOM = 7;
    public static final int CSQUANTITY = 8;
    public static final int CSAVAILABLEQUANTITY = 9;
    public static final int STOREQUANTITY = 10;
    public static final int STOREAVAILABLEQUANTITY = 11;
    public static final int HOLDINGQUANTITY = 12;
    public static final int HOLDINGAVAILABLEQUANTITY = 13;
    public static final int DELIVERIES = 14;
    public static final int SUPPLIER = 15;
    public static final int IMAGE = 16;
    public static final int ANALOG = 17;
    public static final int DEACTIVATION = 18;
    public static final int LASTUPDATEDATE = 19;
    public static final int SELECTEDITEM = 20;
    public static final int ISDEACTRENDERED = 21;
    public static final int SEARCHITEMID = 22;
    public static final int IMAGETEXT = 23;
    public static final int ISANALOGRENDERED = 24;
    public static final int DISPPRICE = 25;
    public static final int INDEXNAME = 26;
    public static final int SELECTIONRENDERED = 27;
    public static final int CURRENTSTOREID = 28;
    public static final int CSSTOREID = 29;
    public static final int VENDORID = 30;
    public static final int POLINEID = 31;
    public static final int OPERATIONSEQNUM = 32;
    public static final int OPERATIONDESCRIPTION = 33;
    public static final int AGREEMENT = 34;
    public static final int DUEDATE = 35;

    /**This is the default constructor (do not remove)
     */
    public SearchResultsVORowImpl() {
    }

    /**Gets the attribute value for the calculated attribute Score
     */
    public Number getScore() {
        return (Number)getAttributeInternal(SCORE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Score
     */
    public void setScore(Number value) {
        setAttributeInternal(SCORE, value);
    }

    /**Gets the attribute value for the calculated attribute InventoryItemId
     */
    public Number getInventoryItemId() {
        return (Number)getAttributeInternal(INVENTORYITEMID);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute InventoryItemId
     */
    public void setInventoryItemId(Number value) {
        setAttributeInternal(INVENTORYITEMID, value);
    }

    /**Gets the attribute value for the calculated attribute ItemCode
     */
    public String getItemCode() {
        return (String)getAttributeInternal(ITEMCODE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute ItemCode
     */
    public void setItemCode(String value) {
        setAttributeInternal(ITEMCODE, value);
    }

    /**Gets the attribute value for the calculated attribute CatalogCode
     */
    public String getCatalogCode() {
        return (String)getAttributeInternal(CATALOGCODE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute CatalogCode
     */
    public void setCatalogCode(String value) {
        setAttributeInternal(CATALOGCODE, value);
    }

    /**Gets the attribute value for the calculated attribute Description
     */
    public String getDescription() {
        return (String)getAttributeInternal(DESCRIPTION);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Description
     */
    public void setDescription(String value) {
        setAttributeInternal(DESCRIPTION, value);
    }

    /**Gets the attribute value for the calculated attribute SupDescription
     */
    public String getSupDescription() {
        return (String)getAttributeInternal(SUPDESCRIPTION);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute SupDescription
     */
    public void setSupDescription(String value) {
        setAttributeInternal(SUPDESCRIPTION, value);
    }

    /**Gets the attribute value for the calculated attribute Price
     */
    public Number getPrice() {
        return (Number)getAttributeInternal(PRICE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Price
     */
    public void setPrice(Number value) {
        setAttributeInternal(PRICE, value);
    }

    /**Gets the attribute value for the calculated attribute Uom
     */
    public String getUom() {
        return (String)getAttributeInternal(UOM);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Uom
     */
    public void setUom(String value) {
        setAttributeInternal(UOM, value);
    }

    /**Gets the attribute value for the calculated attribute CsQuantity
     */
    public Number getCsQuantity() {
        return (Number)getAttributeInternal(CSQUANTITY);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute CsQuantity
     */
    public void setCsQuantity(Number value) {
        setAttributeInternal(CSQUANTITY, value);
    }

    /**Gets the attribute value for the calculated attribute CsAvailableQuantity
     */
    public Number getCsAvailableQuantity() {
        return (Number)getAttributeInternal(CSAVAILABLEQUANTITY);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute CsAvailableQuantity
     */
    public void setCsAvailableQuantity(Number value) {
        setAttributeInternal(CSAVAILABLEQUANTITY, value);
    }

    /**Gets the attribute value for the calculated attribute StoreQuantity
     */
    public Number getStoreQuantity() {
        return (Number)getAttributeInternal(STOREQUANTITY);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute StoreQuantity
     */
    public void setStoreQuantity(Number value) {
        setAttributeInternal(STOREQUANTITY, value);
    }

    /**Gets the attribute value for the calculated attribute StoreAvailableQuantity
     */
    public Number getStoreAvailableQuantity() {
        return (Number)getAttributeInternal(STOREAVAILABLEQUANTITY);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute StoreAvailableQuantity
     */
    public void setStoreAvailableQuantity(Number value) {
        setAttributeInternal(STOREAVAILABLEQUANTITY, value);
    }

    /**Gets the attribute value for the calculated attribute HoldingQuantity
     */
    public Number getHoldingQuantity() {
        return (Number)getAttributeInternal(HOLDINGQUANTITY);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute HoldingQuantity
     */
    public void setHoldingQuantity(Number value) {
        setAttributeInternal(HOLDINGQUANTITY, value);
    }

    /**Gets the attribute value for the calculated attribute HoldingAvailableQuantity
     */
    public Number getHoldingAvailableQuantity() {
        return (Number)getAttributeInternal(HOLDINGAVAILABLEQUANTITY);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute HoldingAvailableQuantity
     */
    public void setHoldingAvailableQuantity(Number value) {
        setAttributeInternal(HOLDINGAVAILABLEQUANTITY, value);
    }

    /**Gets the attribute value for the calculated attribute Deliveries
     */
    public Number getDeliveries() {
        return (Number)getAttributeInternal(DELIVERIES);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Deliveries
     */
    public void setDeliveries(Number value) {
        setAttributeInternal(DELIVERIES, value);
    }

    /**Gets the attribute value for the calculated attribute Supplier
     */
    public String getSupplier() {
        return (String)getAttributeInternal(SUPPLIER);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Supplier
     */
    public void setSupplier(String value) {
        setAttributeInternal(SUPPLIER, value);
    }

    /**Gets the attribute value for the calculated attribute Image
     */
    public String getImage() {
        return (String)getAttributeInternal(IMAGE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Image
     */
    public void setImage(String value) {
        setAttributeInternal(IMAGE, value);
    }

    /**Gets the attribute value for the calculated attribute Analog
     */
    public String getAnalog() {
        return (String)getAttributeInternal(ANALOG);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Analog
     */
    public void setAnalog(String value) {
        setAttributeInternal(ANALOG, value);
    }

    /**Gets the attribute value for the calculated attribute Deactivation
     */
    public String getDeactivation() {
        return (String)getAttributeInternal(DEACTIVATION);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Deactivation
     */
    public void setDeactivation(String value) {
        setAttributeInternal(DEACTIVATION, value);
    }

    /**Gets the attribute value for the calculated attribute LastUpdateDate
     */
    public Date getLastUpdateDate() {
        return (Date)getAttributeInternal(LASTUPDATEDATE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute LastUpdateDate
     */
    public void setLastUpdateDate(Date value) {
        setAttributeInternal(LASTUPDATEDATE, value);
    }

    /**Gets the attribute value for the calculated attribute SelectedItem
     */
    public String getSelectedItem() {
        return (String)getAttributeInternal(SELECTEDITEM);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute SelectedItem
     */
    public void setSelectedItem(String value) {
        setAttributeInternal(SELECTEDITEM, value);
    }

    /**getAttrInvokeAccessor: generated method. Do not modify.
     */
    protected Object getAttrInvokeAccessor(int index, 
                                           AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        case SCORE:
            return getScore();
        case INVENTORYITEMID:
            return getInventoryItemId();
        case ITEMCODE:
            return getItemCode();
        case CATALOGCODE:
            return getCatalogCode();
        case DESCRIPTION:
            return getDescription();
        case SUPDESCRIPTION:
            return getSupDescription();
        case PRICE:
            return getPrice();
        case UOM:
            return getUom();
        case CSQUANTITY:
            return getCsQuantity();
        case CSAVAILABLEQUANTITY:
            return getCsAvailableQuantity();
        case STOREQUANTITY:
            return getStoreQuantity();
        case STOREAVAILABLEQUANTITY:
            return getStoreAvailableQuantity();
        case HOLDINGQUANTITY:
            return getHoldingQuantity();
        case HOLDINGAVAILABLEQUANTITY:
            return getHoldingAvailableQuantity();
        case DELIVERIES:
            return getDeliveries();
        case SUPPLIER:
            return getSupplier();
        case IMAGE:
            return getImage();
        case ANALOG:
            return getAnalog();
        case DEACTIVATION:
            return getDeactivation();
        case LASTUPDATEDATE:
            return getLastUpdateDate();
        case SELECTEDITEM:
            return getSelectedItem();
        case ISDEACTRENDERED:
            return getIsDeactRendered();
        case SEARCHITEMID:
            return getSearchItemId();
        case IMAGETEXT:
            return getImageText();
        case ISANALOGRENDERED:
            return getIsAnalogRendered();
        case DISPPRICE:
            return getDispPrice();
        case INDEXNAME:
            return getIndexName();
        case SELECTIONRENDERED:
            return getSelectionRendered();
        case CURRENTSTOREID:
            return getCurrentStoreId();
        case CSSTOREID:
            return getCsStoreId();
        case VENDORID:
            return getVendorId();
        case POLINEID:
            return getPoLineId();
        case OPERATIONSEQNUM:
            return getOperationSeqNum();
        case OPERATIONDESCRIPTION:
            return getOperationDescription();
        case AGREEMENT:
            return getAgreement();
        case DUEDATE:
            return getDueDate();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }

    /**setAttrInvokeAccessor: generated method. Do not modify.
     */
    protected void setAttrInvokeAccessor(int index, Object value, 
                                         AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        case PRICE:
            setPrice((Number)value);
            return;
        case LASTUPDATEDATE:
            setLastUpdateDate((Date)value);
            return;
        case SELECTEDITEM:
            setSelectedItem((String)value);
            return;
        case INDEXNAME:
            setIndexName((String)value);
            return;
        case CURRENTSTOREID:
            setCurrentStoreId((Number)value);
            return;
        case CSSTOREID:
            setCsStoreId((Number)value);
            return;
        case VENDORID:
            setVendorId((Number)value);
            return;
        case OPERATIONSEQNUM:
            setOperationSeqNum((Number)value);
            return;
        case OPERATIONDESCRIPTION:
            setOperationDescription((String)value);
            return;
        case AGREEMENT:
            setAgreement((String)value);
            return;
        case DUEDATE:
            setDueDate((Date)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }


    /**Gets the attribute value for the calculated attribute SearchItemId
     */
    public Number getSearchItemId() {
        return (Number)getAttributeInternal(SEARCHITEMID);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute SearchItemId
     */
    public void setSearchItemId(Number value) {
        setAttributeInternal(SEARCHITEMID, value);
    }

    /**Gets the attribute value for the calculated attribute ImageText
     */
    public String getImageText() {
        return getImage() != null ? "???? ?????????? ????????????????????" : null;
        //return (String) getAttributeInternal(IMAGETEXT);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute ImageText
     */
    public void setImageText(String value) {
        setAttributeInternal(IMAGETEXT, value);
    }

    /**Gets the attribute value for the calculated attribute IsDeactRendered
     */
    public Boolean getIsDeactRendered() {
        String s = getDeactivation();
        return s != null && !"".equals(s) ? true : false;
        //return (Boolean) getAttributeInternal(ISDEACTRENDERED);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute IsDeactRendered
     */
    public void setIsDeactRendered(Boolean value) {
        setAttributeInternal(ISDEACTRENDERED, value);
    }


    /**Gets the attribute value for the calculated attribute IsAnalogRendered
     */
    public Boolean getIsAnalogRendered() {
        String s = getAnalog();
        //return true;
        return (s != null && !"".equals(s)) ? true : false;
        //return (Boolean)getAttributeInternal(ISANALOGRENDERED);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute IsAnalogRendered
     */
    public void setIsAnalogRendered(Boolean value) {
        setAttributeInternal(ISANALOGRENDERED, value);
    }


    /**Gets the attribute value for the calculated attribute DispPrice
     */
    public String getDispPrice() {
        double price = 0;
        if (getPrice() != null)
            price = getPrice().getValue();
        return String.format("%.2f", price);
        //return (String) getAttributeInternal(DISPPRICE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute DispPrice
     */
    public void setDispPrice(String value) {
        setAttributeInternal(DISPPRICE, value);
    }

    /**Gets the attribute value for the calculated attribute IndexName
     */
    public String getIndexName() {
        return (String) getAttributeInternal(INDEXNAME);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute IndexName
     */
    public void setIndexName(String value) {
        setAttributeInternal(INDEXNAME, value);
    }

    /**Gets the attribute value for the calculated attribute SelectionRendered
     */
    public Boolean getSelectionRendered() {
        double price = 0;
        if (getPrice() != null)
        price = getPrice().getValue();
        
        String index = getIndexName();
        if (price == 0 && "positions_oebs".equals(index))
           return Boolean.FALSE;
        else   
           return Boolean.TRUE;
        //return (Boolean) getAttributeInternal(SELECTIONRENDERED);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute SelectionRendered
     */
    public void setSelectionRendered(Boolean value) {
        setAttributeInternal(SELECTIONRENDERED, value);
    }


    /**Gets the attribute value for the calculated attribute CurrentStoreId
     */
    public Number getCurrentStoreId() {
        return (Number) getAttributeInternal(CURRENTSTOREID);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute CurrentStoreId
     */
    public void setCurrentStoreId(Number value) {
        setAttributeInternal(CURRENTSTOREID, value);
    }

    /**Gets the attribute value for the calculated attribute CsStoreId
     */
    public Number getCsStoreId() {
        return (Number) getAttributeInternal(CSSTOREID);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute CsStoreId
     */
    public void setCsStoreId(Number value) {
        setAttributeInternal(CSSTOREID, value);
    }

    /**Gets the attribute value for the calculated attribute VendorId
     */
    public Number getVendorId() {
        return (Number) getAttributeInternal(VENDORID);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute VendorId
     */
    public void setVendorId(Number value) {
        setAttributeInternal(VENDORID, value);
    }

    /**Gets the attribute value for the calculated attribute PoLineId
     */
    public Number getPoLineId() {
        return (Number) getAttributeInternal(POLINEID);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute PoLineId
     */
    public void setPoLineId(Number value) {
        setAttributeInternal(POLINEID, value);
    }

    /**Gets the attribute value for the calculated attribute OperationSeqNum
     */
    public Number getOperationSeqNum() {
        return (Number) getAttributeInternal(OPERATIONSEQNUM);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute OperationSeqNum
     */
    public void setOperationSeqNum(Number value) {
        setAttributeInternal(OPERATIONSEQNUM, value);
    }

    /**Gets the attribute value for the calculated attribute OperationDescription
     */
    public String getOperationDescription() {
        return (String) getAttributeInternal(OPERATIONDESCRIPTION);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute OperationDescription
     */
    public void setOperationDescription(String value) {
        setAttributeInternal(OPERATIONDESCRIPTION, value);
    }

    /**Gets the attribute value for the calculated attribute Agreement
     */
    public String getAgreement() {
        return (String) getAttributeInternal(AGREEMENT);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Agreement
     */
    public void setAgreement(String value) {
        setAttributeInternal(AGREEMENT, value);
    }

    /**Gets the attribute value for the calculated attribute DueDate
     */
    public Date getDueDate() {
        return (Date) getAttributeInternal(DUEDATE);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute DueDate
     */
    public void setDueDate(Date value) {
        setAttributeInternal(DUEDATE, value);
    }
}
