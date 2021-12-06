declare
  vr_profile_name fnd_profile_options_vl.USER_PROFILE_OPTION_NAME%type := 'XXPHA_SN1041_SERV_URL';
begin
  fnd_profile_options_pkg.LOAD_ROW(X_PROFILE_NAME             => vr_profile_name,
                                   X_OWNER                    => 'INITIAL SETUP',
                                   X_APPLICATION_SHORT_NAME   => 'XXPHA',
                                   X_USER_PROFILE_OPTION_NAME => 'XXPHA: SN1041 Сервлет URL',
                                   X_DESCRIPTION              => 'XXPHA: SN1041 Сервлет URL',
                                   X_USER_CHANGEABLE_FLAG     => 'Y',
                                   X_USER_VISIBLE_FLAG        => 'Y',
                                   X_READ_ALLOWED_FLAG        => 'Y',
                                   X_WRITE_ALLOWED_FLAG       => 'Y',
                                   X_SITE_ENABLED_FLAG        => 'Y',
                                   X_SITE_UPDATE_ALLOWED_FLAG => 'Y',
                                   X_APP_ENABLED_FLAG         => 'Y',
                                   X_APP_UPDATE_ALLOWED_FLAG  => 'Y',
                                   X_RESP_ENABLED_FLAG        => 'Y',
                                   X_RESP_UPDATE_ALLOWED_FLAG => 'Y',
                                   X_USER_ENABLED_FLAG        => 'Y',
                                   X_USER_UPDATE_ALLOWED_FLAG => 'Y',
                                   X_START_DATE_ACTIVE        => to_char(sysdate,
                                                                         'yyyy/mm/dd'),
                                   X_END_DATE_ACTIVE          => NULL,
                                   X_SQL_VALIDATION           => NULL);

  if not fnd_profile.save(x_name       => vr_profile_name,
                          x_value      => 'https://ksrvap678.int.corp.phosagro.ru:7015/sn1041/ep',
                          x_level_name => 'SITE') then
    dbms_output.put_line('Create profile ' || vr_profile_name ||
                         ' - Fail!');
  else
    dbms_output.put_line('Create profile ' || vr_profile_name ||
                         ' - Ok!');
  end if;
end;
/


