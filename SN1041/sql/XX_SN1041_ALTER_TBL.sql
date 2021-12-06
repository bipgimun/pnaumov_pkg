alter table xxpha.xxpha_sn1041_session add WIP_ENTITY_ID NUMBER
/

alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_ENTITY_ID NUMBER
/
alter table xxpha.xxpha_sn1041_item_search_rslt add OPERATION_SEQ_NUM NUMBER
/
alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_SUBINVENTORY VARCHAR2(50)
/
alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_LOCATOR_ID NUMBER
/
alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_DATE_REQUIRED DATE
/
alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_GL_DATE DATE
/
alter table xxpha.xxpha_sn1041_item_search_rslt add AGREEMENT VARCHAR2(150)
/


comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.AGREEMENT is 'ÎÑÇ';