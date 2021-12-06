package xxpha.oracle.apps.icx.sn1041.utils;

import java.io.Serializable;

public class ResultForInvoce implements Serializable {

    private String resType;
    private String resDescr;

    public ResultForInvoce(String resType, String resDescr) {
        this.resType = resType;
        this.resDescr = resDescr;
    }


    public String getResType() {
        return resType;
    }

    public String getResDescr() {
        return resDescr;
    }
}
