begin
  xxpha_create_conc.bild_header(p_cust_short_name       => 'XXPHA_SN1041_EAM_CONC',
                                p_cust_name             => '��.SN1041 ��������� ����������� ��� �������� ������',
                                p_cust_file_name        => 'XXPHA_SN1041_EAM_PKG.RUN_CONCURRENT',
                                p_resp_list             => '����: ����� ���������� �������� �����������',
                                p_delete_conc           => 'Y');
                                
  xxpha_create_conc.add_parametr(p_parameter             => 'p_wip_entity_id',
                                 p_value_set             => '24 Number only',
                                 p_prompt                => '������������� ���'
                                 );
                                 
  xxpha_create_conc.add_parametr(p_parameter             => 'p_org_id',
                                 p_value_set             => '24 Number only',
                                 p_prompt                => '������������� ��'
                                 );
                                 
  xxpha_create_conc.add_parametr(p_parameter             => 'p_517_int_ready',
                                 p_value_set             => '1 Character',
                                 p_prompt                => '���� ��� ������ 517 ������'
                                 );
                                 
  xxpha_create_conc.add_parametr(p_parameter             => 'p_518_int_ready',
                                 p_value_set             => '1 Character',
                                 p_prompt                => '���� ��� ������ 518 ������'
                                 );

end;
/
