CREATE OR REPLACE PACKAGE APPS.XX_PNAUMOV_PKG authid definer IS

  ----служебная Функция лайк, с добавлением %% и без учёта регистра
function f_like(f_test varchar2, f_find_test varchar2)  return number;


gb_rest_name varchar2(200); --при инициализации полномочие по умолчанию
gb_log_mark varchar2(100):= NULL; --пользовательская метка для лог таблиц
gb_user_name  fnd_user.user_name%type;

--Сеттер для лог марка
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

 --Инициализация OEBS пользователя в сессии
procedure initialize (p_name_resp varchar2:= gb_rest_name,  p_mo_mode varchar2 default 'M');

 --Вывод лога
  procedure log(p_msg varchar2 default null
              , p_type_flag varchar2 default null
              , p_new_line varchar2 default 'Y'
              );
  procedure log(p_mess clob);

 --Задание профиля на пользователя
 procedure set_profile (p_profile_user_name fnd_profile_options_tl.profile_option_name%type
                       ,p_value varchar2);

 --Вывод сообщения в специальную таблицу. Если таблицы не существует - создаём её.
 procedure insert_log_table (pr_message varchar2, p_log_mark varchar2 default null);

 --Создание пользователя
 PROCEDURE create_user(p_user_name varchar2
                     , p_user_pass varchar2 default 'Olololo1'
                     , p_email varchar2 default null);
--Поиск канкарентов
PROCEDURE find_concurrent (pr_conc_name varchar2:=NULL
                         , pr_conc_descr varchar2:= NULL
                         , pr_find_flag varchar2:='N' 
                         , p_print_last_reqs number:= 0
                         , p_print_parameters varchar2:='N' 
                         , p_print_fndload_cmd varchar2:='N' 
                          );

 --Убийство сессий, удерживающих разработку
procedure find_block_session (p_obj_name varchar2, p_kill_session varchar2 default 'N');

 --Получение Набора значений в зависимости от типа
 procedure find_value_set (pr_value_set_name varchar2:= NULL
                         , p_use_conc varchar2:= NULL
                         , p_find_flag varchar2:= NULL
                          );

 --Нахождение и выделения русских символов из строки
 PROCEDURE find_rus_chars (pr_string varchar2);

  --Процедура получения значений профиля
 PROCEDURE find_profile(p_profile_name varchar2);

--Процедура поиска объекта БД
procedure find_object(p_object_name varchar2
                    , p_table_size varchar2 default 'N' --определение размера
                    , p_dependencies varchar2 default 'N'); --поиск связанных объектов;
--Задание пользователя для работы с пакетом
procedure set_username(p_username varchar2);

--Процедура запуска параллельной программы Экспорт персонализаций. Результата в любых полномочиях ОЕБС - Вид - Запросы - Найти
procedure export_pers (p_pers_name varchar2, p_level varchar2 default 'A');

--Добавление полномочий пользователю
procedure add_resp_to_user (p_pesp_name varchar2, p_user_name varchar2 default null);

--Добавление полномочий параллельной программе
procedure add_resp_to_conc (p_conc_name varchar2, p_pesp_name varchar2);

--Включение/выключение диагностического профиля
procedure on_diag_profile(p_result_into_table varchar2 default 'N');
procedure off_diag_profile(p_result_into_table varchar2 default 'N');

--Процедуры анализа времени работ кусков кода
procedure time_start (p_name varchar2);
procedure time_end   (p_name varchar2);
procedure time_print (p_name varchar2, p_cliner_frag in varchar2 default 'Y');

--Поиск полномочий формы
procedure find_form(p_form_name varchar2 default null, p_function_name varchar2 default null);

function to_number(p_char varchar2) return number;

-- Процедура добавления заданной формы в корень указанных полномочий в OeBS
PROCEDURE add_resp_to_form( p_form    VARCHAR2      -- Имя формы, можно частично строкой с маской, которую необходимо установить
                            , p_resp  VARCHAR2      -- Имя полномочий, можно частично строкой с маской, в корень меню которых добавляется форма
                          );

--Загрузка файла с сервера в базу
function load_file ( p_dir_name   VARCHAR2,
                      p_file_name  VARCHAR2
                      ) return number;

--Назначение ролей
procedure add_role_to_user (p_role_name varchar2);

--Поиск объектов в исходной коде   
 procedure find_code (p_find_string      varchar2 --искомая строка
                    , p_find_in_obj      boolean :=false --искать в объектах БД (быстрее)
                    , p_source_where     varchar2:= '' --доп условия выбора (динический sql)                 
                    , p_print_up_row     number:= 5 --Выводить от найдено строки строк выше
                    , p_print_down_row   number:= 5); --выводить от найденой строки строк ниже
                    
--Получение всевозможной информации по SQL_ID
procedure print_sql_info (p_sql_id varchar2);         

--Поиск SQL запроса
procedure find_sql (p_find_text varchar2, p_get_sql_info varchar2 default 'N');           
                    
END XX_PNAUMOV_PKG;
/
CREATE OR REPLACE PACKAGE BODY APPS.XX_PNAUMOV_PKG IS

  g_log_table_name varchar2(255):= upper('xx_pnaumov_TBL');
  g_lob_table_name varchar2(255):= upper('xx_pnaumov_LOB_TBL');

  g_log_start_value number; --метка включения диагностического профиля
  g_dbms_profile_run_num number; --номер профилирования
  g_tbl_exists number; --существование таблицы xx_pnaumov_TBL

  --v_count number; --счетчик (юзай кто хочешь)

  --Диагностические профиля
  v_profname_aflog_enbl fnd_profile_options_tl.user_profile_option_name%type:= 'БОП: включен журнал отладки';
  v_profname_aflog_level fnd_profile_options_tl.user_profile_option_name%type:= 'БОП: уровень журнала отладки';
  v_eam_debug_name fnd_profile_options_tl.user_profile_option_name%type:= 'УАП: параметр профиля отладки';
  -- Профиля защиты
  v_profname_ou   fnd_profile_options_tl.user_profile_option_name%type:= 'НО: профиль защиты';
  v_profname_org  fnd_profile_options_tl.user_profile_option_name%type:= 'ПЕР: профиль защиты';
  v_profname_book fnd_profile_options_tl.user_profile_option_name%type:= 'ОС: профиль защиты';

  --g_db_version constant number:= ; --Определения версионности БД (из-за этого меняется некоторый функционал)



  -- Глобальные параметры сессии (служебная информация)
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


  --для работы временных меток
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

  --Сеттер для лог марка
  procedure set_log_mark (p_log_mark varchar2) is 
    begin 
      gb_log_mark:= p_log_mark; --пользовательская метка для лог таблиц
    end;

--получения параметров  пользователя (служебная процедура)
function get_user_parametrs(p_username varchar2) return boolean is
  type list_user_name is table of varchar2(100) index by pls_integer;
  type list_user_id is table of number index by pls_integer;
    c_user_name list_user_name;
    c_full_name list_user_name;
    c_user_id   list_user_id;

  begin

    --Поиск по user_name
      select u.user_name, u.user_id
      bulk collect into c_user_name, c_user_id
      from fnd_user u
      where upper(u.user_name) like upper(p_username)
      and nvl(u.end_date, sysdate) >= sysdate;

    --если найдено большее одного пользователя, выводим список
     if c_user_name.count > 1 then
       log('Ошибка! Найдено более одного активного пользователя:');
       for i in 1..c_user_name.count loop log(c_user_name(i)); end loop;
       raise_application_error(-20000, 'Ошибка! Найдено более одного активного пользователя. Смотрите лог...');
      end if;

    --если не найдено, ищем в полном имени пользователей
     if  c_user_name.count = 0  then

       select fu.user_name, pf.FULL_NAME, fu.user_id
       bulk collect into c_user_name, c_full_name, c_user_id
       from PER_PEOPLE_F pf
       inner join fnd_user fu on fu.employee_id = pf.PERSON_ID
       where 1=1
       and upper(pf.FULL_NAME) LIKE (upper(p_username))
       and pf.EFFECTIVE_END_DATE >= sysdate
       and nvl(fu.end_date, sysdate)>= sysdate;
    --если пользователя не найдено, ошибка
       if c_user_name.count = 0 then log('Ошибка! Указанный пользователь не найден!'); raise_application_error(-20000, 'Ошибка! Указанный пользователь не найден!'); end if;
    --если пользователей больше 1 одного выводим список
       if  c_user_name.count > 1 then
       log('Ошибка! Найдено более одного активного пользователя:');
       for i in 1..c_full_name.count loop log(c_full_name(i)||' - '||c_user_name(i)); end loop;
       raise_application_error(-20000, 'Ошибка! Найдено более одного активного пользователя. Смотрите лог...');
       end if;
     end if;

    --Если выбран один пользователей присваиваем его гл. переменной  gb_user_name
       if c_user_name.count = 1 then
         log('Найден пользователь '|| c_user_name(1));
         G_SESSION_PAR.user_name:= c_user_name(1);
         G_SESSION_PAR.user_id:= c_user_id(1);
       end if;
    return true;


  end get_user_parametrs;

--получение параметров  полномочия
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


        log('Полномочия "'||G_SESSION_PAR.resp_name||'" найдены.');

        BEGIN
            SELECT mn.menu_name
            INTO G_SESSION_PAR.menu_name
            FROM fnd_menus mn
            WHERE mn.menu_id = G_SESSION_PAR.menu_id;

            log( 'Меню найдено: ' || G_SESSION_PAR.menu_name );
        EXCEPTION
            WHEN no_data_found THEN
                log( 'Ошибка определения имени меню!' );
            return FALSE;
            WHEN too_many_rows THEN
                log( 'Ошибка у меню несколько имён' );
            return FALSE;
        END;

        return true;
    exception
      WHEN no_data_found THEN log('Ошибка при получении параметров полномочий!');
                              log('Полномочия '||p_resp_name||' не найдены!!!');
                              return false;
      WHEN too_many_rows THEN log('Ошибка при получении параметров полномочий!');
                              log('По запрошенному параметру найдено слишком много полномочий:');
          FOR i IN (SELECT r.responsibility_name, a.APPLICATION_SHORT_NAME
                    FROM fnd_responsibility_vl r
                    inner join fnd_application a on r.APPLICATION_ID = a.APPLICATION_ID
                    WHERE 1=1
                       and nvl(r.END_DATE, sysdate+1)> sysdate
                       AND f_like(r.responsibility_name, v_resp_like_name) = 1
                    order by a.APPLICATION_SHORT_NAME
                    )
          LOOP
            log(i.responsibility_name ||' модуль ('||i.application_short_name||')');
          END LOOP;
          return false;

   end get_resp_parametrs;

--Получение параметров параллельной программы
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

     log('Параллельная программа '||G_SESSION_PAR.user_name||' ('||G_SESSION_PAR.concurrent_name||') найдена.');
     return true;
   exception
     when no_data_found then
         log('Ошибка! Параллельная программа '||p_conc_name||' не найдена!!!');
         return false;
     when too_many_rows then
         log('Ошибка! По запрошенному параметру найдено слишком много параллельных программ:');
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

   -- получение параметров формы
    -- переделано из get_resp_parametrs, см. выше
    -- проверяем корректность формы
    FUNCTION get_form_parametrs( p_form_name VARCHAR2 -- Имя формы для поиска, можно частично строкой с маской, которую необходимо установить
                               )
    return boolean -- TRUE - функция отработала успешно, FALSE - были ошибки в работе функции
    is
        -- Найденное имя формы
        v_form_like_name applsys.fnd_form.form_name%type;

    BEGIN
        -- Остатки от переноса на тот случай, если выдернут данную функцию из процедуры на верхний уровень
        v_form_like_name := Upper( p_form_name );

        -- Извлекаем данные о форме
        SELECT
            r.form_id           -- Идентификатор формы
            , r.form_name       -- Название формы
            , r.description     -- Описание формы
        INTO
            G_SESSION_PAR.form_id
            , G_SESSION_PAR.form_name
            , G_SESSION_PAR.form_description
        FROM
            fnd_form_vl r
        WHERE
            1 = 1
            and f_like( r.form_name, v_form_like_name ) = 1;

        log( 'Форма '||G_SESSION_PAR.form_name||' с идентификатором "' || G_SESSION_PAR.form_id || '" найдена.' );

        -- Однако в API используется привязанная к форме функция - ищем её
        BEGIN
            SELECT
                fu.function_id      -- Идентификатор функции
                , fu.function_name  -- Имя функции (Как ни странно, в API далее используется имя, а не идентификатор)
            INTO
                G_SESSION_PAR.function_id
                , G_SESSION_PAR.function_name
            FROM
                applsys.fnd_form_functions fu
            WHERE
                1 = 1
                and fu.form_id = G_SESSION_PAR.form_id;

            log( 'К форме привязана функция '||G_SESSION_PAR.function_name||' с идентификатором: ' || G_SESSION_PAR.function_id );
        EXCEPTION
            WHEN no_data_found THEN
                log( 'Ошибка к форме не привязана никакая функция!' );
                return FALSE;
            WHEN too_many_rows THEN
                log( 'Ошибка к форме привязано несколько функций!' );
                return FALSE;
        END;

        return TRUE;
    EXCEPTION
        WHEN no_data_found THEN
            log( 'Ошибка при получении параметров формы!' );
            log( 'Форма ' || p_form_name || ' не найдена!!!' );
            return FALSE;
        WHEN too_many_rows THEN
            log( 'Ошибка при получении параметров формы!' );
            log( 'По запрошенному найдено слишком много форм:' );
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


--Процедура вывода полномочий с проверкой на пользователя
   procedure print_list_responses(p_conc_program_id number default null, p_menu_id number default null)
    is
      v_user_id number;
   begin

     begin
       select u.user_id into v_user_id from fnd_user u where u.user_name = xx_pnaumov_pkg.gb_user_name;
     exception when others then log('Ошибка при определении пользователя '||xx_pnaumov_pkg.gb_user_name||': '||SQLERRM);
     end;

     --Поиск полномочий
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
                    )users --Полномочия пользователя
                  FROM (
                  --Поиск полномочий параллельной программы
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
                  and nvl(rr.END_DATE, sysdate) >= sysdate --Исключаем просроченные полномочия
                  --Поиск полномочий меню
                  union all
                  select rr.RESPONSIBILITY_NAME, rr.RESPONSIBILITY_ID
                  FROM Fnd_Responsibility_Vl rr
                  where 1=1
                  and rr.MENU_ID = p_menu_id
                  and nvl(rr.END_DATE, sysdate) >= sysdate --Исключаем просроченные полномочия
                  )  q
                  order by q.RESPONSIBILITY_NAME)
      loop
        if i.users IS NULL then       log('       |     '||i.resp_name);
        else                          log(i.users||'    |     '||i.resp_name);
        end if;
      end loop;

   end;


--Процедура вывода лога
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
      --вывод отладочной информации время, имя объекта из которого вызвано сообщение, и строка
      --неработающая логика. Для корректной работы требуется использовать пакет 12 базы UTL_CALL_STACK.CONCATENATE_SUBPROGRAM (UTL_CALL_STACK.SUBPROGRAM (1))
          then put(to_char(sysdate, 'hh24:mi:ss')||'/'||$$plsql_unit||'/'||$$plsql_line||' '||p_msg, p_new_line);
         when p_type_flag = 'T'
          then put(to_char(sysdate, 'hh24:mi:ss')||' '||p_msg, p_new_line);
         else put(p_msg, p_new_line);
    end case;
  end log;

--печать clob
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


--служебная Функция лайк, с добавлением %% и без учёта регистра 1 - равны 0 - не равны
  function f_like(f_test varchar2, f_find_test varchar2)  return number is
    begin
      --Если искомая строка НУЛЛ, то тогда автоматически будем считать его равным (условие необязательных параметров)
        if  f_find_test is NULL THEN RETURN 1; END IF;
      --Если строка НУЛЛ а искомая строка не НУЛЛ, то автоматическое неравенство (условие пустых описаний)
        if  f_test IS NULL AND f_find_test IS NOT NULL THEN RETURN 0; END IF;

        if replace(upper(f_test), 'Ё', 'Е') like replace(upper(f_find_test), 'Ё', 'Е') then RETURN 1;
        ELSE RETURN 0;
        END IF;
    end f_like;

--служебная функция создания таблицы
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
         log('Таблица '||p_table_name||' создана');

         EXECUTE IMMEDIATE
          'create sequence '||p_table_name||'_S';
          log('Последовательность '||p_table_name||'_S создана');
    end;
  end create_table;

--служебная функция Создание лог таблицы
procedure create_log_table is
 begin
   create_table(g_log_table_name, 'MESSAGE_TEXT varchar2(4000), CALL_STACK varchar2(4000)');
 end;


--служебная функция Создание LOB таблицы
procedure create_lob_table is
 begin
   create_table(g_lob_table_name, 'LOAD_FILE BLOB');
 end;


--**********************Задание профиля на пользователя****************************
procedure set_profile (p_profile_user_name fnd_profile_options_tl.profile_option_name%type
                      ,p_value varchar2
                       )
       is
       v_profile_name fnd_profile_options_tl.profile_option_name%type;
       begin


       --Поиск профиля
        begin
         select profile_option_name
         into v_profile_name
         from fnd_profile_options_tl po --Поиск по имени (и русский и буржуйский)
         where po.user_profile_option_name =   p_profile_user_name;
        exception when no_data_found then
            begin
              select profile_option_name
              into v_profile_name
              from fnd_profile_options_vl po --Поиск под коду
              where po.profile_option_name =   p_profile_user_name;
            exception when no_data_found then
              log('Профиль '''||p_profile_user_name||''' не найден');
              raise_application_error(-20000, 'Профиль не найден');
            end;
        end;

       --Поиск пользователя
       if not(get_user_parametrs(gb_user_name)) then raise_application_error(-20000, 'Пользователь не найден'); end if;

       --Задание значения
       if  fnd_profile.SAVE(X_NAME => v_profile_name,
                               X_VALUE => p_value,
                               X_LEVEL_NAME => 'USER',
                               X_LEVEL_VALUE =>  G_SESSION_PAR.user_id
                               )  then
             log('Профилю '''||v_profile_name||''' задано значение '||p_value);
             commit;
          else
             log('Ошибки при включении профиля '''||v_profile_name||'''');
             log(Fnd_Message.GET);
          end if;

     end;

 --Вывод сообщения в специальную таблицу. Если таблицы не существует - создаём её.
    procedure insert_log_table (pr_message varchar2, p_log_mark varchar2 default null) is
      PRAGMA AUTONOMOUS_TRANSACTION; --Используем автономные транзакции
    BEGIN

       --На Проде не пишем логов, чтобы не засирать прод
      if nvl(G_SESSION_PAR.instans_name, 'XXX') != 'PROD' then

         EXECUTE IMMEDIATE  --Используется для того чтобы  пакет компилился без ошибок,если таблица не существует.
         'INSERT INTO '||g_log_table_name||'
         VALUES ('||g_log_table_name||'_S.NEXTVAL, substr(fnd_global.user_name,1, 255), sysdate, :log_mark, :message, DBMS_UTILITY.format_call_stack)'
         USING nvl(p_log_mark, xx_pnaumov_pkg.gb_log_mark), substr(pr_message,1, 4000) ;
        COMMIT;

      end if;
     EXCEPTION
      WHEN others then log('Ошибка работы процедуры xx_pnaumov_PKG.insert_log_table!!! '||SQLERRM);
     null;

    end insert_log_table;

--***********************Процедура инициализации пользователя*******************************
    procedure initialize (p_name_resp varchar2:= gb_rest_name, p_mo_mode varchar2 default 'M') IS
       pragma autonomous_transaction;
    BEGIN

        if not(get_user_parametrs(gb_user_name)) then raise_application_error(-20000, 'Пользователь не найден'); end if;

        if get_resp_parametrs(p_name_resp) then
           fnd_global.apps_initialize( user_id => G_SESSION_PAR.user_id
                                     , resp_id => G_SESSION_PAR.resp_id
                                     , resp_appl_id => G_SESSION_PAR.appl_id);
           
           log('Инициализация проведена успешно!');
        else
          log('Ошибка инициализации!!! Проверьте входящие параметры.');
          raise_application_error(-20000, 'Ошибка инициализации!!! Проверьте входящие параметры.');
        end if;
        
       

        --Инициализация мультиорганизации (Упадёт в R11)
        $if DBMS_DB_VERSION.VERSION > 11 $then
           mo_global.init(p_mo_mode, null);
           CEP_STANDARD.init_security(); --полный доступ к данным CE
        $end
        
        
        COMMIT; 
    END initialize;


--************************************Создание пользователя****************************************************
-- Created by Nikolay Lysyuk (05/05/2010)
-- Скрипт добавления пользователя в систему OeBS
-- Не требует смены пароля.
-- Прописывает список полномочий.
-- Устанавливает пользователю работника, заказчика и покупателя.
-- Устанавливает работнику в ОГП на форме "Лица" Организацию и ЦФО,
        PROCEDURE create_user(p_user_name varchar2 
                            , p_user_pass varchar2 default 'Olololo1'
                            , p_email varchar2 default null) IS
          --l_USER_NAME                      fnd_user.user_name%type              := gb_user_name;           -- Логин
          l_EMPLOYEE_NUMBER                constant per_people_f.EMPLOYEE_NUMBER%type    := 'ИЦ18228';              -- Табельный номер
          --l_EMAIL                           varchar2(240)                        := 'pnaumov@phosagro.ru';  -- Почта
          l_DESC                           constant varchar2(240)                        := 'Боевой программер';    -- Комментарий )
          l_PRES_ORG                       constant per_people_f.ATTRIBUTE1%type         := '10';                   -- Организация
          l_PERS_CFO                       constant per_people_f.ATTRIBUTE2%type         := '0000-00';              -- ЦФО
          l_USER_SESSION_TIMEOUT           constant number(6)                            := 10;                     -- Время активной сессии в часах
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
          --Список всех УНП организаций
          CURSOR cur_org_list IS
          select orgn_code from sy_orgn_mst where delete_mark = 0 order by orgn_code;
          -- Извлекаем ID юзверя, если такой уже есть
          CURSOR Cur_user (c_user_name fnd_user.user_name%type) IS
          SELECT user_id FROM fnd_user WHERE user_name = c_user_name;
          --
          -- Извлекаем ID работника, если такой существует
          CURSOR Cur_person (c_employee_number per_people_f.EMPLOYEE_NUMBER%type) IS
          select rowid, person_id, full_name from per_people_f where employee_number = c_employee_number
                                                                 and sysdate between effective_start_date
                                                                                 and effective_end_date;
          -- Проверяем не установлен ли уже такой покупатель
          CURSOR Cur_agent (c_person_id per_people_f.PERSON_ID%type) IS
          select agent_name from po_agents_v where agent_id = c_person_id;
          --
          -- Выбираем параметры для настройки покупателя на работника
          CURSOR Cur_agent_emp (c_employee_number per_people_f.EMPLOYEE_NUMBER%type) IS
          select employee_id, location_id from hr_employees_current_v where employee_num = c_employee_number;
          --
          -- Извлекаем ID заказчика, если такой существует
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
          , resp_id => 20420  -- Системный администратор
          , resp_appl_id => 1 -- Системное администрирование
          );
          --
          SAVEPOINT thx_point;
          -- Поиск табельного номера
          OPEN  Cur_person (l_EMPLOYEE_NUMBER);
          FETCH Cur_person INTO l_PERS_ROWID,  l_EMPLOYEE_ID, l_EMPLOYEE_FULL_NAME;
          IF (Cur_person % FOUND) THEN
            log('Найден работник "'||l_EMPLOYEE_FULL_NAME||'" с табельным номером '||l_EMPLOYEE_NUMBER);
            --
            -- Установка работнику Организации и ЦФО
            begin
              update per_people_f
                set ATTRIBUTE1 = l_PRES_ORG
                  , ATTRIBUTE2 = l_PERS_CFO
                where rowid = l_PERS_ROWID;
              log('Работнику "'||l_EMPLOYEE_FULL_NAME||'" в ОГП формы "Лица" установлена организация "'||l_PRES_ORG||'" и ЦФО "'||l_PERS_CFO||'"');
            exception
              when others then
                log('Ошибка обновления формы "Лица": Работнику "'||l_EMPLOYEE_FULL_NAME||'" в ОГП формы "Лица" НЕ установлена организация "'||l_PRES_ORG||'" и ЦФО "'||l_PERS_CFO||'"');
                log(sqlerrm);
            end;
            --
            -- Установка покупателя на работника
            OPEN  Cur_agent (l_EMPLOYEE_ID);
            FETCH Cur_agent INTO l_AGENT_NAME;
            IF (Cur_agent % FOUND) THEN
              CLOSE Cur_agent;
              log('Работнику "'||l_EMPLOYEE_FULL_NAME||'" найден покупатель "'||l_AGENT_NAME||'"');
            ELSIF (Cur_agent % NOTFOUND) THEN
              CLOSE Cur_agent;
        --      log('Работнику '||l_EMPLOYEE_FULL_NAME||' не установлен покупатель');
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
                , X_Location_ID         => null--l_AGENT_LOCATION_ID -- Получение товара (Location_Code)
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
                  then log('Работнику "'||l_EMPLOYEE_FULL_NAME||'" установлен покупатель "'||l_EMPLOYEE_FULL_NAME||'"');
                  else log('Ошибка установки работнику "'||l_EMPLOYEE_FULL_NAME||'" покупателя "'||l_EMPLOYEE_FULL_NAME||'"');
                end if;
              ELSIF (Cur_agent_emp % NOTFOUND) THEN
                log('Работнику "'||l_EMPLOYEE_FULL_NAME||'" не найден соответствующий ему покупатель');
              END IF;
              CLOSE Cur_agent_emp;
            END IF;
            --
            -- Поиск заказчика по работнику
            OPEN  Cur_customer (l_EMPLOYEE_ID);
            FETCH Cur_customer INTO l_CUSTOMER_ID, l_CUSTOMER_NAME;
            IF (Cur_customer % FOUND) THEN
              log('Работнику '||l_EMPLOYEE_FULL_NAME||' найден заказчик "'||l_CUSTOMER_NAME||'"');
            ELSIF (Cur_customer % NOTFOUND) THEN
              log('По данному работнику заказчик не найден');
            END IF;
            CLOSE Cur_customer;
            --
          ELSIF (Cur_person % NOTFOUND) THEN
            log('Работник с табельным номером '||v_user_name||' и актуальным состоянием не найден');
          END IF;
          CLOSE Cur_person;
          --
          -- Ищем не существует ли уже такой логин
          OPEN  Cur_user (v_user_name);
          FETCH Cur_user INTO l_USER_ID;
          IF (Cur_user % FOUND) THEN
            CLOSE Cur_user;
            log('Пользователь '||v_user_name||' уже СУЩЕСТВУЕТ. Задаём пароль '||p_user_pass);
            fnd_user_pkg.UpdateUser(x_user_name => v_user_name,x_owner => NULL, x_unencrypted_password => p_user_pass);


          ELSIF (Cur_user % NOTFOUND) THEN
            CLOSE Cur_user;
            log('Пользователь '||v_user_name||' не существует');
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
              -- Проверяем как создался пользователь
              OPEN  Cur_user (v_user_name);
              FETCH Cur_user INTO l_USER_ID;
              IF (Cur_user % FOUND) THEN
                CLOSE Cur_user;
                commit; -- Сохраняем вновь созданного пользователя
                log('Пользователь '||v_user_name||' СОЗДАН');
                gb_user_name:= v_user_name;
              ELSIF (Cur_user % NOTFOUND) THEN
                CLOSE Cur_user;
                log('Ошибка при создании пользователя: ');
              END IF;
              --
            exception
              when others then
                log(sqlerrm);
            end;
          END IF;
          --
          -- Установка настроек профилей пользователя
          -- Установка времени активной сессии (в минутах)
          IF Fnd_Profile.save (
             x_name => 'ICX_SESSION_TIMEOUT'
            ,x_value => to_char(60*l_USER_SESSION_TIMEOUT)
            ,x_level_name => 'USER'
            ,x_level_value => l_user_id
          )
          THEN log('Время сессии для пользователя '||v_user_name||' установлено: '||to_char(l_USER_SESSION_TIMEOUT)||' часов');
          ELSE log('Невозможно переопределить время активной сессии для пользователя '||v_user_name);
          END IF;
          -- Установка настроек профилей пользователя
          -- This profile option defines the maximum connection time for a connection
          IF Fnd_Profile.save (
             x_name => 'ICX_LIMIT_TIME'
            ,x_value => l_USER_SESSION_TIMEOUT
            ,x_level_name => 'USER'
            ,x_level_value => l_user_id
          )
          THEN log('Лимит времени сессии для пользователя '||v_user_name||' установлен: '||to_char(l_USER_SESSION_TIMEOUT)||' часов');
          ELSE log('Невозможно переопределить время активной сессии для пользователя '||v_user_name);
          END IF;

          -- Не нужно вводить пароль apps при заходе в диагностику
          IF Fnd_Profile.save (
             x_name => 'DIAGNOSTICS'
            ,x_value => 'Y'
            ,x_level_name => 'USER'
            ,x_level_value => l_user_id
          )
          THEN log('Установлен режим диагностики для пользователя '||v_user_name);
          ELSE log('Невозможно установить режим диагностики для пользователя '||v_user_name);
          END IF;
          --
          -- Добавление полномочий
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
--'Администратор издателя XML',
--'Глобальный суперпользователь-руководитель СУПЕР',
'Диспетчер сигналов',
'Разработчик приложений',
--'Руководитель контроля качества',
--'Системное администрирование УНП',
'Системный администратор',
--'Составитель формул',
--'Суперпользователь-руководитель СУПЕР (Россия)',
--'Администратор Oracle Daily Business Intelligence',
--'Oracle Business Intelligence Administrator',
--'Суперпользователь Oracle Sourcing',
'Администратор функций',
--'Администратор издателя XML',
--'Диспетчер сигналов',
--'Разработчик приложений',
--'Системный администратор',
--'Диспетчер Дебиторов',
--'Диспетчер кредиторов',
--'Суперпользователь Казначейства',
--'УК: Финансист Казначейства',
'Руководство по инструментам OA Framework',
'Публикатор XML: администратор',
'Администратор потоков операций'
,'Роль: СУПЕР Администратор БАРС'
,'Роль: СУПЕР Главная книга'
,'Роль: СУПЕР Диспетчер основных средств'
--,'Роль: СУПЕР Администратор BI'
--,'Роль: СУПЕР Разработчик отчетов BI'
,'Роль: СУПЕР Диспетчер Кредиторов'
,'Роль: СУПЕР Закупки'
--,'Роль: СУПЕР Руководитель юридического лица'
,'Роль: СУПЕР Диспетчер Дебиторов'
--,'Роль: СУПЕР Менеджер по налогам'
,'Роль: СУПЕР Учета затрат по проектам'
,'Роль: СУПЕР Выбор источника'
,'Роль: СУПЕР ЭТП'
,'Роль: СУПЕР Запасы'
,'Роль: СУПЕР Управление активами предприятия'
,'Роль: СУПЕР Финансы УНП'
,'Роль: СУПЕР Управление непрерывным производством'
,'Роль: СУПЕР Управления заказами'
,'Роль: СУПЕР Незавершенное производство'
--,'Роль: СУПЕР Управление утверждениями (администратор)'
,'Роль: СУПЕР Нормативно-справочная информация'
--,'Роль: СУПЕР Сопровождение системы электронного архива Саперион'
--,'Роль: СУПЕР ЭДО (LD)'
--,'Роль: СУПЕР Borlas Cash Management'
,'Роль: СУПЕР Администратор договоров (Борлас)'
,'Роль: Поддержка пользователей (ПП)'
,'Специалист по ведению договоров'
,'Роль: Руководитель Казначейства'
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
                 log('Не удалось найти полномочие: '||sqlerrm);
            END;
          END IF;

--Назначение ролей
add_role_to_user('Защита набора значений ГП - все права');


          --
          -- Назначений УНП организаций для пользователя
          declare
            cur_user_exist   number(1) := 0;

            -- Проверка на установку в уже установленное полномочие
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

          -- Назначения профиля защиты Организации для пользователя (Только Апатит like 'К%')
          -- Чтобы иметь доступ к формулам в модуле УНП
          -- Подправил, подкрутил. Теперь выцепляем всё УНП организации и назначаем из юзера
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

       --Назначаем нужные профили
       set_profile('БОП: включен журнал отладки', 'Y'); --профиль диагностики
       set_profile('Настройка веб-определений', 'Y');  --для персональной настройки веб. страниц
       set_profile('БОП: диагностика', 'Y'); --для развернутых ошибок на веб. страницах

       --Utilities:Diagnostics: Yes


       set_profile( v_profname_ou, '0' );     -- Профиль защиты SetupBuisnessGroup, с типом "без защиты" - доступ ко всему
       set_profile( v_profname_org, '0' );    -- Профиль защиты SetupBuisnessGroup, с типом "без защиты" - доступ ко всему
       set_profile( v_profname_book, '7932' );   -- Профиль защиты SetupBuisnessGroup, с типом "без защиты" - доступ ко всему
       
        commit; -- Cохраняемся =)

        EXCEPTION
        WHEN OTHERS THEN
          log('Ошибка:');
          log(sqlerrm);
          ROLLBACK TO SAVEPOINT thx_point;
        END create_user;

--****************************Поиск разработки и её полномочий*****************************************************
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
     log('***********Последние запуски***********');   
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
       
     log('***********Параметры***********');
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
    log('***********Команды для загрузки/выгрузке через ldt***********');
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

  IF  pr_conc_name IS NULL and pr_conc_descr IS NULL then log('Не заданы параметра поиска');
  ELSE
   --p_resp_name:= '%'||pr_resp_name||'%';

    --log('+ - на пользователя '||gb_user_name||' назначено указанное полномочие');
    log('---------------------------------------------------------------');
--Поиск параллельной программы
for a IN ( select  pr.concurrent_program_name||' \ '||pr.user_concurrent_program_name||' \ '||pr.DESCRIPTION pr_name,
                   pr.concurrent_program_name, 
                   pr.CONCURRENT_PROGRAM_ID pr_id,
                   DECODE(pr.enabled_flag, 'N', '(ВЫКЛЮЧЕНА) ', NULL)enable, --Если разработка выключена - отмечаем это
                   --Данные о исполнительном файле
                   CASE ex.EXECUTION_METHOD_CODE
                            WHEN 'H' THEN 'Хост-сценарий'
                            WHEN 'S' THEN 'Прямой запуск'
                            WHEN 'J' THEN 'Сохраненная процедура Java'
                            WHEN 'K' THEN 'Параллельная программа Java'
                            WHEN 'M' THEN 'Многоязыковая функция'
                            WHEN 'P' THEN 'Отчеты Oracle(*.rdf)'
                            WHEN 'I' THEN 'Сохраненная процедура PL/SQL'
                            WHEN 'B' THEN 'Функция этапа набора запросов'
                            WHEN 'A' THEN 'Порожденная программа(С++)'
                            WHEN 'L' THEN 'SQL*Loader'
                            WHEN 'Q' THEN 'SQL*Plus'
                            WHEN 'E' THEN 'Параллельная программа Perl'
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
                  (   pr_find_flag = 'N'  --Поиск разработки по конкретным именам
                  and (xx_pnaumov_pkg.f_like(pr.concurrent_program_name, pr_conc_name) = 1
                    or xx_pnaumov_pkg.f_like(pr.USER_CONCURRENT_PROGRAM_NAME, pr_conc_name)=1
                      )
                  and xx_pnaumov_pkg.f_like(NVL(pr.DESCRIPTION, pr.USER_CONCURRENT_PROGRAM_NAME), pr_conc_descr) = 1
                   )
               or  (   pr_find_flag = 'Y' --При включенном параметре поиска ищем все вхождения параметра NVL(pr_resp_name,pr_resp_descr)
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
      log('Модуль: '||a.application_short_name
        ||' Метод выполнения: '||a.execution_method_code 
        ||' Исполняемый файл: '||a.EXECUTION_FILE_NAME
        ||' Формат вывода:'||a.output_file_type
        ||' Тип шаблона:'||a.TEMPLATE_TYPE_CODE
        ||' Формат по умолчанию:'||a.DEFAULT_OUTPUT_TYPE
        );
      print_list_responses(p_conc_program_id => a.pr_id);
      
      --печать последних запусков
      if p_print_last_reqs > 0 then 
        print_conc_req(a.pr_id, p_print_last_reqs);
      end if;
      
      --параметры + НЗ для параметров
      if p_print_parameters = 'Y' then 
        print_parameters(a.concurrent_program_name);
      end if;
      
      if p_print_fndload_cmd = 'Y' then 
        print_fndload_cmd(a.pr_id, a.concurrent_program_name, a.application_short_name);
      end if;
      
    end loop;
  END IF;
END find_concurrent;

--***********************Убить сессии, использующие выбранный объект*****************************
procedure find_block_session (p_obj_name varchar2, p_kill_session varchar2 default 'N') is
  l_sql VARCHAR2(4000);
  TYPE EmpCurTyp  IS REF CURSOR;
  v_emp_cursor    EmpCurTyp;

BEGIN
  --Снятие блокировок с объектов
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
         log('1. Найдена сессия '||i.SID||' юзера '||i.osuser||' для объекта '||i.object_name);
         if p_kill_session = 'Y' then
           l_sql := 'alter system kill session ''' || i.SID || ',' ||i.serial# || '''';
           EXECUTE IMMEDIATE l_sql;
           log('...и убита');
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
      --TODO не работает из-за отсутствия доступа хотя бы к одной из таблиц
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

      --вынесена в динамику из-за грантов
     OPEN v_emp_cursor FOR v_stmt_str USING p_obj_name, p_obj_name;

     LOOP
        FETCH v_emp_cursor INTO v_session_id, v_obj_name;
        EXIT WHEN v_emp_cursor%NOTFOUND;

        for j in (select distinct serial# data, osuser
                  from v$session
                  where sid = v_session_id)
             loop
                 begin
                   log('2. Найдена сессия '||v_session_id||' юзера '||j.osuser||' для объекта '||v_obj_name);
                   if p_kill_session = 'Y' then
                     l_sql := 'alter system kill session ''' || v_session_id || ',' ||j.data|| '''';
                     EXECUTE IMMEDIATE l_sql;
                     log('...и убита');
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

--************************Процедуры получений Набора значений в зависимости от типа**************************************
procedure find_value_set (pr_value_set_name varchar2:= NULL
                        , p_use_conc varchar2:= NULL
                        , p_find_flag varchar2:= NULL
                        ) is
begin

 for i in (select s.flex_value_set_name, s.flex_value_set_id,
                  s.description, s.validation_type ,
                  case s.validation_type
                        when 'D' then 'Зависимые'
                        when 'I' then 'Независимые'
                        when 'N' then 'Нет'
                        when 'P' then 'Пара'
                        when 'U' then 'Особый'
                        when 'F' then 'Таблица'
                        when 'X' then 'Пересчитанные независимые'
                        when 'Y' then 'Переводимые зависимые'
                  end validation_type_descr
           from FND_FLEX_VALUE_SETS s
           where 1=1
           and xx_pnaumov_pkg.f_like(s.flex_value_set_name, pr_value_set_name)=1
           or (p_find_flag = 'Y'
           and xx_pnaumov_pkg.f_like(s.description, pr_value_set_name)=1
               )
           )
    loop
        log('НАБОР ЗНАЧЕНИЙ: '||i.flex_value_set_name||' - '||i.description||' ('||i.validation_type_descr||'):');
        log(' ');

      --Табличные наборы значение
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

            --Если в начале строки p_where не хватает слова where, то добавляем его
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

     --Независимые наборы значение
       if i.validation_type = 'I' then
        declare
                  p_err_date varchar2(100);
                  p_err_enable varchar2(100);

                  p_max_size_value number;
                  p_max_size_meaning number;
                  p_max_size_descr number;

                  p_sum_max_size number;

                  p_colum_name_value varchar2(100):= 'Значение';
                  p_colum_name_meaning varchar2(100):= 'Пересч. знач.';
                  p_colum_name_descr varchar2(100):= 'Описание';

                  p_min_size_value number:= length(p_colum_name_value)+1;
                  p_min_size_meaning number:= length(p_colum_name_meaning)+1;
                  p_min_size_descr number:= length(p_colum_name_descr)+1;

         begin
                --определение размера полей для импровизированной таблицы
                select max(length(v.FLEX_VALUE))+1, max(length(v.FLEX_VALUE_MEANING))+1, max(length(v.DESCRIPTION))+1
                into p_max_size_value, p_max_size_meaning, p_max_size_descr
                from FND_FLEX_VALUES_VL v
                where v.flex_value_set_id = i.flex_value_set_id;

                if p_min_size_value > p_max_size_value then p_max_size_value:= p_min_size_value; end if;
                if p_min_size_meaning > p_max_size_meaning then p_max_size_meaning:= p_min_size_meaning; end if;
                if p_min_size_descr > p_max_size_descr then p_max_size_descr:= p_min_size_descr; end if;
              --Заголовок
              log(RPAD(p_colum_name_value,p_max_size_value)||' | '||RPAD(p_colum_name_meaning,p_max_size_meaning)||' | '||RPAD(p_colum_name_descr,p_min_size_descr)||p_err_date||p_err_enable);
              --Разделительная черта
              p_sum_max_size:= p_max_size_value + p_max_size_meaning + p_max_size_descr;
              log(RPAD('-',p_sum_max_size+4, '-'));
              for j in (select v.FLEX_VALUE, v.ENABLED_FLAG,
                               v.start_date_active, v.end_date_active,
                               v.FLEX_VALUE_MEANING FLEX_VALUE_MEANING,
                               v.DESCRIPTION DESCRIPTION
                        from FND_FLEX_VALUES_VL v
                        where v.flex_value_set_id = i.flex_value_set_id)
              loop
                  if j.enabled_flag = 'N' then p_err_enable:= '  (Выключено!)';
                                          else p_err_enable:= NULL;
                  end if;
                  if SYSDATE NOT BETWEEN NVL(j.start_date_active, SYSDATE) AND NVL(j.end_date_active, SYSDATE)
                    then p_err_date:= '  (Просрочено! c '||j.start_date_active||' по '||j.end_date_active||')'; end if;


                  log(RPAD(j.FLEX_VALUE,p_max_size_value)||' | '||RPAD(j.FLEX_VALUE_MEANING,p_max_size_meaning)||' | '||RPAD(j.description,p_max_size_descr)||p_err_date||p_err_enable);
              end loop;

             end;
        end if;
    log('');
    if p_use_conc = 'Y' then
      log(' Используется в параметрах следующих параллельных программ:');
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

--******************************Процедура выделения русских символов из строки****************************************
PROCEDURE find_rus_chars (pr_string varchar2) IS
    p_new_string  varchar2(1000):=NULL;
    p_num number;
    p_count number:=0;
BEGIN
    p_num:= length(pr_string);
    for i in 1..p_num
     loop
       --Задаём диапазон русских символов
         if ASCII(substr(pr_string, i, 1))>= 192 and ASCII(substr(pr_string, i, 1)) <= 255
           then p_new_string:= p_new_string||'['||substr(pr_string, i, 1)||']';
                p_count:= p_count + 1;
           else  p_new_string:= p_new_string||substr(pr_string, i, 1);
         end if;
    end loop;
      log('Кол-во русских символов в строке: '||p_count);
      log(p_new_string);
END find_rus_chars;


--*****************************Процедура получения значений профиля************************
--Взято и немного переработано из http://www.notesbit.com/index.php/oracle-applications/11i-scripts/how-do-you-check-the-profile-option-values-using-sql-oracle-applications/
PROCEDURE find_profile(p_profile_name varchar2) is

l_profile_name varchar2(2000):='XXX';

begin
FOR i in  (SELECT po.profile_option_name profile_option_name,
                  decode(po.profile_option_name, po.USER_PROFILE_OPTION_NAME, null, ' ('||po.USER_PROFILE_OPTION_NAME||')')USER_PROFILE_OPTION_NAME,
                  decode(to_char(pov.level_id),
                         '10001', 'Отделение',
                         '10002', 'Приложение',
                         '10003', 'Полномочие',
                         '10004', 'Пользователь',
                         '10005', 'Сервер',
                         '10006', 'Организация',
                         '10007', 'Полномочие', --непонятно чем отличается от 10003
                          pov.level_id||'(неопределено)') lev,
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
    log('ПРОФИЛЬ '||l_profile_name||i.USER_PROFILE_OPTION_NAME);
    log('(Текущее значение: '||fnd_profile.VALUE(l_profile_name)||')');
  end if;

  log('  '||i.lev||' ('||i.context||')  ЗНАЧЕНИЕ: '||i.value);

end loop;

END find_profile;

--*****************************Процедура заданиям глобального имени пользователя*****************************************
procedure set_username(p_username varchar2)
is
begin
  if get_user_parametrs(p_username) then gb_user_name:= G_SESSION_PAR.user_name; end if;
end set_username;


--********************Процедура поиска объекта БД***************************
procedure find_object(p_object_name varchar2
                    , p_table_size varchar2 default 'N'
                    , p_dependencies varchar2 default 'N') is
    v_total_size number:=0;                
 begin
   for i in (select distinct --Для схлопывания пакета и его тела
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
    --Определяем физические размеры таблицы
    if i.object_type = 'TABLE' and p_table_size = 'Y'then
      log('     Размеры физические размеры связанны объектов:');
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
        
        log('     Итого: '||v_total_size||' Mb');
      end if;
      --Находим объекты, которые вызывают искомый объект
      if p_dependencies = 'Y' then
         log('     Данный объект используют:');
         find_code(p_find_string => i.OBJECT_NAME);
         
        end if;
  log('-------------------------------------------------------');
  end loop;
end   find_object;

--************Процедура запуска параллельной программы Экспорт персонализаций.**************************
--Результата в любых полномочиях ОЕБС - Вид - Запросы - Найти
procedure export_pers (p_pers_name varchar2, p_level varchar2 default 'A') is
    v_api_request_id number;

  begin
    xx_pnaumov_pkg.initialize('Разработчик приложений'); --Результат запроса будет в полномочиях того пользователя под которым прошла инициализация

    v_api_request_id := fnd_request.submit_request
        (
          application    => 'XXPHA',
          program        => 'XXPHA_TA004',
          description    => 'PHA Экспорт персонализаций',
          start_time     => null,
          sub_request    => false,
          argument1      => p_level,
          argument2      => null,
          argument3      => null,
          argument4      => p_pers_name
        );
   if   v_api_request_id = 0 then  xx_pnaumov_pkg.log('Не удалось создать запрос Экспорт персонализация');
   else
     commit;
     xx_pnaumov_pkg.log('');
     xx_pnaumov_pkg.log('Экспорт персонализаций успешно запущен. Номер запроса '||v_api_request_id);
     xx_pnaumov_pkg.log('Результат в любых OeBS полномочиях '||gb_user_name||' (Вид - Запросы - Найти)');
   end if;


  end export_pers;

--**********************Добавление полномочий пользователю************************
procedure add_resp_to_user (p_pesp_name varchar2, p_user_name varchar2 default null) is
    v_start_date date;
    v_end_date date;
    v_security_group_id fnd_user_resp_groups.security_group_id%type;
  begin

  if not get_user_parametrs(nvl(p_user_name, gb_user_name)) then  raise_application_error(-20000, 'Ошибка! При определении пользователя'); end if;
  if not get_resp_parametrs(p_pesp_name) then raise_application_error(-20000, 'Ошибка! При определении полномочия. Смотрите лог...'); end if;

  log('');
  if not (fnd_user_resp_groups_api.assignment_exists(G_SESSION_PAR.user_id, G_SESSION_PAR.resp_id, G_SESSION_PAR.appl_id, 0))
    then  fnd_user_resp_groups_api.insert_assignment(G_SESSION_PAR.user_id
                                                   , G_SESSION_PAR.resp_id
                                                   , G_SESSION_PAR.appl_id
                                                   , 0
                                                   , TRUNC(SYSDATE)
                                                   , NULL
                                                   , NULL);
      log('Полномочия '||G_SESSION_PAR.resp_name||' успешно добавлены пользователю '||G_SESSION_PAR.user_name);
      commit;
     else

        --активация, если отключены
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
             log('Полномочия '||G_SESSION_PAR.resp_name||' активированы для пользователя '||G_SESSION_PAR.user_name);
         else
             log('Полномочия '||G_SESSION_PAR.resp_name||' уже назначены пользователю '||G_SESSION_PAR.user_name);
         end if;

   end if;
  end add_resp_to_user;


--**********************Включение/выключение диагностического профиля****************************
procedure on_diag_profile (p_result_into_table varchar2 default 'N') is



   --v_enable_profile varchar2(100);
   --v_log_end_value   number;

   --задание значений
pragma autonomous_transaction;
v_start_parament varchar2(200);
begin
 
         log('Включение диагностических профилей: ');

         FND_LOG.G_CURRENT_RUNTIME_LEVEL:= 1;
         set_profile(v_profname_aflog_enbl, 'Y');
         set_profile(v_profname_aflog_level, '1');
         set_profile('БОП: модуль журнала отладки', '%');
         set_profile(v_eam_debug_name, 'Y');
         set_profile('INV_DEBUG_LEVEL', '102'); --для дебага через INVPUTLI

         
         xx_pnaumov_pkg.initialize('Системный администратор');

        --PO Логи

        --PO_LOG.enable_logging('%');
        --PO_LOG.refresh_log_flags;
        --PO_LOG.d_stmt:= TRUE;

        --начало записи
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

    --Выключение профилей
 commit;
 exception
   when others then
     log('Error', 'E');
 end on_diag_profile;



--**********************Включение/выключение диагностического профиля****************************
procedure off_diag_profile(p_result_into_table varchar2 default 'N') is
   v_log_end_value   number;
   v_result_message varchar2(32000);
pragma autonomous_transaction;
begin


     log('Выключение диагностических профилей: ');


     execute immediate 'ALTER SESSION SET EVENTS ''10046 trace name context OFF''';

        --конец записи
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
        'Результат профилей отладки: '||chr(13)||
        ''||chr(13)||
        'select * '||chr(13)||
            'from FND_LOG_MESSAGES lm'||chr(13)||
            'where lm.log_sequence between '||nvl(to_char(g_log_start_value), ':g_log_start_value')||' and '||v_log_end_value||chr(13)||
            'and lm.user_id = '||fnd_global.USER_ID||chr(13)||
            'order by log_sequence'||chr(13)||

        ''||chr(13)||
        'Результат профилирования: '||chr(13)||
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








--**************************************Анализ времени работы кусков кода в цикле************************************
 --Начало анализа
   procedure time_start (p_name varchar2) is
     begin
      G_TIME(p_name).start_time:= CURRENT_TIMESTAMP;
      G_TIME(p_name).total_call:= G_TIME(p_name).total_call + 0.5;
     end;

 --Конец анализа
   procedure time_end (p_name varchar2) is

     begin
        G_TIME(p_name).end_time:= CURRENT_TIMESTAMP;
         G_TIME(p_name).diff_time:=  G_TIME(p_name).end_time -  G_TIME(p_name).start_time;

        --первый запуск
        if  G_TIME(p_name).min_time is null then   G_TIME(p_name).min_time:=  G_TIME(p_name).diff_time; end if;
        if  G_TIME(p_name).max_time is null then   G_TIME(p_name).max_time:=  G_TIME(p_name).diff_time; end if;
        --итоги
        if   G_TIME(p_name).diff_time <  G_TIME(p_name).min_time then  G_TIME(p_name).min_time:=  G_TIME(p_name).diff_time; end if;
        if   G_TIME(p_name).diff_time >  G_TIME(p_name).max_time then  G_TIME(p_name).max_time:=   G_TIME(p_name).diff_time; end if;

         G_TIME(p_name).total_time:=  G_TIME(p_name).total_time + G_TIME(p_name).diff_time;
         G_TIME(p_name).total_call:=  G_TIME(p_name).total_call + 0.5;
     end time_end;

--Вывод результата
  procedure time_print (p_name varchar2, p_cliner_frag in varchar2 default 'Y') is

  v_avg_time interval day to second;

     begin

      if     G_TIME.exists(p_name)
         and G_TIME(p_name).total_call > 0
         and trunc(G_TIME(p_name).total_call) =  G_TIME(p_name).total_call
      then
        log('');
        log('Статистика по '||upper(p_name)||':');
        log('Минимальное время работы  :'|| G_TIME(p_name).min_time);
        log('Максимальное время работы :'|| G_TIME(p_name).max_time );
        v_avg_time:=  G_TIME(p_name).total_time/ G_TIME(p_name).total_call;
        log('Среднее время работы      :'||v_avg_time);

        log('Общее время работы        :'|| G_TIME(p_name).total_time );
        log('Общее кол-во запусков     :'|| G_TIME(p_name).total_call );
      elsif  G_TIME.exists(p_name)
         and G_TIME(p_name).total_call > 0
         and trunc(G_TIME(p_name).total_call) <>  G_TIME(p_name).total_call
      then
        log('');
        log('Ошибки по '||upper(p_name)||':');
        log('Количество вызванных  time_start не соответствует вызванным time_end');
      elsif  not G_TIME.exists(p_name)  or G_TIME(p_name).total_call = 0 then
        log('');
        log('Статистика по '||upper(p_name)||' не была запущена');
      else
       log('');
       log('По '||upper(p_name)||'какая-то странная херня. Обратитесь к Наумову. total_call = '|| G_TIME(p_name).total_call);
      end if;

        if p_cliner_frag = 'Y' then  G_TIME(p_name).min_time:=   null;
                                     G_TIME(p_name).max_time:=   null;
                                     G_TIME(p_name).total_time:= (sysdate-sysdate) DAY TO SECOND;
                                     G_TIME(p_name).total_call:= 0;

        end if;

     end time_print;

-- time_end
--

--**************************Поиск полномочий формы***********************************
procedure find_form(p_form_name varchar2 default null, p_function_name varchar2 default null) is

    type list_menu_t is table of varchar2(32000) index by pls_integer;
    list_prompt list_menu_t;

    type par_menu_t is table of number index by pls_integer;
    par_menu par_menu_t;

    v_last_element number:=0;

    --рекурсивная функция перебора меню (ума не хватило сделать одним селектом)
    procedure get_recursive_menu (p_menu_id number, p_list_prompt varchar2 default null)
    is
      --v_list_prompt varchar2(32000);
      --v_last_menu boolean:= true;
    begin

          v_last_element:= v_last_element + 1;
          par_menu(v_last_element):= p_menu_id;
          list_prompt(v_last_element):= p_list_prompt;

      --Крутим меню
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

  --Выбор формы и функции
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
      log('--------- Форма: '||i.form_descr||'--------------');
      log('---------- Функция: '||i.function_descr||' -------------------');
        --Выбор меню
        for j in (select fme.MENU_ID, fme.SUB_MENU_ID, fme.PROMPT
                  from FND_MENU_ENTRIES_VL fme
                  inner join fnd_menus_vl fm on fme.MENU_ID = fm.menu_id
                  where fme.FUNCTION_ID = i.FUNCTION_ID
                  )
        loop
          get_recursive_menu(j.MENU_ID, j.PROMPT);
        end loop;

        --Вывод результатов
        for j in par_menu.FIRST..par_menu.LAST
        loop
           log('   Навигация: '||list_prompt(j));
           print_list_responses( p_menu_id=> par_menu(j));
        end loop;
      log('');
    end loop;
 end find_form;

function to_number(p_char varchar2) return number is
  begin
    return fnd_number.canonical_to_number(regexp_substr(p_char, '[[:alnum:]|[:punct:]]+')); --пробуем преобразовать в число
  exception
    when others then return null; --если не вышло, пишем ошибку
  end;


--**********************Добавление полномочий параллельной программе************************
procedure add_resp_to_conc (p_conc_name varchar2, p_pesp_name varchar2) is
    v_no_data_found_flag boolean:= true;
  begin

  --Проверка параллельной программы
  if not get_conc_parametrs(p_conc_name) then  raise_application_error(-20000, 'Ошибка! При определении параллельной программы.'); end if;

  --Перебор групп запросов
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
            log('Программа добавлена в группу запросов "' || rec.group_name ||'" ('||rec.rg_DESCRIPTION||')');
        else
            log('Программа уже была добавлена в группу запросов "' || rec.group_name||'" ('||rec.rg_DESCRIPTION||')');
        END IF;

      END LOOP;

     if v_no_data_found_flag  then
        log('Ошибка! Полномочия не найдены');
        raise_application_error(-20000, 'Ошибка! Полномочия не найдены.');
     end if;

     commit;
  end add_resp_to_conc;

-- Процедура добавления заданной формы в корень указанных полномочий в OeBS (Д. Гусев)
PROCEDURE add_resp_to_form( p_form    VARCHAR2      -- Имя формы, можно частично строкой с маской, которую необходимо установить
                            , p_resp  VARCHAR2      -- Имя полномочий, можно частично строкой с маской, в корень меню которых добавляется форма
                          )
is
    -- Производим нормализацию имени формы - убираем пробелы, приводим всё к верхнему регистру
    c_normalization_form CONSTANT applsys.fnd_form.form_name%type := Upper( Trim( p_form ) );
    -- Производим нормализацию имени полномочий - убираем пробелы, приводим всё к верхнему регистру
    c_normalization_resp CONSTANT applsys.fnd_responsibility_tl.responsibility_name%type := Upper( Trim( p_resp ) );

    v_find                        NUMBER;   -- служебная переменная

BEGIN
    -- смотрим корректность имени полномочий, заодно заполняем глобальную структуру необходимыми данными
    if( get_resp_parametrs( c_normalization_resp ) ) then
        -- смотрим корректность имени формы, заодно заполняем глобальную структуру необходимыми данными
        if( get_form_parametrs( c_normalization_form ) ) then
            -- Может уже привязаны полномочия и форма???
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

            if( v_find = 0 ) then  -- найдены форма и полномочия, но форма не привязана к полномочиям
                BEGIN
                    -- Регистрация пункта меню
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
                    log( 'Добавление формы - ' || G_SESSION_PAR.form_name || ' - в полномочия - ' || G_SESSION_PAR.resp_name || ' - произведено успешно.' );
                EXCEPTION when others then
                    rollback;
                    raise;
                END;
            else -- найдены форма и полномочия, и форма привязана к полномочиям, ничего не делаем
                log( 'Форма уже добавлена в данные полномочия' );
            end if;
        else
          raise_application_error(-20000, 'Ошибка! При определении формы');
        end if;
    else
      raise_application_error(-20000, 'Ошибка! При определении полномочий');
    end if;
END add_resp_to_form;

--Загрузка файла с сервера
--Взято отсюда https://blogs.oracle.com/searchtech/entry/loading_documents_and_other_file
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

  --Получение директории
  function get_directory(p_dir_name_f varchar2) return varchar2
   is
     v_return_dir_name all_directories.DIRECTORY_NAME%type;
     v_dir_path all_directories.DIRECTORY_PATH%type;
  begin
    select ad.DIRECTORY_NAME,   ad.DIRECTORY_PATH
    into v_return_dir_name, v_dir_path
    from all_directories ad
    where (ad.DIRECTORY_NAME = upper(p_dir_name_f)
        or ad.DIRECTORY_PATH = p_dir_name_f) --ищем либо по имени, либо по пути. (молимся богам чтобы они не совпали)
    and rownum = 1;--директорий может быть несколько, берём первую попавшуюся
    log('Директория '||v_return_dir_name||' ['||v_dir_path||'] найдена.');
    return v_return_dir_name;
  exception
    when no_data_found then
       log('Директория '||p_dir_name_f||' не найдена!');
      begin
        --Пробуем создать директорию
        execute immediate 'CREATE OR REPLACE DIRECTORY '||l_temp_dir_name||' AS '''||p_dir_name_f||'''';
        log('Создана директория '||l_temp_dir_name);
        l_create_temp_dir:= true;
        --Рекурсия
        return get_directory(p_dir_name_f);

      exception when others then raise_application_error(-20000, 'Ошибка! Директория не найдена!');
      end;
  end;
BEGIN


   l_dir_name:= get_directory(p_dir_name); --получение директории
   l_bfile := BFILENAME(l_dir_name, p_file_name); --получение локатора на файл
   IF (dbms_lob.fileexists(l_bfile) = 1) THEN
      --log('Файл '||p_file_name||' найден!');
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
      log('Файл '||p_file_name||' успешно загружен в '||g_lob_table_name||' row_id = '||l_row_id);

   ELSE
     log('Файл '||p_file_name||' не найден!');
     raise_application_error(-20000, 'Ошибка! Файл не найден!');
   END IF;

   --Подчищаем следы
     if l_create_temp_dir then
       begin
         execute immediate 'DROP DIRECTORY '||l_temp_dir_name;
       exception
         when others then null; --под апсом нет грантов на дроп, так что пофиг
       end;
     end if;

     return l_row_id;

END;

--Назначение ролей
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
            log('На юзера '||G_SESSION_PAR.user_name || ' назначена роль ' ||c.role_code||' -- '||p_role_name);
          END LOOP;
   
  if v_flag then 
     commit;
  else 
    log('Роль '||p_role_name||' не найдена');
  end if;
  
  end add_role_to_user;
  
--Поиск объектов в исходной коде   
 
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
--todo передалать на бинды
--todo доставать исходники из вьюх
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
       
   log('Поиск объектов по запросу:');
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

--Получение всевозможной информации по SQL_ID
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
         log('Ошибка при получении report_sql_monitor: '||SQLERRM);
    end;
        
         
end print_sql_info;  


--Поиск SQL запроса
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
    gb_rest_name:='Диспетчер Дебиторов';
    gb_user_name:='PNAUMOV1'; --имя пользователя

    --Имя инстанса
    G_SESSION_PAR.instans_name:= sys_context('USERENV','INSTANCE_NAME');

    --задание параметров внутри параллельной программы
    if fnd_global.USER_NAME is not null then set_username(p_username => fnd_global.USER_NAME); end if;

    --Создание таблиц
    create_lob_table;
    create_log_table;

END XX_PNAUMOV_PKG;
/
SHOW ERRORS
