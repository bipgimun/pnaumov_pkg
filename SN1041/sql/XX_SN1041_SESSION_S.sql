begin
execute immediate 'drop sequence XXPHA.XXPHA_SN1041_SESSION_S';
exception
   when others then
     null;
end;
/

sho err
create sequence XXPHA.XXPHA_SN1041_SESSION_S
/
