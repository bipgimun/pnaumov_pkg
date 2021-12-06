declare
  l_dummy   varchar2(10) := 'DUMMY';
  l_appl_id number;
  --

  procedure create_msg(p_message_name varchar2, p_message_text varchar2) is
  begin
    if (l_appl_id is null) then
      select a.application_id
        into l_appl_id
        from fnd_application a
       where a.application_short_name = 'XXPHA';
    end if;
    begin
      fnd_new_messages_pkg.delete_row(x_application_id => l_appl_id,
                                      x_language_code  => userenv('LANG'),
                                      x_message_name   => p_message_name);
    exception
      when no_data_found then
        null;
    end;
    fnd_new_messages_pkg.load_row(x_application_id   => l_appl_id,
                                  x_message_name     => p_message_name,
                                  x_message_number   => null,
                                  x_message_text     => p_message_text,
                                  x_description      => null,
                                  x_type             => null,
                                  x_max_length       => null,
                                  x_category         => null,
                                  x_severity         => null,
                                  x_fnd_log_severity => null,
                                  x_owner            => null,
                                  x_custom_mode      => null,
                                  x_last_update_date => to_char(sysdate,
                                                                'YYYY/MM/DD'));
  end create_msg;

begin
  for i_cur in (select 'RUSSIAN' as lang
                  from dual
                union all
                select 'AMERICAN' as lang
                  from dual) loop
    execute immediate 'alter session set NLS_LANGUAGE = ''' || i_cur.lang || '''';
  
    create_msg(p_message_name => 'XXPHA_SN1041_DEL_LINE_CONFIRM',
               p_message_text => '�� �������, ��� ������ ������� ��������� ������ ' ||
                                 chr(38) || 'LINE_NUM?');
  
    create_msg(p_message_name => 'XXPHA_SN1041_DEL_LINE_CONF',
               p_message_text => '������ ' || chr(38) ||
                                 'LINE_NUM ������� �������.');
  
    create_msg(p_message_name => 'XXPHA_SN1041_CHANGES_SAVED',    
               p_message_text => '��������� ��������� �������.');
               
    create_msg(p_message_name => 'XXPHA_SN1041_HAVE_DRAFT',
               p_message_text => '� ���������� ������ �������� �������������� ������!');           
    
    create_msg(p_message_name => 'XXPHA_SN1041_DEL_DRAFT_Y',
               p_message_text => '�������� ������');           
    create_msg(p_message_name => 'XXPHA_SN1041_DEL_DRAFT_N',
               p_message_text => '���������� �������� ������');   
    create_msg(p_message_name => 'XXPHA_SN1041_NOT_SELECTED_ITEM',    
               p_message_text => '�� ������� �������');           
    create_msg(p_message_name => 'XXPHA_SN1041_EMPTY_SEARCH',
               p_message_text => '��� ���������� ������ ��������� ���� "�������"');  
    create_msg(p_message_name => 'XXPHA_SN1041_RETURN_TO',
               p_message_text => '������� �� ������ ����� �����������');                             

    create_msg(p_message_name => 'XXPHA_SN1041_ELASTIC_SYNC',
               p_message_text => '������� ������� ������������� � ElasticSearch');           
               
    create_msg(p_message_name => 'XXPHA_SN1041_NOT_ACTIV_CART',
               p_message_text => '��� �������� �������. �������� ������� � ����� �������');  
    create_msg(p_message_name => 'XXPHA_SN1041_NOT_ISTORE_ITEM',
               p_message_text => '������� '||chr(38)||'ITEM_CODE: �� �������� �������� ��. ���������� ���� �� �����������.');			   
    create_msg(p_message_name => 'XXPHA_SN1041_PRICE_NOT_NULL',
               p_message_text => '������� '||chr(38)||'ITEM_CODE: ���� �� 0. ���������� ���� �� �����������.');	   
    create_msg(p_message_name => 'XXPHA_SN1041_DEACT_NO_AVAIL_CS',
               p_message_text => '������� '||chr(38)||'ITEM_CODE: - � �����������. ��� ���������� ���������� �� ��. �������� � ������� ������.');	                    
  end loop;
  commit;
end;
/
