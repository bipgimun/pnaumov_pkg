declare
  l_menu_name      varchar2(30) := 'ICX_POR_HOMEPAGE_MENU';
  l_menu_id        number;
  l_row_id         varchar2(100);
  l_entry_sequence number := 7;
  l_function_id    number;
  l_res            varchar2(1);
  l_counter        number;
begin
  select m.MENU_ID
    into l_menu_id
    from fnd_menus_vl m
   where 1 = 1
     and m.MENU_NAME = l_menu_name;

  select count(*)
    into l_counter
    from fnd_menu_entries_vl me
   where 1 = 1
     and me.MENU_ID = l_menu_id
     and me.ENTRY_SEQUENCE = 7;

  if l_counter = 0 then
    select ff.FUNCTION_ID
      into l_function_id
      from fnd_form_functions_vl ff
     where 1 = 1
       and ff.FUNCTION_NAME = 'XXPHA_SN1041_HOME';
  
    fnd_menu_entries_pkg.INSERT_ROW(X_ROWID             => l_row_id,
                                    X_MENU_ID           => l_menu_id,
                                    X_ENTRY_SEQUENCE    => l_entry_sequence,
                                    X_SUB_MENU_ID       => null,
                                    X_FUNCTION_ID       => l_function_id,
                                    X_GRANT_FLAG        => 'Y',
                                    X_PROMPT            => 'ÅÔÏÏ',
                                    X_DESCRIPTION       => 'Âêëàäêà "XX.SN1041 ÅÔÏÏ"',
                                    X_CREATION_DATE     => sysdate,
                                    X_CREATED_BY        => 0,
                                    X_LAST_UPDATE_DATE  => sysdate,
                                    X_LAST_UPDATED_BY   => 0,
                                    X_LAST_UPDATE_LOGIN => fnd_global.LOGIN_ID);
  
    l_res := fnd_menu_entries_pkg.SUBMIT_COMPILE();
    
    commit;
  end if;
end;
/
