begin
  xxpha_create_conc.bild_header(p_cust_short_name       => 'XXPHA_SN1041_EAM_CONC',
                                p_cust_name             => 'ФА.SN1041 Обработка интерфейсов для создания заявок',
                                p_cust_file_name        => 'XXPHA_SN1041_EAM_PKG.RUN_CONCURRENT',
                                p_resp_list             => 'Роль: СУПЕР Управление активами предприятия',
                                p_delete_conc           => 'Y');
                                
  xxpha_create_conc.add_parametr(p_parameter             => 'p_wip_entity_id',
                                 p_value_set             => '24 Number only',
                                 p_prompt                => 'Идентификатор ЗВР'
                                 );
                                 
  xxpha_create_conc.add_parametr(p_parameter             => 'p_org_id',
                                 p_value_set             => '24 Number only',
                                 p_prompt                => 'Идентификатор ОЕ'
                                 );
                                 
  xxpha_create_conc.add_parametr(p_parameter             => 'p_517_int_ready',
                                 p_value_set             => '1 Character',
                                 p_prompt                => 'Флаг для вызова 517 пакета'
                                 );
                                 
  xxpha_create_conc.add_parametr(p_parameter             => 'p_518_int_ready',
                                 p_value_set             => '1 Character',
                                 p_prompt                => 'Флаг для вызова 518 пакета'
                                 );

end;
/
