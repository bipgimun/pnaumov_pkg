create or replace package XXPHA_SN1041_EAM_PKG is

type EAM_rec is record
(
  mvz                 apps.mtl_eam_asset_attr_values.c_attribute1%type,
  cfo                 apps.fnd_lookup_values.tag%type,
  project_id          apps.wip_discrete_jobs.project_id%type,
  task_id             apps.wip_discrete_jobs.task_id%type,
  code_combination_id number
);

--Находит значения для распределний корзинки
function Get_distr_values(p_wip_entity_id in number,
                          p_item_id in number,
                          p_operation in number) return XXPHA_SN1041_CREATE_REQ_PKG.Dist_Rec_type;

procedure Fill_MVZ_CFO(p_req_item_id in number);

function lock_rows return boolean;

function Create_Wip_Req(x_msg out varchar2) return varchar2;

procedure Run_concurrent(x_errbuf out nocopy varchar2,
                         x_retcode out nocopy number,
                         p_wip_entity_id in number,
                         p_org_id in number,
                         p_517_int_ready varchar2,
                         p_518_ready varchar2
                        );
                               
end XXPHA_SN1041_EAM_PKG;
/
