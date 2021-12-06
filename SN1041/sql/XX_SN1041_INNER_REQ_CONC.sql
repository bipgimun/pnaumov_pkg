begin
  xxpha_create_conc.bild_header(p_cust_short_name       => 'XXPHA_SN1041_INNER_REQ',
                                p_cust_name             => 'ФА.SN1041 Создание внутренней заявки на основе строк заявок на проработку',
                                p_cust_file_name        => 'XXPHA_SN1041_INNER_REQ_PKG.MAIN',
                                p_resp_list             => '',
                                p_delete_conc           => 'Y');
                                
  xxpha_create_conc.add_parametr(p_parameter             => 'p_req_lines_id_concat',
                                 p_value_set             => '240 Characters',
                                 p_prompt                => 'Строки заявок'
                                 );
end;
/
