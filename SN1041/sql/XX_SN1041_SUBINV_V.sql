create or replace view XXPHA_SN1041_SUBINV_V as
select m.SECONDARY_INVENTORY_NAME
      ,m.DESCRIPTION
      ,m.ORGANIZATION_ID 
from mtl_subinventories_all_v m
where 1=1
and nvl(m.DISABLE_DATE, sysdate)>= sysdate
and m.ASSET_INVENTORY = 1
/
