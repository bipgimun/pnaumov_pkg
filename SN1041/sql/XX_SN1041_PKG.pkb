create or replace package body XXPHA_SN1041_PKG is

  --g_oe_id          number; --Складская организация
  --g_store_receiver number; --Склад-получатель
  --g_wip_num        number; --Номер ЗВР

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;
  lc_es_template constant varchar2(32767) := '{
    "query": {
      "bool": {
        "must": {
          "query_string": {
              "query": "<<SEARCH_STRING>>*",
              "default_operator": "AND",
              "analyze_wildcard": true
           }
        },
        "must_not": {
          "exists": {
            "field": "deakt"
          }
        }
      }
    },
    "size": <<SIZE>>
  }';
  /*  lc_es_template constant varchar2(32767) := '{
    "query": {
      "bool": {
        "must": {
          "query_string": {
              "query": "<<SEARCH_STRING>>",
              "fuzziness": "AUTO"
           }
        },
        "must_not": {
          "exists": {
            "field": "deakt"
          }
        }
      }
    },
    "size": <<SIZE>>
  }';*/

  lc_oebs_index_template constant varchar2(32767) := '{
    "query": {
          "query_string": {
              "query": "<<SEARCH_STRING>>*",
              "default_operator": "AND",
              "analyze_wildcard": true
           }
    },
    "size": <<SIZE>>
  }';

  /*  lc_oebs_index_template constant varchar2(32767) := '{
    "query": {
          "query_string": {
              "query": "<<SEARCH_STRING>>",
              "fuzziness": "AUTO"
           }
    },
    "size": <<SIZE>>
  }';*/

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
                      "terms": {
                          "oe_id": ["<<OE_ID>>"]
                      }
                  }
              ]
          }
      },
      "size": <<SIZE>>
  }';
  /*  lc_ipurch_index_template constant varchar2(32767) := '{
      "query": {
          "bool": {
              "must": [
                  {
                      "query_string": {
                          "query": "<<SEARCH_STRING>>",
                          "fuzziness": "AUTO"
                      }
                  },
                  {
                      "terms": {
                          "oe_id": ["<<OE_ID>>"]
                      }
                  }
              ]
          }
      },
      "size": <<SIZE>>
  }';*/

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  /*function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
    <LocalVariable> <Datatype>;
  begin
    <Statement>;
    return(<Result>);
  end;*/

  check_select_item_ex exception;
  ----------------------------------------------------------------------------------------
  procedure Dummy as
  begin
    null;
    $IF XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('Dummy - Ok!');
    $END
  end Dummy;

  ----------------------------------------------------------------------------------------
  function get_requisition_type(p_catalog_code          in varchar2,
                                p_cs_available_quantity in number,
                                p_quantity              in number default null)
    return varchar2 deterministic is
    l_result varchar2(1);
  begin
    l_result := case
                
                  when p_cs_available_quantity > 0 and
                       (p_quantity is null or
                       p_quantity <= p_cs_available_quantity) then
                   '2' --'Из наличного количества'
                  when p_catalog_code is not null then
                   '6' --'По каталогу' для И-М
                  else
                   '1' --'Плановая'
                
                end;
    return l_result;
  end get_requisition_type;

  ----------------------------------------------------------------------------------------
  procedure add_log(p_msg in varchar2) is
  begin
    xxpha_log(p_msg);
  
    --DEBUG
    $if xxpha_sn1041_pkg.debug $then
    xxpha_pnaumov_pkg.insert_log_table(p_msg);
    $end
  
  end add_log;

  function clean_search_string(s varchar2) return varchar2 as
  begin
    return replace(replace(s, '/', '\\\/'), '"', '\\\"');
    --return s;
  end clean_search_string;

  ----------------------------------------------------------------------------------------
  function get_elastic_items(p_search_str IN varchar2,
                             p_index_name in varchar2,
                             p_org_id     in number default null) return clob as
    err     XXPHA_RGP001_PKG.elastic_return_error_record;
    c       CLOB;
    c_Query clob;
    l_query varchar2(32767);
    --l_searchString varchar2(500);
    l_extra_param   varchar2(100) := '?pretty';
    l_Index         varchar2(100);
    l_size_iStore   number := nvl(fnd_profile.value('XXPHA_SN775_ELASTIC_RESULT'),
                                  150);
    l_size_oebs     number := 500;
    l_search_string varchar2(32767) := p_search_str;
  begin
    $IF XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('get_elastic_items: p_search_str = ' ||
                                       p_search_str);
    xxpha_pnaumov_pkg.insert_log_table('get_elastic_items: p_index_name = ' ||
                                       p_index_name);
    xxpha_pnaumov_pkg.insert_log_table('get_elastic_items: p_org_id = ' ||
                                       p_org_id);
    $END
  
    --l_search_string := replace(get_elastic_items.p_search_str, '\', '\\\\');
    --l_search_string := replace(l_search_string, '/', '\\\/');
    --l_search_string := replace(l_search_string, '"', '\\\"');
  
    $IF XXPHA_SN1041_ELASTIC_PROXY_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'l_search_string=' ||
                                                     l_search_string);
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'clean_search_string(l_search_string)=' ||
                                                     clean_search_string(l_search_string));
    $END
  
    l_Index := p_index_name;
  
    if l_Index = xxpha_rgp001_pkg.INDEX_NAME_OEBS then
    
      l_query := replace(replace(lc_oebs_index_template,
                                 '<<SEARCH_STRING>>',
                                 clean_search_string(l_search_string)),
                         '<<SIZE>>',
                         l_size_oebs);
    else
      l_query := replace(replace(replace(lc_ipurch_index_template,
                                         '<<SEARCH_STRING>>',
                                         clean_search_string(l_search_string)),
                                 '<<SIZE>>',
                                 l_size_iStore),
                         '<<OE_ID>>',
                         get_elastic_items.p_org_id);
    end if;
    /*fnd_profile.value('XXPHA_SN775_ELASTIC_RESULT'));
    l_Index := xxpha_rgp001_pkg.INDEX_NAME_OEBS || ',' ||
               xxpha_rgp001_pkg.INDEX_NAME_IPURCH;*/
  
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
    return c;
  exception
    when others then
      begin
        $IF XXPHA_SN1041_PKG.DEBUG $THEN
        xxpha_pnaumov_pkg.insert_log_table('get_elastic_items - Error!');
        xxpha_pnaumov_pkg.insert_log_table('get_elastic_items:' || sqlerrm);
        $END
        return null;
      end;
  end get_elastic_items;

  ----------------------------------------------------------------------------------------
  procedure Item_Search(p_search_str IN varchar2) as
    l_query       varchar2(32767);
    l_Index       varchar2(250);
    c_Query       CLOB;
    c             CLOB;
    l_extra_param varchar2(100) := '?pretty';
    err           XXPHA_RGP001_PKG.elastic_return_error_record;
  begin
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.Item_Search: search_str = ' ||
                                                     p_search_str);
    $end
  
    l_query := replace(replace(lc_es_template,
                               '<<SEARCH_STRING>>',
                               p_search_str),
                       '<<SIZE>>',
                       fnd_profile.value('XXPHA_SN775_ELASTIC_RESULT'));
    l_Index := xxpha_rgp001_pkg.INDEX_NAME_OEBS || ', ' ||
               xxpha_rgp001_pkg.INDEX_NAME_IPURCH;
  
    dbms_lob.createtemporary(c_Query, true, dbms_lob.session);
    dbms_lob.writeappend(c_Query, length(l_query), l_query);
  
    c := XXPHA_RGP001_PKG.search_with_body_as_clob(p_param_names  => null,
                                                   p_param_values => null,
                                                   p_extra_param  => l_extra_param,
                                                   p_clob         => c_Query,
                                                   
                                                   p_index_list => l_Index,
                                                   o_errors     => err);
  
    if err.http_status = 200 or err.http_status is null then
    
      delete from XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT;
    
      insert into XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT
        (inventory_item_id, item_code, DESCRIPTION, SCORE, INDEX_NAME)
        select unique jt.inventory_item_id,
               jt.ITEM_CODE,
               jt.DESCRIPTION,
               jt.SCORE,
               jt.INDEX_NAME
          from (select c from dual) e,
               JSON_TABLE(c,
                          '$.hits.hits[*]'
                          columns(inventory_item_id NUMBER PATH '$._id',
                                  SCORE NUMBER PATH '$._score',
                                  DESCRIPTION VARCHAR2(4000) PATH
                                  '$._source.deskr',
                                  ITEM_CODE VARCHAR2(4000) PATH
                                  '$._source.code',
                                  INDEX_NAME VARCHAR(50) PATH '$._index')) as jt;
    
      $if XXPHA_SN1041_PKG.DEBUG $then
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.Item_Search: sql%rowcount =  ' ||
                                                       sql%rowcount);
      $end
      --commit;
    end if;
    null;
  end Item_Search;

  ----------------------------------------------------------------------------------------
  --функция расчёта цены
  function get_item_price(p_price_id   number,
                          p_item_id    number,
                          p_po_line_id number) return number is
    l_price number := null;
  begin
  
    --Сначала пробуем получить цену из ОСЗ
    if p_po_line_id is not null then
      select case
               when h.CURRENCY_CODE = 'RUB' then
                l.UNIT_PRICE
               else
                icx_cat_util_pvt.convert_amount(p_from_currency   => h.CURRENCY_CODE,
                                                p_to_currency     => 'RUB',
                                                p_conversion_date => h.RATE_DATE,
                                                p_conversion_type => h.RATE_TYPE,
                                                p_conversion_rate => h.RATE,
                                                p_amount          => l.UNIT_PRICE)
             end
        into l_price
        from po_lines_all l
       inner join po_headers_all h
          on l.PO_HEADER_ID = h.PO_HEADER_ID
       where l.PO_LINE_ID = p_po_line_id;
    
    end if;
    --Если цену не нашли, ищем в прайсе
    if nvl(l_price, 0) <= 0 then
      begin
        select /*+ Index_SS(p, QP_PRICING_ATTRIBUTES_N15) */
         l.OPERAND
          into l_price
          from qp.qp_pricing_attributes p
         inner join qp_list_lines l
            on l.LIST_LINE_ID = p.LIST_LINE_ID
         where p.LIST_HEADER_ID = p_price_id --:1
           and p.product_Attr_Value = p_item_id
           and sysdate between nvl(l.start_date_active, sysdate) and
               nvl(l.end_date_active, sysdate)
              --for performans
           and p.PRODUCT_ATTRIBUTE = 'PRICING_ATTRIBUTE1'
           and p.pricing_attribute_context is null
           and p.pricing_attribute is null
           and p.excluder_flag = 'N'
              --from qp_list_lines_v
           and p.pricing_phase_id = 1
           and p.qualification_ind in (4, 6, 20, 22)
           and l.pricing_phase_id = 1
           and l.qualification_ind in (4, 6, 20, 22)
           and l.list_line_type_code in ('PLL', 'PBH');
      
        $if XXPHA_SN1041_PKG.DEBUG $then
        xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_item_price: l_price =  ' ||
                                                         l_price);
        $end
      exception
        when no_data_found then
          begin
            $if XXPHA_SN1041_PKG.DEBUG $then
            xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_item_price: l_price =  ' ||
                                                             l_price);
            $end
            l_price := null;
          end;
      end;
    end if;
  
    return l_price;
  end get_item_price;

  ----------------------------------------------------------------------------------------
  -- Поиск по EAM ЗВР с результатами во временной таблице
  --
  procedure get_search_tbl_eam(p_wip_entity_id in number) as
    price_id number;
    l_oe_id  number;
  begin
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_search_tbl_eam: p_wip_entity_id = ' ||
                                                     p_wip_entity_id);
    $end
  
    select o.OPERATING_UNIT
      into l_oe_id
      from wip_entities we, xxpha_organizations_v o
     where 1 = 1
       and o.ORGANIZATION_ID = we.ORGANIZATION_ID
       and we.WIP_ENTITY_ID = p_wip_entity_id;
  
    price_id := to_number(fnd_profile.value_specific(name   => 'XXPHA_PRICELIST_4_INT_REQ',
                                                     org_id => l_oe_id));
  
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_items_pipe: price_id = ' ||
                                                     price_id);
  
    $end
  
    delete from XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT;
  
    insert into xxpha.xxpha_sn1041_item_search_rslt
      (score,
       inventory_item_id,
       po_line_id,
       item_code,
       catalog_code,
       description,
       sup_description,
       price,
       uom,
       cs_quantity,
       cs_available_quantity,
       store_quantity,
       store_available_quantity,
       holding_quantity,
       holding_available_quantity,
       deliveries,
       supplier,
       image,
       analog,
       deactivation,
       last_update_date,
       index_name,
       score_str,
       --search_item_id,
       vendor_id,
       wip_entity_id,
       OPERATION_SEQ_NUM,
       WIP_SUBINVENTORY,
       WIP_LOCATOR_ID,
       WIP_DATE_REQUIRED,
       WIP_GL_DATE,
       AGREEMENT,
       WIP_BUYER_NOTES,
       WIP_OL_NUM,
       WIP_OL_DATE)
      select 1 as score,
             se.inventory_item_id,
             se.po_line_id,
             se.item_code,
             se.vendor_product_num catalog_code,
             se.item_description description,
             se.sup_description,
             get_item_price(price_id,
                            se.inventory_item_id,
                            se.po_line_id --null
                            /*decode(bq.PO_LINE_ID, -2, null, bq.PO_LINE_ID)*/) price,
             se.item_primary_uom_code uom,
             null cs_quantity,
             null cs_available_quantity,
             null store_quantity,
             null store_available_quantity,
             null holding_quantity,
             null holding_available_quantity,
             /*(select sum(status_quantity)
             from (select unique NVL(qa_status_quantity, NVL2(mn.shipment_line_id, mn.quantity_shipped, NVL2(mn.po_line_location_id, mn.po_line_location_quantity, NVL2(mn.linked_purchase_req_line_id, mn.linked_purchase_req_line_qnt, mn.req_quantity)))) AS status_quantity,
                          mn.po_line_location_id
                     from XXPHA_SN976_STATUS_MV mn
                    where mn.status in
                          ('WAREHOUSE', 'DELAY', 'INTIME', 'ENTRANCE')
                      and mn.item_id = se.inventory_item_id
                      and mn.org_id = l_oe_id /*get_search_tbl.p_oe_id*/
             /*))*/
             null           deliveries,
             se.vendor_name supplier,
             
             null
             /*(select cav.PICTURE
              from icx_cat_attribute_values cav
             where 1=1
               --and bq.PO_LINE_ID1 = cav.PO_LINE_ID
               and se.INVENTORY_ITEM_ID = cav.INVENTORY_ITEM_ID
               and l_oe_id = cav.org_ID)*/ image,
             
             null analog,
             null deactivation,
             null last_update_date,
             null index_name,
             null score_str,
             --null                     search_item_id,
             se.vendor_id vendor_id,
             p_wip_entity_id,
             se.operation_seq_num,
             se.supply_subinventory,
             se.supply_locator_id,
             se.date_required,
             trunc(nvl(se.WIP_GL_DATE, se.date_required)) WIP_GL_DATE,
             se.agreement,
             se.buyer_notes wip_buyer_notes,
             se.wip_ol_num,
             se.wip_ol_date
        from XXPHA_SN1041_EAM_SEARCH_V se
       where 1 = 1
         and se.wip_entity_id = p_wip_entity_id;
  
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_search_tbl: sql%rowcount =  ' ||
                                                     sql%rowcount);
    $end
  
  end get_search_tbl_eam;

  ----------------------------------------------------------------------------------------
  --Поиск с результатами во временной таблице
  procedure get_search_tbl(p_search_str     IN varchar2,
                           p_oe_id          in number,
                           p_store_receiver in number,
                           p_use_elastic    in varchar2 default 'Y') as
    pragma autonomous_transaction;
    price_id         number;
    l_store_receiver number := null; --загрузка. По магазину искать не нужно.
  begin
  
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_search_tbl: search_str = ' ||
                                                     p_search_str);
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_search_tbl: p_oe_id = ' ||
                                                     p_oe_id);
  
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_search_tbl: p_store_receiver = ' ||
                                                     p_store_receiver --l_store_receiver
                                       );
  
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_search_tbl: p_use_elastic = ' ||
                                                     p_use_elastic);
    $end
  
    price_id := to_number(fnd_profile.value_specific(name   => 'XXPHA_PRICELIST_4_INT_REQ',
                                                     org_id => p_oe_id));
  
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_items_pipe: price_id = ' ||
                                                     price_id);
  
    $end
  
    --insert into xxpha.xxpha_sn775_elast (c) values (c);
    --Определить ID центрального склада
    /*select hoi2.ORGANIZATION_ID --, HOI2.ORG_INFORMATION3
     into l_cs_id
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
      and HOI2.ORG_INFORMATION3 = to_char(p_oe_id);*/
  
    /*
      $if XXPHA_SN1041_PKG.DEBUG $then
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_search_tbl: l_cs_id = ' ||
                                                       l_cs_id);
    
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN775_ELASTIC_PROXY_PKG.get_search_tbl: p_org_id = ' ||
                                                       p_org_id);
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN775_ELASTIC_PROXY_PKG.get_search_tbl: p_req_type = ' ||
                                                       p_req_type);
      $end
    */
    delete from XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT;
  
    --goto NO_ACTION;
    if p_use_elastic = 'Y' then
      insert into XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT
        (inventory_item_id,
         ITEM_CODE,
         description,
         sup_description,
         PRICE,
         CATALOG_CODE,
         SCORE,
         LAST_UPDATE_DATE,
         INDEX_NAME,
         SCORE_STR,
         UOM,
         CS_QUANTITY,
         CS_AVAILABLE_QUANTITY,
         STORE_QUANTITY,
         STORE_AVAILABLE_QUANTITY,
         HOLDING_QUANTITY,
         HOLDING_AVAILABLE_QUANTITY,
         SUPPLIER,
         DELIVERIES,
         DEACTIVATION,
         IMAGE,
         PO_LINE_ID,
         VENDOR_ID,
         AGREEMENT)
        select unique tb.ITEM_ID,
               tb.ITEM_CODE,
               tb.ITEM_DESCRIPTION,
               tb.SUP_DESCRIPTION,
               
               /*(select --to_number(ll.operand, '999999999.99')
               ll.operand
                from qp_list_lines_v ll
               where 1 = 1
                 and ll.list_header_id = price_id
                    --aND ll.product_attr_val_disp = '00-300219-02012'
                 and ll.product_id = tb.item_id
                 and sysdate between ll.start_date_active and
                     nvl(ll.end_date_active, sysdate)) PRICE,*/
               --Оптимизиция (П.Наумов)
               get_item_price(price_id, tb.item_id, tb.PO_LINE_ID) PRICE,
               
               tb.VENDOR_PRODUCT_NUM as CATALOG_CODE,
               tb.score,
               sysdate,
               tb.index_name,
               to_char(tb.score),
               tb.UOM,
               tb.CS_QUANTITY,
               tb.CS_AVAILABLE_QUANTITY,
               tb.STORE_QUANTITY,
               tb.STORE_AVAILABLE_QUANTITY,
               tb.HOLDING_QUANTITY - tb.CS_QUANTITY - tb.STORE_QUANTITY,
               tb.HOLDING_AVAILABLE_QUANTITY - tb.CS_AVAILABLE_QUANTITY -
               tb.STORE_AVAILABLE_QUANTITY,
               v.VENDOR_NAME,
               
               (select sum(status_quantity)
                  from (select unique /*NVL(qa_status_quantity, NVL2(mn.shipment_line_id, mn.quantity_shipped, NVL2(mn.po_line_location_id, mn.po_line_location_quantity, NVL2(mn.linked_purchase_req_line_id, mn.linked_purchase_req_line_qnt, mn.req_quantity)))) AS status_quantity,*/ NVL(qa_status_quantity, NVL(mn.receive_qnt, NVL(mn.po_line_location_quantity, NVL(mn.linked_purchase_req_line_qnt, mn.req_quantity)))) AS status_quantity,
                               mn.po_line_location_id
                          from XXPHA_SN976_STATUS_MV mn
                         where mn.status in
                               ('WAREHOUSE', 'DELAY', 'INTIME', 'ENTRANCE')
                           and mn.item_id = tb.ITEM_ID
                           and mn.org_id = get_search_tbl.p_oe_id)) /*null*/ expected_delivery,
               
               tb.DEAKT as DEACTIVATION,
               tb.PICTURE as IMAGE,
               max(tb.po_line_id) over(partition by tb.item_id) as PO_LINE_ID,
               tb.VENDOR_ID,
               tb.AGREEMENT
        
          from table(XXPHA_SN1041_PKG.get_items_pipe(p_search_str     => get_search_tbl.p_search_str,
                                                     p_oe_id          => get_search_tbl.p_oe_id,
                                                     p_store_receiver => get_search_tbl.l_store_receiver,
                                                     p_index_name     => xxpha_rgp001_pkg.INDEX_NAME_IPURCH)) tb,
               PO_VENDORS v
         where 1 = 1
           and tb.VENDOR_ID = v.VENDOR_ID(+)
           and (tb.ITEM_ID is null or exists
                (select 1
                   from apps.mtl_system_items_b msi
                  where 1 = 1
                    and msi.organization_id = p_store_receiver
                    and msi.inventory_item_id = tb.ITEM_ID));
    
      $if XXPHA_SN1041_PKG.DEBUG $then
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_search_tbl: sql%rowcount =  ' ||
                                                       sql%rowcount);
      $end
    
      insert into XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT
        (inventory_item_id,
         ITEM_CODE,
         description,
         sup_description,
         PRICE,
         CATALOG_CODE,
         SCORE,
         LAST_UPDATE_DATE,
         INDEX_NAME,
         SCORE_STR,
         UOM,
         CS_QUANTITY,
         CS_AVAILABLE_QUANTITY,
         STORE_QUANTITY,
         STORE_AVAILABLE_QUANTITY,
         HOLDING_QUANTITY,
         HOLDING_AVAILABLE_QUANTITY,
         SUPPLIER,
         DELIVERIES,
         DEACTIVATION,
         IMAGE,
         PO_LINE_ID,
         VENDOR_ID)
        select unique tb.ITEM_ID,
               tb.ITEM_CODE,
               tb.ITEM_DESCRIPTION,
               tb.SUP_DESCRIPTION,
               
               /*(select --to_number(ll.operand, '999999999.99')
               ll.operand
                from qp_list_lines_v ll
               where 1 = 1
                 and ll.list_header_id = price_id
                    --aND ll.product_attr_val_disp = '00-300219-02012'
                 and ll.product_id = tb.item_id
                 and sysdate between ll.start_date_active and
                     nvl(ll.end_date_active, sysdate)) PRICE,*/
               --Оптимизиция (П.Наумов)
               get_item_price(price_id, tb.item_id, tb.PO_LINE_ID) PRICE,
               
               tb.VENDOR_PRODUCT_NUM as CATALOG_CODE,
               tb.score,
               sysdate,
               tb.index_name,
               to_char(tb.score),
               tb.UOM,
               tb.CS_QUANTITY,
               tb.CS_AVAILABLE_QUANTITY,
               tb.STORE_QUANTITY,
               tb.STORE_AVAILABLE_QUANTITY,
               tb.HOLDING_QUANTITY - tb.CS_QUANTITY - tb.STORE_QUANTITY,
               tb.HOLDING_AVAILABLE_QUANTITY - tb.CS_AVAILABLE_QUANTITY -
               tb.STORE_AVAILABLE_QUANTITY,
               v.VENDOR_NAME,
               
               (select sum(status_quantity)
                  from (select unique /*NVL(qa_status_quantity, NVL2(mn.shipment_line_id, mn.quantity_shipped, NVL2(mn.po_line_location_id, mn.po_line_location_quantity, NVL2(mn.linked_purchase_req_line_id, mn.linked_purchase_req_line_qnt, mn.req_quantity)))) AS status_quantity,*/ NVL(qa_status_quantity, NVL(mn.receive_qnt, NVL(mn.po_line_location_quantity, NVL(mn.linked_purchase_req_line_qnt, mn.req_quantity)))) AS status_quantity,
                               mn.po_line_location_id
                          from XXPHA_SN976_STATUS_MV mn
                         where mn.status in
                               ('WAREHOUSE', 'DELAY', 'INTIME', 'ENTRANCE')
                           and mn.item_id = tb.ITEM_ID
                           and mn.org_id = get_search_tbl.p_oe_id)) /*null*/ expected_delivery,
               
               tb.DEAKT      as DEACTIVATION,
               tb.PICTURE    as IMAGE,
               tb.PO_LINE_ID as PO_LINE_ID,
               tb.VENDOR_ID
        
          from table(XXPHA_SN1041_PKG.get_items_pipe(p_search_str     => get_search_tbl.p_search_str,
                                                     p_oe_id          => get_search_tbl.p_oe_id,
                                                     p_store_receiver => get_search_tbl.l_store_receiver,
                                                     p_index_name     => xxpha_rgp001_pkg.INDEX_NAME_OEBS)) tb,
               PO_VENDORS v
         where 1 = 1
           and tb.VENDOR_ID = v.VENDOR_ID(+)
           and (tb.ITEM_ID is null or exists
                (select 1
                   from apps.mtl_system_items_b msi
                  where 1 = 1
                    and msi.organization_id = p_store_receiver
                    and msi.inventory_item_id = tb.ITEM_ID))
           and not exists
         (select 1
                  from XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT r
                 where r.inventory_item_id = tb.ITEM_ID);
    
      $if XXPHA_SN1041_PKG.DEBUG $then
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_search_tbl: sql%rowcount =  ' ||
                                                       sql%rowcount);
      $end
    else
      insert into XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT
        (inventory_item_id,
         ITEM_CODE,
         description,
         sup_description,
         PRICE,
         CATALOG_CODE,
         SCORE,
         LAST_UPDATE_DATE,
         INDEX_NAME,
         SCORE_STR,
         UOM,
         CS_QUANTITY,
         CS_AVAILABLE_QUANTITY,
         STORE_QUANTITY,
         STORE_AVAILABLE_QUANTITY,
         HOLDING_QUANTITY,
         HOLDING_AVAILABLE_QUANTITY,
         SUPPLIER,
         DELIVERIES,
         DEACTIVATION,
         IMAGE,
         PO_LINE_ID,
         VENDOR_ID,
         AGREEMENT)
      
        select unique               bq.inventory_item_id,
               msi.SEGMENT1,
               msi.DESCRIPTION,
               pla.ITEM_DESCRIPTION sup_description,
               
               get_item_price(price_id,
                              bq.inventory_item_id,
                              decode(bq.PO_LINE_ID, -2, null, bq.PO_LINE_ID)) PRICE,
               
               pla.VENDOR_PRODUCT_NUM CATALOG_CODE,
               bq.s SCORE,
               GREATEST(bq.LAST_UPDATE_DATE1, PLA.LAST_UPDATE_DATE) LAST_UPDATE_DATE,
               'CTX' /*XXPHA_RGP001_PKG.INDEX_NAME_OEBS*/ INDEX_NAME,
               to_char(bq.s) SCORE_STR,
               nvl(bq.unit_meas_lookup_code, msi.PRIMARY_UOM_CODE) UOM,
               null CS_QUANTITY,
               null CS_AVAILABLE_QUANTITY,
               null STORE_QUANTITY,
               null STORE_AVAILABLE_QUANTITY,
               null HOLDING_QUANTITY,
               null HOLDING_AVAILABLE_QUANTITY,
               bq.SUPPLIER SUPPLIER,
               
               (select sum(status_quantity)
                  from (select unique /*NVL(qa_status_quantity, NVL2(mn.shipment_line_id, mn.quantity_shipped, NVL2(mn.po_line_location_id, mn.po_line_location_quantity, NVL2(mn.linked_purchase_req_line_id, mn.linked_purchase_req_line_qnt, mn.req_quantity)))) AS status_quantity,*/ NVL(qa_status_quantity, NVL(mn.receive_qnt, NVL(mn.po_line_location_quantity, NVL(mn.linked_purchase_req_line_qnt, mn.req_quantity)))) AS status_quantity,
                               mn.po_line_location_id
                          from XXPHA_SN976_STATUS_MV mn
                         where mn.status in
                               ('WAREHOUSE', 'DELAY', 'INTIME', 'ENTRANCE')
                           and mn.item_id = bq.inventory_item_id
                           and mn.org_id = bq.owning_org_id)) /*null*/ DELIVERIES,
               
               case
                 when pha.SEGMENT1 is not null then
                  null
                 else
                  (Select mc.SEGMENT1
                     from mtl_item_categories mic
                     join mtl_category_sets mcs
                       on mcs.CATEGORY_SET_ID = mic.CATEGORY_SET_ID
                     join mtl_categories mc
                       on mc.CATEGORY_ID = mic.CATEGORY_ID
                      and mic.ORGANIZATION_ID = 101
                      and mic.INVENTORY_ITEM_ID = bq.INVENTORY_ITEM_ID
                      and mcs.CATEGORY_SET_NAME = 'Позиция к деактивации')
               end DEACTIVATION,
               
               (select cav.PICTURE
                  from icx_cat_attribute_values cav
                 where bq.PO_LINE_ID1 = cav.PO_LINE_ID
                   and bq.INVENTORY_ITEM_ID = cav.INVENTORY_ITEM_ID
                   and bq.org_id = cav.org_ID) IMAGE,
               
               /*decode(bq.PO_LINE_ID, -2, null, bq.PO_LINE_ID)*/
               bq.PO_LINE_ID1 PO_LINE_ID,
               decode(bq.supplier_Id, -2, null, bq.supplier_Id) VENDOR_ID,
               pha.SEGMENT1
        --bq.*
          from (select count(*) over(partition by ctxh.inventory_item_id, ctxh.purchasing_org_id, ctxh.language) as source_count,
                       ctxh.*
                  from (select score(1) s,
                               c.*,
                               max(decode(c.PO_LINE_ID,
                                          -2,
                                          null,
                                          c.PO_LINE_ID)) over(partition by c.inventory_item_id) PO_LINE_ID1,
                               max(c.LAST_UPDATE_DATE) over(partition by c.inventory_item_id) LAST_UPDATE_DATE1
                          from icx_cat_items_ctx_hdrs_tlp c
                         where 1 = 1
                           and contains(c.ctx_desc,
                                        p_search_str
                                        /*'(({00-315025-00368}) & (82 within orgid)) & ((RU within language)*10*10)'*/,
                                        1) > 0) ctxh
                 where 1 = 1) bq,
               mtl_system_items_b msi,
               po_lines_all pla,
               po_headers_all pha
         where 1 = 1
           and (bq.source_count = 1 OR bq.source_type <> 'MASTER_ITEM')
           and msi.INVENTORY_ITEM_ID(+) = bq.inventory_item_id
           and msi.ORGANIZATION_ID = 101
           and pla.PO_LINE_ID(+) = bq.po_line_id
           and pha.PO_HEADER_ID(+) = bq.po_header_Id
           and pha.closed_code is null;
    
      $if XXPHA_SN1041_PKG.DEBUG $then
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'get_search_tbl: sql%rowcount =  ' ||
                                                       sql%rowcount);
      $end
    end if;
  
    <<NO_ACTION>>
  
    commit;
  
    null;
  end get_search_tbl;
  ----------------------------------------------------------------------------------------

  function get_items_pipe(p_search_str     IN varchar2,
                          p_oe_id          in number,
                          p_store_receiver number,
                          p_index_name     in varchar2 default xxpha_rgp001_pkg.INDEX_NAME_IPURCH)
    return t_found_items
    pipelined as
    l_index_name varchar2(50);
    l_res        t_Found_Item;
    price_id     number;
  
    elastic_data xxpha_sn1041_pkg.t_found_item;
  begin
    --Опредлить прайс
    price_id := to_number(fnd_profile.value_specific(name   => 'XXPHA_PRICELIST_4_INT_REQ',
                                                     org_id => p_oe_id));
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.get_items_pipe: price_id = ' ||
                                                     price_id);
  
    $end
  
    if p_index_name = xxpha_rgp001_pkg.INDEX_NAME_IPURCH then
      l_index_name := xxpha_rgp001_pkg.INDEX_NAME_IPURCH;
      for rec in (select l_index_name,
                         jt.score,
                         jt.ITEM_ID,
                         jt.ITEM_CODE,
                         JT.ITEM_DESCR         ITEM_DESCRIPTION,
                         JT.ITEM_DESCR         ITEM_LONG_DESCR,
                         JT.SUP_DESCRIPTION,
                         JT.UOM,
                         JT.VENDOR_ID,
                         JT.VENDOR_PRODUCT_NUM,
                         JT.PO_LINE_ID,
                         cav.PICTURE,
                         ph.SEGMENT1           AGREEMENT
                    from (select XXPHA_SN1041_PKG.get_elastic_items(p_search_str => get_items_pipe.p_search_str,
                                                                    p_index_name => l_index_name,
                                                                    p_org_id     => get_items_pipe.p_oe_id) c
                            from dual) el,
                         JSON_TABLE(el.c,
                                    '$.hits.hits[*]'
                                    columns("PO_LINE_ID" number PATH '$._id',
                                            "SCORE" NUMBER PATH '$._score',
                                            "SUP_DESCRIPTION" VARCHAR2(4000) PATH
                                            '$._source.deskr',
                                            "IS_ACTUAL" VARCHAR2(20) PATH
                                            '$._source.isActual',
                                            "OE_ID" varchar2(100) PATH
                                            '$._source.oe_id',
                                            "OE_ID_LIST" varchar2(100) FORMAT JSON PATH
                                            '$._source.oe_id',
                                            "ITEM_CODE" VARCHAR2(100) PATH
                                            '$._source.oebs_item_code',
                                            "ITEM_ID" NUMBER PATH
                                            '$._source.oebs_item_id',
                                            "ITEM_DESCR" VARCHAR2(500) PATH
                                            '$._source.oebs_descr',
                                            "STORE_ID_LIST" VARCHAR2(100)
                                            FORMAT JSON PATH
                                            '$._source.store_id_list',
                                            "STORE_NAME_LIST" VARCHAR2(500)
                                            FORMAT JSON PATH
                                            '$._source.store_name_list',
                                            "UOM" VARCHAR2(100) PATH
                                            '$._source.uom',
                                            "VENDOR_ID" number PATH
                                            '$._source.vendor_id',
                                            "VENDOR_PRODUCT_NUM" VARCHAR2(100) PATH
                                            '$._source.vendor_product_num')) as jt,
                         icx_cat_attribute_values cav,
                         po_lines_all pl,
                         po_headers_all ph
                   where 1 = 1
                        --ограничение по операционке
                     and pl.PO_LINE_ID = jt.PO_LINE_ID
                     and pl.ORG_ID = p_oe_id
                     and ph.PO_HEADER_ID = pl.PO_HEADER_ID
                     and nvl(ph.END_DATE, sysdate + 1) > sysdate
                     and NVL(PH.CLOSED_CODE, 'OPEN') <> 'CLOSED'
                     and nvl(ph.CLOSED_DATE, sysdate + 1) > sysdate
                     and jt.PO_LINE_ID = cav.PO_LINE_ID(+)
                  
                  ) loop
      
        l_res.index_name := rec.l_index_name;
        l_res.score      := rec.score;
        l_res.item_id    := rec.item_id;
        l_res.ITEM_CODE  := rec.item_code;
      
        l_res.ITEM_DESCRIPTION := rec.item_description;
        l_res.ITEM_LONG_DESCR  := rec.item_long_descr;
      
        l_res.UOM                := rec.uom;
        l_res.DEAKT              := null;
        l_res.SUP_DESCRIPTION    := rec.sup_description;
        l_res.VENDOR_ID          := rec.vendor_id;
        l_res.VENDOR_PRODUCT_NUM := rec.vendor_product_num;
        l_res.PO_LINE_ID         := rec.po_line_id;
        l_res.PICTURE            := rec.picture;
        l_res.AGREEMENT          := rec.Agreement;
      
        l_res.CS_QUANTITY                := 0;
        l_res.CS_AVAILABLE_QUANTITY      := 0;
        l_res.STORE_QUANTITY             := 0;
        l_res.STORE_AVAILABLE_QUANTITY   := 0;
        l_res.HOLDING_QUANTITY           := 0;
        l_res.HOLDING_AVAILABLE_QUANTITY := 0;
      
        pipe row(l_res);
      end loop;
    
    else
      l_index_name := xxpha_rgp001_pkg.INDEX_NAME_OEBS;
      declare
        l_row_counter number := 0;
        l_cs_id       number;
        l_cs_quantity number;
      begin
        --Определить ID центрального склада
        select hoi2.ORGANIZATION_ID --, HOI2.ORG_INFORMATION3
          into l_cs_id
          from HR_ORGANIZATION_INFORMATION HOI2,
               mtl_parameters              p,
               HR_ALL_ORGANIZATION_UNITS   HOU
         where 1 = 1
           AND (HOI2.ORG_INFORMATION_CONTEXT || '') =
               'Accounting Information'
           and p.ORGANIZATION_ID = hoi2.ORGANIZATION_ID
           and p.ATTRIBUTE15 = 'Центральный'
           and p.ATTRIBUTE10 = 'Группа учета материалов'
           and hou.organization_id = p.ORGANIZATION_ID
           and sysdate between hou.date_from and nvl(hou.date_to, sysdate)
           and p.ORGANIZATION_CODE <> 'ЧЦ0'
           and HOI2.ORG_INFORMATION3 = to_char(p_oe_id);
      
        $if XXPHA_SN1041_PKG.DEBUG $THEN
        XXPHA_PNAUMOV_PKG.insert_log_table('l_cs_id = ' || l_cs_id);
        $END
      
        for rec in (select l_index_name,
                           jt.score,
                           jt.ITEM_ID,
                           jt.ITEM_CODE,
                           ITEM_DESCRIPTION,
                           ITEM_LONG_DESCR,
                           UOM,
                           DEAKT
                      from (select XXPHA_SN1041_PKG.get_elastic_items(p_search_str => get_items_pipe.p_search_str,
                                                                      p_index_name => l_index_name) c
                              from dual) el,
                           JSON_TABLE(el.c,
                                      '$.hits.hits[*]'
                                      columns("ITEM_ID" NUMBER PATH '$._id',
                                              "SCORE" NUMBER PATH '$._score',
                                              "ITEM_CODE" VARCHAR2(50) PATH
                                              '$._source.code',
                                              "ITEM_DESCRIPTION"
                                              VARCHAR2(4000) PATH
                                              '$._source.deskr',
                                              "ITEM_LONG_DESCR" VARCHAR2(4000) PATH
                                              '$._source.long_deskr',
                                              "UOM" VARCHAR2(100) PATH
                                              '$._source.uom',
                                              "ZAKUP_KAT" VARCHAR2(100) PATH
                                              '$._source.zakup_kat',
                                              "DEAKT" VARCHAR2(100) PATH
                                              '$._source.deakt',
                                              "PURCH_ENABLED" VARCHAR2(100) PATH
                                              '$._source.purch_enabled',
                                              "IS_IN_IPURCH" VARCHAR2(20) PATH
                                              '$._source.isInIpurch')) as jt) loop
        
          if rec.deakt is not null then
            begin
              select SUM(CASE
                           WHEN s.organization_type = 0 THEN
                            nvl(NVL2(s.sales_order_id,
                                     s.reserved_quantity,
                                     s.positiv_avail_quantity),
                                0)
                           ELSE
                            0
                         END) AS cs_quantity
                into l_cs_quantity
                from (select organization_type,
                             organization_id,
                             sales_order_id,
                             reserved_quantity,
                             DECODE(SIGN(o.available_quantity),
                                    -1,
                                    0,
                                    o.available_quantity) AS positiv_avail_quantity,
                             o.inventory_item_id
                        from xxpha_sn976_onhand_info_mv o
                       where 1 = 1
                         and o.inventory_item_id = rec.item_id
                         and o.organization_id = l_cs_id) s;
            exception
              when no_data_found then
                l_cs_quantity := 0;
            end;
          
            $if XXPHA_SN1041_PKG.DEBUG $THEN
            XXPHA_PNAUMOV_PKG.insert_log_table('rec.item_id = ' ||
                                               rec.item_id ||
                                               ' =>  l_cs_quantity = ' ||
                                               l_cs_quantity ||
                                               ' =>  rec.item_description = ' ||
                                               rec.item_description);
            $END
          
            if l_cs_quantity is null or l_cs_quantity = 0 then
              declare
                l_pair_quant number := get_pair_available_qant(p_organization_id   => l_cs_id,
                                                               p_inventory_item_id => rec.item_id);
              begin
                if l_pair_quant = 0 then
                  continue;
                end if;
              end;
            end if;
          end if;
        
          l_row_counter := l_row_counter + 1;
        
          if l_row_counter >
             fnd_profile.value('XXPHA_SN775_ELASTIC_RESULT') then
            exit;
          end if;
        
          l_res.index_name                 := rec.l_index_name;
          l_res.score                      := rec.score;
          l_res.item_id                    := rec.item_id;
          l_res.ITEM_CODE                  := rec.item_code;
          l_res.ITEM_DESCRIPTION           := rec.item_description;
          l_res.ITEM_LONG_DESCR            := rec.item_long_descr;
          l_res.UOM                        := rec.uom;
          l_res.DEAKT                      := rec.deakt;
          l_res.SUP_DESCRIPTION            := null;
          l_res.VENDOR_ID                  := null;
          l_res.VENDOR_PRODUCT_NUM         := null;
          l_res.PO_LINE_ID                 := null;
          l_res.CS_QUANTITY                := l_cs_quantity;
          l_res.CS_AVAILABLE_QUANTITY      := 0;
          l_res.STORE_QUANTITY             := 0;
          l_res.STORE_AVAILABLE_QUANTITY   := 0;
          l_res.HOLDING_QUANTITY           := 0;
          l_res.HOLDING_AVAILABLE_QUANTITY := 0;
        
          pipe row(l_res);
        end loop;
      end;
    end if;
  end get_items_pipe;

  ----------------------------------------------------------------------------------------------------------------------------
  function get_store(p_po_line_id number,
                     p_org_id     number,
                     x_STORE_ID   out number) return varchar2 is
    v_vendor_id  number;
    v_store_name ICX_CAT_SHOP_STORES_VL.NAME%type;
  
  begin
    x_STORE_ID := null;
    add_log('get_store p_po_line_id= ' || p_po_line_id);
    --Для позиций не из ИМ
    if p_po_line_id is null then
      return null;
    end if;
  
    --get vendor_id from by OSZ
    select h.VENDOR_ID
      into v_vendor_id
      from po_headers_all h
     inner join po_lines_all l
        on h.PO_HEADER_ID = l.PO_HEADER_ID
     where l.PO_LINE_ID = p_po_line_id;
  
    --TODO get store (if has 1 store)
    select s.NAME, s.STORE_ID
      into v_store_name, x_STORE_ID
      from icx_cat_content_zones_vl z
     inner join icx_cat_zone_secure_attributes a
        on z.ZONE_ID = a.ZONE_ID
     inner join po_vendors v
        on a.SUPPLIER_ID = v.VENDOR_ID
     inner join po_vendor_sites_all vs
        on vs.VENDOR_SITE_ID = a.SUPPLIER_SITE_ID
     inner join icx_cat_store_contents c
        on c.CONTENT_ID = z.ZONE_ID
      left join ICX_CAT_SHOP_STORES_VL s
        on s.STORE_ID = c.STORE_ID
     where 1 = 1
       and v.VENDOR_ID = v_vendor_id
       and vs.ORG_ID = p_org_id;
  
    add_log('v_store_name = ' || v_store_name || ', x_STORE_ID = ' ||
            x_STORE_ID);
    return v_store_name;
  
  exception
    --Не заполняем, ибо 1 поставщик поставляется в несколько ИМ. Пусть юзер сам выберет
    --Сейчас таких случаев нет
    when too_many_rows then
      return null;
  end get_store;

  ----------------------------------------------------------------------------------------------------------------------------
  function check_select_item(p_search_row    xxpha.xxpha_sn1041_item_search_rslt%rowtype,
                             p_wip_entity_id number,
                             x_mess          out varchar2) return boolean is
    v_count number;
  begin
    --Нет позиции
    if p_search_row.inventory_item_id is null then
      x_mess := 'Для позиции нет созданной позиции в КИС';
      return false;
    end if;
  
    --TODO Нет цены (из темп таблицы)
    if NVL(p_search_row.price, 0) = 0 then
      x_mess := 'Позиция ' || p_search_row.item_code ||
                ' не добавлена. Не определена цена.';
      return false;
    end if;
  
    --Уже добавлена (из пост. таблицы)
  
    if p_wip_entity_id is not null then
      select count(*)
        into v_count
        from XXPHA.XXPHA_SN1041_REQ_ITEMS r
       where r.item_id = p_search_row.inventory_item_id
         and r.OPERATION_SEQ_NUM = p_search_row.operation_seq_num;
    else
      select count(*)
        into v_count
        from XXPHA.XXPHA_SN1041_REQ_ITEMS r
       where r.item_id = p_search_row.inventory_item_id;
    end if;
  
    if v_count > 0 then
      x_mess := 'Позиция ' || p_search_row.item_code ||
                ' уже ранее добавлена.';
      return false;
    end if;
  
    return true;
  end check_select_item;

  ----------------------------------------------------------------------------------------------------------------------------
  function add_selected_items(p_search_item_id  in number, --FND_TABLE_OF_NUMBER
                              p_oe_id           number,
                              p_organization_id number,
                              p_wip_entity_id   number,
                              p_cs_quantity     number default 0,
                              x_messages        out varchar2) return number as
    --l_current_max_line_num number;
    --l_source_organization_id number;
    l_item_row           XXPHA.XXPHA_SN1041_REQ_ITEMS%rowtype;
    l_search_row         xxpha.xxpha_sn1041_item_search_rslt%rowtype;
    l_time               xxpha_nsi000_pkg.delivery_time_rec_type;
    v_req_item_id        number;
    l_agent_id           number;
    l_planner_code       VARCHAR2(10);
    l_flag_input_control VARCHAR2(1);
    l_category_id        number;
    l_pair_quant         number;
  begin
    -- x_messages.extend;
    --Получение поиской строки
    select *
      into l_search_row
      from xxpha.xxpha_sn1041_item_search_rslt i
     where i.search_item_id = p_search_item_id;
  
    --Выполенение проверок
    if not check_select_item(l_search_row, p_wip_entity_id, x_messages) then
      add_log(x_messages);
      raise check_select_item_ex;
    end if;
  
    --Получение аттрибутов
    select nvl(max(LINE_NUM), 0) + 1
      into l_item_row.line_num
      from XXPHA.XXPHA_SN1041_REQ_ITEMS;
  
    $IF XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.add_selected_items: l_item_row.line_num = ' ||
                                                     l_item_row.line_num);
    $END
  
    -- Находим Склад-отправитель по ОЕ
    select hoi2.ORGANIZATION_ID
      into l_item_row.source_organization_id
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
       and HOI2.ORG_INFORMATION3 = to_char(p_oe_id);
  
    $IF XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.add_selected_items: l_item_row.source_organization_id = ' ||
                                                     l_item_row.source_organization_id);
    $END
  
    --Расчет срока поставки
    xxpha_nsi000_pkg.get_list_bayer(p_item_id            => l_search_row.inventory_item_id,
                                    p_org_id             => p_oe_id,
                                    x_agent_id           => l_agent_id,
                                    x_delivery_time      => l_time,
                                    x_planner_code       => l_planner_code,
                                    x_flag_input_control => l_flag_input_control,
                                    x_category_id        => l_category_id);
  
    l_item_row.delivery_date := l_time.time_purchase + l_time.time_tender +
                                l_time.time_contract + l_time.time_delivery +
                                l_time.time_input_control;
  
    --Расчет расположения для организации-получателя
    /*
    select l.location_id
      into l_item_row.DELIVER_TO_LOCATION_ID
      from hr_locations l
     where l.inventory_organization_id = p_organization_id
       and rownum = 1; -- Пока берем любую
    */
    begin
      select l.location_id
        into l_item_row.DELIVER_TO_LOCATION_ID
        from HR_ORGANIZATION_UNITS_V l
       where l.organization_id = p_organization_id
         and rownum = 1;
    exception
      when others then
        select l.location_id
          into l_item_row.DELIVER_TO_LOCATION_ID
          from hr_locations l
         where l.inventory_organization_id = p_organization_id
           and rownum = 1; -- Пока берем любую
    end;
  
    --Определение ИМ
    begin
      l_item_row.SUPPLIER := get_store(l_search_row.po_line_id,
                                       p_oe_id,
                                       l_item_row.SUPPLIER_ID); --Поставщик
    
    exception
      when others then
        x_messages := 'Ошибка при определении И-М.' || sqlerrm;
        add_log(x_messages || ' po_line_id = ' || l_search_row.po_line_id);
        raise check_select_item_ex;
    end;
  
    l_item_row.item_id                 := l_search_row.inventory_item_id;
    l_item_row.ORG_ID                  := p_oe_id;
    l_item_row.dest_organization_id    := p_organization_id;
    l_item_row.deliver_to_requestor_id := fnd_global.EMPLOYEE_ID;
    l_item_row.PREPARER_ID             := fnd_global.EMPLOYEE_ID;
    l_item_row.DESCRIPTIONS            := l_search_row.description;
    l_item_row.ITEM_CODE               := l_search_row.item_code;
    l_item_row.CATALOG_NUM             := l_search_row.catalog_code;
    l_item_row.SUP_DESCRIPTION         := l_search_row.sup_description;
    l_item_row.UNIT_PRICE              := l_search_row.price;
    l_item_row.UOM                     := l_search_row.uom;
  
    if nvl(l_search_row.cs_available_quantity, 0) > 0 then
      l_item_row.CS_AVAILABLE_QUANTITY := l_search_row.cs_available_quantity;
    else
      l_item_row.CS_AVAILABLE_QUANTITY := p_cs_quantity;
    end if;
    --l_item_row.NEED_BY_DATE            := sysdate + 3; заполняется в момент подачи заявки
  
    l_item_row.DEACTIVATION      := l_search_row.deactivation;
    l_item_row.INDEX_NAME        := l_search_row.index_name;
    l_item_row.created_by        := fnd_global.USER_ID;
    l_item_row.last_updated_by   := fnd_global.USER_ID;
    l_item_row.LAST_UPDATE_DATE  := sysdate;
    l_item_row.CREATION_DATE     := sysdate;
    l_item_row.last_update_login := fnd_global.LOGIN_ID;
  
    l_item_row.requisition_type := get_requisition_type(l_search_row.catalog_code,
                                                        l_item_row.CS_AVAILABLE_QUANTITY);
    $IF XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.add_selected_items: l_item_row.requisition_type = ' ||
                                                     l_item_row.requisition_type);
    $END
  
    /*
    Позиция к деактивации для Механик:
    при нулевом наличии на ЦС Механик проверяем наличие на складе Апатит
    */
    if l_item_row.DEACTIVATION is not null and
       nvl(l_item_row.CS_AVAILABLE_QUANTITY, 0) = 0 then
      declare
        l_pair_quant number := 0;
      begin
        l_pair_quant := get_pair_available_qant(p_organization_id   => l_item_row.source_organization_id,
                                                p_inventory_item_id => l_item_row.item_id);
        if l_pair_quant > 0 then
          l_item_row.requisition_type := get_requisition_type(l_search_row.catalog_code,
                                                              l_pair_quant);
        end if;
      end;
    end if;
  
    l_item_row.is_processed := 'N';
    l_item_row.po_line_id   := l_search_row.po_line_id;
    --Ремонтные операции
    l_item_row.WIP_ENTITY_ID     := p_wip_entity_id;
    l_item_row.OPERATION_SEQ_NUM := l_search_row.operation_seq_num;
    l_item_row.WIP_SUBINVENTORY  := l_search_row.wip_subinventory;
    l_item_row.WIP_LOCATOR_ID    := l_search_row.wip_locator_id;
    l_item_row.wip_buyer_notes   := l_search_row.wip_buyer_notes;
    l_item_row.wip_ol_num        := l_search_row.wip_ol_num;
    l_item_row.wip_ol_date       := l_search_row.wip_ol_date;
  
    if l_search_row.wip_entity_id is not null then
      declare
        l_wip_due_date date;
      begin
        select trunc(sysdate) +
               XXPHA_NSI000_PKG.get_lt_total(l_item_row.item_id, p_oe_id)
          into l_wip_due_date
          from dual;
        l_item_row.wip_due_date := l_wip_due_date;
      exception
        when others then
          add_log(p_msg => sqlerrm);
      end;
    end if;
  
    if nvl(p_wip_entity_id, -1) > 0 then
      l_item_row.WIP_DATE_REQUIRED := nvl(l_search_row.wip_date_required,
                                          Get_Wip_Sheduled_Start_Date(p_wip_entity_id));
      l_item_row.WIP_GL_DATE       := nvl(l_search_row.wip_gl_date,
                                          Get_Wip_Sheduled_Start_Date(p_wip_entity_id));
    end if;
  
    l_item_row.RESP_ID := fnd_global.RESP_ID;
  
    --Вставка строки
    insert into XXPHA.XXPHA_SN1041_REQ_ITEMS
    values l_item_row
    returning req_item_id into v_req_item_id;
  
    --Заполнение доп. аттрибутов для ремонтов
    if nvl(p_wip_entity_id, -1) > 0 then
      xxpha_sn1041_eam_pkg.Fill_MVZ_CFO(v_req_item_id);
    end if;
  
    commit;
  
    add_log('end add_selected_items');
    x_messages := 'Позиция ' || l_item_row.ITEM_CODE || ' добавлена';
    return 0;
  
  exception
    when check_select_item_ex then
      return 1;
    when others then
      add_log(sqlerrm);
      add_log(dbms_utility.format_error_backtrace);
      add_log('Параметры запуска: p_search_item_id =' || p_search_item_id ||
              ', p_oe_id = ' || p_oe_id || ', p_organization_id = ' ||
              p_organization_id || ', p_wip_entity_id = ' ||
              p_wip_entity_id || ', p_cs_quantity = ' || p_cs_quantity);
    
      x_messages := 'Критическая ошибка по позиции ' ||
                    l_search_row.ITEM_CODE || '. ' || sqlerrm;
    
      return 2;
  end add_selected_items;

  ----------------------------------------------------------------------------------------------------------------------------
  function delete_selected_items(line_num in varchar2) return number as
    l_row_count number;
  begin
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.delete_selected_items: line_num  = ' ||
                                                     delete_selected_items.line_num);
    $end
  
    delete from XXPHA.XXPHA_SN1041_REQ_ITEMS ri
     where ri.line_num = to_number(delete_selected_items.line_num);
    l_row_count := sql%rowcount;
  
    $if XXPHA_SN1041_PKG.DEBUG $then
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'XXPHA_SN1041_PKG.delete_selected_items: l_row_count  = ' ||
                                                     l_row_count);
    $end
  
    return l_row_count;
  exception
    when others then
      return - 1;
  end delete_selected_items;

  ----------------------------------------------------------------------------------------------------------------------------
  function have_draft return varchar2 as
    l_counter number := 0;
    l_result  varchar2(1) := '';
  begin
    select count(*)
      into l_counter
      from xxpha.xxpha_sn1041_req_items v
     where v.IS_PROCESSED = 'N';
    if l_counter > 0 then
      l_result := 'Y';
    else
      l_result := 'N';
    end if;
    return l_result;
  end have_draft;

  ----------------------------------------------------------------------------------------------------------------------------
  function delete_draft return number as
  begin
    delete from xxpha.xxpha_sn1041_req_items v;
    return sql%rowcount;
  end delete_draft;

  ----------------------------------------------------------------------------------------------------------------------------
  --Получить ID центрального склада
  --По текущей ORG_ID
  function Get_CS_ID(p_org_id varchar2) return number as
    l_result number;
  begin
    select hoi2.ORGANIZATION_ID
      into l_result
      from HR_ORGANIZATION_INFORMATION HOI2,
           mtl_parameters              p,
           HR_ALL_ORGANIZATION_UNITS   HOU
     where 1 = 1
       AND (HOI2.ORG_INFORMATION_CONTEXT || '') = 'Accounting Information'
       and HOI2.ORG_INFORMATION3 = p_org_id --to_char(fnd_global.ORG_ID) --to_char(l_pair_ou);
       and p.ORGANIZATION_ID = hoi2.ORGANIZATION_ID
       and p.ATTRIBUTE15 = 'Центральный'
       and p.ATTRIBUTE10 = 'Группа учета материалов'
       and p.ORGANIZATION_CODE <> 'ЧЦ0'
       and hou.organization_id = p.ORGANIZATION_ID
       and sysdate between hou.date_from and nvl(hou.date_to, sysdate);
    return l_result;
  exception
    when no_data_found then
      return(-1);
  end Get_CS_ID;

  ----------------------------------------------------------------------------------------------------------------------------
  --Получить ID склада текущей сессии
  function Get_Cur_Ses_Store_ID return number as
    l_Current_Store number;
  begin
    select s.store_id
      into l_Current_Store
      from xxpha.xxpha_sn1041_session s
     where 1 = 1
       and s.s_id = (select max(s1.s_id)
                       from xxpha.xxpha_sn1041_session s1
                      where 1 = 1
                        and s1.user_id = fnd_global.USER_ID
                        and s1.resp_id = fnd_global.RESP_ID);
    return l_Current_Store;
  exception
    when no_data_found then
      return(-1);
  end Get_Cur_Ses_Store_ID;

  ----------------------------------------------------------------------------------------------------------------------------

  function Add_Analog(p_item_ids              in fnd_table_of_number,
                      p_item_codes            in fnd_table_of_varchar2_30,
                      p_item_descriptions     in fnd_table_of_varchar2_4000,
                      p_uom                   in fnd_table_of_varchar2_30,
                      p_cs_available_quantity in fnd_table_of_number,
                      p_oe_id                 in number,
                      p_organization_id       in number,
                      p_wip_entity_id         number := NULL,
                      x_out_messages          out fnd_table_of_varchar2_4000)
    return number as
    l_Count number := 0;
  
    l_messages               varchar2(32676);
    l_add_selected_items_res number;
  
    l_search_item_id       xxpha.xxpha_sn1041_item_search_rslt.search_item_id%type;
    elastic_data           xxpha_sn1041_pkg.t_Found_Item;
    l_out_messages         fnd_table_of_varchar2_4000 := fnd_table_of_varchar2_4000();
    price_id               number;
    l_Deact_No_CS_Quantity varchar2(1) := 'N';
  begin
    price_id := to_number(fnd_profile.value_specific(name   => 'XXPHA_PRICELIST_4_INT_REQ',
                                                     org_id => p_oe_id));
    select count(*) into l_Count from xxpha.xxpha_sn1041_item_search_rslt;
    $IF XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog: l_count = ' ||
                                                     l_count);
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog: p_oe_id = ' ||
                                                     p_oe_id);
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog: p_organization_id = ' ||
                                                     p_organization_id);
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog: price_id = ' ||
                                                     price_id);
    xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog: p_wip_entity_id = ' ||
                                                     p_wip_entity_id);
    $END
  
    delete from xxpha.xxpha_sn1041_item_search_rslt where 1 = 1;
  
    for i in 1 .. p_item_ids.count loop
      add_log(p_item_ids(i));
    
      l_Deact_No_CS_Quantity := 'N';
    
      begin
        select index_name,
               score,
               item_id,
               ITEM_CODE,
               ITEM_DESCRIPTION,
               ITEM_LONG_DESCR,
               SUP_DESCRIPTION,
               get_item_price(price_id, t.item_id, t.PO_LINE_ID) PRICE,
               UOM,
               VENDOR_ID,
               VENDOR_PRODUCT_NUM,
               PO_LINE_ID,
               DEAKT,
               CS_QUANTITY,
               CS_AVAILABLE_QUANTITY,
               STORE_QUANTITY,
               STORE_AVAILABLE_QUANTITY,
               HOLDING_QUANTITY,
               HOLDING_AVAILABLE_QUANTITY,
               PICTURE,
               AGREEMENT
          into elastic_data
          from table(get_items_pipe(p_search_str     => p_item_codes(i),
                                    p_oe_id          => Add_Analog.p_oe_id,
                                    p_store_receiver => Add_Analog.p_organization_id)) t
         where 1 = 1
           and rownum = 1;
      exception
        when no_data_found then
          begin
            $IF XXPHA_SN1041_PKG.DEBUG $THEN
            xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog: NO_DATA_FOUND !');
            $END
            select index_name,
                   score,
                   item_id,
                   ITEM_CODE,
                   ITEM_DESCRIPTION,
                   ITEM_LONG_DESCR,
                   SUP_DESCRIPTION,
                   get_item_price(price_id, t.item_id, t.PO_LINE_ID) PRICE,
                   UOM,
                   VENDOR_ID,
                   VENDOR_PRODUCT_NUM,
                   PO_LINE_ID,
                   DEAKT,
                   CS_QUANTITY,
                   CS_AVAILABLE_QUANTITY,
                   STORE_QUANTITY,
                   STORE_AVAILABLE_QUANTITY,
                   HOLDING_QUANTITY,
                   HOLDING_AVAILABLE_QUANTITY,
                   PICTURE,
                   AGREEMENT
              into elastic_data
              from table(get_items_pipe(p_search_str     => p_item_codes(i),
                                        p_oe_id          => Add_Analog.p_oe_id,
                                        p_store_receiver => Add_Analog.p_organization_id,
                                        p_index_name     => xxpha_rgp001_pkg.INDEX_NAME_OEBS)) t
             where 1 = 1
               and rownum = 1;
          exception
            when no_data_found then
              $IF XXPHA_SN1041_PKG.DEBUG $THEN
              xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog: NO_DATA_FOUND FATAL !!!');
              $END
            
              l_Deact_No_CS_Quantity := 'Y';
          end;
      end;
    
      $IF XXPHA_SN1041_PKG.DEBUG $THEN
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog (before insert): elastic_data.PRICE=' ||
                                                       elastic_data.PRICE ||
                                                       ',elastic_data.PO_LINE_ID=' ||
                                                       elastic_data.PO_LINE_ID ||
                                                       ',elastic_data.item_id=' ||
                                                       elastic_data.item_id ||
                                                       ',price_id=' ||
                                                       price_id);
    
      $END
    
      --Если по логике поиска не найдена позиция
      if (l_Deact_No_CS_Quantity = 'Y') then
        elastic_data.item_id := p_item_ids(i);
        elastic_data.PRICE   := get_item_price(price_id,
                                               p_item_ids(i),
                                               elastic_data.PO_LINE_ID);
      end if;
    
      insert into xxpha.xxpha_sn1041_item_search_rslt
        (score,
         inventory_item_id,
         po_line_id,
         item_code,
         catalog_code,
         description,
         sup_description,
         price,
         uom,
         cs_quantity,
         cs_available_quantity,
         store_quantity,
         store_available_quantity,
         holding_quantity,
         holding_available_quantity,
         deliveries,
         supplier,
         image,
         analog,
         deactivation,
         last_update_date,
         index_name,
         score_str,
         WIP_ENTITY_ID)
      values
        (elastic_data.score,
         p_item_ids(i),
         elastic_data.PO_LINE_ID,
         p_item_codes(i),
         elastic_data.VENDOR_PRODUCT_NUM,
         p_item_descriptions(i),
         elastic_data.SUP_DESCRIPTION,
         elastic_data.PRICE,
         
         p_uom(i),
         0,
         p_cs_available_quantity(i),
         0,
         0,
         0,
         0,
         null,
         elastic_data.VENDOR_ID,
         null,
         null,
         elastic_data.DEAKT,
         sysdate,
         'analog',
         null,
         Add_Analog.p_wip_entity_id);
    
      $IF XXPHA_SN1041_PKG.DEBUG $THEN
      xxpha_pnaumov_pkg.insert_log_table(pr_message => 'Add_Analog: insert  sql%rowcount = ' ||
                                                       sql%rowcount);
    
      $END
    
      begin
        select sr.search_item_id
          into l_search_item_id
          from xxpha.xxpha_sn1041_item_search_rslt sr
         where 1 = 1
           and sr.inventory_item_id = p_item_ids(i);
      
        if l_Deact_No_CS_Quantity = 'N' then
          l_add_selected_items_res := add_selected_items(p_search_item_id  => l_search_item_id,
                                                         p_oe_id           => Add_Analog.p_oe_id,
                                                         p_organization_id => Add_Analog.p_organization_id,
                                                         p_wip_entity_id   => Add_Analog.p_wip_entity_id,
                                                         x_messages        => l_messages);
        else
          /*
          l_messages := 'Позиция ' || p_item_codes(i) ||
                       ' не может быть добавлена. Позиция к деактивации. Нет наличного количества на ЦС.';
          */
          begin
            fnd_message.SET_NAME(APPLICATION => 'XXPHA',
                                 NAME        => 'XXPHA_SN1041_DEACT_NO_AVAIL_CS');
            fnd_message.SET_TOKEN(TOKEN => 'ITEM_CODE',
                                  VALUE => p_item_codes(i));
            l_messages := fnd_message.GET;
          end;
        end if;
      
        add_log(l_messages);
      
        l_out_messages.extend();
        l_out_messages(l_out_messages.last) := l_messages;
        l_Count := l_Count + 1;
      end;
    
    end loop;
  
    x_out_messages := l_out_messages;
  
    return l_count;
  end Add_Analog;

  ----------------------------------------------------------------------------------------------------------------------------
  procedure Refresh_Price(p_org_id       in number,
                          p_vendor_codes in FND_TABLE_OF_VARCHAR2_120,
                          x_out_messages out FND_TABLE_OF_VARCHAR2_4000) as
    l_out_messages fnd_table_of_varchar2_4000 := fnd_table_of_varchar2_4000();
    l_messages     varchar2(32676);
  begin
    for i in 1 .. p_vendor_codes.count loop
      $if XXPHA_SN1041_PKG.DEBUG $THEN
      xxpha_pnaumov_pkg.insert_log_table('Refresh_Price.p_vendor_codes[' || i ||
                                         '] = ' || p_vendor_codes(i));
      $END
    
      declare
        l_request_id number;
      begin
        l_request_id := fnd_request.submit_request(application => 'XXPHA',
                                                   program     => 'XXPHA_SN990',
                                                   description => null,
                                                   start_time  => null,
                                                   sub_request => false,
                                                   argument1   => -1, --p_org_id, --org_id
                                                   argument2   => -1, --blanket_header
                                                   argument3   => p_vendor_codes(i) --blanket_line
                                                   );
        commit;
      
        $if XXPHA_SN1041_PKG.DEBUG $THEN
        xxpha_pnaumov_pkg.insert_log_table('Refresh_Price.l_request_id = ' ||
                                           l_request_id);
        $END
      
        l_messages := 'Позиция ' || p_vendor_codes(i) || ' : ';
        if l_request_id = 0 then
          l_messages := l_messages ||
                        'Ошибка запуска параллельной программы ФА.SN990 "Актуальные цены от поставщика"!';
        else
          l_messages := l_messages ||
                        'Запущена параллельная программа ФА.SN990 "Актуальные цены от поставщика". Проверьте лог параллельной программы.';
        end if;
      
        $if XXPHA_SN1041_PKG.DEBUG $THEN
        xxpha_pnaumov_pkg.insert_log_table('Refresh_Price.l_messages = ' ||
                                           l_messages);
        $END
      
        l_out_messages.extend();
        l_out_messages(l_out_messages.last) := l_messages;
      
      end;
    end loop;
  
    x_out_messages := l_out_messages;
  end Refresh_Price;
  ----------------------------------------------------------------------------------------------------------------------------

  procedure Clear_Draft as
    l_counter number;
  begin
    $if XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('Clear_Draft - Start!');
    $END
  
    --Определить есть ли привязанные заявки в статусе не "Утверждено"
    select count(*)
      into l_counter
      from xxpha.xxpha_sn1041_req_items ri,
           po_requisition_lines_all     rl,
           po_requisition_headers_all   rh
     where 1 = 1
       and ri.req_line_id = rl.REQUISITION_LINE_ID(+)
       and rh.REQUISITION_HEADER_ID(+) = rl.REQUISITION_HEADER_ID
       and nvl(rh.AUTHORIZATION_STATUS, 'NULL') <> 'APPROVED';
  
    if l_counter = 0 then
      delete from xxpha.xxpha_sn1041_req_items;
    
      $if XXPHA_SN1041_PKG.DEBUG $THEN
      xxpha_pnaumov_pkg.insert_log_table('Clear_Draft: deleted !' ||
                                         sql%rowcount);
      $END
    
      commit;
    end if;
  
  end Clear_Draft;
  ----------------------------------------------------------------------------------------------------------------------------
  function Get_Organization_Id(p_organization_code in varchar2) return number as
    l_Organization_Id xxpha_organizations_v.ORGANIZATION_ID%type;
  begin
    select o.ORGANIZATION_ID
      into l_Organization_Id
      from xxpha_organizations_v o
     where o.ORGANIZATION_CODE = p_organization_code;
    return l_Organization_Id;
  exception
    when others then
      return null;
  end Get_Organization_Id;

  ----------------------------------------------------------------------------------------------------------------------------
  procedure Clear_Search as
  begin
    delete from xxpha.xxpha_sn1041_item_search_rslt;
  end Clear_Search;

  ----------------------------------------------------------------------------------------------------------------------------
  function Get_Wip_Organization_ID(p_wip_entity_id in number) return number as
    L_ORGANIZATION_ID wip_entities.WIP_ENTITY_ID%type;
  begin
    select we.ORGANIZATION_ID
      into L_ORGANIZATION_ID
      from wip_entities we
     where 1 = 1
       and we.WIP_ENTITY_ID = p_wip_entity_id;
    return L_ORGANIZATION_ID;
  exception
    when others then
      begin
        $IF  XXPHA_SN1041_PKG.DEBUG $THEN
        xxpha_pnaumov_pkg.insert_log_table('Get_Wip_Organization_ID - Error!');
        xxpha_pnaumov_pkg.insert_log_table(sqlerrm);
        $END
        return - 1;
      end;
  end Get_Wip_Organization_ID;
  ----------------------------------------------------------------------------------------------------------------------------
  function Get_Org_Id_By_Organization_ID(p_organization_id in number)
    return number as
    L_OPERATING_UNIT_ID xxpha_ou_v.ORGANIZATION_ID%type;
  begin
    select org.OPERATING_UNIT
      into L_OPERATING_UNIT_ID
      from xxpha_organizations_v org
     where 1 = 1
       and org.ORGANIZATION_ID = p_organization_id;
    return L_OPERATING_UNIT_ID;
  exception
    when others then
      begin
        $IF  XXPHA_SN1041_PKG.DEBUG $THEN
        xxpha_pnaumov_pkg.insert_log_table('Get_Org_Id_By_Organization_ID - Error!');
        xxpha_pnaumov_pkg.insert_log_table(sqlerrm);
        $END
        return - 1;
      end;
  end Get_Org_Id_By_Organization_ID;

  ----------------------------------------------------------------------------------------------------------------------------
  function Get_Organization_name(p_organization_id in number) return varchar2 as
    org_name xxpha_organizations_v.ORGANIZATION_NAME%type;
  begin
    select org.ORGANIZATION_NAME
      into org_name
      from xxpha_organizations_v org
     where org.ORGANIZATION_ID = p_organization_id;
    return org_name;
  end Get_Organization_name;

  ----------------------------------------------------------------------------------------------------------------------------
  function Get_Cur_Wip_Entity_ID return number as
    l_wip_entity_id number;
  begin
    select s.wip_entity_id
      into l_wip_entity_id
      from xxpha.xxpha_sn1041_session s
     where 1 = 1
       and s.s_id = (select max(s1.s_id)
                       from xxpha.xxpha_sn1041_session s1
                      where 1 = 1
                        and s1.user_id = fnd_global.USER_ID
                        and s1.resp_id = fnd_global.RESP_ID);
    return l_wip_entity_id;
  exception
    when no_data_found then
      return(-1);
  end Get_Cur_Wip_Entity_ID;

  ----------------------------------------------------------------------------------------------------------------------------
  function Get_Default_Wip_Subinventory(p_wip_entity_id number)
    return Varchar2 as
    Wip_Subinventory varchar2(50);
  begin
    select unique wro.supply_subinventory
      into Wip_Subinventory
      from WIP_REQUIREMENT_OPERATIONS_V wro
     where 1 = 1
       and wro.wip_entity_id = p_wip_entity_id
       and wro.supply_subinventory is not null;
  
    $IF  XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('Wip_Subinventory=' ||
                                       Wip_Subinventory);
    $END
  
    return Wip_Subinventory;
  exception
    when others then
      return null;
  end Get_Default_Wip_Subinventory;

  ----------------------------------------------------------------------------------------------------------------------------
  function Get_Wip_Sheduled_Start_Date(p_wip_entity_id number) return Date as
    l_Sheduled_Start_Date date;
  begin
    select wo.scheduled_start_date
      into l_Sheduled_Start_Date
      from EAM_WORK_ORDERS_V wo
     where 1 = 1
       and wo.wip_entity_id = p_wip_entity_id;
    return l_Sheduled_Start_Date;
  end Get_Wip_Sheduled_Start_Date;

  /*
  ----------------------------------------------------------------------------------------------------------------------------
  function Get_Default_Wip_Locator_Id(p_wip_entity_id number) return number as
    Wip_Subinventory varchar2(50);
  begin
    select unique wro.supply_subinventory
      into Wip_Subinventory
      from WIP_REQUIREMENT_OPERATIONS_V wro
     where 1 = 1
       and wro.wip_entity_id = p_wip_entity_id
       and wro.supply_subinventory is not null;
  
    $IF  XXPHA_SN1041_PKG.DEBUG $THEN
    xxpha_pnaumov_pkg.insert_log_table('Wip_Subinventory=' ||
                                       Wip_Subinventory);
    $END
  
    return Wip_Subinventory;
  exception
    when others then
      return null;
  end Get_Default_Wip_Locator_Id;
  */

  --Определение доступного количества на складе второй ОЕ на данной площадке
  FUNCTION get_pair_available_qant(p_organization_id   IN NUMBER,
                                   p_inventory_item_id IN NUMBER)
    RETURN NUMBER deterministic as
    v_cur_ou varchar2(200);
  begin
    --Определяем, что это "Механик", если не Механик, функция возвращает 0
    begin
      select fv.FLEX_VALUE
        into v_cur_ou
        from apps.xxpha_flex_values_v fv, xxpha_organizations_v orgs
       where 1 = 1
         and to_char(orgs.OPERATING_UNIT) = fv.FLEX_VALUE
         and fv.FLEX_VALUE_SET_NAME = 'XXPHA_SN904_OPER_UNIT'
         and orgs.ORGANIZATION_ID = p_organization_id;
    exception
      when others then
        return 0;
    end;
  
    return XXPHA_SN775_ELASTIC_PROXY_PKG.get_pair_available_qant(p_organization_id   => get_pair_available_qant.p_organization_id,
                                                                 p_inventory_item_id => get_pair_available_qant.p_inventory_item_id);
  
  end get_pair_available_qant;
  ----------------------------------------------------------------------------------------------------------------------------
begin
  -- Initialization
  $IF XXPHA_SN1041_PKG.DEBUG $THEN
  xxpha_pnaumov_pkg.gb_log_mark := 'SN1041';
  $END

  NULL;
end XXPHA_SN1041_PKG;
/
