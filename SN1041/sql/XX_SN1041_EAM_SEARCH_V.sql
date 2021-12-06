create or replace view xxpha_sn1041_eam_search_v as
with req_reference as
 (select wro.wip_entity_id,
         wro.inventory_item_id,
         wro.operation_seq_num,
         wro.concatenated_segments item_code,
         wro.item_description,
         wro.item_primary_uom_code,
         wro.supply_subinventory,
         wro.supply_locator_id,
         wro.date_required,
         fnd_date.canonical_to_date(wro.attribute4) WIP_GL_DATE,
         trim(substr(substr(wro.attribute1,
                            instr(wro.attribute1, ';', -1) + 1),
                     1,
                     instr(substr(wro.attribute1,
                                  instr(wro.attribute1, ';', -1) + 1),
                           '/') - 1)) req_num,
         trim(substr(substr(wro.attribute1,
                            instr(wro.attribute1, ';', -1) + 1),
                     instr(substr(wro.attribute1,
                                  instr(wro.attribute1, ';', -1) + 1),
                           '/') + 1)) line_num,
         o.operating_unit,
         wro.comments buyer_notes,
         wro.attribute5 WIP_OL_NUM,
         fnd_date.canonical_to_date(wro.attribute6) WIP_OL_DATE
    from WIP_REQUIREMENT_OPERATIONS_V wro,
         MFG_LOOKUPS                  ML2,
         wip_entities                 we,
         xxpha_organizations_v        o
   where 1 = 1
     AND ((WRO.BASIS_TYPE IS NULL AND ML2.LOOKUP_CODE = 1) OR
         (WRO.BASIS_TYPE IS NOT NULL AND ML2.LOOKUP_CODE = WRO.BASIS_TYPE))
     AND ML2.LOOKUP_TYPE = 'BOM_BASIS_TYPE'
     and we.WIP_ENTITY_ID = wro.wip_entity_id
     and wro.organization_id = o.organization_id
     and XXPHA_EAM518_PKG.get_qty(p_ORGANIZATION_ID   => wro.ORGANIZATION_ID,
                                  p_wip_entity_id     => wro.wip_entity_id,
                                  p_wip_entity_name   => we.wip_entity_name,
                                  p_inventory_item_id => wro.inventory_item_id,
                                  p_operation_seq_num => wro.operation_seq_num,
                                  p_REQUIRED_QUANTITY => wro.REQUIRED_QUANTITY,
                                  p_QUANTITY_ISSUED   => wro.QUANTITY_ISSUED,
                                  p_QUANTITY_OPEN     => wro.QUANTITY_OPEN) > 0),
result_set as
 (select r.*,
         pl.po_line_id,
         pl.vendor_product_num,
         l.vendor_id,
         pv.vendor_name,
         pl.item_description   sup_description,
         ph.segment1           agreement
    from req_reference              r,
         po_requisition_headers_all h,
         po_requisition_lines_all   l,
         po_lines_all               pl,
         po_vendors                 pv,
         po_headers_all             ph
   where r.req_num = h.segment1(+)
     and h.org_id(+) = r.operating_unit
     and h.requisition_header_id = l.requisition_header_id(+)
     and r.line_num = to_char(l.line_num(+))
     and pl.po_header_id(+) = l.blanket_po_header_id
     and pl.line_num(+) = l.blanket_po_line_num
     and l.vendor_id = pv.vendor_id(+)
     and ph.po_header_id(+) = pl.po_header_id)
select "WIP_ENTITY_ID",
       "INVENTORY_ITEM_ID",
       "OPERATION_SEQ_NUM",
       "ITEM_CODE",
       "ITEM_DESCRIPTION",
       "ITEM_PRIMARY_UOM_CODE",
       "SUPPLY_SUBINVENTORY",
       "SUPPLY_LOCATOR_ID",
       "DATE_REQUIRED",
       "WIP_GL_DATE",
       "REQ_NUM",
       "LINE_NUM",
       "OPERATING_UNIT",
       "PO_LINE_ID",
       "VENDOR_PRODUCT_NUM",
       "VENDOR_ID",
       "VENDOR_NAME",
       "SUP_DESCRIPTION",
       "AGREEMENT",
       "BUYER_NOTES",
       "WIP_OL_NUM",
       "WIP_OL_DATE"
  from result_set;
