create or replace view xxpha_sn1041_wip_operations_v as
select o.wip_entity_id, o.operation_seq_num, o.DESCRIPTION
from wip_operations o;