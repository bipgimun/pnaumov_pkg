create or replace view XXPHA_SN1041_REQ_TYPE_V as
select '2' as REQUISITION_TYPE, '�� ��������� ����������' as RT_DESCRIPTION from dual
union all
select '1' as REQUISITION_TYPE, '� �������' as RT_DESCRIPTION from dual
union all
select '6' as REQUISITION_TYPE, '�� ��������' as RT_DESCRIPTION from dual;
