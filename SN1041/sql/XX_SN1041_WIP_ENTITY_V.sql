CREATE OR REPLACE VIEW XXPHA_SN1041_WIP_ENTITY_V AS
select we.WIP_ENTITY_ID,
       we.WIP_ENTITY_NAME,
       we.ORGANIZATION_ID,
       (SELECT concatenated_segments
          FROM mtl_system_items_vl
         WHERE inventory_item_id = wdj.primary_item_id
           AND organization_id = wdj.organization_id) as sn1041_description,
       null STORE_NAME,
       null OU_NAME,
       (select 'Да'
          from dual
         where exists (select 1
                  from WIP_REQUIREMENT_OPERATIONS_V wro
                 where 1 = 1
                   and wro.wip_entity_id = we.WIP_ENTITY_ID
                   and wro.organization_id = we.ORGANIZATION_ID)
           and rownum = 1
        union all
        select 'Нет'
          from dual
         where not exists (select 1
                  from WIP_REQUIREMENT_OPERATIONS_V wro
                 where 1 = 1
                   and wro.wip_entity_id = we.WIP_ENTITY_ID
                   and wro.organization_id = we.ORGANIZATION_ID)
           and rownum = 1) as HAS_REQUIREMENTS
  from wip_entities we, wip_discrete_jobs wdj
 where 1 = 1
   and we.WIP_ENTITY_ID = wdj.WIP_ENTITY_ID
   and we.ORGANIZATION_ID = wdj.ORGANIZATION_ID
   and wdj.STATUS_TYPE in
       (select to_number(fv.FLEX_VALUE)
          from xxpha_flex_values_v fv
         where fv.FLEX_VALUE_SET_NAME = 'XXPHA_EAM624_STATUS_WO');
