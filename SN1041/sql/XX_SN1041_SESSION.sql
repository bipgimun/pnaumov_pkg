begin
execute immediate 'drop table XXPHA.XXPHA_SN1041_SESSION';
exception
   when others then
     null;
end;
/
sho err
-- Create table
create table XXPHA.XXPHA_SN1041_SESSION
(
  s_id                  NUMBER not null,
  user_id               NUMBER not null,
  resp_id               NUMBER not null,
  login_id              NUMBER not null,
  session_date          DATE not null,
  store_id              NUMBER,
  created_by            NUMBER not null,
  creation_date         DATE default sysdate not null,
  last_updated_by       NUMBER not null,
  last_update_date      DATE default sysdate not null,
  last_update_login     NUMBER,
  object_version_number NUMBER
);
-- Add comments to the columns 
comment on column XXPHA.XXPHA_SN1041_SESSION.created_by
  is 'Keeps track of which user created each row';
comment on column XXPHA.XXPHA_SN1041_SESSION.creation_date
  is 'Stores the date on which each row was created';
comment on column XXPHA.XXPHA_SN1041_SESSION.last_updated_by
  is 'Keeps track of who last updated each row';
comment on column XXPHA.XXPHA_SN1041_SESSION.last_update_date
  is 'Stores the date on which each row was last updated';
comment on column XXPHA.XXPHA_SN1041_SESSION.last_update_login
  is 'Provides access to information about the operating system login of the user who last updated each row';
