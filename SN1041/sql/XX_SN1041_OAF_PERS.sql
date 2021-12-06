DELETE XXPHA_OAF_CUSTOMIZATIONS
where customization_name = 'SN1041'
/
sho err

insert into XXPHA_OAF_CUSTOMIZATIONS
  (customization_id
  ,customization_name
  ,caller
  ,event_param
  ,source_param
  ,java_class
  ,call_order
  ,description
  ,call_time
  ,calling_method
  ,enabled_flag
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
values
  (xxpha_oaf_customizations_s.nextval
  ,'SN1041'
  ,'xxpha.oracle.apps.icx.por.req.webui.xxEditSubmitCO'
  ,null
  ,null
  ,'xxpha.oracle.apps.icx.sn1041.webui.xxPersEditSubmitCO'
  ,10
  ,'SN1041. Открытие корзинки из 1031'
  ,'BEFORE_SUPER_CALL'
  ,'processRequest'
  ,'Y'
  ,1
  ,to_date('22.05.2020', 'dd-mm-yyyy')
  ,-1
  ,SYSDATE
  ,-1
  ,-1)
/
sho err

insert into XXPHA_OAF_CUSTOMIZATIONS
  (customization_id
  ,customization_name
  ,caller
  ,event_param
  ,source_param
  ,java_class
  ,call_order
  ,description
  ,call_time
  ,calling_method
  ,enabled_flag
  ,object_version_number
  ,creation_date
  ,created_by
  ,last_update_date
  ,last_updated_by
  ,last_update_login)
values
  (xxpha_oaf_customizations_s.nextval
  ,'SN1041'
  ,'xxpha.oracle.apps.icx.por.req.webui.xxEditSubmitCO'
  ,null
  ,null
  ,'xxpha.oracle.apps.icx.sn1041.webui.xxPersEditSubmitCO'
  ,11
  ,'SN1041. Возврат на форму ЕФПП'
  ,'AFTER_SUPER_CALL'
  ,'processRequest'
  ,'Y'
  ,1
  ,to_date('04.06.2020', 'dd-mm-yyyy')
  ,-1
  ,SYSDATE
  ,-1
  ,-1)
/
sho err

commit
/
