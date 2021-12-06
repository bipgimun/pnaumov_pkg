begin
   execute immediate 'drop table xxpha.xxpha_sn1041_eam_distr_temp_t';
exception
  when others then 
    null;
end;   
/
create global temporary table xxpha.xxpha_sn1041_eam_distr_temp_t 
( line_req_item_id number,
  req_item_id number,
  wip_entity_id number,
  operation_seq_num number,
  quantity number,
  wip_subinventory varchar2(50),
  wip_date_required date,
  wip_gl_date date,
  po_line_id number
)
on commit preserve rows;
