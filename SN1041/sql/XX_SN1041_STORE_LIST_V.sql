create or replace view XXPHA_SN1041_STORE_LIST_V as
select org.ORGANIZATION_ID, org.ORGANIZATION_NAME, org.OPERATING_UNIT
  from xxpha_organizations_v org, mtl_parameters p
 where 1 = 1
   and p.ORGANIZATION_ID = org.ORGANIZATION_ID
   --and p.ATTRIBUTE10 = '������ ����� ����������'
   --and p.ATTRIBUTE6 = '���������'
   --and p.ATTRIBUTE15 <> '�����������'
   and nvl(org.DISABLE_DATE, sysdate) >= sysdate
   and org.OPERATING_UNIT  = fnd_profile.value('ORG_ID') --�� �������� ����������� ����������� �� ���. �������� ��� � ....
;
