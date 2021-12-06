begin
   execute immediate 'drop table XXPHA.XXPHA_SN1041_REQ_TEMP_T';
exception
  when others then 
    null;  
end;   
/
sho err

create global temporary table XXPHA.XXPHA_SN1041_REQ_TEMP_T on commit preserve rows
as select sri.req_item_id, sri.* from xxpha.xxpha_sn1041_req_items sri where 1=2
/
