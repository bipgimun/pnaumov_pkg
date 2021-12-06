create or replace package XXPHA_SN1041_ELASTIC_PROXY_PKG is

  -- Author  : AEMAMATOV
  -- Created : 03.05.2020 15:46:01
  -- Purpose :

  -- Public type declarations
  type t_elastic_item is record(
    item_id          VARCHAR2(100),
    item_code        varchar2(100),
    item_description varchar2(4000),
    score            number);

  type t_elastic_items is table of t_elastic_item;

  -- Public constant declarations
  DEBUG constant boolean := true;

  -- Вариант компиляции
  -- Выпадающий список c проверки наличного количества
  DROP_DOWN_WITH_AVAILABLE_CHECK constant boolean := false;

  -- Public variable declarations
  -- <VariableName> <Datatype>;

  -- Public function and procedure declarations
  function Search_By_String(p_search_string VARCHAR2,
                            p_store_id      VARCHAR2 default null,
                            p_org_id        VARCHAR2 default null,
                            p_req_type      varchar2 default null)
    RETURN CLOB;

  function Search_By_String_Pipe(p_search_string VARCHAR2,
                                 p_store_id      VARCHAR2 default null,
                                 p_org_id        VARCHAR2 default null)
    return t_elastic_items
    pipelined;

  --Определение доступного количества на складе второй ОЕ на данной площадке
  FUNCTION get_pair_available_qant(p_organization_id   IN NUMBER,
                                   p_inventory_item_id IN NUMBER)
    RETURN NUMBER deterministic;

  --Определение количества на складе второй ОЕ на данной площадке
  FUNCTION get_pair_all_qant(p_organization_id   IN NUMBER,
                             p_inventory_item_id IN NUMBER) RETURN NUMBER
    deterministic;

  --Определение склада второй ОЕ на данной площадке
  FUNCTION get_pair_org_name(p_org_id IN NUMBER) RETURN varchar2;

  --Определение признака проекта
  FUNCTION is_project(p_organization_id   IN NUMBER,
                      p_inventory_item_id IN NUMBER) RETURN NUMBER
    deterministic;

  --Определение признака проекта на складе второй ОЕ на данной площадке
  FUNCTION is_pair_project(p_organization_id   IN NUMBER,
                           p_inventory_item_id IN NUMBER) RETURN NUMBER
    deterministic;

  --Поиск с результатами во временной таблице
  /*  procedure get_search_tbl(p_search_str IN varchar2,
  p_store_id   IN NUMBER,
  p_org_id     in number default 82,
  p_req_type   in varchar2 default null);*/

  function Dummy_Param(s varchar2) return number deterministic;

end XXPHA_SN1041_ELASTIC_PROXY_PKG;
/
create or replace package body XXPHA_SN1041_ELASTIC_PROXY_PKG is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  lc_from_available_quantity constant varchar2(100) := 'Из наличного количества';

  /* lc_oebs_index_template constant varchar2(32767) := '{
    "query": {
      "bool": {
        "must": {
          "query_string": {
              "query": "<<SEARCH_STRING>>*",
              "default_operator": "AND",
              "analyze_wildcard": true
           }
        }
      }
    },
    "size": <<SIZE>>
  }';*/

  lc_oebs_index_template constant varchar2(32767) := '{
    "query": {
       "query_string": {
          "query": "<<SEARCH_STRING>>",
          "fuzziness": "AUTO"
       }
     },
    "size":<<SIZE>>
  }';

  /*  lc_oebs_inx_nodeact_template constant varchar2(32767) := '{
    "query": {
      "bool": {
        "must": {
          "query_string": {
              "query": "<<SEARCH_STRING>>*",
              "default_operator": "AND",
              "analyze_wildcard": true
           }
        }
      }
    },
    "size": <<SIZE>>
  }';*/

  lc_oebs_inx_nodeact_template constant varchar2(32767) := '{
    "query": {
          "query_string": {
              "query": "<<SEARCH_STRING>>*",
              "default_operator": "AND",
              "analyze_wildcard": true
           }
    },
    "size": <<SIZE>>
  }';

  lc_ipurch_index_template constant varchar2(32767) := '{
    "query": {
        "bool": {
            "must": [
                {
                    "query_string": {
                        "query": "<<SEARCH_STRING>>*",
                        "default_operator": "AND",
                        "analyze_wildcard": true
                    }
                },
                {
                    "term": {
                        "store_id_list": <<STORE_ID>>
                    }
                },
                {
                    "term": {
                        "oe_id": <<OE_ID>>
                    }
                }
            ]
        }
    },
    "size": <<SIZE>>
}';

  -- Private variable declarations
  -- <VariableName> <Datatype>;

  -- Function and procedure implementations

  -- ================================================
  -- SN1041
  -- Поиск по введенной строке для выпадающего списка
  -- ================================================
  function Search_By_String(p_search_string VARCHAR2,
                            p_store_id      VARCHAR2 default null,
                            p_org_id        VARCHAR2 default null,
                            p_req_type      varchar2 default null)
    RETURN CLOB is
    err     XXPHA_RGP001_PKG.elastic_return_error_record;
    c       CLOB;
    c_Query clob;
    l_query varchar2(32767);
    --l_searchString varchar2(500);
    l_extra_param varchar2(100) := '?pretty';
    l_Index       varchar2(100);
  begin
    /*
    TODO: owner="AEMamatov" created="17.02.2020"
    text="Добавить обработку ошибок"
    */
    $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('Search_By_String: p_search_string = ' ||
                                       p_search_string || ' p_store_id = ' ||
                                       p_store_id || ' p_org_id = ' ||
                                       p_org_id || ' p_req_type = ' ||
                                       p_req_type);
    $END
  
    l_query := replace(replace(lc_oebs_index_template,
                               '<<SEARCH_STRING>>',
                               p_search_string),
                       '<<SIZE>>',
                       nvl(fnd_profile.value('XXPHA_SN775_ELASTIC_LOOK'), 10));
    l_Index := xxpha_rgp001_pkg.INDEX_NAME_OEBS || ',' ||
               xxpha_rgp001_pkg.INDEX_NAME_IPURCH;
  
    dbms_lob.createtemporary(c_Query, true, dbms_lob.session);
    dbms_lob.writeappend(c_Query, length(l_query), l_query);
  
    c := XXPHA_RGP001_PKG.search_with_body_as_clob( --p_searchString       => l_searchString,
                                                   --p_search_fields      => null,
                                                   --p_filter_names       => null,
                                                   --p_filter_values      => null,
                                                   --p_filter_search_cond => null,
                                                   p_param_names  => null,
                                                   p_param_values => null,
                                                   p_extra_param  => l_extra_param,
                                                   p_clob         => c_Query,
                                                   --p_field_list         => null,
                                                   p_index_list => l_Index,
                                                   o_errors     => err);
    $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('Search_By_String: err = ' ||
                                       err.reason);
    $END
    return c;
  exception
    when others then
      return null;
  end Search_By_String;

  -- ================================================
  -- SN1041
  -- Табличная конвейерная функция
  -- Поиск по введенной строке для выпадающего списка 
  -- ================================================
  function Search_By_String_Pipe(p_search_string VARCHAR2,
                                 p_store_id      VARCHAR2 default null,
                                 p_org_id        VARCHAR2 default null)
    return t_elastic_items
    pipelined as
    l_qty_atr         number;
    l_ORGANIZATION_ID number;
    l_rownum          number := 0;
    l_search_string   varchar2(32767);
  begin
    --Если Тип заявки не равен "Из наличного количества"
    $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Search_By_String_Pipe.p_search_string=' ||
                                                     Search_By_String_Pipe.p_search_string);
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Search_By_String_Pipe.p_store_id=' ||
                                                     Search_By_String_Pipe.p_store_id);
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Search_By_String_Pipe.p_org_id=' ||
                                                     Search_By_String_Pipe.p_org_id);
    $END
  
    l_search_string := replace(Search_By_String_Pipe.p_search_string,
                               '\\',
                               '\\\\');                               
    l_search_string := replace(l_search_string,
                               '/',
                               '\\\/');                           
    l_search_string := replace(l_search_string,
                               chr(38)||'quot;',
                               '\\\"');                           
  
    $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'l_search_string=' ||
                                                     l_search_string);
    $END
  
    for rec in (select jt.ITEM_ID,
                       jt.ITEM_CODE,
                       trim(replace(replace(jt.ITEM_DESCRIPTION, chr(10), ''),
                                    '"',
                                    '\"')) ITEM_DESCRIPTION,
                       jt.score
                  from (select XXPHA_SN1041_ELASTIC_PROXY_PKG.Search_By_String(p_search_string => l_search_string,
                                                                               p_store_id      => Search_By_String_Pipe.p_store_id,
                                                                               p_org_id        => Search_By_String_Pipe.p_org_id) c
                          from dual) el,
                       JSON_TABLE(el.c,
                                  '$.hits.hits[*]'
                                  columns("ITEM_ID" VARCHAR2(100) PATH
                                          '$._id',
                                          "SCORE" NUMBER PATH '$._score',
                                          "ITEM_DESCRIPTION" VARCHAR2(4000) PATH
                                          '$._source.deskr',
                                          "ITEM_CODE" VARCHAR2(100) PATH
                                          '$._source.code')) as jt) loop
    
      pipe row(rec);
    
    end loop;
  
  end Search_By_String_Pipe;

  -- ==============================================================================
  -- SN1041
  -- Функция возвращает Org_ID "парной" организации
  -- Параметры:
  --         p_Current_Org_Id - текущий org_id, для которого ищем пару
  -- ==============================================================================
  function Get_Pair_Org_Id(p_Current_Org_Id number) return number
    deterministic as
    l_Pair_org_id number;
  begin
    select to_number(HIERARCHY_LEVEL)
      into l_Pair_org_id
      from (select fv.FLEX_VALUE, fv.HIERARCHY_LEVEL
              from apps.xxpha_flex_values_v fv
             where 1 = 1
               and fv.FLEX_VALUE_SET_NAME = 'XXPHA_SN904_OPER_UNIT'
            union all
            select fv.HIERARCHY_LEVEL, fv.FLEX_VALUE
              from apps.xxpha_flex_values_v fv
             where 1 = 1
               and fv.FLEX_VALUE_SET_NAME = 'XXPHA_SN904_OPER_UNIT')
     where 1 = 1
       and flex_value = to_char(p_Current_Org_Id);
    return l_Pair_org_id;
  end Get_Pair_Org_Id;

  -- ==============================================================================
  -- SN775-61
  -- Функция возвращает Organization_ID Центрального склада "парной" организации
  -- Параметры:
  --         p_Current_Cs_Id - текущий organization_id ЦС, для которого ищем пару
  -- ==============================================================================
  function Get_Pair_CS_Id(p_Current_Cs_Id number) return number deterministic as
    l_Pair_org_id number;
    l_cur_ou      number;
    l_pair_ou     number;
  begin
    select TO_NUMBER(HOI2.ORG_INFORMATION3) org_id
      into l_cur_ou
      from HR_ORGANIZATION_INFORMATION HOI2,
           mtl_parameters              p,
           HR_ALL_ORGANIZATION_UNITS   HOU
     where 1 = 1
       AND (HOI2.ORG_INFORMATION_CONTEXT || '') = 'Accounting Information'
       and p.ORGANIZATION_ID = hoi2.ORGANIZATION_ID
       and p.ATTRIBUTE15 = 'Центральный'
       and p.ATTRIBUTE10 = 'Группа учета материалов'
       and hou.organization_id = p.ORGANIZATION_ID
       and sysdate between hou.date_from and nvl(hou.date_to, sysdate)
       and p.ORGANIZATION_CODE <> 'ЧЦ0'
       and hoi2.ORGANIZATION_ID = p_Current_Cs_Id;
  
    $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('XXPHA_SN1041_ELASTIC_PROXY_PKG.Get_Pair_CS_Id l_cur_ou = ' ||
                                       l_cur_ou);
    $END
  
    l_pair_ou := Get_Pair_Org_Id(l_cur_ou);
  
    $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('XXPHA_SN1041_ELASTIC_PROXY_PKG.Get_Pair_CS_Id l_pair_ou = ' ||
                                       l_pair_ou);
    $END
  
    select hoi2.ORGANIZATION_ID
      into l_Pair_org_id
      from HR_ORGANIZATION_INFORMATION HOI2,
           mtl_parameters              p,
           HR_ALL_ORGANIZATION_UNITS   HOU
     where 1 = 1
       AND (HOI2.ORG_INFORMATION_CONTEXT || '') = 'Accounting Information'
       and p.ORGANIZATION_ID = hoi2.ORGANIZATION_ID
       and p.ATTRIBUTE15 = 'Центральный'
       and p.ATTRIBUTE10 = 'Группа учета материалов'
       and hou.organization_id = p.ORGANIZATION_ID
       and sysdate between hou.date_from and nvl(hou.date_to, sysdate)
       and p.ORGANIZATION_CODE <> 'ЧЦ0'
       and HOI2.ORG_INFORMATION3 = to_char(l_pair_ou);
  
    $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('XXPHA_SN1041_ELASTIC_PROXY_PKG.Get_Pair_CS_Id l_Pair_org_id = ' ||
                                       l_Pair_org_id);
    $END
  
    return l_Pair_org_id;
  end Get_Pair_CS_Id;

  -- ==============================================================================
  -- SN775-61
  -- Функция возвращает значение поля "Доступно на ЦС %"
  -- Параметры:
  --         p_org_id - текущий ЦС, для которого ищем пару
  --         p_inventory_item_id - позиция
  -- ==============================================================================
  FUNCTION get_pair_available_qant(p_organization_id   IN NUMBER,
                                   p_inventory_item_id IN NUMBER)
    RETURN NUMBER deterministic IS
    --l_place                  varchar2(100);
    l_pair_cs_id number;
    --l_current_operating_unit number;
    l_qty_atr NUMBER := 0;
  BEGIN
    --Определяем парный склад
    l_pair_cs_id := Get_Pair_CS_Id(p_organization_id);
  
    --Определяем доступное количество на нем
    select sum(nvl(ohi.available_quantity, 0))
      into l_qty_atr
      from XXPHA_SN976_ONHAND_INFO_MV ohi
     where 1 = 1
       and ohi.inventory_item_id = p_inventory_item_id
       and ohi.organization_id = l_pair_cs_id
    --and rownum = 1
    ;
  
    RETURN nvl(l_qty_atr, 0);
  exception
    when no_data_found then
      return 0;
  END get_pair_available_qant;

  -- ==============================================================================
  -- SN775-61
  -- Функция возвращает значение поля "Всего на ЦС %"
  -- Параметры:
  --         p_org_id - текущий ЦС, для которого ищем пару
  --         p_inventory_item_id - позиция
  -- ==============================================================================
  FUNCTION get_pair_all_qant(p_organization_id   IN NUMBER,
                             p_inventory_item_id IN NUMBER) RETURN NUMBER
    deterministic IS
    --l_place      varchar2(100);
    l_org_id     number;
    l_qty_atr    NUMBER := null;
    l_qty_res    number := null;
    l_pair_cs_id number;
  BEGIN
    --Определяем парный склад
    l_pair_cs_id := Get_Pair_CS_Id(p_organization_id);
  
    --Определяем доступное количество на нем
    begin
      select nvl(ohi.available_quantity, 0)
        into l_qty_atr
        from XXPHA_SN976_ONHAND_INFO_MV ohi
       where 1 = 1
         and ohi.inventory_item_id = p_inventory_item_id
         and ohi.organization_id = l_pair_cs_id
         and rownum = 1;
    exception
      when no_data_found then
        begin
          $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
          xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_pair_all_qant: l_qty_atr ' ||
                                                           sqlerrm);
          $end
        
          l_qty_atr := 0;
        end;
      when others then
        begin
          $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
          xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_pair_all_qant: l_qty_atr ' ||
                                                           sqlerrm);
          $end
        
          return null;
        end;
    end;
  
    begin
      select sum(nvl(ohi.reserved_quantity, 0))
        into l_qty_res
        from XXPHA_SN976_ONHAND_INFO_MV ohi
       where 1 = 1
         and ohi.inventory_item_id = p_inventory_item_id
         and ohi.organization_id = l_org_id;
    
      $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_pair_all_qant: l_qty_res =  ' ||
                                                       l_qty_res);
      $end
    
    exception
      when no_data_found then
        begin
          $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
          xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_pair_all_qant: eop ' ||
                                                           sqlerrm);
          $end
        
          l_qty_res := 0;
        end;
      when others then
        begin
          $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
          xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_pair_all_qant: eop ' ||
                                                           sqlerrm);
          $end
        
          return null;
        end;
    end;
  
    RETURN nvl(l_qty_atr + l_qty_res, 0);
  
  END get_pair_all_qant;

  -- ==============================================================================
  -- SN775-61
  -- Функция возвращает наименование "парной" ОЕ
  -- Параметры:
  --         p_org_id - текущий ORG_ID, для которого ищем пару
  -- ==============================================================================
  FUNCTION get_pair_org_name(p_org_id IN NUMBER) RETURN varchar2 as
    --l_place     varchar2(100);
    l_oper_unit number;
    l_org_name  varchar2(300);
  begin
    --Определяем "парный" org_id
    l_oper_unit := Get_Pair_Org_Id(p_org_id);
  
    select ou.NAME
      into l_org_name
      from apps.hr_operating_units ou
     where ou.ORGANIZATION_ID = l_oper_unit
       and sysdate between ou.date_from and nvl(ou.date_to, sysdate);
  
    return l_org_name;
  exception
    when no_data_found then
      return null;
    
  end get_pair_org_name;

  --------------------------------------------------------------------------------
  FUNCTION is_project(p_organization_id   IN NUMBER,
                      p_inventory_item_id IN NUMBER) RETURN NUMBER
    deterministic as
    res NUMBER;
  begin
    select 1
      into res
      from dual
     where 1 = 1
       and exists
     (select 1
              from XXPHA_SN976_ONHAND_INFO_MV ohi
             where 1 = 1
               and ohi.project_id is not null
               and ohi.inventory_item_id = p_inventory_item_id
               and ohi.organization_id = p_organization_id);
  
    return res;
  exception
    when no_data_found then
      return 0;
  end is_project;

  --------------------------------------------------------------------------------
  FUNCTION is_pair_project(p_organization_id   IN NUMBER,
                           p_inventory_item_id IN NUMBER) RETURN NUMBER
    deterministic as
    res NUMBER;
    --l_place  varchar2(100);
    --l_org_id number;
    l_pair_cs_id number;
  begin
    --Определяем парный склад
    l_pair_cs_id := Get_Pair_CS_Id(p_organization_id);
  
    select 1
      into res
      from dual
     where 1 = 1
       and exists (select 1
              from XXPHA_SN976_ONHAND_INFO_MV ohi
             where 1 = 1
               and ohi.project_id is not null
               and ohi.inventory_item_id = p_inventory_item_id
               and ohi.organization_id = l_pair_cs_id);
  
    return res;
  exception
    when no_data_found then
      return 0;
  end is_pair_project;

  --Поиск с результатами во временной таблице
  /*procedure get_search_tbl(p_search_str IN varchar2,
                             p_store_id   IN NUMBER,
                             p_org_id     in number default 82,
                             p_req_type   in varchar2 default null) as
      --pragma autonomous_transaction;
      err XXPHA_RGP001_PKG.elastic_return_error_record;
      c   CLOB;
      --l_param_names  XXPHA_RGP001_PKG.filterList := XXPHA_RGP001_PKG.filterList();
      --l_param_values XXPHA_RGP001_PKG.filterList := XXPHA_RGP001_PKG.filterList();
  
      c_Query CLOB;
      l_query varchar2(32767);
      l_Index varchar2(100);
  
      --l_searchString varchar2(500);
      l_extra_param varchar2(100) := '?pretty';
  
      l_ORGANIZATION_ID number;
    begin
      $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_ELASTIC_PROXY_PKG.get_search_tbl: search_str = ' ||
                                                       p_search_str);
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_ELASTIC_PROXY_PKG.get_search_tbl: store_id = ' ||
                                                       p_store_id);
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_ELASTIC_PROXY_PKG.get_search_tbl: p_org_id = ' ||
                                                       p_org_id);
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_ELASTIC_PROXY_PKG.get_search_tbl: p_req_type = ' ||
                                                       p_req_type);
      $end
  
      if p_store_id = 1 and p_req_type <> lc_from_available_quantity then
        l_query := replace(replace(lc_oebs_index_template,
                                   '<<SEARCH_STRING>>',
                                   p_search_str),
                           '<<SIZE>>',
                           fnd_profile.value('XXPHA_SN775_ELASTIC_RESULT'));
        l_Index := xxpha_rgp001_pkg.INDEX_NAME_OEBS;
      elsif p_store_id = 1 and p_req_type = lc_from_available_quantity then
        l_query := replace(replace(lc_oebs_inx_nodeact_template,
                                   '<<SEARCH_STRING>>',
                                   p_search_str),
                           '<<SIZE>>',
                           greatest(to_number(fnd_profile.value('XXPHA_SN775_ELASTIC_RESULT')),
                                    500));
        l_Index := xxpha_rgp001_pkg.INDEX_NAME_OEBS;
      else
        l_query := replace(replace(replace(replace(lc_ipurch_index_template,
                                                   '<<SEARCH_STRING>>',
                                                   p_search_str),
                                           '<<SIZE>>',
                                           fnd_profile.value('XXPHA_SN775_ELASTIC_RESULT')),
                                   '<<OE_ID>>',
                                   p_org_id),
                           '<<STORE_ID>>',
                           p_store_id);
        l_Index := xxpha_rgp001_pkg.INDEX_NAME_IPURCH;
      end if;
  
      dbms_lob.createtemporary(c_Query, true, dbms_lob.session);
      dbms_lob.writeappend(c_Query, length(l_query), l_query);
  
      c := XXPHA_RGP001_PKG.search_with_body_as_clob(p_param_names  => null,
                                                     p_param_values => null,
                                                     p_extra_param  => l_extra_param,
                                                     p_clob         => c_Query,
                                                     p_index_list   => l_Index,
                                                     o_errors       => err);
  
      if err.http_status = 200 or err.http_status is null then
        --insert into xxpha.xxpha_sn775_elast (c) values (c);
  
        delete from XXPHA.XXPHA_SN775_ELAST_RESULT_T;
  
        if p_req_type <> lc_from_available_quantity then
          insert into XXPHA.XXPHA_SN775_ELAST_RESULT_T
            (ITEM_ID, ITEM_CODE, DESKR, SCORE, ES_TIME)
            select unique       jt.ITEM_ID,
                   jt.ITEM_CODE,
                   jt.DESKR,
                   jt.SCORE,
                   systimestamp as ES_TIME
              from (select c from dual) e,
                   JSON_TABLE(c,
                              '$.hits.hits[*]'
                              columns(ITEM_ID NUMBER PATH '$._id',
                                      SCORE NUMBER PATH '$._score',
                                      DESKR VARCHAR2(4000) PATH
                                      '$._source.deskr',
                                      ITEM_CODE VARCHAR2(4000) PATH
                                      '$._source.code')) as jt;
  
          $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
          xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_search_tbl: sql%rowcount =  ' ||
                                                           sql%rowcount);
          $end
        else
          --Определить ID центрального склада
          select p.ORGANIZATION_ID
            into l_ORGANIZATION_ID
            from mtl_parameters              p,
                 HR_ALL_ORGANIZATION_UNITS   HOU,
                 HR_ORGANIZATION_INFORMATION HOI2
           where 1 = 1
             and p.ATTRIBUTE15 = 'Центральный'
             and p.ATTRIBUTE10 = 'Группа учета материалов'
             and p.ORGANIZATION_CODE <> 'ЧЦ0'
             and hou.organization_id = p.ORGANIZATION_ID
             and sysdate between hou.date_from and nvl(hou.date_to, sysdate)
             AND (HOI2.ORG_INFORMATION_CONTEXT || '') =
                 'Accounting Information'
             and p.ORGANIZATION_ID = hoi2.ORGANIZATION_ID
             and HOI2.ORG_INFORMATION3 = to_char(p_org_id);
  
          $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
          xxpha_pnaumov_pkg.insert_log_table('Search_By_String_Pipe: l_ORGANIZATION_ID = ' ||
                                             l_ORGANIZATION_ID);
          $END
          insert into XXPHA.XXPHA_SN775_ELAST_RESULT_T
            (ITEM_ID, ITEM_CODE, DESKR, SCORE, ES_TIME)
            select unique       jt.ITEM_ID,
                   jt.ITEM_CODE,
                   jt.DESKR,
                   jt.SCORE,
                   systimestamp as ES_TIME
              from (select c from dual) e,
                   JSON_TABLE(c,
                              '$.hits.hits[*]'
                              columns(ITEM_ID NUMBER PATH '$._id',
                                      SCORE NUMBER PATH '$._score',
                                      DESKR VARCHAR2(4000) PATH
                                      '$._source.deskr',
                                      ITEM_CODE VARCHAR2(4000) PATH
                                      '$._source.code')) as jt
             where 1 = 1
               and exists
             (select 1
                      from XXPHA_SN976_ONHAND_INFO_MV ohi
                     where 1 = 1
                       and ohi.organization_id = l_ORGANIZATION_ID
                       and ohi.inventory_item_id = jt.ITEM_ID
                       and nvl(ohi.available_quantity, 0) > 0)
               and rownum <=
                   to_number(fnd_profile.value('XXPHA_SN775_ELASTIC_RESULT'));
  
          $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
          xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_search_tbl: sql%rowcount =  ' ||
                                                           sql%rowcount);
          $end
        end if;
        --commit;
      end if;
  
      null;
    end get_search_tbl;
  */
  function Dummy_Param(s varchar2) return number deterministic as
  begin
    $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Dummy_Param: s =  ' || s);
    $end
    return 1;
  end Dummy_Param;

begin
  -- Initialization
  $if XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $then
  xxpha_pnaumov_pkg.gb_log_mark := 'SN1041';
  $end
  null;
end XXPHA_SN1041_ELASTIC_PROXY_PKG;
/
