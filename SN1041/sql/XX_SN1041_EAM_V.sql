create or replace view xxpha_sn1041_eam_v as
select d.wip_entity_id,
       we.wip_entity_name,
       d.req_item_id,
       we.ORGANIZATION_ID,
       d.operation_seq_num,
       r.item_id,
       wro.wip_entity_id   wro, --flag есть ли потребность в материалах
       wo.DEPARTMENT_ID,
       si.DESCRIPTION      ITEM_DESCRIPTION, --X
       d.quantity,
       --,r.need_by_date
       rownum                   rn,
       wro.SUPPLY_SUBINVENTORY,
       r.requisition_type,
       r.source_organization_id,
       d.WIP_SUBINVENTORY,
       d.WIP_DATE_REQUIRED,
       d.wip_gl_date,
       r.org_id,
       wro.REQUIRED_QUANTITY,
       wro.QUANTITY_ISSUED,
       wro.QUANTITY_OPEN,
       d.po_line_id,
       r.wip_buyer_notes,
       r.wip_ol_num,
       r.wip_ol_date
  from xxpha.xxpha_sn1041_req_temp_t r
 inner join xxpha.xxpha_sn1041_eam_distr_temp_t d
    on r.req_item_id = d.line_req_item_id
 inner join wip_entities we
    on we.WIP_ENTITY_ID = d.wip_entity_id
 inner join wip_operations wo
    on wo.WIP_ENTITY_ID = we.WIP_ENTITY_ID
   and wo.OPERATION_SEQ_NUM = d.operation_seq_num
 inner join mtl_system_items_b si
    on si.INVENTORY_ITEM_ID = r.item_id
   and si.organization_id = we.ORGANIZATION_ID
  left join wip_requirement_operations_v wro
    on wro.wip_entity_id = d.wip_entity_id
   and wro.organization_id = we.ORGANIZATION_ID
   and wro.operation_seq_num = d.operation_seq_num
   and wro.inventory_item_id = r.item_id;
