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
   
    create_msg(p_message_name => 'XXPHA_SN1041_DEACT_NO_AVAIL_CS',
               p_message_text => 'Позиция '||chr(38)||'ITEM_CODE: - к деактивации. Нет доступного количества на ЦС. Добавить в выборку нельзя.');                      
  end loop;
  commit;
end;
/
