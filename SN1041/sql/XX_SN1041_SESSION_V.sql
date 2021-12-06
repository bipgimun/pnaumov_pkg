create or replace FORCE EDITIONABLE view XXPHA.XXPHA_SN1041_SESSION_V as
select s_id,
       user_id,
       resp_id,
       login_id,
       session_date,
       store_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       object_version_number,
       t.wip_entity_id
  from xxpha.xxpha_sn1041_session t
  where (t.created_by = apps.fnd_global.USER_ID);
