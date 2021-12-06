package xxpha.oracle.apps.icx.sn1041.server;

import oracle.apps.fnd.framework.server.OAViewRowImpl;

import oracle.jbo.domain.Number;
import oracle.jbo.server.AttributeDefImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ParametersVORowImpl extends OAViewRowImpl {
    public static final int NAME = 0;
    public static final int STORERECEIVER = 1;
    public static final int SERVURL = 2;

    /**This is the default constructor (do not remove)
     */
    public ParametersVORowImpl() {
    }

    /**Gets the attribute value for the calculated attribute Name
     */
    public String getName() {
        return (String) getAttributeInternal(NAME);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute Name
     */
    public void setName(String value) {
        setAttributeInternal(NAME, value);
    }

    /**Gets the attribute value for the calculated attribute StoreReceiver
     */
    public Number getStoreReceiver() {
        return (Number) getAttributeInternal(STORERECEIVER);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute StoreReceiver
     */
    public void setStoreReceiver(Number value) {
        setAttributeInternal(STORERECEIVER, value);
    }

    /**Gets the attribute value for the calculated attribute ServUrl
     */
    public String getServUrl() {
        return (String) getAttributeInternal(SERVURL);
    }

    /**Sets <code>value</code> as the attribute value for the calculated attribute ServUrl
     */
    public void setServUrl(String value) {
        setAttributeInternal(SERVURL, value);
    }


    /**getAttrInvokeAccessor: generated method. Do not modify.
     */
    protected Object getAttrInvokeAccessor(int index, 
                                           AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        case NAME:
            return getName();
        case STORERECEIVER:
            return getStoreReceiver();
        case SERVURL:
            return getServUrl();
        default:
            return super.getAttrInvokeAccessor(index, attrDef);
        }
    }

    /**setAttrInvokeAccessor: generated method. Do not modify.
     */
    protected void setAttrInvokeAccessor(int index, Object value, 
                                         AttributeDefImpl attrDef) throws Exception {
        switch (index) {
        case STORERECEIVER:
            setStoreReceiver((Number)value);
            return;
        case SERVURL:
            setServUrl((String)value);
            return;
        default:
            super.setAttrInvokeAccessor(index, value, attrDef);
            return;
        }
    }
}
