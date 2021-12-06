declare
  l_func_id number;
begin
  select ff.FUNCTION_ID
    into l_func_id
    from fnd_form_functions_vl ff
   where ff.FUNCTION_NAME = 'XXPHA_SN1041_EAM_HOME';
  dbms_output.put_line('l_func_id = ' || l_func_id);

  --Роль: УАП Ответственный за формирование затрат по ТОиР
  --Роль: УАП Ответственный за планирование ТОиР
  --Роль: СУПЕР Управление активами предприятия
  for r in (select r.MENU_ID
              from fnd_responsibility_vl r
             where 1 = 1
               and r.RESPONSIBILITY_KEY in
                   ('XXPHA_BR_EAM_RESP_MRO_COSTS',
                    'XXPHA_BR_EAM_RESP_MRO_PLANNING',
                    'XXPHA_BR_EAM_SUPERUSER_EAM')) loop
    dbms_output.put_line('MENU_ID = ' || r.MENU_ID);
  
    declare
      l_count         number;
      l_menu_sequence number;
      l_row_id        varchar2(100);
      l_res           varchar2(1);
    begin
      select count(*)
        into l_count
        from fnd_menu_entries_vl me
       where me.FUNCTION_ID = l_func_id
         and me.MENU_ID = r.menu_id;
      dbms_output.put_line('l_count = ' || l_count);
    
      if l_count = 0 then
        select max(me1.ENTRY_SEQUENCE) + 10
          into l_menu_sequence
          from fnd_menu_entries_vl me1
         where me1.MENU_ID = r.menu_id;
        dbms_output.put_line('l_menu_sequence = ' || l_menu_sequence);
      
        fnd_menu_entries_pkg.INSERT_ROW(X_ROWID             => l_row_id,
                                        X_MENU_ID           => r.MENU_ID,
                                        X_ENTRY_SEQUENCE    => l_menu_sequence,
                                        X_SUB_MENU_ID       => null,
                                        X_FUNCTION_ID       => l_func_id,
                                        X_GRANT_FLAG        => 'Y',
                                        X_PROMPT            => '',
                                        X_DESCRIPTION       => 'XX.SN1041 ЕФПП',
                                        X_CREATION_DATE     => sysdate,
                                        X_CREATED_BY        => 0,
                                        X_LAST_UPDATE_DATE  => sysdate,
                                        X_LAST_UPDATED_BY   => 0,
                                        X_LAST_UPDATE_LOGIN => fnd_global.LOGIN_ID);
      
        l_res := fnd_menu_entries_pkg.SUBMIT_COMPILE();
        commit;
      end if;
    end;
  end loop;
end;
/

select r.MENU_ID from fnd_responsibility_vl r
where 1=1
and r.RESPONSIBILITY_KEY in ('XXPHA_BR_EAM_RESP_MRO_COSTS', 'XXPHA_BR_EAM_RESP_MRO_PLANNING', 'XXPHA_BR_EAM_SUPERUSER_EAM');
/
select m.MENU_NAME, m.USER_MENU_NAME, me.* from fnd_menu_entries_vl me, fnd_menus_vl m 
where 1=1
and m.MENU_ID = me.MENU_ID
--and me.MENU_ID = 93431
and me.FUNCTION_ID = 72528

/
--XXPHA_SN1041_EAM_HOME  (72528)
select * from fnd_form_functions_vl ff
where 1=1
and ff.FUNCTION_NAME like '%1041%'
