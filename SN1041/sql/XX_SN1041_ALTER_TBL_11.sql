alter table xxpha.xxpha_sn1041_req_items_t add wip_buyer_notes VARCHAR2(240)
/
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.wip_buyer_notes is 'Заметки покупателю WIP_REQUIREMENT_OPERATIONS_V.comments'
/
alter table xxpha.xxpha_sn1041_req_items_t add WIP_OL_NUM VARCHAR2(150)
/
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.WIP_OL_NUM is 'В атрибут ATTRIBUTE6 (Номер ОЛ) строки внутренней заявки записываем значение сегмента XXPHA_EAM518_OL_NUM ОГП формы "Потребности в материалах" строки материала в ЗВР .'
/
alter table xxpha.xxpha_sn1041_req_items_t add WIP_OL_DATE DATE
/
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.WIP_OL_DATE is 'В атрибут ATTRIBUTE7 (Дата ОЛ) строки внутренней заявки записываем значение сегмента XXPHA_EAM518_OL_DATE ОГП формы "Потребности в материалах"строки материала в ЗВР .'
/
alter table xxpha.xxpha_sn1041_req_items_t add wip_due_date date
/
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.wip_due_date is 'Расчетная дата поставки'
/

/*
begin
  xxpha_pnaumov_pkg.find_block_session(p_obj_name=>'XXPHA_SN1041%', p_kill_session=>'Y');
end;
/
*/

alter table xxpha.xxpha_sn1041_item_search_rslt add wip_buyer_notes VARCHAR2(240)
/
comment on column XXPHA.xxpha_sn1041_item_search_rslt.wip_buyer_notes is 'Заметки покупателю WIP_REQUIREMENT_OPERATIONS_V.comments'
/
alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_OL_NUM VARCHAR2(150)
/
comment on column XXPHA.xxpha_sn1041_item_search_rslt.WIP_OL_NUM is 'В атрибут ATTRIBUTE6 (Номер ОЛ) строки внутренней заявки записываем значение сегмента XXPHA_EAM518_OL_NUM ОГП формы "Потребности в материалах" строки материала в ЗВР .'
/
alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_OL_DATE DATE
/
comment on column XXPHA.xxpha_sn1041_item_search_rslt.WIP_OL_DATE is 'В атрибут ATTRIBUTE7 (Дата ОЛ) строки внутренней заявки записываем значение сегмента XXPHA_EAM518_OL_DATE ОГП формы "Потребности в материалах"строки материала в ЗВР .'
/
