create or replace view xxpha_sn1041_workorders_list_v as
select we.wip_entity_id, we.wip_entity_name, we.organization_id
from       apps.wip_entities      we
inner join apps.wip_discrete_jobs wdj on we.wip_entity_id = wdj.wip_entity_id
                                      and we.organization_id = wdj.organization_id;
