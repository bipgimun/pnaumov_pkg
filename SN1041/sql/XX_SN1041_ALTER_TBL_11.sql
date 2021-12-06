alter table xxpha.xxpha_sn1041_req_items_t add wip_buyer_notes VARCHAR2(240)
/
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.wip_buyer_notes is '������� ���������� WIP_REQUIREMENT_OPERATIONS_V.comments'
/
alter table xxpha.xxpha_sn1041_req_items_t add WIP_OL_NUM VARCHAR2(150)
/
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.WIP_OL_NUM is '� ������� ATTRIBUTE6 (����� ��) ������ ���������� ������ ���������� �������� �������� XXPHA_EAM518_OL_NUM ��� ����� "����������� � ����������" ������ ��������� � ��� .'
/
alter table xxpha.xxpha_sn1041_req_items_t add WIP_OL_DATE DATE
/
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.WIP_OL_DATE is '� ������� ATTRIBUTE7 (���� ��) ������ ���������� ������ ���������� �������� �������� XXPHA_EAM518_OL_DATE ��� ����� "����������� � ����������"������ ��������� � ��� .'
/
alter table xxpha.xxpha_sn1041_req_items_t add wip_due_date date
/
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.wip_due_date is '��������� ���� ��������'
/

/*
begin
  xxpha_pnaumov_pkg.find_block_session(p_obj_name=>'XXPHA_SN1041%', p_kill_session=>'Y');
end;
/
*/

alter table xxpha.xxpha_sn1041_item_search_rslt add wip_buyer_notes VARCHAR2(240)
/
comment on column XXPHA.xxpha_sn1041_item_search_rslt.wip_buyer_notes is '������� ���������� WIP_REQUIREMENT_OPERATIONS_V.comments'
/
alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_OL_NUM VARCHAR2(150)
/
comment on column XXPHA.xxpha_sn1041_item_search_rslt.WIP_OL_NUM is '� ������� ATTRIBUTE6 (����� ��) ������ ���������� ������ ���������� �������� �������� XXPHA_EAM518_OL_NUM ��� ����� "����������� � ����������" ������ ��������� � ��� .'
/
alter table xxpha.xxpha_sn1041_item_search_rslt add WIP_OL_DATE DATE
/
comment on column XXPHA.xxpha_sn1041_item_search_rslt.WIP_OL_DATE is '� ������� ATTRIBUTE7 (���� ��) ������ ���������� ������ ���������� �������� �������� XXPHA_EAM518_OL_DATE ��� ����� "����������� � ����������"������ ��������� � ��� .'
/
