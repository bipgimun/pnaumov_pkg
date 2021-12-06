CREATE OR REPLACE PACKAGE APPS.XX_PNAUMOV_PKG authid definer IS

  ----��������� ������� ����, � ����������� %% � ��� ����� ��������
function f_like(f_test varchar2, f_find_test varchar2)  return number;


gb_rest_name varchar2(200); --��� ������������� ���������� �� ���������
gb_log_mark varchar2(100):= NULL; --���������������� ����� ��� ��� ������
gb_user_name  fnd_user.user_name%type;

--������ ��� ��� �����
procedure set_log_mark (p_log_mark varchar2);

TYPE rec_20field  IS RECORD
      ( field1                varchar2(255)
       ,field2                varchar2(255)
       ,field3                varchar2(255)
       ,field4                varchar2(255)
       ,field5                varchar2(255)
       ,field6                varchar2(255)
       ,field7                varchar2(255)
       ,field8                varchar2(255)
       ,field9                varchar2(255)
       ,field10                varchar2(255)
       ,field11                varchar2(255)
       ,field12                varchar2(255)
       ,field13                varchar2(255)
       ,field14                varchar2(255)
       ,field15                varchar2(255)
       ,field16                varchar2(255)
       ,field17                varchar2(255)
       ,field18                varchar2(255)
       ,field19                varchar2(255)
       ,field20                varchar2(255)
      );

type tbl_20field is table of rec_20field;

 --������������� OEBS ������������ � ������
procedure initialize (p_name_resp varchar2:= gb_rest_name,  p_mo_mode varchar2 default 'M');

 --����� ����
  procedure log(p_msg varchar2 default null
              , p_type_flag varchar2 default null
              , p_new_line varchar2 default 'Y'
              );
  procedure log(p_mess clob);

 --������� ������� �� ������������
 procedure set_profile (p_profile_user_name fnd_profile_options_tl.profile_option_name%type
                       ,p_value varchar2);

 --����� ��������� � ����������� �������. ���� ������� �� ���������� - ������ �.
 procedure insert_log_table (pr_message varchar2, p_log_mark varchar2 default null);

 --�������� ������������
 PROCEDURE create_user(p_user_name varchar2
                     , p_user_pass varchar2 default 'Olololo1'
                     , p_email varchar2 default null);
--����� �����������
PROCEDURE find_concurrent (pr_conc_name varchar2:=NULL
                         , pr_conc_descr varchar2:= NULL
                         , pr_find_flag varchar2:='N' 
                         , p_print_last_reqs number:= 0
                         , p_print_parameters varchar2:='N' 
                         , p_print_fndload_cmd varchar2:='N' 
                          );

 --�������� ������, ������������ ����������
procedure find_block_session (p_obj_name varchar2, p_kill_session varchar2 default 'N');

 --��������� ������ �������� � ����������� �� ����
 procedure find_value_set (pr_value_set_name varchar2:= NULL
                         , p_use_conc varchar2:= NULL
                         , p_find_flag varchar2:= NULL
                          );

 --���������� � ��������� ������� �������� �� ������
 PROCEDURE find_rus_chars (pr_string varchar2);

  --��������� ��������� �������� �������
 PROCEDURE find_profile(p_profile_name varchar2);

--��������� ������ ������� ��
procedure find_object(p_object_name varchar2
                    , p_table_size varchar2 default 'N' --����������� �������
                    , p_dependencies varchar2 default 'N'); --����� ��������� ��������;
--������� ������������ ��� ������ � �������
procedure set_username(p_username varchar2);

--��������� ������� ������������ ��������� ������� ��������������. ���������� � ����� ����������� ���� - ��� - ������� - �����
procedure export_pers (p_pers_name varchar2, p_level varchar2 default 'A');

--���������� ���������� ������������
procedure add_resp_to_user (p_pesp_name varchar2, p_user_name varchar2 default null);

--���������� ���������� ������������ ���������
procedure add_resp_to_conc (p_conc_name varchar2, p_pesp_name varchar2);

--���������/���������� ���������������� �������
procedure on_diag_profile(p_result_into_table varchar2 default 'N');
procedure off_diag_profile(p_result_into_table varchar2 default 'N');

--��������� ������� ������� ����� ������ ����
procedure time_start (p_name varchar2);
procedure time_end   (p_name varchar2);
procedure time_print (p_name varchar2, p_cliner_frag in varchar2 default 'Y');

--����� ���������� �����
procedure find_form(p_form_name varchar2 default null, p_function_name varchar2 default null);

function to_number(p_char varchar2) return number;

-- ��������� ���������� �������� ����� � ������ ��������� ���������� � OeBS
PROCEDURE add_resp_to_form( p_form    VARCHAR2      -- ��� �����, ����� �������� ������� � ������, ������� ���������� ����������
                            , p_resp  VARCHAR2      -- ��� ����������, ����� �������� ������� � ������, � ������ ���� ������� ����������� �����
                          );

--�������� ����� � ������� � ����
function load_file ( p_dir_name   VARCHAR2,
                      p_file_name  VARCHAR2
                      ) return number;

--���������� �����
procedure add_role_to_user (p_role_name varchar2);

--����� �������� � �������� ����   
 procedure find_code (p_find_string      varchar2 --������� ������
                    , p_find_in_obj      boolean :=false --������ � �������� �� (�������)
                    , p_source_where     varchar2:= '' --��� ������� ������ (���������� sql)                 
                    , p_print_up_row     number:= 5 --�������� �� ������� ������ ����� ����
                    , p_print_down_row   number:= 5); --�������� �� �������� ������ ����� ����
                    
--��������� ������������ ���������� �� SQL_ID
procedure print_sql_info (p_sql_id varchar2);         

--����� SQL �������
procedure find_sql (p_find_text varchar2, p_get_sql_info varchar2 default 'N');           
                    
END XX_PNAUMOV_PKG;
/
CREATE OR REPLACE PACKAGE BODY APPS.XX_PNAUMOV_PKG IS

  g_log_table_name varchar2(255):= upper('xx_pnaumov_TBL');
  g_lob_table_name varchar2(255):= upper('xx_pnaumov_LOB_TBL');

  g_log_start_value number; --����� ��������� ���������������� �������
  g_dbms_profile_run_num number; --����� ��������������
  g_tbl_exists number; --������������� ������� xx_pnaumov_TBL

  --v_count number; --������� (���� ��� ������)

  --��������������� �������
  v_profname_aflog_enbl fnd_profile_options_tl.user_profile_option_name%type:= '���: ������� ������ �������';
  v_profname_aflog_level fnd_profile_options_tl.user_profile_option_name%type:= '���: ������� ������� �������';
  v_eam_debug_name fnd_profile_options_tl.user_profile_option_name%type:= '���: �������� ������� �������';
  -- ������� ������
  v_profname_ou   fnd_profile_options_tl.user_profile_option_name%type:= '��: ������� ������';
  v_profname_org  fnd_profile_options_tl.user_profile_option_name%type:= '���: ������� ������';
  v_profname_book fnd_profile_options_tl.user_profile_option_name%type:= '��: ������� ������';

  --g_db_version constant number:= ; --����������� ������������ �� (��-�� ����� �������� ��������� ����������)



  -- ���������� ��������� ������ (��������� ����������)
  TYPE G_PARAMETERS_TYPE  IS RECORD
      ( user_id               number
       ,user_name             fnd_user.user_name%type
       ,resp_id               number
       ,resp_name             fnd_responsibility_tl.responsibility_name%type
       ,appl_id               number
       , menu_id              NUMBER
       , menu_name            applsys.fnd_menus.menu_name%type
       , form_id              NUMBER
       , form_name            applsys.fnd_form.form_name%type
       , form_description     applsys.fnd_form_tl.description%type
       , function_id          NUMBER
       , function_name        applsys.fnd_form_functions.function_name%type
       , concurrent_id        APPLSYS.FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID%type
       , concurrent_name      APPLSYS.FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_NAME%type
       , concurrent_user_name APPLSYS.FND_CONCURRENT_PROGRAMS_TL.USER_CONCURRENT_PROGRAM_NAME%type
       , concurrent_appl_name APPLSYS.FND_APPLICATION.APPLICATION_SHORT_NAME%type
       , instans_name         varchar2(255)
      );
  G_SESSION_PAR G_PARAMETERS_TYPE;

  --G_TIME G_TIME_TYPE;


  --��� ������ ��������� �����
    TYPE G_TIME_REC_TYPE  IS RECORD
      (  min_time       INTERVAL DAY TO SECOND
        ,max_time       INTERVAL DAY TO SECOND
        ,total_time     INTERVAL DAY TO SECOND default (sysdate-sysdate) DAY TO SECOND
        ,total_call     number default 0
        ,start_time     timestamp
        ,end_time       timestamp
        ,diff_time     INTERVAL DAY TO SECOND
      );
    TYPE G_TIME_COLL_T is table of G_TIME_REC_TYPE index by varchar2(100);
    G_TIME G_TIME_COLL_T;

  --������ ��� ��� �����
  procedure set_log_mark (p_log_mark varchar2) is 
    begin 
      gb_log_mark:= p_log_mark; --���������������� ����� ��� ��� ������
    end;

--��������� ����������  ������������ (��������� ���������)
function get_user_parametrs(p_username varchar2) return boolean is
  type list_user_name is table of varchar2(100) index by pls_integer;
  type list_user_id is table of number index by pls_integer;
    c_user_name list_user_name;
    c_full_name list_user_name;
    c_user_id   list_user_id;

  begin

    --����� �� user_name
      select u.user_name, u.user_id
      bulk collect into c_user_name, c_user_id
      from fnd_user u
      where upper(u.user_name) like upper(p_username)
      and nvl(u.end_date, sysdate) >= sysdate;

    --���� ������� ������� ������ ������������, ������� ������
     if c_user_name.count > 1 then
       log('������! ������� ����� ������ ��������� ������������:');
       for i in 1..c_user_name.count loop log(c_user_name(i)); end loop;
       raise_application_error(-20000, '������! ������� ����� ������ ��������� ������������. �������� ���...');
      end if;

    --���� �� �������, ���� � ������ ����� �������������
     if  c_user_name.count = 0  then

       select fu.user_name, pf.FULL_NAME, fu.user_id
       bulk collect into c_user_name, c_full_name, c_user_id
       from PER_PEOPLE_F pf
       inner join fnd_user fu on fu.employee_id = pf.PERSON_ID
       where 1=1
       and upper(pf.FULL_NAME) LIKE (upper(p_username))
       and pf.EFFECTIVE_END_DATE >= sysdate
       and nvl(fu.end_date, sysdate)>= sysdate;
    --���� ������������ �� �������, ������
       if c_user_name.count = 0 then log('������! ��������� ������������ �� ������!'); raise_application_error(-20000, '������! ��������� ������������ �� ������!'); end if;
    --���� ������������� ������ 1 ������ ������� ������
       if  c_user_name.count > 1 then
       log('������! ������� ����� ������ ��������� ������������:');
       for i in 1..c_full_name.count loop log(c_full_name(i)||' - '||c_user_name(i)); end loop;
       raise_application_error(-20000, '������! ������� ����� ������ ��������� ������������. �������� ���...');
       end if;
     end if;

    --���� ������ ���� ������������� ����������� ��� ��. ����������  gb_user_name
       if c_user_name.count = 1 then
         log('������ ������������ '|| c_user_name(1));
         G_SESSION_PAR.user_name:= c_user_name(1);
         G_SESSION_PAR.user_id:= c_user_id(1);
       end if;
    return true;


  end get_user_parametrs;

--��������� ����������  ����������
function get_resp_parametrs(p_resp_name varchar2) return boolean is
      v_resp_like_name fnd_responsibility_tl.responsibility_name%type;
    begin
        v_resp_like_name:= upper(p_resp_name);

        SELECT distinct r.responsibility_id, r.application_id, r.responsibility_name, r.MENU_ID
        INTO G_SESSION_PAR.resp_id, G_SESSION_PAR.appl_id, G_SESSION_PAR.resp_name, G_SESSION_PAR.menu_id
        FROM fnd_responsibility_tl rt
        inner join fnd_responsibility_vl r on r.RESPONSIBILITY_ID = rt.RESPONSIBILITY_ID
                                          and r.APPLICATION_ID = rt.APPLICATION_ID
        WHERE 1=1
           and nvl(r.END_DATE, sysdate+1)> sysdate
           AND f_like(rt.responsibility_name, v_resp_like_name) = 1;


        log('���������� "'||G_SESSION_PAR.resp_name||'" �������.');

        BEGIN
            SELECT mn.menu_name
            INTO G_SESSION_PAR.menu_name
            FROM fnd_menus mn
            WHERE mn.menu_id = G_SESSION_PAR.menu_id;

            log( '���� �������: ' || G_SESSION_PAR.menu_name );
        EXCEPTION
            WHEN no_data_found THEN
                log( '������ ����������� ����� ����!' );
            return FALSE;
            WHEN too_many_rows THEN
                log( '������ � ���� ��������� ���' );
            return FALSE;
        END;

        return true;
    exception
      WHEN no_data_found THEN log('������ ��� ��������� ���������� ����������!');
                              log('���������� '||p_resp_name||' �� �������!!!');
                              return false;
      WHEN too_many_rows THEN log('������ ��� ��������� ���������� ����������!');
                              log('�� ������������ ��������� ������� ������� ����� ����������:');
          FOR i IN (SELECT r.responsibility_name, a.APPLICATION_SHORT_NAME
                    FROM fnd_responsibility_vl r
                    inner join fnd_application a on r.APPLICATION_ID = a.APPLICATION_ID
                    WHERE 1=1
                       and nvl(r.END_DATE, sysdate+1)> sysdate
                       AND f_like(r.responsibility_name, v_resp_like_name) = 1
                    order by a.APPLICATION_SHORT_NAME
                    )
          LOOP
            log(i.responsibility_name ||' ������ ('||i.application_short_name||')');
          END LOOP;
          return false;

   end get_resp_parametrs;

--��������� ���������� ������������ ���������
 function get_conc_parametrs (p_conc_name varchar2) return boolean is
   begin
     select cp.CONCURRENT_PROGRAM_ID
          , cp.USER_CONCURRENT_PROGRAM_NAME
          , cp.CONCURRENT_PROGRAM_NAME
          , fa.application_short_name
     into G_SESSION_PAR.concurrent_id
        , G_SESSION_PAR.concurrent_user_name
        , G_SESSION_PAR.concurrent_name
        , G_SESSION_PAR.concurrent_appl_name
     from fnd_concurrent_programs_vl cp
     inner join APPLSYS.FND_APPLICATION fa on cp.APPLICATION_ID = fa.application_id
     where 1=1
     and (f_like(cp.CONCURRENT_PROGRAM_NAME, p_conc_name) = 1
     or f_like(cp.USER_CONCURRENT_PROGRAM_NAME, p_conc_name) = 1);

     log('������������ ��������� '||G_SESSION_PAR.user_name||' ('||G_SESSION_PAR.concurrent_name||') �������.');
     return true;
   exception
     when no_data_found then
         log('������! ������������ ��������� '||p_conc_name||' �� �������!!!');
         return false;
     when too_many_rows then
         log('������! �� ������������ ��������� ������� ������� ����� ������������ ��������:');
         for i in (select cp.CONCURRENT_PROGRAM_NAME, fa.application_short_name, cp.USER_CONCURRENT_PROGRAM_NAME
                   from fnd_concurrent_programs_vl cp
                   inner join APPLSYS.FND_APPLICATION fa on cp.APPLICATION_ID = fa.application_id
                   where 1=1
                   and (f_like(cp.CONCURRENT_PROGRAM_NAME, p_conc_name) = 1
                   or f_like(cp.USER_CONCURRENT_PROGRAM_NAME, p_conc_name) = 1)
                   order by application_short_name, CONCURRENT_PROGRAM_NAME)
         loop
           log(i.application_short_name||' '||i.USER_CONCURRENT_PROGRAM_NAME||' ('||i.CONCURRENT_PROGRAM_NAME||') ');
         end loop;
         return false;
   end get_conc_parametrs;

   -- ��������� ���������� �����
    -- ���������� �� get_resp_parametrs, ��. ����
    -- ��������� ������������ �����
    FUNCTION get_form_parametrs( p_form_name VARCHAR2 -- ��� ����� ��� ������, ����� �������� ������� � ������, ������� ���������� ����������
                               )
    return boolean -- TRUE - ������� ���������� �������, FALSE - ���� ������ � ������ �������
    is
        -- ��������� ��� �����
        v_form_like_name applsys.fnd_form.form_name%type;

    BEGIN
        -- ������� �� �������� �� ��� ������, ���� �������� ������ ������� �� ��������� �� ������� �������
        v_form_like_name := Upper( p_form_name );

        -- ��������� ������ � �����
        SELECT
            r.form_id           -- ������������� �����
            , r.form_name       -- �������� �����
            , r.description     -- �������� �����
        INTO
            G_SESSION_PAR.form_id
            , G_SESSION_PAR.form_name
            , G_SESSION_PAR.form_description
        FROM
            fnd_form_vl r
        WHERE
            1 = 1
            and f_like( r.form_name, v_form_like_name ) = 1;

        log( '����� '||G_SESSION_PAR.form_name||' � ��������������� "' || G_SESSION_PAR.form_id || '" �������.' );

        -- ������ � API ������������ ����������� � ����� ������� - ���� �
        BEGIN
            SELECT
                fu.function_id      -- ������������� �������
                , fu.function_name  -- ��� ������� (��� �� �������, � API ����� ������������ ���, � �� �������������)
            INTO
                G_SESSION_PAR.function_id
                , G_SESSION_PAR.function_name
            FROM
                applsys.fnd_form_functions fu
            WHERE
                1 = 1
                and fu.form_id = G_SESSION_PAR.form_id;

            log( '� ����� ��������� ������� '||G_SESSION_PAR.function_name||' � ���������������: ' || G_SESSION_PAR.function_id );
        EXCEPTION
            WHEN no_data_found THEN
                log( '������ � ����� �� ��������� ������� �������!' );
                return FALSE;
            WHEN too_many_rows THEN
                log( '������ � ����� ��������� ��������� �������!' );
                return FALSE;
        END;

        return TRUE;
    EXCEPTION
        WHEN no_data_found THEN
            log( '������ ��� ��������� ���������� �����!' );
            log( '����� ' || p_form_name || ' �� �������!!!' );
            return FALSE;
        WHEN too_many_rows THEN
            log( '������ ��� ��������� ���������� �����!' );
            log( '�� ������������ ������� ������� ����� ����:' );
            for i in (  SELECT
                            r.form_name
                        FROM
                            fnd_form_vl r
                        WHERE
                            1 = 1
                            and f_like( r.form_name, v_form_like_name ) = 1
                    )
            loop
                log( i.form_name );
            end loop;
            return FALSE;
    end get_form_parametrs;


--��������� ������ ���������� � ��������� �� ������������
   procedure print_list_responses(p_conc_program_id number default null, p_menu_id number default null)
    is
      v_user_id number;
   begin

     begin
       select u.user_id into v_user_id from fnd_user u where u.user_name = xx_pnaumov_pkg.gb_user_name;
     exception when others then log('������ ��� ����������� ������������ '||xx_pnaumov_pkg.gb_user_name||': '||SQLERRM);
     end;

     --����� ����������
        for i IN (select q.RESPONSIBILITY_NAME resp_name,
                  (select ' + '
                    from     FND_USER_RESP_GROUPS_DIRECT d
                    where 1=1
                    and d.user_id = v_user_id
                    and d.RESPONSIBILITY_ID = q.RESPONSIBILITY_ID
                   union
                   select ' + '
                    from     FND_USER_RESP_GROUPS_INDIRECT d
                    where 1=1
                    and d.user_id = v_user_id
                    and d.RESPONSIBILITY_ID = q.RESPONSIBILITY_ID
                    )users --���������� ������������
                  FROM (
                  --����� ���������� ������������ ���������
                  select rr.RESPONSIBILITY_NAME, rr.RESPONSIBILITY_ID
                  FROM
                    FND_REQUEST_GROUP_UNITS gru
                  , FND_REQUEST_GROUPS gr
                  , FND_APPLICATION_VL appl
                  , Fnd_Responsibility_Vl rr
                  where 1=1
                  and gru.request_unit_id = p_conc_program_id
                  and gr.request_group_id=gru.request_group_id
                  and appl.APPLICATION_ID=gr.application_id
                  and rr.REQUEST_GROUP_ID=gr.request_group_id
                  and nvl(rr.END_DATE, sysdate) >= sysdate --��������� ������������ ����������
                  --����� ���������� ����
                  union all
                  select rr.RESPONSIBILITY_NAME, rr.RESPONSIBILITY_ID
                  FROM Fnd_Responsibility_Vl rr
                  where 1=1
                  and rr.MENU_ID = p_menu_id
                  and nvl(rr.END_DATE, sysdate) >= sysdate --��������� ������������ ����������
                  )  q
                  order by q.RESPONSIBILITY_NAME)
      loop
        if i.users IS NULL then       log('       |     '||i.resp_name);
        else                          log(i.users||'    |     '||i.resp_name);
        end if;
      end loop;

   end;


--��������� ������ ����
  procedure log(p_msg varchar2 default null
              , p_type_flag varchar2 default null
              , p_new_line varchar2 default 'Y'
              ) is
     --v_msg varchar2(1000):= p_msg;

      procedure put(p_msg varchar2, p_new_line varchar2 ) is
        begin
          if fnd_global.CONC_REQUEST_ID = -1 then
            dbms_output.enable(buffer_size => 10000000);
            
            if p_new_line = 'N' then 
              dbms_output.put(p_msg);
            else 
              dbms_output.put_line(p_msg);
            end if;
          else
            if p_new_line = 'N' then 
              fnd_file.put(fnd_file.log,p_msg);
            else 
              fnd_file.put_line(fnd_file.log,p_msg);
            end if;
          end if;
       end ;

     begin
    

    case when (p_type_flag is null or p_type_flag = 'D' )and 1=2
      --����� ���������� ���������� �����, ��� ������� �� �������� ������� ���������, � ������
      --������������ ������. ��� ���������� ������ ��������� ������������ ����� 12 ���� UTL_CALL_STACK.CONCATENATE_SUBPROGRAM (UTL_CALL_STACK.SUBPROGRAM (1))
          then put(to_char(sysdate, 'hh24:mi:ss')||'/'||$$plsql_unit||'/'||$$plsql_line||' '||p_msg, p_new_line);
         when p_type_flag = 'T'
          then put(to_char(sysdate, 'hh24:mi:ss')||' '||p_msg, p_new_line);
         else put(p_msg, p_new_line);
    end case;
  end log;

--������ clob
 procedure log(p_mess clob) is 
     l_offset     number := 1;  
   begin 
     loop  
        exit when l_offset > dbms_lob.getlength(p_mess);  
        log( dbms_lob.substr( p_mess, 255, l_offset ),p_new_line => 'N');
        l_offset := l_offset + 255;  
     end loop;  
     log('');
   end; 


--��������� ������� ����, � ����������� %% � ��� ����� �������� 1 - ����� 0 - �� �����
  function f_like(f_test varchar2, f_find_test varchar2)  return number is
    begin
      --���� ������� ������ ����, �� ����� ������������� ����� ������� ��� ������ (������� �������������� ����������)
        if  f_find_test is NULL THEN RETURN 1; END IF;
      --���� ������ ���� � ������� ������ �� ����, �� �������������� ����������� (������� ������ ��������)
        if  f_test IS NULL AND f_find_test IS NOT NULL THEN RETURN 0; END IF;

        if replace(upper(f_test), '�', '�') like replace(upper(f_find_test), '�', '�') then RETURN 1;
        ELSE RETURN 0;
        END IF;
    end f_like;

--��������� ������� �������� �������
procedure create_table(p_table_name varchar2
                      ,p_special_fieds varchar2) is
   v_exst number;
  begin
    begin
       SELECT  1
       into v_exst
       FROM all_objects
       WHERE 1=1
         AND object_name = p_table_name
         and object_type = 'TABLE';
     exception
        when NO_DATA_FOUND then
         execute immediate
          'create table '||p_table_name||'
          (       ROW_ID                        number NOT NULL PRIMARY KEY,
                  USER_NAME                     varchar2(255),
                  INSERT_DATE                   date       NOT NULL,
                  LOG_MARK                      varchar2(100),
                  '||p_special_fieds||'
          )';
         log('������� '||p_table_name||' �������');

         EXECUTE IMMEDIATE
          'create sequence '||p_table_name||'_S';
          log('������������������ '||p_table_name||'_S �������');
    end;
  end create_table;

--��������� ������� �������� ��� �������
procedure create_log_table is
 begin
   create_table(g_log_table_name, 'MESSAGE_TEXT varchar2(4000), CALL_STACK varchar2(4000)');
 end;


--��������� ������� �������� LOB �������
procedure create_lob_table is
 begin
   create_table(g_lob_table_name, 'LOAD_FILE BLOB');
 end;


--**********************������� ������� �� ������������****************************
procedure set_profile (p_profile_user_name fnd_profile_options_tl.profile_option_name%type
                      ,p_value varchar2
                       )
       is
       v_profile_name fnd_profile_options_tl.profile_option_name%type;
       begin


       --����� �������
        begin
         select profile_option_name
         into v_profile_name
         from fnd_profile_options_tl po --����� �� ����� (� ������� � ����������)
         where po.user_profile_option_name =   p_profile_user_name;
        exception when no_data_found then
            begin
              select profile_option_name
              into v_profile_name
              from fnd_profile_options_vl po --����� ��� ����
              where po.profile_option_name =   p_profile_user_name;
            exception when no_data_found then
              log('������� '''||p_profile_user_name||''' �� ������');
              raise_application_error(-20000, '������� �� ������');
            end;
        end;

       --����� ������������
       if not(get_user_parametrs(gb_user_name)) then raise_application_error(-20000, '������������ �� ������'); end if;

       --������� ��������
       if  fnd_profile.SAVE(X_NAME => v_profile_name,
                               X_VALUE => p_value,
                               X_LEVEL_NAME => 'USER',
                               X_LEVEL_VALUE =>  G_SESSION_PAR.user_id
                               )  then
             log('������� '''||v_profile_name||''' ������ �������� '||p_value);
             commit;
          else
             log('������ ��� ��������� ������� '''||v_profile_name||'''');
             log(Fnd_Message.GET);
          end if;

     end;

 --����� ��������� � ����������� �������. ���� ������� �� ���������� - ������ �.
    procedure insert_log_table (pr_message varchar2, p_log_mark varchar2 default null) is
      PRAGMA AUTONOMOUS_TRANSACTION; --���������� ���������� ����������
    BEGIN

       --�� ����� �� ����� �����, ����� �� �������� ����
      if nvl(G_SESSION_PAR.instans_name, 'XXX') != 'PROD' then

         EXECUTE IMMEDIATE  --������������ ��� ���� �����  ����� ���������� ��� ������,���� ������� �� ����������.
         'INSERT INTO '||g_log_table_name||'
         VALUES ('||g_log_table_name||'_S.NEXTVAL, substr(fnd_global.user_name,1, 255), sysdate, :log_mark, :message, DBMS_UTILITY.format_call_stack)'
         USING nvl(p_log_mark, xx_pnaumov_pkg.gb_log_mark), substr(pr_message,1, 4000) ;
        COMMIT;

      end if;
     EXCEPTION
      WHEN others then log('������ ������ ��������� xx_pnaumov_PKG.insert_log_table!!! '||SQLERRM);
     null;

    end insert_log_table;

--***********************��������� ������������� ������������*******************************
    procedure initialize (p_name_resp varchar2:= gb_rest_name, p_mo_mode varchar2 default 'M') IS
       pragma autonomous_transaction;
    BEGIN

        if not(get_user_parametrs(gb_user_name)) then raise_application_error(-20000, '������������ �� ������'); end if;

        if get_resp_parametrs(p_name_resp) then
           fnd_global.apps_initialize( user_id => G_SESSION_PAR.user_id
                                     , resp_id => G_SESSION_PAR.resp_id
                                     , resp_appl_id => G_SESSION_PAR.appl_id);
           
           log('������������� ��������� �������!');
        else
          log('������ �������������!!! ��������� �������� ���������.');
          raise_application_error(-20000, '������ �������������!!! ��������� �������� ���������.');
        end if;
        
       

        --������������� ����������������� (����� � R11)
        $if DBMS_DB_VERSION.VERSION > 11 $then
           mo_global.init(p_mo_mode, null);
           CEP_STANDARD.init_security(); --������ ������ � ������ CE
        $end
        
        
        COMMIT; 
    END initialize;


--************************************�������� ������������****************************************************
-- Created by Nikolay Lysyuk (05/05/2010)
-- ������ ���������� ������������ � ������� OeBS
-- �� ������� ����� ������.
-- ����������� ������ ����������.
-- ������������� ������������ ���������, ��������� � ����������.
-- ������������� ��������� � ��� �� ����� "����" ����������� � ���,
        PROCEDURE create_user(p_user_name varchar2 
                            , p_user_pass varchar2 default 'Olololo1'
                            , p_email varchar2 default null) IS
          --l_USER_NAME                      fnd_user.user_name%type              := gb_user_name;           -- �����
          l_EMPLOYEE_NUMBER                constant per_people_f.EMPLOYEE_NUMBER%type    := '��18228';              -- ��������� �����
          --l_EMAIL                           varchar2(240)                        := 'pnaumov@phosagro.ru';  -- �����
          l_DESC                           constant varchar2(240)                        := '������ ����������';    -- ����������� )
          l_PRES_ORG                       constant per_people_f.ATTRIBUTE1%type         := '10';                   -- �����������
          l_PERS_CFO                       constant per_people_f.ATTRIBUTE2%type         := '0000-00';              -- ���
          l_USER_SESSION_TIMEOUT           constant number(6)                            := 10;                     -- ����� �������� ������ � �����
          l_USER_ID                        fnd_user.user_id%type;
          l_PERS_ROWID                     rowid;
          l_EMPLOYEE_ID                    per_people_f.PERSON_ID%type;
          l_EMPLOYEE_FULL_NAME             per_people_f.FULL_NAME%type;
          l_AGENT_ID                       po_agents.agent_id%type;
          l_AGENT_LOCATION_ID              po_agents.location_id%type;
          l_AGENT_NAME                     per_people_f.FULL_NAME%type;
          l_AGENT_ROWID                    VARCHAR2(18)  := NULL;
          l_CUSTOMER_ID                    HZ_PARTIES.PARTY_ID%type;
          l_CUSTOMER_NAME                  HZ_PARTIES.Party_Name%type;
          
          v_user_name                      fnd_user.USER_NAME%type:= upper(p_user_name);
          --
          --������ ���� ��� �����������
          CURSOR cur_org_list IS
          select orgn_code from sy_orgn_mst where delete_mark = 0 order by orgn_code;
          -- ��������� ID ������, ���� ����� ��� ����
          CURSOR Cur_user (c_user_name fnd_user.user_name%type) IS
          SELECT user_id FROM fnd_user WHERE user_name = c_user_name;
          --
          -- ��������� ID ���������, ���� ����� ����������
          CURSOR Cur_person (c_employee_number per_people_f.EMPLOYEE_NUMBER%type) IS
          select rowid, person_id, full_name from per_people_f where employee_number = c_employee_number
                                                                 and sysdate between effective_start_date
                                                                                 and effective_end_date;
          -- ��������� �� ���������� �� ��� ����� ����������
          CURSOR Cur_agent (c_person_id per_people_f.PERSON_ID%type) IS
          select agent_name from po_agents_v where agent_id = c_person_id;
          --
          -- �������� ��������� ��� ��������� ���������� �� ���������
          CURSOR Cur_agent_emp (c_employee_number per_people_f.EMPLOYEE_NUMBER%type) IS
          select employee_id, location_id from hr_employees_current_v where employee_num = c_employee_number;
          --
          -- ��������� ID ���������, ���� ����� ����������
          CURSOR Cur_customer (c_person_id per_people_f.PERSON_ID%type) IS
          SELECT PARTY_ID, PARTY_NAME FROM HZ_PARTIES WHERE STATUS = 'A' AND PARTY_TYPE = 'PERSON' and person_identifier = c_person_id;
          --

        BEGIN
          --l_USER_NAME:= p_user_name;
          --l_EMAIL:= p_email;
          --l_UNCR_PASS:=

          --
          fnd_global.apps_initialize(
            user_id => 1   -- AUTOINSTALL
          , resp_id => 20420  -- ��������� �������������
          , resp_appl_id => 1 -- ��������� �����������������
          );
          --
          SAVEPOINT thx_point;
          -- ����� ���������� ������
          OPEN  Cur_person (l_EMPLOYEE_NUMBER);
          FETCH Cur_person INTO l_PERS_ROWID,  l_EMPLOYEE_ID, l_EMPLOYEE_FULL_NAME;
          IF (Cur_person % FOUND) THEN
            log('������ �������� "'||l_EMPLOYEE_FULL_NAME||'" � ��������� ������� '||l_EMPLOYEE_NUMBER);
            --
            -- ��������� ��������� ����������� � ���
            begin
              update per_people_f
                set ATTRIBUTE1 = l_PRES_ORG
                  , ATTRIBUTE2 = l_PERS_CFO
                where rowid = l_PERS_ROWID;
              log('��������� "'||l_EMPLOYEE_FULL_NAME||'" � ��� ����� "����" ����������� ����������� "'||l_PRES_ORG||'" � ��� "'||l_PERS_CFO||'"');
            exception
              when others then
                log('������ ���������� ����� "����": ��������� "'||l_EMPLOYEE_FULL_NAME||'" � ��� ����� "����" �� ����������� ����������� "'||l_PRES_ORG||'" � ��� "'||l_PERS_CFO||'"');
                log(sqlerrm);
            end;
            --
            -- ��������� ���������� �� ���������
            OPEN  Cur_agent (l_EMPLOYEE_ID);
            FETCH Cur_agent INTO l_AGENT_NAME;
            IF (Cur_agent % FOUND) THEN
              CLOSE Cur_agent;
              log('��������� "'||l_EMPLOYEE_FULL_NAME||'" ������ ���������� "'||l_AGENT_NAME||'"');
            ELSIF (Cur_agent % NOTFOUND) THEN
              CLOSE Cur_agent;
        --      log('��������� '||l_EMPLOYEE_FULL_NAME||' �� ���������� ����������');
              OPEN  Cur_agent_emp (l_EMPLOYEE_NUMBER);
              FETCH Cur_agent_emp INTO l_AGENT_ID, l_AGENT_LOCATION_ID;
              IF (Cur_agent_emp % FOUND) THEN
                PO_AGENTS_PKG.Insert_Row
                ( X_Rowid               => l_AGENT_ROWID
                , X_Agent_Id            => l_AGENT_ID
                , X_Last_Update_Date    => sysdate
                , X_Last_Updated_By     => fnd_global.USER_ID
                , X_Last_Update_Login   => fnd_global.LOGIN_ID
                , X_Creation_Date       => sysdate
                , X_Created_By          => fnd_global.USER_ID
                , X_Location_ID         => null--l_AGENT_LOCATION_ID -- ��������� ������ (Location_Code)
                , X_Category_ID         => null
                , X_Authorization_Limit => null
                , X_Start_Date_Active   => sysdate
                , X_End_Date_Active     => null
                , X_Attribute_Category  => null
                , X_Attribute1          => null
                , X_Attribute2          => null
                , X_Attribute3          => null
                , X_Attribute4          => null
                , X_Attribute5          => null
                , X_Attribute6          => null
                , X_Attribute7          => null
                , X_Attribute8          => null
                , X_Attribute9          => null
                , X_Attribute10         => null
                , X_Attribute11         => null
                , X_Attribute12         => null
                , X_Attribute13         => null
                , X_Attribute14         => null
                , X_Attribute15         => null
                );
                if l_AGENT_ROWID is not null
                  then log('��������� "'||l_EMPLOYEE_FULL_NAME||'" ���������� ���������� "'||l_EMPLOYEE_FULL_NAME||'"');
                  else log('������ ��������� ��������� "'||l_EMPLOYEE_FULL_NAME||'" ���������� "'||l_EMPLOYEE_FULL_NAME||'"');
                end if;
              ELSIF (Cur_agent_emp % NOTFOUND) THEN
                log('��������� "'||l_EMPLOYEE_FULL_NAME||'" �� ������ ��������������� ��� ����������');
              END IF;
              CLOSE Cur_agent_emp;
            END IF;
            --
            -- ����� ��������� �� ���������
            OPEN  Cur_customer (l_EMPLOYEE_ID);
            FETCH Cur_customer INTO l_CUSTOMER_ID, l_CUSTOMER_NAME;
            IF (Cur_customer % FOUND) THEN
              log('��������� '||l_EMPLOYEE_FULL_NAME||' ������ �������� "'||l_CUSTOMER_NAME||'"');
            ELSIF (Cur_customer % NOTFOUND) THEN
              log('�� ������� ��������� �������� �� ������');
            END IF;
            CLOSE Cur_customer;
            --
          ELSIF (Cur_person % NOTFOUND) THEN
            log('�������� � ��������� ������� '||v_user_name||' � ���������� ���������� �� ������');
          END IF;
          CLOSE Cur_person;
          --
          -- ���� �� ���������� �� ��� ����� �����
          OPEN  Cur_user (v_user_name);
          FETCH Cur_user INTO l_USER_ID;
          IF (Cur_user % FOUND) THEN
            CLOSE Cur_user;
            log('������������ '||v_user_name||' ��� ����������. ����� ������ '||p_user_pass);
            fnd_user_pkg.UpdateUser(x_user_name => v_user_name,x_owner => NULL, x_unencrypted_password => p_user_pass);


          ELSIF (Cur_user % NOTFOUND) THEN
            CLOSE Cur_user;
            log('������������ '||v_user_name||' �� ����������');
            --
            begin
              fnd_user_pkg.createuser (
                x_user_name => v_user_name
              , x_owner => NULL
              , x_unencrypted_password => p_user_pass
              , x_employee_id => l_EMPLOYEE_ID
              , x_customer_id => l_CUSTOMER_ID
              , x_description => l_DESC
              , x_email_address => p_email
              , x_last_logon_date => sysdate
              , x_password_date => sysdate
              );
              -- ��������� ��� �������� ������������
              OPEN  Cur_user (v_user_name);
              FETCH Cur_user INTO l_USER_ID;
              IF (Cur_user % FOUND) THEN
                CLOSE Cur_user;
                commit; -- ��������� ����� ���������� ������������
                log('������������ '||v_user_name||' ������');
                gb_user_name:= v_user_name;
              ELSIF (Cur_user % NOTFOUND) THEN
                CLOSE Cur_user;
                log('������ ��� �������� ������������: ');
              END IF;
              --
            exception
              when others then
                log(sqlerrm);
            end;
          END IF;
          --
          -- ��������� �������� �������� ������������
          -- ��������� ������� �������� ������ (� �������)
          IF Fnd_Profile.save (
             x_name => 'ICX_SESSION_TIMEOUT'
            ,x_value => to_char(60*l_USER_SESSION_TIMEOUT)
            ,x_level_name => 'USER'
            ,x_level_value => l_user_id
          )
          THEN log('����� ������ ��� ������������ '||v_user_name||' �����������: '||to_char(l_USER_SESSION_TIMEOUT)||' �����');
          ELSE log('���������� �������������� ����� �������� ������ ��� ������������ '||v_user_name);
          END IF;
          -- ��������� �������� �������� ������������
          -- This profile option defines the maximum connection time for a connection
          IF Fnd_Profile.save (
             x_name => 'ICX_LIMIT_TIME'
            ,x_value => l_USER_SESSION_TIMEOUT
            ,x_level_name => 'USER'
            ,x_level_value => l_user_id
          )
          THEN log('����� ������� ������ ��� ������������ '||v_user_name||' ����������: '||to_char(l_USER_SESSION_TIMEOUT)||' �����');
          ELSE log('���������� �������������� ����� �������� ������ ��� ������������ '||v_user_name);
          END IF;

          -- �� ����� ������� ������ apps ��� ������ � �����������
          IF Fnd_Profile.save (
             x_name => 'DIAGNOSTICS'
            ,x_value => 'Y'
            ,x_level_name => 'USER'
            ,x_level_value => l_user_id
          )
          THEN log('���������� ����� ����������� ��� ������������ '||v_user_name);
          ELSE log('���������� ���������� ����� ����������� ��� ������������ '||v_user_name);
          END IF;
          --
          -- ���������� ����������
          IF (l_user_id IS NOT NULL) THEN
            BEGIN
              for a in (
                SELECT rownum
                     , responsibility_id    ln_resp_id
                     , application_id       ln_appl_id
                     , description          ls_resp_desc
                     , responsibility_name  resp_name
                  FROM fnd_responsibility_tl
                  WHERE language = 'RU'
                    AND responsibility_name in (
--'������������� �������� XML',
--'���������� �����������������-������������ �����',
'��������� ��������',
'����������� ����������',
--'������������ �������� ��������',
--'��������� ����������������� ���',
'��������� �������������',
--'����������� ������',
--'�����������������-������������ ����� (������)',
--'������������� Oracle Daily Business Intelligence',
--'Oracle Business Intelligence Administrator',
--'����������������� Oracle Sourcing',
'������������� �������',
--'������������� �������� XML',
--'��������� ��������',
--'����������� ����������',
--'��������� �������������',
--'��������� ���������',
--'��������� ����������',
--'����������������� ������������',
--'��: ��������� ������������',
'����������� �� ������������ OA Framework',
'���������� XML: �������������',
'������������� ������� ��������'
,'����: ����� ������������� ����'
,'����: ����� ������� �����'
,'����: ����� ��������� �������� �������'
--,'����: ����� ������������� BI'
--,'����: ����� ����������� ������� BI'
,'����: ����� ��������� ����������'
,'����: ����� �������'
--,'����: ����� ������������ ������������ ����'
,'����: ����� ��������� ���������'
--,'����: ����� �������� �� �������'
,'����: ����� ����� ������ �� ��������'
,'����: ����� ����� ���������'
,'����: ����� ���'
,'����: ����� ������'
,'����: ����� ���������� �������� �����������'
,'����: ����� ������� ���'
,'����: ����� ���������� ����������� �������������'
,'����: ����� ���������� ��������'
,'����: ����� ������������� ������������'
--,'����: ����� ���������� ������������� (�������������)'
,'����: ����� ����������-���������� ����������'
--,'����: ����� ������������� ������� ������������ ������ ��������'
--,'����: ����� ��� (LD)'
--,'����: ����� Borlas Cash Management'
,'����: ����� ������������� ��������� (������)'
,'����: ��������� ������������� (��)'
,'���������� �� ������� ���������'
,'����: ������������ ������������'
 )
              )
              loop
                IF NOT (fnd_user_resp_groups_api.assignment_exists(l_user_id, a.ln_resp_id, a.ln_appl_id, 0))
                THEN
                  fnd_user_resp_groups_api.insert_assignment(l_user_id, a.ln_resp_id, a.ln_appl_id, 0, TRUNC(SYSDATE), NULL, a.ls_resp_desc);
                END IF;
              end loop;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 log('�� ������� ����� ����������: '||sqlerrm);
            END;
          END IF;

--���������� �����
add_role_to_user('������ ������ �������� �� - ��� �����');


          --
          -- ���������� ��� ����������� ��� ������������
          declare
            cur_user_exist   number(1) := 0;

            -- �������� �� ��������� � ��� ������������� ����������
            CURSOR Cur_orgn_code (c_orgn_code SY_ORGN_USR.ORGN_CODE%type
                                , c_user_id fnd_user.user_id%type        ) IS
            select 1 from SY_ORGN_USR where user_id = c_user_id and orgn_code = c_orgn_code;
          begin
            for i in cur_org_list LOOP
                OPEN  Cur_orgn_code (i.orgn_code, l_user_id);
                FETCH Cur_orgn_code INTO cur_user_exist;
                IF (Cur_orgn_code % NOTFOUND) THEN
                  insert into SY_ORGN_USR (USER_ID, ORGN_CODE, LAST_UPDATE_DATE, Last_Updated_By, creation_date, created_by)
                                    values(l_user_id, i.orgn_code, sysdate, 1, sysdate, 1);
                END IF;
                CLOSE Cur_orgn_code;
            end loop;
          end;

          -- ���������� ������� ������ ����������� ��� ������������ (������ ������ like '�%')
          -- ����� ����� ������ � �������� � ������ ���
          -- ���������, ���������. ������ ��������� �� ��� ����������� � ��������� �� �����
          declare
            p_sec_profile     gmd_security_profiles%ROWTYPE;
            p_old_prof_rec    gmd_security_profiles%ROWTYPE;
            Security_seq_id   NUMBER;
            l_return_status   varchar2(1);
            l_return_code     number;
            l_msg_count       number;
            l_msg_data        VARCHAR2(240);
          begin
            for i in cur_org_list LOOP--1..org_list.count loop
                p_sec_profile.orgn_code := i.orgn_code;--org_list(i);
                p_sec_profile.user_id := l_user_id;
                p_sec_profile.responsibility_id := null;
                p_sec_profile.other_orgn := null;
                p_sec_profile.object_type := 'F';
                p_sec_profile.assign_method_ind := 'A';
                p_sec_profile.access_type_ind := 'U';
                p_sec_profile.created_by := fnd_profile.value('USER_ID');
                p_sec_profile.creation_date := sysdate;
                p_sec_profile.last_update_date := sysdate;
                p_sec_profile.last_updated_by := fnd_profile.value('USER_ID');
                p_sec_profile.last_update_login := fnd_global.LOGIN_ID;
                --
                Select gmd_security_profile_id_s.nextval INTO Security_seq_id from sys.dual;
                p_sec_profile.security_profile_id := security_seq_id;
                --
                GMD_FOR_SEC1.sec_prof_form(
                  p_api_version       => 1.0,
                  p_init_msg_list     => 'F',
                  before_sec_prof_rec => p_old_prof_rec ,
                  sec_prof_rec        => p_sec_profile,
                  p_formula_id        => null,
                  p_db_action_ind     => 'I' ,
                  x_return_status     => l_return_status,
                  x_msg_count         => l_msg_count,
                  x_msg_data          => l_msg_data,
                  x_return_code       => l_return_code);

            end loop;
          end;

      --  xx_pnaumov_pkg.initialize;

       --��������� ������ �������
       set_profile('���: ������� ������ �������', 'Y'); --������� �����������
       set_profile('��������� ���-�����������', 'Y');  --��� ������������ ��������� ���. �������
       set_profile('���: �����������', 'Y'); --��� ����������� ������ �� ���. ���������

       --Utilities:Diagnostics: Yes


       set_profile( v_profname_ou, '0' );     -- ������� ������ SetupBuisnessGroup, � ����� "��� ������" - ������ �� �����
       set_profile( v_profname_org, '0' );    -- ������� ������ SetupBuisnessGroup, � ����� "��� ������" - ������ �� �����
       set_profile( v_profname_book, '7932' );   -- ������� ������ SetupBuisnessGroup, � ����� "��� ������" - ������ �� �����
       
        commit; -- C���������� =)

        EXCEPTION
        WHEN OTHERS THEN
          log('������:');
          log(sqlerrm);
          ROLLBACK TO SAVEPOINT thx_point;
        END create_user;

--****************************����� ���������� � � ����������*****************************************************
PROCEDURE find_concurrent (pr_conc_name varchar2:=NULL
                         , pr_conc_descr varchar2:= NULL
                         , pr_find_flag varchar2:='N' 
                         , p_print_last_reqs number:= 0
                         , p_print_parameters varchar2:='N' 
                         , p_print_fndload_cmd varchar2:='N' 
                          ) is
 --p_resp_name varchar2(100);
 
 procedure print_conc_req (p_CONCURRENT_PROGRAM_ID number, p_rownum number ) is 
   CO_SEP CONSTANT VARCHAR2(100):= ' | ';
   begin  
     log('***********��������� �������***********');   
     log('REQUEST_ID'||CO_SEP
       ||'USER_NAME'||CO_SEP
       ||'PHASE_CODE'||CO_SEP
       ||'STATUS_CODE'||CO_SEP
       ||'ARGUMENT_TEXT'||CO_SEP
       ||'PERIOD'||CO_SEP
       ||'LOGFILE_NAME');      
       
     for i in (
      select * from (
      select cr.REQUEST_ID
           , u.USER_NAME
           , cr.PHASE_CODE
           , cr.STATUS_CODE
           , cr.ARGUMENT_TEXT
           , to_char(cr.ACTUAL_START_DATE, 'dd.mm.yyyy hh24:mi')||'-'||to_char(cr.ACTUAL_COMPLETION_DATE, 'dd.mm.yyyy hh24:mi') period
           , cr.logfile_name
      from fnd_concurrent_requests cr
      inner join fnd_user u on cr.REQUESTED_BY = u.USER_ID
      where cr.CONCURRENT_PROGRAM_ID = p_CONCURRENT_PROGRAM_ID
      order by cr.ACTUAL_START_DATE desc nulls last)
      where 1=1
      and rownum <= p_rownum
      )
    loop
      log(i.request_id||CO_SEP
        ||i.USER_NAME||CO_SEP
        ||i.PHASE_CODE||CO_SEP
        ||i.STATUS_CODE||CO_SEP
        ||i.ARGUMENT_TEXT||CO_SEP
        ||i.period||CO_SEP
        ||i.logfile_name);
    end loop;
   end print_conc_req;
   
procedure print_parameters (p_conc_name varchar2) is 
     begin   
       
     log('***********���������***********');
       log('    Sequence'||' | '
            ||'Parameter'||' | '
            ||'Desciption'||' | '
            ||'Desciption'||' | '
            ||'Parameter_Required'||' | '
            ||'Parameter_Display'||' | '
            ||'Value_Set'||' | '
            ||'Default_Type'||' | '
            ||'Default_Value');
            
        for i in (    
          select df.column_seq_num Sequence,
                 df.end_user_column_name Parameter ,                 
                 df.description Desciption,
                 df.FORM_LEFT_PROMPT PROMPT, 
                 df.required_flag Parameter_Required,
                 df.display_flag Parameter_Display, 
                 fvs.flex_value_set_name Value_Set,
                 df.default_type Default_Type,
                 df.default_value Default_Value
          from apps.fnd_descr_flex_col_usage_vl df
          inner join apps.fnd_flex_value_sets fvs on fvs.flex_value_set_id=df.flex_value_set_id
          where 1=1
          and df.descriptive_flexfield_name = '$SRS$.'||p_conc_name
          and df.enabled_flag = 'Y'
          order by df.column_seq_num)
        loop
          log('    '||i.Sequence||' | '
            ||i.Parameter||' | '
            ||i.Desciption||' | '
            ||i.PROMPT||' | '            
            ||i.Parameter_Required||' | '
            ||i.Parameter_Display||' | '
            ||i.Value_Set||' | '
            ||i.Default_Type||' | '
            ||i.Default_Value);
        end loop;
     end print_parameters;
     
     
  procedure print_fndload_cmd (P_CONCURRENT_PROGRAM_ID number
                                ,P_CONCURRENT_PROGRAM_NAME varchar2
                                ,P_APPLICATION_SHORT_NAME varchar2) 
    is 
  begin 
    log('***********������� ��� ��������/�������� ����� ldt***********');
    log('    FNDLOAD apps/<apps_pass> O Y DOWNLOAD $FND_TOP/patch/115/import/afcpprog.lct '
     ||P_CONCURRENT_PROGRAM_NAME||'_CP.ldt PROGRAM APPLICATION_SHORT_NAME="'
     ||P_APPLICATION_SHORT_NAME||'" CONCURRENT_PROGRAM_NAME="'||P_CONCURRENT_PROGRAM_NAME||'"');
    
    --TODO print RG
    for i in (
        select gr.REQUEST_GROUP_NAME
             , appl.APPLICATION_SHORT_NAME
             , rownum rn
        FROM
          FND_REQUEST_GROUP_UNITS gru
        , FND_REQUEST_GROUPS gr
        , FND_APPLICATION_VL appl
        where 1=1
        and gru.request_unit_id = p_CONCURRENT_PROGRAM_ID
        and gr.request_group_id=gru.request_group_id
        and appl.APPLICATION_ID=gr.application_id
      )          
    loop
       log('    FNDLOAD apps/<apps_pass> 0 Y DOWNLOAD $FND_TOP/patch/115/import/afcpreqg.lct '
       ||P_CONCURRENT_PROGRAM_NAME||'_RG'||i.rn||'.ldt REQUEST_GROUP REQUEST_GROUP_NAME="'||i.REQUEST_GROUP_NAME||'"'
       ||' APPLICATION_SHORT_NAME="'||i.APPLICATION_SHORT_NAME||'" UNIT_NAME="'||P_CONCURRENT_PROGRAM_NAME||'"');
    end loop;
    
    --TODO FNDLOAD apps/$CLIENT_APPS_PWD O Y DOWNLOAD  $XDO_TOP/patch/115/import/xdotmpl.lct XX_CUSTOM_DD.ldt XDO_DS_DEFINITIONS APPLICATION_SHORT_NAME='XXCUST' DATA_SOURCE_CODE='XX_SOURCE_CODE' TMPL_APP_SHORT_NAME='XXCUST' TEMPLATE_CODE='XX_SOURCE_CODE'
  end print_fndload_cmd;   
   
 
  begin

  IF  pr_conc_name IS NULL and pr_conc_descr IS NULL then log('�� ������ ��������� ������');
  ELSE
   --p_resp_name:= '%'||pr_resp_name||'%';

    --log('+ - �� ������������ '||gb_user_name||' ��������� ��������� ����������');
    log('---------------------------------------------------------------');
--����� ������������ ���������
for a IN ( select  pr.concurrent_program_name||' \ '||pr.user_concurrent_program_name||' \ '||pr.DESCRIPTION pr_name,
                   pr.concurrent_program_name, 
                   pr.CONCURRENT_PROGRAM_ID pr_id,
                   DECODE(pr.enabled_flag, 'N', '(���������) ', NULL)enable, --���� ���������� ��������� - �������� ���
                   --������ � �������������� �����
                   CASE ex.EXECUTION_METHOD_CODE
                            WHEN 'H' THEN '����-��������'
                            WHEN 'S' THEN '������ ������'
                            WHEN 'J' THEN '����������� ��������� Java'
                            WHEN 'K' THEN '������������ ��������� Java'
                            WHEN 'M' THEN '������������� �������'
                            WHEN 'P' THEN '������ Oracle(*.rdf)'
                            WHEN 'I' THEN '����������� ��������� PL/SQL'
                            WHEN 'B' THEN '������� ����� ������ ��������'
                            WHEN 'A' THEN '����������� ���������(�++)'
                            WHEN 'L' THEN 'SQL*Loader'
                            WHEN 'Q' THEN 'SQL*Plus'
                            WHEN 'E' THEN '������������ ��������� Perl'
                      END execution_method_code,
                      ex.EXECUTION_FILE_NAME,
                      pr.OUTPUT_FILE_TYPE,
                      fa.APPLICATION_SHORT_NAME, 
                      tmpl.TEMPLATE_TYPE_CODE,
                      tmpl.DEFAULT_OUTPUT_TYPE
                      
                   --
            from fnd_concurrent_programs_vl pr
           inner join fnd_application_vl fa on pr.APPLICATION_ID = fa.APPLICATION_ID
           inner join FND_EXECUTABLES_FORM_V ex on ex.EXECUTABLE_ID = pr.EXECUTABLE_ID
                                                and ex.APPLICATION_ID = pr.EXECUTABLE_APPLICATION_ID
            left join XDO_TEMPLATES_B tmpl on pr.CONCURRENT_PROGRAM_NAME = tmpl.TEMPLATE_CODE
           where 1=1
             and pr.srs_flag in ('Y', 'Q')
             and (
                  (   pr_find_flag = 'N'  --����� ���������� �� ���������� ������
                  and (xx_pnaumov_pkg.f_like(pr.concurrent_program_name, pr_conc_name) = 1
                    or xx_pnaumov_pkg.f_like(pr.USER_CONCURRENT_PROGRAM_NAME, pr_conc_name)=1
                      )
                  and xx_pnaumov_pkg.f_like(NVL(pr.DESCRIPTION, pr.USER_CONCURRENT_PROGRAM_NAME), pr_conc_descr) = 1
                   )
               or  (   pr_find_flag = 'Y' --��� ���������� ��������� ������ ���� ��� ��������� ��������� NVL(pr_resp_name,pr_resp_descr)
                   and (  xx_pnaumov_pkg.f_like(pr.concurrent_program_name, NVL(pr_conc_name,pr_conc_descr)) = 1
                       or xx_pnaumov_pkg.f_like(pr.DESCRIPTION, NVL(pr_conc_name,pr_conc_descr)) = 1
                       or xx_pnaumov_pkg.f_like(pr.USER_CONCURRENT_PROGRAM_NAME, NVL(pr_conc_name,pr_conc_descr)) = 1
                       or xx_pnaumov_pkg.f_like(ex.EXECUTION_FILE_NAME, NVL(pr_conc_name,pr_conc_descr)) = 1                       
                       or xx_pnaumov_pkg.f_like(ex.EXECUTION_FILE_NAME, NVL(pr_conc_name,pr_conc_descr)) = 1                       
                       )
                   ) 
                 )
           order by pr.concurrent_program_name)
   loop
      log('----------------------'||a.enable||a.pr_name||'-----------------------');
      log('������: '||a.application_short_name
        ||' ����� ����������: '||a.execution_method_code 
        ||' ����������� ����: '||a.EXECUTION_FILE_NAME
        ||' ������ ������:'||a.output_file_type
        ||' ��� �������:'||a.TEMPLATE_TYPE_CODE
        ||' ������ �� ���������:'||a.DEFAULT_OUTPUT_TYPE
        );
      print_list_responses(p_conc_program_id => a.pr_id);
      
      --������ ��������� ��������
      if p_print_last_reqs > 0 then 
        print_conc_req(a.pr_id, p_print_last_reqs);
      end if;
      
      --��������� + �� ��� ����������
      if p_print_parameters = 'Y' then 
        print_parameters(a.concurrent_program_name);
      end if;
      
      if p_print_fndload_cmd = 'Y' then 
        print_fndload_cmd(a.pr_id, a.concurrent_program_name, a.application_short_name);
      end if;
      
    end loop;
  END IF;
END find_concurrent;

--***********************����� ������, ������������ ��������� ������*****************************
procedure find_block_session (p_obj_name varchar2, p_kill_session varchar2 default 'N') is
  l_sql VARCHAR2(4000);
  TYPE EmpCurTyp  IS REF CURSOR;
  v_emp_cursor    EmpCurTyp;

BEGIN
  --������ ���������� � ��������
  FOR i in (SELECT c.owner,
                   c.object_name,
                   c.object_type,
                   b.SID,
                   b.serial#,
                   b.status,
                   b.osuser,
                   b.machine
              FROM v$locked_object a, v$session b, dba_objects c
             WHERE b.SID = a.session_id
               AND a.object_id = c.object_id
               and upper(c.object_name) like upper(p_obj_name)
              union
              
             SELECT c.owner,
                   c.object_name,
                   c.object_type,
                   b.SID,
                   b.serial#,
                   b.status,
                   b.osuser,
                   b.machine
              FROM v$lock a, v$session b, dba_objects c
             WHERE b.SID = a.SID
               AND a.id1 = c.object_id
               and upper(c.object_name) like upper(p_obj_name)               
               )
    LOOP
      begin
         log('1. ������� ������ '||i.SID||' ����� '||i.osuser||' ��� ������� '||i.object_name);
         if p_kill_session = 'Y' then
           l_sql := 'alter system kill session ''' || i.SID || ',' ||i.serial# || '''';
           EXECUTE IMMEDIATE l_sql;
           log('...� �����');
         end if;
       exception
         when others then log(SQLERRM); --continue;
       end;
    END LOOP;


  declare
    v_session_id number;
    v_obj_name varchar2(255);
    v_stmt_str varchar2(4000);
  begin
      --TODO �� �������� ��-�� ���������� ������� ���� �� � ����� �� ������
      v_stmt_str:= 'select session_id, name
                     from DBA_DML_LOCKS
                     where lower(name) like lower(:p_obj_name)
                     union
                     select session_id, name
                     from dba_ddl_locks
                     where lower(name) like lower(:p_obj_name)
                     union
                     select session_id, lock_id1
                     from dba_lock_internal
                     where lower(lock_id1) like lower(:p_obj_name)
                     AND l.lock_type = ''Body Definition Lock''                     
                     ';

      --�������� � �������� ��-�� �������
     OPEN v_emp_cursor FOR v_stmt_str USING p_obj_name, p_obj_name;

     LOOP
        FETCH v_emp_cursor INTO v_session_id, v_obj_name;
        EXIT WHEN v_emp_cursor%NOTFOUND;

        for j in (select distinct serial# data, osuser
                  from v$session
                  where sid = v_session_id)
             loop
                 begin
                   log('2. ������� ������ '||v_session_id||' ����� '||j.osuser||' ��� ������� '||v_obj_name);
                   if p_kill_session = 'Y' then
                     l_sql := 'alter system kill session ''' || v_session_id || ',' ||j.data|| '''';
                     EXECUTE IMMEDIATE l_sql;
                     log('...� �����');
                   end if;
                 exception
                   when others then log(SQLERRM); --continue;
                 end;
         end loop;

      END LOOP;
   exception
    when others then log(SQLERRM);
  end;

end find_block_session;

--************************��������� ��������� ������ �������� � ����������� �� ����**************************************
procedure find_value_set (pr_value_set_name varchar2:= NULL
                        , p_use_conc varchar2:= NULL
                        , p_find_flag varchar2:= NULL
                        ) is
begin

 for i in (select s.flex_value_set_name, s.flex_value_set_id,
                  s.description, s.validation_type ,
                  case s.validation_type
                        when 'D' then '���������'
                        when 'I' then '�����������'
                        when 'N' then '���'
                        when 'P' then '����'
                        when 'U' then '������'
                        when 'F' then '�������'
                        when 'X' then '������������� �����������'
                        when 'Y' then '����������� ���������'
                  end validation_type_descr
           from FND_FLEX_VALUE_SETS s
           where 1=1
           and xx_pnaumov_pkg.f_like(s.flex_value_set_name, pr_value_set_name)=1
           or (p_find_flag = 'Y'
           and xx_pnaumov_pkg.f_like(s.description, pr_value_set_name)=1
               )
           )
    loop
        log('����� ��������: '||i.flex_value_set_name||' - '||i.description||' ('||i.validation_type_descr||'):');
        log(' ');

      --��������� ������ ��������
       if i.validation_type = 'F' then
          declare
            p_select varchar2(500);
            p_from varchar2(500);
            p_where FND_FLEX_VALIDATION_TABLES.additional_where_clause%TYPE;
          begin
            select 'select '||t.value_column_name||' value' ||NVL2(t.meaning_column_name, ', '||t.meaning_column_name||' descr', NULL)||NVL2(t.id_column_name, ', '||t.id_column_name||' id', NULL) t_select
                   ,'from '||t.application_table_name t_from
                   ,t.additional_where_clause t_where
            into p_select, p_from, p_where
            from FND_FLEX_VALIDATION_TABLES t
            where t.flex_value_set_id = i.flex_value_set_id;

            --���� � ������ ������ p_where �� ������� ����� where, �� ��������� ���
           p_where:= case nvl(upper(substr(rtrim(p_where),1,5)), 'NULL')
                     when 'WHERE' then p_where
                     when 'NULL'  then NULL
                                  else 'where '||p_where
                     end;

            log('    '||p_select);
            log('    '||p_from);
            log('    '||p_where);
          end;
        end if;

     --����������� ������ ��������
       if i.validation_type = 'I' then
        declare
                  p_err_date varchar2(100);
                  p_err_enable varchar2(100);

                  p_max_size_value number;
                  p_max_size_meaning number;
                  p_max_size_descr number;

                  p_sum_max_size number;

                  p_colum_name_value varchar2(100):= '��������';
                  p_colum_name_meaning varchar2(100):= '������. ����.';
                  p_colum_name_descr varchar2(100):= '��������';

                  p_min_size_value number:= length(p_colum_name_value)+1;
                  p_min_size_meaning number:= length(p_colum_name_meaning)+1;
                  p_min_size_descr number:= length(p_colum_name_descr)+1;

         begin
                --����������� ������� ����� ��� ����������������� �������
                select max(length(v.FLEX_VALUE))+1, max(length(v.FLEX_VALUE_MEANING))+1, max(length(v.DESCRIPTION))+1
                into p_max_size_value, p_max_size_meaning, p_max_size_descr
                from FND_FLEX_VALUES_VL v
                where v.flex_value_set_id = i.flex_value_set_id;

                if p_min_size_value > p_max_size_value then p_max_size_value:= p_min_size_value; end if;
                if p_min_size_meaning > p_max_size_meaning then p_max_size_meaning:= p_min_size_meaning; end if;
                if p_min_size_descr > p_max_size_descr then p_max_size_descr:= p_min_size_descr; end if;
              --���������
              log(RPAD(p_colum_name_value,p_max_size_value)||' | '||RPAD(p_colum_name_meaning,p_max_size_meaning)||' | '||RPAD(p_colum_name_descr,p_min_size_descr)||p_err_date||p_err_enable);
              --�������������� �����
              p_sum_max_size:= p_max_size_value + p_max_size_meaning + p_max_size_descr;
              log(RPAD('-',p_sum_max_size+4, '-'));
              for j in (select v.FLEX_VALUE, v.ENABLED_FLAG,
                               v.start_date_active, v.end_date_active,
                               v.FLEX_VALUE_MEANING FLEX_VALUE_MEANING,
                               v.DESCRIPTION DESCRIPTION
                        from FND_FLEX_VALUES_VL v
                        where v.flex_value_set_id = i.flex_value_set_id)
              loop
                  if j.enabled_flag = 'N' then p_err_enable:= '  (���������!)';
                                          else p_err_enable:= NULL;
                  end if;
                  if SYSDATE NOT BETWEEN NVL(j.start_date_active, SYSDATE) AND NVL(j.end_date_active, SYSDATE)
                    then p_err_date:= '  (����������! c '||j.start_date_active||' �� '||j.end_date_active||')'; end if;


                  log(RPAD(j.FLEX_VALUE,p_max_size_value)||' | '||RPAD(j.FLEX_VALUE_MEANING,p_max_size_meaning)||' | '||RPAD(j.description,p_max_size_descr)||p_err_date||p_err_enable);
              end loop;

             end;
        end if;
    log('');
    if p_use_conc = 'Y' then
      log(' ������������ � ���������� ��������� ������������ ��������:');
        for j in (select distinct ltrim(cp.DESCRIPTIVE_FLEXFIELD_NAME, '$SRS$.') conc_name
                  from FND_DESCR_FLEX_COL_USAGE_VL  cp
                  where cp.FLEX_VALUE_SET_ID = i.flex_value_set_id
                  )
        loop
           log('      '||j.conc_name);
        end loop;
     end if;
    log('**********************************************************');
    end loop;


end find_value_set;

--******************************��������� ��������� ������� �������� �� ������****************************************
PROCEDURE find_rus_chars (pr_string varchar2) IS
    p_new_string  varchar2(1000):=NULL;
    p_num number;
    p_count number:=0;
BEGIN
    p_num:= length(pr_string);
    for i in 1..p_num
     loop
       --����� �������� ������� ��������
         if ASCII(substr(pr_string, i, 1))>= 192 and ASCII(substr(pr_string, i, 1)) <= 255
           then p_new_string:= p_new_string||'['||substr(pr_string, i, 1)||']';
                p_count:= p_count + 1;
           else  p_new_string:= p_new_string||substr(pr_string, i, 1);
         end if;
    end loop;
      log('���-�� ������� �������� � ������: '||p_count);
      log(p_new_string);
END find_rus_chars;


--*****************************��������� ��������� �������� �������************************
--����� � ������� ������������ �� http://www.notesbit.com/index.php/oracle-applications/11i-scripts/how-do-you-check-the-profile-option-values-using-sql-oracle-applications/
PROCEDURE find_profile(p_profile_name varchar2) is

l_profile_name varchar2(2000):='XXX';

begin
FOR i in  (SELECT po.profile_option_name profile_option_name,
                  decode(po.profile_option_name, po.USER_PROFILE_OPTION_NAME, null, ' ('||po.USER_PROFILE_OPTION_NAME||')')USER_PROFILE_OPTION_NAME,
                  decode(to_char(pov.level_id),
                         '10001', '���������',
                         '10002', '����������',
                         '10003', '����������',
                         '10004', '������������',
                         '10005', '������',
                         '10006', '�����������',
                         '10007', '����������', --��������� ��� ���������� �� 10003
                          pov.level_id||'(������������)') lev,
                  decode(to_char(pov.level_id),
                         '10001', '',
                         '10002', app.application_short_name,
                         '10003', rt.responsibility_name,--rsp.responsibility_key,
                         '10004', usr.user_name,
                         '10005', svr.node_name,
                         '10006', org.name,
                         '10007', rt.responsibility_name,
                         '???') context,
                  pov.profile_option_value value
           FROM   FND_PROFILE_OPTIONS_VL po
           left join  FND_PROFILE_OPTION_VALUES pov on pov.application_id = po.application_id
                                                      and pov.profile_option_id = po.profile_option_id
           left join   fnd_user usr                  on usr.user_id  = pov.level_value
           left join   fnd_application app           on app.application_id  = pov.level_value
           --left join   fnd_responsibility rsp        on rsp.application_id  = pov.level_value_application_id
           --                                           and rsp.responsibility_id  = pov.level_value
           left join    fnd_nodes svr                 on svr.node_id = pov.level_value
           left join   hr_operating_units org        on org.organization_id = pov.level_value
           left join   fnd_responsibility_tl rt      on rt.responsibility_id = pov.level_value
                                                     and rt.application_id = pov.level_value_application_id
                                                     and rt.language = userenv('LANG')

           WHERE 1=1
           and po.profile_option_name in (select pot.profile_option_name
                                          from  FND_PROFILE_OPTIONS_TL pot
                                          where  f_like(pot.profile_option_name, p_profile_name)=1
                                              or f_like(pot.USER_PROFILE_OPTION_NAME, p_profile_name)=1
                                          )
           ORDER BY profile_option_name, pov.level_id, context, "VALUE")
loop
  if l_profile_name <> i.profile_option_name then
    l_profile_name:= i.profile_option_name;
    log(' ');
    log('������� '||l_profile_name||i.USER_PROFILE_OPTION_NAME);
    log('(������� ��������: '||fnd_profile.VALUE(l_profile_name)||')');
  end if;

  log('  '||i.lev||' ('||i.context||')  ��������: '||i.value);

end loop;

END find_profile;

--*****************************��������� �������� ����������� ����� ������������*****************************************
procedure set_username(p_username varchar2)
is
begin
  if get_user_parametrs(p_username) then gb_user_name:= G_SESSION_PAR.user_name; end if;
end set_username;


--********************��������� ������ ������� ��***************************
procedure find_object(p_object_name varchar2
                    , p_table_size varchar2 default 'N'
                    , p_dependencies varchar2 default 'N') is
    v_total_size number:=0;                
 begin
   for i in (select distinct --��� ����������� ������ � ��� ����
                    ao.OWNER
                  , ao.OBJECT_NAME
                  , decode(ao.TEMPORARY, 'Y', 'TEMP ', NULL)
                  ||decode(ao.OBJECT_TYPE, 'PACKAGE BODY', 'PACKAGE',ao.OBJECT_TYPE) OBJECT_TYPE

             from all_objects ao
             where f_like(ao.OBJECT_NAME, p_object_name)=1
             order by OBJECT_TYPE, ao.OWNER, ao.OBJECT_NAME)
  loop
    v_total_size:=0;
     
    log(i.object_type||' - '||i.OWNER||'.'||i.OBJECT_NAME);
    --���������� ���������� ������� �������
    if i.object_type = 'TABLE' and p_table_size = 'Y'then
      log('     ������� ���������� ������� �������� ��������:');
      for j in (SELECT segment_type, owner|| '.' ||segment_name object_name, BYTES/1024/1024 obj_size
                FROM dba_segments
                WHERE owner = i.owner
                AND segment_name IN (
                SELECT table_name
                FROM dba_tables
                WHERE owner = i.owner AND table_name = i.object_name
                UNION
                SELECT index_name
                FROM dba_indexes
                WHERE owner = i.owner AND table_name = i.object_name
                UNION
                SELECT segment_name
                FROM dba_lobs
                WHERE owner = i.owner AND table_name = i.object_name)
                ORDER BY 3 desc,1,2)
        loop
          log('        '||j.segment_type||' - '||j.object_name||'('||j.obj_size||' Mb)');
          v_total_size:= v_total_size + j.obj_size;
        end loop;
        
        log('     �����: '||v_total_size||' Mb');
      end if;
      --������� �������, ������� �������� ������� ������
      if p_dependencies = 'Y' then
         log('     ������ ������ ����������:');
         find_code(p_find_string => i.OBJECT_NAME);
         
        end if;
  log('-------------------------------------------------------');
  end loop;
end   find_object;

--************��������� ������� ������������ ��������� ������� ��������������.**************************
--���������� � ����� ����������� ���� - ��� - ������� - �����
procedure export_pers (p_pers_name varchar2, p_level varchar2 default 'A') is
    v_api_request_id number;

  begin
    xx_pnaumov_pkg.initialize('����������� ����������'); --��������� ������� ����� � ����������� ���� ������������ ��� ������� ������ �������������

    v_api_request_id := fnd_request.submit_request
        (
          application    => 'XXPHA',
          program        => 'XXPHA_TA004',
          description    => 'PHA ������� ��������������',
          start_time     => null,
          sub_request    => false,
          argument1      => p_level,
          argument2      => null,
          argument3      => null,
          argument4      => p_pers_name
        );
   if   v_api_request_id = 0 then  xx_pnaumov_pkg.log('�� ������� ������� ������ ������� ��������������');
   else
     commit;
     xx_pnaumov_pkg.log('');
     xx_pnaumov_pkg.log('������� �������������� ������� �������. ����� ������� '||v_api_request_id);
     xx_pnaumov_pkg.log('��������� � ����� OeBS ����������� '||gb_user_name||' (��� - ������� - �����)');
   end if;


  end export_pers;

--**********************���������� ���������� ������������************************
procedure add_resp_to_user (p_pesp_name varchar2, p_user_name varchar2 default null) is
    v_start_date date;
    v_end_date date;
    v_security_group_id fnd_user_resp_groups.security_group_id%type;
  begin

  if not get_user_parametrs(nvl(p_user_name, gb_user_name)) then  raise_application_error(-20000, '������! ��� ����������� ������������'); end if;
  if not get_resp_parametrs(p_pesp_name) then raise_application_error(-20000, '������! ��� ����������� ����������. �������� ���...'); end if;

  log('');
  if not (fnd_user_resp_groups_api.assignment_exists(G_SESSION_PAR.user_id, G_SESSION_PAR.resp_id, G_SESSION_PAR.appl_id, 0))
    then  fnd_user_resp_groups_api.insert_assignment(G_SESSION_PAR.user_id
                                                   , G_SESSION_PAR.resp_id
                                                   , G_SESSION_PAR.appl_id
                                                   , 0
                                                   , TRUNC(SYSDATE)
                                                   , NULL
                                                   , NULL);
      log('���������� '||G_SESSION_PAR.resp_name||' ������� ��������� ������������ '||G_SESSION_PAR.user_name);
      commit;
     else

        --���������, ���� ���������
        select ur.START_DATE, ur.END_DATE, ur.security_group_id
        into v_start_date, v_end_date, v_security_group_id
        from fnd_user_resp_groups_all ur
        where ur.user_id = G_SESSION_PAR.user_id
          and ur.RESPONSIBILITY_ID = G_SESSION_PAR.resp_id
          and ur.RESPONSIBILITY_APPLICATION_ID = G_SESSION_PAR.appl_id;

        if v_end_date < sysdate then
            fnd_user_resp_groups_api.Update_Assignment(user_id                       => G_SESSION_PAR.user_id,
                                                       responsibility_id             => G_SESSION_PAR.resp_id,
                                                       responsibility_application_id => G_SESSION_PAR.appl_id,
                                                       security_group_id             => v_security_group_id,
                                                       start_date                    => v_start_date,
                                                       end_date                      => null,
                                                       description                   => null
                                                       );


             commit;
             log('���������� '||G_SESSION_PAR.resp_name||' ������������ ��� ������������ '||G_SESSION_PAR.user_name);
         else
             log('���������� '||G_SESSION_PAR.resp_name||' ��� ��������� ������������ '||G_SESSION_PAR.user_name);
         end if;

   end if;
  end add_resp_to_user;


--**********************���������/���������� ���������������� �������****************************
procedure on_diag_profile (p_result_into_table varchar2 default 'N') is



   --v_enable_profile varchar2(100);
   --v_log_end_value   number;

   --������� ��������
pragma autonomous_transaction;
v_start_parament varchar2(200);
begin
 
         log('��������� ��������������� ��������: ');

         FND_LOG.G_CURRENT_RUNTIME_LEVEL:= 1;
         set_profile(v_profname_aflog_enbl, 'Y');
         set_profile(v_profname_aflog_level, '1');
         set_profile('���: ������ ������� �������', '%');
         set_profile(v_eam_debug_name, 'Y');
         set_profile('INV_DEBUG_LEVEL', '102'); --��� ������ ����� INVPUTLI

         
         xx_pnaumov_pkg.initialize('��������� �������������');

        --PO ����

        --PO_LOG.enable_logging('%');
        --PO_LOG.refresh_log_flags;
        --PO_LOG.d_stmt:= TRUE;

        --������ ������
        SELECT MAX(LOG_SEQUENCE)
        into g_log_start_value
        FROM FND_LOG_MESSAGES;

        DBMS_PROFILER.start_profiler(run_comment  => fnd_global.USER_NAME,
                                     run_comment1 => to_char(sysdate, 'hh24:mi:ss'),
                                     run_number   => g_dbms_profile_run_num);


       execute immediate 'ALTER SESSION SET tracefile_identifier  = ''XXDVLP''';
       execute immediate 'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 12''';

       v_start_parament:= 'g_log_start_value = '||g_log_start_value||' g_dbms_profile_run_num = '||g_dbms_profile_run_num;
       if p_result_into_table = 'Y'
          then xx_pnaumov_pkg.insert_log_table(v_start_parament);
          else log(v_start_parament);
       end if;

    --���������� ��������
 commit;
 exception
   when others then
     log('Error', 'E');
 end on_diag_profile;



--**********************���������/���������� ���������������� �������****************************
procedure off_diag_profile(p_result_into_table varchar2 default 'N') is
   v_log_end_value   number;
   v_result_message varchar2(32000);
pragma autonomous_transaction;
begin


     log('���������� ��������������� ��������: ');


     execute immediate 'ALTER SESSION SET EVENTS ''10046 trace name context OFF''';

        --����� ������
        SELECT MAX(LOG_SEQUENCE)
        into v_log_end_value
        FROM FND_LOG_MESSAGES;

        DBMS_PROFILER.stop_profiler;
        set_profile(v_profname_aflog_enbl, 'N');
        set_profile(v_profname_aflog_level, '6');

        set_profile(v_eam_debug_name, 'N');

        --PO
        --PO_LOG.refresh_log_flags;


        v_result_message:=
        '��������� �������� �������: '||chr(13)||
        ''||chr(13)||
        'select * '||chr(13)||
            'from FND_LOG_MESSAGES lm'||chr(13)||
            'where lm.log_sequence between '||nvl(to_char(g_log_start_value), ':g_log_start_value')||' and '||v_log_end_value||chr(13)||
            'and lm.user_id = '||fnd_global.USER_ID||chr(13)||
            'order by log_sequence'||chr(13)||

        ''||chr(13)||
        '��������� ��������������: '||chr(13)||
        ''||chr(13)||
        'select pu.runid, pu.unit_number, pu.unit_name, pd.line#, ass.TEXT, pd.total_occur, pd.total_time, pd.min_time, pd.max_time'||chr(13)||
            'from plsql_profiler_runs pr'||chr(13)||
            'inner join plsql_profiler_units pu on pr.runid = pu.runid'||chr(13)||
            'inner join plsql_profiler_data  pd on pu.runid = pd.runid'||chr(13)||
            '                                    and pu.unit_number = pd.unit_number'||chr(13)||
            'inner join all_source           ass  on ass.OWNER = pu.unit_owner'||chr(13)||
            '                                     and ass.NAME = pu.unit_name'||chr(13)||
            '                                     and ass.TYPE = pu.unit_type'||chr(13)||
            '                                     and ass.LINE = pd.line#'||chr(13)||
            'where pu.runid = '||nvl(to_char(g_dbms_profile_run_num), ':g_dbms_profile_run_num')||chr(13)||
            'and pd.total_occur > 0'||chr(13)||chr(13);


     if p_result_into_table = 'Y'
       then xx_pnaumov_pkg.insert_log_table(v_result_message);
       else log(v_result_message);
     end if;



 commit;
 end off_diag_profile;








--**************************************������ ������� ������ ������ ���� � �����************************************
 --������ �������
   procedure time_start (p_name varchar2) is
     begin
      G_TIME(p_name).start_time:= CURRENT_TIMESTAMP;
      G_TIME(p_name).total_call:= G_TIME(p_name).total_call + 0.5;
     end;

 --����� �������
   procedure time_end (p_name varchar2) is

     begin
        G_TIME(p_name).end_time:= CURRENT_TIMESTAMP;
         G_TIME(p_name).diff_time:=  G_TIME(p_name).end_time -  G_TIME(p_name).start_time;

        --������ ������
        if  G_TIME(p_name).min_time is null then   G_TIME(p_name).min_time:=  G_TIME(p_name).diff_time; end if;
        if  G_TIME(p_name).max_time is null then   G_TIME(p_name).max_time:=  G_TIME(p_name).diff_time; end if;
        --�����
        if   G_TIME(p_name).diff_time <  G_TIME(p_name).min_time then  G_TIME(p_name).min_time:=  G_TIME(p_name).diff_time; end if;
        if   G_TIME(p_name).diff_time >  G_TIME(p_name).max_time then  G_TIME(p_name).max_time:=   G_TIME(p_name).diff_time; end if;

         G_TIME(p_name).total_time:=  G_TIME(p_name).total_time + G_TIME(p_name).diff_time;
         G_TIME(p_name).total_call:=  G_TIME(p_name).total_call + 0.5;
     end time_end;

--����� ����������
  procedure time_print (p_name varchar2, p_cliner_frag in varchar2 default 'Y') is

  v_avg_time interval day to second;

     begin

      if     G_TIME.exists(p_name)
         and G_TIME(p_name).total_call > 0
         and trunc(G_TIME(p_name).total_call) =  G_TIME(p_name).total_call
      then
        log('');
        log('���������� �� '||upper(p_name)||':');
        log('����������� ����� ������  :'|| G_TIME(p_name).min_time);
        log('������������ ����� ������ :'|| G_TIME(p_name).max_time );
        v_avg_time:=  G_TIME(p_name).total_time/ G_TIME(p_name).total_call;
        log('������� ����� ������      :'||v_avg_time);

        log('����� ����� ������        :'|| G_TIME(p_name).total_time );
        log('����� ���-�� ��������     :'|| G_TIME(p_name).total_call );
      elsif  G_TIME.exists(p_name)
         and G_TIME(p_name).total_call > 0
         and trunc(G_TIME(p_name).total_call) <>  G_TIME(p_name).total_call
      then
        log('');
        log('������ �� '||upper(p_name)||':');
        log('���������� ���������  time_start �� ������������� ��������� time_end');
      elsif  not G_TIME.exists(p_name)  or G_TIME(p_name).total_call = 0 then
        log('');
        log('���������� �� '||upper(p_name)||' �� ���� ��������');
      else
       log('');
       log('�� '||upper(p_name)||'�����-�� �������� �����. ���������� � �������. total_call = '|| G_TIME(p_name).total_call);
      end if;

        if p_cliner_frag = 'Y' then  G_TIME(p_name).min_time:=   null;
                                     G_TIME(p_name).max_time:=   null;
                                     G_TIME(p_name).total_time:= (sysdate-sysdate) DAY TO SECOND;
                                     G_TIME(p_name).total_call:= 0;

        end if;

     end time_print;

-- time_end
--

--**************************����� ���������� �����***********************************
procedure find_form(p_form_name varchar2 default null, p_function_name varchar2 default null) is

    type list_menu_t is table of varchar2(32000) index by pls_integer;
    list_prompt list_menu_t;

    type par_menu_t is table of number index by pls_integer;
    par_menu par_menu_t;

    v_last_element number:=0;

    --����������� ������� �������� ���� (��� �� ������� ������� ����� ��������)
    procedure get_recursive_menu (p_menu_id number, p_list_prompt varchar2 default null)
    is
      --v_list_prompt varchar2(32000);
      --v_last_menu boolean:= true;
    begin

          v_last_element:= v_last_element + 1;
          par_menu(v_last_element):= p_menu_id;
          list_prompt(v_last_element):= p_list_prompt;

      --������ ����
      for i in (select fme.MENU_ID, fme.PROMPT
                from FND_MENU_ENTRIES_VL fme
                where fme.SUB_MENU_ID = p_menu_id)
      loop
        get_recursive_menu(i.MENU_ID, i.PROMPT||' - '||p_list_prompt);
      end loop;

      /*if v_last_menu then
          v_last_element:= v_last_element + 1;
          par_menu(v_last_element):= p_menu_id;
          list_prompt(v_last_element):= nvl(v_list_prompt, p_list_prompt);
      end if;*/
    end get_recursive_menu;

  begin

  --����� ����� � �������
  for i in (select  ff.FUNCTION_NAME||' ('|| ff.USER_FUNCTION_NAME||') - '||ff.DESCRIPTION function_descr
                   ,f.FORM_NAME||' ('||f.USER_FORM_NAME||') - '||f.DESCRIPTION form_descr
                   ,ff.FUNCTION_ID
            from  FND_FORM_FUNCTIONS_VL  ff
            inner join fnd_form_vl f on f.form_id = ff.FORM_ID
            where 1=1
            and xx_pnaumov_pkg.f_like(f.form_name, p_form_name) = 1
            and xx_pnaumov_pkg.f_like(ff.FUNCTION_NAME, p_function_name) = 1
            )
   loop
      log('--------- �����: '||i.form_descr||'--------------');
      log('---------- �������: '||i.function_descr||' -------------------');
        --����� ����
        for j in (select fme.MENU_ID, fme.SUB_MENU_ID, fme.PROMPT
                  from FND_MENU_ENTRIES_VL fme
                  inner join fnd_menus_vl fm on fme.MENU_ID = fm.menu_id
                  where fme.FUNCTION_ID = i.FUNCTION_ID
                  )
        loop
          get_recursive_menu(j.MENU_ID, j.PROMPT);
        end loop;

        --����� �����������
        for j in par_menu.FIRST..par_menu.LAST
        loop
           log('   ���������: '||list_prompt(j));
           print_list_responses( p_menu_id=> par_menu(j));
        end loop;
      log('');
    end loop;
 end find_form;

function to_number(p_char varchar2) return number is
  begin
    return fnd_number.canonical_to_number(regexp_substr(p_char, '[[:alnum:]|[:punct:]]+')); --������� ������������� � �����
  exception
    when others then return null; --���� �� �����, ����� ������
  end;


--**********************���������� ���������� ������������ ���������************************
procedure add_resp_to_conc (p_conc_name varchar2, p_pesp_name varchar2) is
    v_no_data_found_flag boolean:= true;
  begin

  --�������� ������������ ���������
  if not get_conc_parametrs(p_conc_name) then  raise_application_error(-20000, '������! ��� ����������� ������������ ���������.'); end if;

  --������� ����� ��������
  FOR rec IN
            (
            SELECT UNIQUE
              rg.request_group_name group_name
            , ap.application_name module_name
            , rg.DESCRIPTION rg_DESCRIPTION
            FROM fnd_responsibility_vl r
             inner join fnd_request_groups rg on r.REQUEST_GROUP_ID = rg.REQUEST_GROUP_ID
             inner join fnd_application_vl ap on rg.APPLICATION_ID = ap.APPLICATION_ID
            WHERE    1=1
            and (
                  exists(
                  select 1 from (
                  select trim(regexp_substr(regexp_substr(cc.str, '[^,]+', 1, level), '[[:print:]]+')) conc_name
                  from (SELECT p_pesp_name str from dual) cc
                  connect by instr(str, ',', 1, level-1 ) > 0 ) q
                  where upper(r.responsibility_name) like upper(conc_name)
                        )
                 )
             )
      LOOP
        v_no_data_found_flag:= false;
        --
        IF NOT fnd_program.program_in_group(G_SESSION_PAR.concurrent_name, G_SESSION_PAR.concurrent_appl_name, rec.group_name,rec.module_name)
        THEN
            fnd_program.add_to_group(G_SESSION_PAR.concurrent_name,G_SESSION_PAR.concurrent_appl_name, rec.group_name,rec.module_name);
            log('��������� ��������� � ������ �������� "' || rec.group_name ||'" ('||rec.rg_DESCRIPTION||')');
        else
            log('��������� ��� ���� ��������� � ������ �������� "' || rec.group_name||'" ('||rec.rg_DESCRIPTION||')');
        END IF;

      END LOOP;

     if v_no_data_found_flag  then
        log('������! ���������� �� �������');
        raise_application_error(-20000, '������! ���������� �� �������.');
     end if;

     commit;
  end add_resp_to_conc;

-- ��������� ���������� �������� ����� � ������ ��������� ���������� � OeBS (�. �����)
PROCEDURE add_resp_to_form( p_form    VARCHAR2      -- ��� �����, ����� �������� ������� � ������, ������� ���������� ����������
                            , p_resp  VARCHAR2      -- ��� ����������, ����� �������� ������� � ������, � ������ ���� ������� ����������� �����
                          )
is
    -- ���������� ������������ ����� ����� - ������� �������, �������� �� � �������� ��������
    c_normalization_form CONSTANT applsys.fnd_form.form_name%type := Upper( Trim( p_form ) );
    -- ���������� ������������ ����� ���������� - ������� �������, �������� �� � �������� ��������
    c_normalization_resp CONSTANT applsys.fnd_responsibility_tl.responsibility_name%type := Upper( Trim( p_resp ) );

    v_find                        NUMBER;   -- ��������� ����������

BEGIN
    -- ������� ������������ ����� ����������, ������ ��������� ���������� ��������� ������������ �������
    if( get_resp_parametrs( c_normalization_resp ) ) then
        -- ������� ������������ ����� �����, ������ ��������� ���������� ��������� ������������ �������
        if( get_form_parametrs( c_normalization_form ) ) then
            -- ����� ��� ��������� ���������� � �����???
            SELECT
                count( * ) cnt
            INTO
                v_find
            FROM
                applsys.fnd_menu_entries  fme
            WHERE
                1 = 1
                and fme.function_id = G_SESSION_PAR.function_id
                and fme.menu_id = G_SESSION_PAR.menu_id;

            if( v_find = 0 ) then  -- ������� ����� � ����������, �� ����� �� ��������� � �����������
                BEGIN
                    -- ����������� ������ ����
                    fnd_menu_entries_pkg.load_row( x_mode            => 'REPLACE'
                                                   , x_ent_sequence  => 999
                                                   , x_menu_name     => G_SESSION_PAR.menu_name
                                                   , x_sub_menu_name => NULL
                                                   , x_function_name => G_SESSION_PAR.function_name
                                                   , x_grant_flag    => 'Y'
                                                   , x_prompt        => substr( G_SESSION_PAR.form_name || ' ' || G_SESSION_PAR.form_description,  1, 60 )
                                                   , x_description   => substr( G_SESSION_PAR.form_name || ' ' || G_SESSION_PAR.form_description,  1, 240 )
                                                   , x_owner         => USER
                                                 );

                    commit;
                    log( '���������� ����� - ' || G_SESSION_PAR.form_name || ' - � ���������� - ' || G_SESSION_PAR.resp_name || ' - ����������� �������.' );
                EXCEPTION when others then
                    rollback;
                    raise;
                END;
            else -- ������� ����� � ����������, � ����� ��������� � �����������, ������ �� ������
                log( '����� ��� ��������� � ������ ����������' );
            end if;
        else
          raise_application_error(-20000, '������! ��� ����������� �����');
        end if;
    else
      raise_application_error(-20000, '������! ��� ����������� ����������');
    end if;
END add_resp_to_form;

--�������� ����� � �������
--����� ������ https://blogs.oracle.com/searchtech/entry/loading_documents_and_other_file
function load_file ( p_dir_name   VARCHAR2,
                      p_file_name  VARCHAR2
                      ) return number
 is
  l_bfile   BFILE;
  l_blob    BLOB;
  l_row_id  number:= null;
  l_dir_name varchar2(255);

  l_temp_dir_name varchar2(255):= 'XX_TEMP_DIR';
  l_create_temp_dir boolean:= false;

  --��������� ����������
  function get_directory(p_dir_name_f varchar2) return varchar2
   is
     v_return_dir_name all_directories.DIRECTORY_NAME%type;
     v_dir_path all_directories.DIRECTORY_PATH%type;
  begin
    select ad.DIRECTORY_NAME,   ad.DIRECTORY_PATH
    into v_return_dir_name, v_dir_path
    from all_directories ad
    where (ad.DIRECTORY_NAME = upper(p_dir_name_f)
        or ad.DIRECTORY_PATH = p_dir_name_f) --���� ���� �� �����, ���� �� ����. (������� ����� ����� ��� �� �������)
    and rownum = 1;--���������� ����� ���� ���������, ���� ������ ����������
    log('���������� '||v_return_dir_name||' ['||v_dir_path||'] �������.');
    return v_return_dir_name;
  exception
    when no_data_found then
       log('���������� '||p_dir_name_f||' �� �������!');
      begin
        --������� ������� ����������
        execute immediate 'CREATE OR REPLACE DIRECTORY '||l_temp_dir_name||' AS '''||p_dir_name_f||'''';
        log('������� ���������� '||l_temp_dir_name);
        l_create_temp_dir:= true;
        --��������
        return get_directory(p_dir_name_f);

      exception when others then raise_application_error(-20000, '������! ���������� �� �������!');
      end;
  end;
BEGIN


   l_dir_name:= get_directory(p_dir_name); --��������� ����������
   l_bfile := BFILENAME(l_dir_name, p_file_name); --��������� �������� �� ����
   IF (dbms_lob.fileexists(l_bfile) = 1) THEN
      --log('���� '||p_file_name||' ������!');
      EXECUTE IMMEDIATE 'INSERT INTO '||g_lob_table_name||'
                         VALUES ('||g_lob_table_name||'_S.NEXTVAL
                                ,substr(fnd_global.user_name,1, 255)
                                ,sysdate
                                ,:log_mark
                                ,EMPTY_BLOB()
                        )RETURN load_file, row_id INTO :l_blob, :l_row_id' using gb_log_mark, out l_blob, out l_row_id;
      --l_bfile := bfilename(dir_name, file_name);
      dbms_lob.fileopen( l_bfile, dbms_lob.FILE_READONLY );
      dbms_lob.loadfromfile( l_blob, l_bfile, dbms_lob.getlength(l_bfile) );
      dbms_lob.fileclose( l_bfile );
      COMMIT;
      log('���� '||p_file_name||' ������� �������� � '||g_lob_table_name||' row_id = '||l_row_id);

   ELSE
     log('���� '||p_file_name||' �� ������!');
     raise_application_error(-20000, '������! ���� �� ������!');
   END IF;

   --��������� �����
     if l_create_temp_dir then
       begin
         execute immediate 'DROP DIRECTORY '||l_temp_dir_name;
       exception
         when others then null; --��� ����� ��� ������� �� ����, ��� ��� �����
       end;
     end if;

     return l_row_id;

END;

--���������� �����
procedure add_role_to_user (p_role_name varchar2) is
    v_flag boolean:= false;
  begin
    FOR c IN (
              select wr.NAME role_code
              from wf_roles  wr
              where 1=1
              AND (f_like(wr.DISPLAY_NAME, p_role_name) = 1 or f_like(wr.NAME, p_role_name) = 1)
              and wr.ORIG_SYSTEM = 'UMX'
              and wr.STATUS = 'ACTIVE'
              and nvl(wr.EXPIRATION_DATE, sysdate) >= sysdate
                     )
          LOOP
            v_flag:=true;
            wf_local_synch.PropagateUserRole(p_user_name => gb_user_name,
                                             p_role_name => c.role_code,
                                             p_start_date => sysdate);
            log('�� ����� '||G_SESSION_PAR.user_name || ' ��������� ���� ' ||c.role_code||' -- '||p_role_name);
          END LOOP;
   
  if v_flag then 
     commit;
  else 
    log('���� '||p_role_name||' �� �������');
  end if;
  
  end add_role_to_user;
  
--����� �������� � �������� ����   
 
 procedure find_code (p_find_string      varchar2
                    , p_find_in_obj      boolean :=false
                    , p_source_where     varchar2:= ''                
                    , p_print_up_row     number:= 5
                    , p_print_down_row   number:= 5) is 


 TYPE t_cursor  IS REF CURSOR;
 c_cursor t_cursor; 
 v_row all_source%ROWTYPE; 
 v_sql varchar2(32000);
 

begin 


--base query
--todo ���������� �� �����
--todo ��������� ��������� �� ����
  v_sql:= 
'select *
from all_source src
where 1=1
and upper(src.TEXT) like ''%''||upper('''||p_find_string||''')||''%'''||chr(10);
 --
   if p_find_in_obj then 
     v_sql:=v_sql
||'and (src.OWNER, src.NAME, src.TYPE) in (select ad.OWNER, ad.name, ad.TYPE 
from all_dependencies ad 
where ad.REFERENCED_NAME like upper('''||p_find_string||'''))'||chr(10);
   end if;
 
   if p_source_where is not null then 
    v_sql:= v_sql||'and '||p_source_where||chr(10);
   end if;
  
 
   v_sql:= v_sql||'order by src.OWNER, src.TYPE, src.NAME, src.line';
       
   log('����� �������� �� �������:');
   log(v_sql);

  OPEN c_cursor FOR v_sql; --USING 'MANAGER';

  -- Fetch rows from result set one at a time:
  LOOP
    FETCH c_cursor INTO v_row;
    EXIT WHEN c_cursor%NOTFOUND;
    
     --print single rows
    if p_print_up_row = 0 and p_print_down_row = 0  then 
       log(v_row.OWNER||'.'||v_row.NAME||' - '||v_row.type||': '||v_row.line||' - '||ltrim(v_row.text));
    else 
      --print multi rows
      log('');
      log(v_row.OWNER||'.'||v_row.NAME||' - '||v_row.type);
      for j in (
          select * 
          from all_source src
          where 1=1
          and src.OWNER = v_row.OWNER
          and src.TYPE = v_row.type
          and src.NAME = v_row.NAME
          and src.line between v_row.line-p_print_up_row and v_row.line+p_print_down_row
          order by src.OWNER, src.TYPE, src.NAME, src.line          
          )
      loop
        log(j.line||' - '||ltrim(j.text));
      end loop;
      
    
    
    end if;
    
    
  END LOOP;


end;

--��������� ������������ ���������� �� SQL_ID
procedure print_sql_info (p_sql_id varchar2) is 
 
  
begin 
  --TODO loop v$sql
   log ('sql_id = '||p_sql_id);
   for i in (select * from gv$sql s where s.SQL_ID = p_sql_id)
   loop
       log ('child_number = '||i.child_number);
       log ('Get info from gv$active_session_history:');
       for j in (select * from gv$active_session_history ash
                 where ash.SQL_ID = i.sql_id                 
                 and ash.SQL_CHILD_NUMBER = i.child_number
                 order by ash.SAMPLE_TIME desc
                 fetch first 10 rows only)
        loop
          --TODO print info from ash
          log('    '||j.sample_id);          
        end loop;
        
        --TODO get xplan
        log ('Get xplan:');
        for j in (select * from table(dbms_xplan.display_cursor(i.sql_id, i.child_number)))
        loop
          log('    '||j.plan_table_output); 
        end loop;
        
    end loop;    

    --TODO get sql monitor
    declare 
      v_clob clob;
    begin 
    
      select dbms_sqltune.report_sql_monitor(p_sql_id)
      into v_clob
      from dual;
      
      log(v_clob);
    exception
      when others then 
         log('������ ��� ��������� report_sql_monitor: '||SQLERRM);
    end;
        
         
end print_sql_info;  


--����� SQL �������
procedure find_sql (p_find_text varchar2, p_get_sql_info varchar2 default 'N') is 
  begin 
    for i in (select distinct /*pnaumov_not_find*/ s.sql_id
                from gv$sql s
               where 1=1
                 and upper(s.sql_fulltext) like upper('%'||p_find_text||'%')
                 and s.sql_fulltext not like upper('%/*pnaumov_not_find*/%')
              )
    loop
      declare 
        v_sql_test_clob clob;
      begin 
        log('***********'||i.sql_id||'**********');
        
        select s.sql_fulltext
        into v_sql_test_clob
        from gv$sql s
        where s.sql_id = i.sql_id
        and rownum = 1;
        log(v_sql_test_clob);
        
        if p_get_sql_info = 'Y' then 
          log('*********SQL INFO:***********');
          print_sql_info(i.sql_id);
          log('*********/SQL INFO***********');
        end if;
      end;
    end loop;
    
  /*select sh.SQL_ID, sh.MODULE, sh.ACTION, count(*) cnt
  from gv$active_session_history  sh
  where 1=1
  AND sh.client_id like 'PNAUMOV1'
  AND sh.MODULE LIKE '%:cp:%SN976%'
  and sh.sql_id is not null
  group by sh.SQL_ID, sh.MODULE, sh.ACTION
  order by cnt desc  */
    
  end;

--********************************************************************************************************
BEGIN
    g_tbl_exists:=0;
    gb_rest_name:='��������� ���������';
    gb_user_name:='PNAUMOV1'; --��� ������������

    --��� ��������
    G_SESSION_PAR.instans_name:= sys_context('USERENV','INSTANCE_NAME');

    --������� ���������� ������ ������������ ���������
    if fnd_global.USER_NAME is not null then set_username(p_username => fnd_global.USER_NAME); end if;

    --�������� ������
    create_lob_table;
    create_log_table;

END XX_PNAUMOV_PKG;
/
SHOW ERRORS
