create or replace package body xxpha_sn1041_lst_req_bskt_pkg is
  /* $id: xxpha_1041_1_lst_req_bskt_pkg.sql 1.0 09/04/2020-10:01 gdavydenko $ */

  procedure add_log(p_msg in varchar2) is
  begin
    xxpha_log(p_msg);
  
    $if xxpha_sn1041_pkg.debug
                                                                    $then
    xxpha_pnaumov_pkg.insert_log_table(p_msg);
    $end
  
  end add_log;

  --Постобработка
  procedure upd_shop_flag(p_line_tbl XXPHA_SN1041_CREATE_REQ_PKG.Line_Tbl_type,
                          p_eam_flag in varchar2) is
    --v_error_mes varchar2(4000);
  begin
  
    --Маркируем успешно созданные строки
    for i in 1 .. p_line_tbl.count loop
      add_log(i || '->' || p_line_tbl(i).req_item_id || '->' || p_line_tbl(i)
              .requisition_line_id);
    
      update xxpha.xxpha_sn1041_req_temp_t t
         set t.req_line_id = p_line_tbl(i).requisition_line_id
       where t.req_item_id = p_line_tbl(i).req_item_id;
    end loop;
  
    --перебор отработанных строк, для проверки успешно созданных транзаций
    for i in (select *
                from xxpha.xxpha_sn1041_req_temp_t sr
               where sr.req_line_id is not null) loop
      declare
        v_REQUISITION_num       po_requisition_headers_all.SEGMENT1%type;
        v_REQUISITION_HEADER_ID number;
        v_line_qty              number;
      begin
      
        add_log('upd_shop_flag i.req_line_id = ' || i.req_line_id);
      
        --Поиск свежей заявки
        select rh.REQUISITION_HEADER_ID, rh.SEGMENT1, rl.QUANTITY
          into v_REQUISITION_HEADER_ID, v_REQUISITION_num, v_line_qty
          from po_requisition_lines_all rl
         inner join po_requisition_headers_all rh
            on rl.REQUISITION_HEADER_ID = rh.REQUISITION_HEADER_ID
         where rl.REQUISITION_LINE_ID = i.req_line_id;
      
        add_log('upd_shop_flag v_REQUISITION_HEADER_ID = ' ||
                v_REQUISITION_HEADER_ID);
      
        --и апдейт флага (не актуально из-за прямых инсёртов)
        /*       update po_requisition_headers_all prha
        set prha.active_shopping_cart_flag = 'Y'
        where prha.requisition_header_id = v_REQUISITION_HEADER_ID
        and nvl(prha.active_shopping_cart_flag, 'N') = 'N';*/
      
        if p_eam_flag = 'Y' then
        
          --Номер заявки и количество пока берем не по ФД, а по последней корзинке
        
          --Апдейт ссылки на заявку в пост.таблице
          update xxpha.xxpha_sn1041_req_items ri
             set ri.req_line_id    = i.req_line_id,
                 ri.REQ_HEADER_NUM = v_REQUISITION_num,
                 ri.REQ_LINE_QTY   = v_line_qty,
                 ri.STATUS         = 'Создана корзина'
           where ri.req_item_id in
                 (select d.req_item_id
                    from xxpha.xxpha_sn1041_eam_distr_temp_t d
                   where d.line_req_item_id = i.req_item_id);
        
          --TODO MERGE строк таблицы 5 для которых создана корзина с Материалами ЗВР
        
        else
          --Апдейт ссылки на заявку в пост. таблице
          update xxpha.xxpha_sn1041_req_items ri
             set ri.req_line_id    = i.req_line_id,
                 ri.REQ_HEADER_NUM = v_REQUISITION_num,
                 ri.REQ_LINE_QTY   = v_line_qty,
                 ri.STATUS         = 'Создана корзина'
           where ri.req_item_id = i.req_item_id;
        end if;
      
        --Бросок эксепшена  при поиске свежей заявки
        --не актуально, ибо если нет заявки при прямом-то инсёрте, то ты явно что-то делаешь не так
        /*exception
        when no_data_found then
           add_log('upd_shop_flag no_data_found');
        
          --выведем первую строку по ошибке из интерейсов
           select max(ie.COLUMN_NAME||'-'|| ie.ERROR_MESSAGE)
           into v_error_mes
           from po_requisitions_interface_all i
           inner join po_interface_errors  ie on ie.INTERFACE_TRANSACTION_ID = i.TRANSACTION_ID
           where 1=1
           and i.REQUISITION_LINE_ID = i.req_line_id;
        
           update xxpha.xxpha_sn1041_req_items ri
           set ri.STATUS = 'Ошибка обработки'
           where ri.req_item_id = i.req_item_id;
        
           --, проверить po_requisitions_interface_all и po_interface_errors';
           x_msg := 'Не удалось создать корзину. '||substr(v_error_mes, 1, 300);*/
      end;
    end loop;
  
    /*update po_requisition_headers_all prha
       set prha.active_shopping_cart_flag = 'Y'
     where prha.requisition_header_id in (select prh.requisition_header_id
                                          from po_requisition_headers_all prh
                                          inner join po_requisition_lines_all prl on prh.requisition_header_id = prl.requisition_header_id --строки тоже создались
                                          where prh.interface_source_code = g_interface_source_code
                                            and prh.request_id = p_request_id
                                            and nvl(prh.active_shopping_cart_flag, 'N') != 'Y');
    
    l_row_count := sql%rowcount;
    add_log('upd_shop_flag: p_request_id = ' || p_request_id);
    add_log('upd_shop_flag: rowcount = ' || l_row_count);
    
    if l_row_count = 0 then
      x_msg := 'Не удалось создать заявки, проверить po_requisitions_interface_all и po_interface_errors'; --TODO вывод ошибок интерфейса для пользователя
    end if;
    */
  end upd_shop_flag;

  --Заполняет складское подразделение для для строк, где его нет
  procedure set_subinv(p_subinv in varchar2) is
  begin
  
    update xxpha.xxpha_sn1041_req_items sri
       set sri.wip_subinventory = p_subinv
     where sri.wip_subinventory is null;
  
  end set_subinv;

  --Заполняет нужную дату для для строк, где её нет
  procedure set_need_by_date(p_need_by_date in varchar2) is
  begin
  
    update xxpha.xxpha_sn1041_req_items sri
       set sri.wip_date_required = p_need_by_date
     where sri.wip_date_required is null;
  
  end set_need_by_date;

  -----------------------------------------------------------------------------------------------------------
  --Заполнение незаполненных полей с типом заявки в постоянной таблице xxpha.xxpha_sn1041_req_items sri
  procedure set_requisition_types is
  begin
    update xxpha.xxpha_sn1041_req_items sri
       set sri.requisition_type = case
                                    when sri.DEACTIVATION is not null and
                                         nvl(sri.CS_AVAILABLE_QUANTITY, 0) <= 0 then
                                     xxpha_sn1041_pkg.get_requisition_type(sri.catalog_num,
                                                                           xxpha_sn1041_pkg.get_pair_available_qant(p_organization_id   => sri.SOURCE_ORGANIZATION_ID,
                                                                                                                    p_inventory_item_id => sri.ITEM_ID),
                                                                           sri.quantity)
                                    else
                                     xxpha_sn1041_pkg.get_requisition_type(sri.catalog_num,
                                                                           sri.cs_available_quantity,
                                                                           sri.quantity)
                                  end
     where sri.requisition_type is null;
  
  end set_requisition_types;

  -----------------------------------------------------------------------------------------------------------
  function fill_temp_table(p_row_list in fnd_table_of_number,
                           x_msg      out varchar2,
                           --для EAM
                           p_eam_flag in varchar2) return varchar2 is
  
    v_row    xxpha.xxpha_sn1041_req_temp_t%rowtype;
    v_rowcnt number := 0;
  begin
    --очистка
    delete xxpha.xxpha_sn1041_req_temp_t;
    --для EAM
    delete xxpha.xxpha_sn1041_eam_distr_temp_t;
  
    if p_eam_flag = 'Y' then
      --Вставка сгруппированных значений в темповую таблицу
      --Сейчас группировка по МВЗ и ЦФО, т.к. не позволяем выбирать строки для разных ЗВР
      --Задвоит строки в xxpha_sn1041_req_temp_t и xxpha_sn1041_req_items, если не будут заполнены МВЗ и ЦФО
      for rec in (select max(sri.req_item_id) line_item_id,
                         sri.item_id,
                         sri.descriptions,
                         sri.item_code,
                         sri.catalog_num,
                         sri.sup_description,
                         sri.uom,
                         sri.need_by_date,
                         sum(sri.quantity) quantity,
                         sri.unit_price,
                         sri.supplier_id,
                         sri.source_organization_id,
                         sri.dest_organization_id,
                         sri.preparer_id,
                         sri.deliver_to_location_id,
                         sri.deliver_to_requestor_id,
                         sri.org_id,
                         sri.is_processed,
                         sri.cs_available_quantity,
                         sri.supplier,
                         sri.delivery_date,
                         sri.deactivation,
                         sri.index_name,
                         sri.delete_line,
                         sri.requisition_type,
                         sri.MVZ,
                         sri.cfo,
                         sum(sri.req_line_id) sum_req_line_id,
                         sri.wip_buyer_notes,
                         sri.wip_ol_num,
                         sri.wip_ol_date
                    from xxpha.xxpha_sn1041_req_items sri
                   inner join table(p_row_list) c
                      on c.column_value = sri.req_item_id
                   group by sri.item_id,
                            sri.descriptions,
                            sri.item_code,
                            sri.catalog_num,
                            sri.sup_description,
                            sri.uom,
                            sri.need_by_date,
                            sri.unit_price,
                            sri.supplier_id,
                            sri.source_organization_id,
                            sri.dest_organization_id,
                            sri.preparer_id,
                            sri.deliver_to_location_id,
                            sri.deliver_to_requestor_id,
                            sri.org_id,
                            sri.is_processed,
                            sri.cs_available_quantity,
                            sri.supplier,
                            sri.delivery_date,
                            sri.deactivation,
                            sri.index_name,
                            sri.delete_line,
                            sri.requisition_type,
                            sri.MVZ,
                            sri.cfo,
                            sri.wip_buyer_notes,
                            sri.wip_ol_num,
                            sri.wip_ol_date) loop
        v_row.req_item_id             := rec.line_item_id;
        v_row.item_id                 := rec.item_id;
        v_row.descriptions            := rec.descriptions;
        v_row.item_code               := rec.item_code;
        v_row.catalog_num             := rec.catalog_num;
        v_row.sup_description         := rec.sup_description;
        v_row.uom                     := rec.uom;
        v_row.need_by_date            := rec.need_by_date;
        v_row.quantity                := rec.quantity;
        v_row.unit_price              := rec.unit_price;
        v_row.supplier_id             := rec.supplier_id;
        v_row.source_organization_id  := rec.source_organization_id;
        v_row.dest_organization_id    := rec.dest_organization_id;
        v_row.preparer_id             := rec.preparer_id;
        v_row.deliver_to_location_id  := rec.deliver_to_location_id;
        v_row.deliver_to_requestor_id := rec.deliver_to_requestor_id;
        v_row.org_id                  := rec.org_id;
        v_row.is_processed            := rec.is_processed;
        v_row.cs_available_quantity   := rec.cs_available_quantity;
        v_row.supplier                := rec.supplier;
        v_row.delivery_date           := rec.delivery_date;
        v_row.deactivation            := rec.deactivation;
        v_row.index_name              := rec.index_name;
        v_row.delete_line             := rec.delete_line;
        v_row.requisition_type        := rec.requisition_type;
        v_row.mvz                     := rec.mvz;
        v_row.cfo                     := rec.cfo;
        v_row.req_line_id             := rec.sum_req_line_id; --Суммарное значение только чтобы проверить, есть ли уже созданные заявки
      
        v_row.wip_buyer_notes := rec.wip_buyer_notes;
        v_row.wip_ol_num      := rec.wip_ol_num;
        v_row.wip_ol_date     := rec.wip_ol_date;
      
        v_row.created_by       := fnd_global.USER_ID;
        v_row.creation_date    := sysdate;
        v_row.last_updated_by  := fnd_global.USER_ID;
        v_row.last_update_date := sysdate;
      
        insert into xxpha.xxpha_sn1041_req_temp_t values v_row;
      
        --Вставка значений распределений в дополнительную таблицу (связка между таблицей 5 и темповой таблицей)
        insert into xxpha.xxpha_sn1041_eam_distr_temp_t
          select rec.line_item_id,
                 sri.req_item_id,
                 sri.wip_entity_id,
                 sri.operation_seq_num,
                 sri.quantity,
                 sri.wip_subinventory,
                 sri.wip_date_required,
                 sri.wip_gl_date,
                 sri.po_line_id
            from xxpha.xxpha_sn1041_req_items sri
           inner join table(p_row_list) c
              on c.column_value = sri.req_item_id
           where sri.item_id = rec.item_id;
      
        v_rowcnt := v_rowcnt + 1;
      end loop;
    else
      --Вставка в темповую таблицу дитрибуций пока по item_id
      --item_id должен быть уникален для каждой строки заявки
      insert into xxpha.xxpha_sn1041_req_temp_t
        select sri.req_item_id, sri.*
          from xxpha.xxpha_sn1041_req_items sri
         inner join table(p_row_list) c
            on c.column_value = sri.req_item_id;
    
      v_rowcnt := sql%rowcount;
    end if;
  
    if v_rowcnt = 0 then
      x_msg := 'Не выбраны строки для обработки';
      return '2';
    end if;
  
    for i in (select * from xxpha.xxpha_sn1041_req_temp_t) loop
      add_log(i.req_item_id || ' ' || i.requisition_type);
    end loop;
  
    return '1';
  
  end fill_temp_table;

  --получение актуальной корзины
  function get_shop_cart(p_org_id number) return number is
    v_requisition_header_id number;
  begin
    select max(prh.requisition_header_id) keep(dense_rank first order by prh.last_update_date desc)
    --технически у юзера может быть несколько корзинок. Берём последнюю
      into v_requisition_header_id
      from po_requisition_headers_all prh
     where 1 = 1
       and prh.active_shopping_cart_flag = 'Y'
       and prh.last_updated_by = to_number(fnd_profile.value('USER_ID'))
       and prh.org_id = p_org_id;
  
    return nvl(v_requisition_header_id, -1);
  
  end;

  -- Предварительные проверки для заявок
  function check_data(p_sub_inv      varchar2,
                      p_need_by_date date,
                      x_msg          out varchar2, /*для ЕАМ*/
                      p_eam_flag     in varchar2) return varchar2 is
    l_req_count number;
    l_wrong_row number;
    --l_req_type  number;
    l_items varchar2(4000);
  begin
  
    --Дополнительная проверка для ЕАМ.
    if p_eam_flag = 'Y' then
    
      --Запрещаем выбирать строки с разными ЗВР
      --В дальнейшем будет создание корзины для нескольких ЗВР
      select count(distinct d.wip_entity_id)
        into l_req_count
        from xxpha.xxpha_sn1041_eam_distr_temp_t d;
    
      if l_req_count > 1 then
        x_msg := 'Выбраны строки для разных ЗВР';
        return '2';
      end if;
    
      --Нельзя обрабатывать строки с невыбранным Складским подразделением
      select count(*),
             LISTAGG(r.item_code, ', ') WITHIN GROUP(order by r.item_code)
        into l_req_count, l_items
        from xxpha.xxpha_sn1041_req_temp_t r
       inner join xxpha.xxpha_sn1041_eam_distr_temp_t d
          on r.req_item_id = d.line_req_item_id
       where d.wip_subinventory is null;
    
      if l_req_count > 0 then
        x_msg := 'Не заполнено поле Скл. подразд. Позиции: ' || l_items;
        return '2';
      end if;
    
      --Нельзя обрабатывать строки незаполненным полем Нужная дата
      select count(*),
             LISTAGG(r.item_code, ', ') WITHIN GROUP(order by r.item_code)
        into l_req_count, l_items
        from xxpha.xxpha_sn1041_req_temp_t r
       inner join xxpha.xxpha_sn1041_eam_distr_temp_t d
          on r.req_item_id = d.line_req_item_id
       where d.wip_date_required is null;
    
      if l_req_count > 0 then
        x_msg := 'Не заполненно поле Нужная дата. Позиции: ' || l_items;
        return '2';
      end if;
    
      --Проверка требуемой даты
      select count(*),
             LISTAGG(r.item_code, ', ') WITHIN GROUP(order by r.item_code)
        into l_req_count, l_items
        from xxpha.xxpha_sn1041_req_temp_t r
       inner join xxpha.xxpha_sn1041_eam_distr_temp_t d
          on r.req_item_id = d.line_req_item_id
       where d.wip_date_required < sysdate;
    
      if l_req_count > 0 then
        x_msg := 'Нужная дата не может быть меньше текущей даты. Позиции: ' ||
                 l_items;
        return '2';
      end if;
    
      --Проверка выбранной операции
      select count(*),
             LISTAGG(r.item_code, ', ') WITHIN GROUP(order by r.item_code)
        into l_req_count, l_items
        from xxpha.xxpha_sn1041_req_temp_t r
       inner join xxpha.xxpha_sn1041_eam_distr_temp_t d
          on r.req_item_id = d.line_req_item_id
       where d.operation_seq_num is null;
    
      if l_req_count > 0 then
        x_msg := 'Выбраны строки с незаполненным полем Операция. Позиции: ' ||
                 l_items;
        return '2';
      end if;
    
      --Проверка операций на соответствие ЗВР
      select count(*),
             LISTAGG(r.item_code, ', ') WITHIN GROUP(order by r.item_code)
        into l_req_count, l_items
        from xxpha.xxpha_sn1041_req_temp_t r
       inner join xxpha.xxpha_sn1041_eam_distr_temp_t d
          on r.req_item_id = d.line_req_item_id
       where d.operation_seq_num not in
             (select wo.operation_seq_num
                from wip_operations wo
               where wo.wip_entity_id = d.wip_entity_id);
      if l_req_count > 0 then
        x_msg := 'Для выбранных позиций Операция не соответствует Операциям ЗВР ' ||
                 l_items;
        return '2';
      end if;
    
      --Проверка одинаковой операции и позиции
      select count(*),
             LISTAGG(q.item_code, ', ') WITHIN GROUP(order by q.item_code)
        into l_req_count, l_items
        from (select count(*),
                     r.item_code || '/' || d.operation_seq_num item_code
                from xxpha.xxpha_sn1041_req_temp_t r
               inner join xxpha.xxpha_sn1041_eam_distr_temp_t d
                  on r.req_item_id = d.line_req_item_id
               group by r.wip_entity_id, r.item_code, d.operation_seq_num
              having count(*) > 1) q;
    
      if l_req_count > 0 then
        x_msg := 'Выбраны одинаковые позиции с одинаковым полем Операция. Позиции/операции: ' ||
                 l_items;
        return '2';
      end if;
    
      if not XXPHA_SN1041_EAM_PKG.lock_rows then
        x_msg := 'Строки материалов заблокированы. Сохраните изменения в форме Потребности в материалах для выбранного ЗВР.';
        return '2';
      end if;
    else
      if p_sub_inv is null then
        x_msg := 'Не выбрано складское подразделение';
        return '2';
      end if;
    
      if p_need_by_date is null then
        x_msg := 'Не заполнена нужная дата';
        return '2';
      end if;
    
      if p_need_by_date < sysdate then
        x_msg := 'Нужная дата не может быть в прошлом. Укажите корректную нужную дату';
        return '2';
      end if;
    
      --Проверка одинакового типа заявок
      select count(distinct nvl(t.requisition_type, 'NULL')) -- считаем количество уникальных типов
        into l_req_count
        from xxpha.xxpha_sn1041_req_temp_t t;
    
      if l_req_count > 1 then
        x_msg := 'Выбраны строки с разным типом заявок';
        return '2';
      end if;
    
      --Проверка одинакового интернет-магазинов
      select count(distinct nvl(t.supplier, 'NULL')) -- считаем количество уникальных типов
            ,
             LISTAGG(t.item_code, ', ') WITHIN GROUP(order by t.item_code)
        into l_req_count, l_items
        from xxpha.xxpha_sn1041_req_temp_t t
       where t.requisition_type <> 2;
    
      if l_req_count > 1 then
        x_msg := 'Выбраны строки из разных интернет-магазинов. Позиции: ' ||
                 l_items;
        return '2';
      end if;
    
    end if;
  
    --Проверка правильности типов заявок на строках
    for rec in (select * from xxpha.xxpha_sn1041_req_temp_t) loop
      --trunc()потому что для ЕАМ в поле requisition_type могут быть подтипы от основного типа.
      --Проверку проводим только по основному типу, отрезая идентификатор подтипа.
      if rec.deactivation is not null and
         nvl(rec.cs_available_quantity, 0) <= 0 then
        declare
          l_pair_quant number := 0;
        begin
          l_pair_quant := xxpha_sn1041_pkg.get_pair_available_qant(p_organization_id   => rec.source_organization_id,
                                                                   p_inventory_item_id => rec.item_id);
          if trunc(rec.requisition_type) !=
             xxpha_sn1041_pkg.get_requisition_type(rec.catalog_num,
                                                   l_pair_quant,
                                                   rec.quantity) then
            l_wrong_row := 1;
            l_items     := ltrim(l_items || ', ' || rec.item_code, ', ');
          end if;
        end;
      else
        if trunc(rec.requisition_type) !=
           xxpha_sn1041_pkg.get_requisition_type(rec.catalog_num,
                                                 rec.cs_available_quantity,
                                                 rec.quantity) then
          l_wrong_row := 1;
          l_items     := ltrim(l_items || ', ' || rec.item_code, ', ');
        end if;
      end if;
    
    end loop;
  
    if l_wrong_row != 0 then
      x_msg := 'Неверно определён тип заявки. Позиции: ' || l_items;
      return '2';
    end if;
  
    -- Проверка заполненного количества
    select count(*),
           LISTAGG(t.item_code, ', ') WITHIN GROUP(order by t.item_code)
      into l_req_count, l_items
      from xxpha.xxpha_sn1041_req_temp_t t
     where t.quantity is null;
  
    if l_req_count != 0 then
      x_msg := 'Не заполнено кол-во. Позиций: ' || l_items;
      return '2';
    end if;
  
    -- Проверка уже обработанных
    select count(*),
           LISTAGG(t.item_code, ', ') WITHIN GROUP(order by t.item_code)
      into l_req_count, l_items
      from xxpha.xxpha_sn1041_req_temp_t t
     where t.req_line_id is not null;
  
    if l_req_count != 0 then
      x_msg := 'Строки ранее обработаны. Позиций: ' || l_items;
      return '2';
    end if;
  
    --Проверка по позициям с признаком деактивации нельзя делать плановые закупки
    select count(*),
           LISTAGG(t.item_code, ', ') WITHIN GROUP(order by t.item_code)
      into l_req_count, l_items
      from xxpha.xxpha_sn1041_req_temp_t t
     where 1 = 1
       and t.requisition_type = '1' --плановая закупка
       and t.deactivation is not null; --деактивация
  
    if l_req_count != 0 then
      x_msg := 'Для позиций к деактивации плановые закупки недоступны. Позиций: ' ||
               l_items;
      return '2';
    end if;
  
    --Проверка магазинов
    --Проверка на неопределённый магазин
    select count(*),
           LISTAGG(t.item_code, ', ') WITHIN GROUP(order by t.item_code)
      into l_req_count, l_items
      from xxpha.xxpha_sn1041_req_temp_t t
     where t.requisition_type = 6
       and t.supplier_id is null;
  
    if l_req_count > 1 then
      x_msg := 'Не удалось определить магазин. Позиций: ' || l_items;
      return '2';
    end if;
  
    x_msg := 'OK';
    return '1';
  
  end check_data;

  --Заполнение записи
  function fill_req_header(p_header_row out XXPHA_SN1041_CREATE_REQ_PKG.Header_Rec_Type,
                           x_msg        out varchar2
                           --для EAM
                          ,
                           p_eam_flag in varchar2) return boolean is
  
    l_header_row XXPHA_SN1041_CREATE_REQ_PKG.Header_Rec_Type;
    v_store_id   number;
  begin
    select distinct --упасть в ту мени роу не должно, за это отвечают проверки в check_data
                    t.org_id,
                    t.preparer_id,
                    t.requisition_type,
                    --store_id учитываем только если тип заявки 6
                    decode(t.requisition_type, 6, t.supplier_id, null)
                    --, t.dest_organization_id --Склад назначения. Может дать TMR, т.к. нет проверки
                    --Берем значения для ЕАМ из таблицы
                    --для сгруппированных строк по одному ЗВР не должно дать too_many_rows
                   ,
                    t.mvz,
                    t.cfo
      into l_header_row.org_id,
           l_header_row.preparer_id,
           l_header_row.attribute1,
           v_store_id
           --,v_organization_id
          ,
           l_header_row.attribute3,
           l_header_row.attribute4
      from xxpha.xxpha_sn1041_req_temp_t t;
  
    l_header_row.last_update_date  := sysdate;
    l_header_row.last_updated_by   := fnd_global.USER_ID;
    l_header_row.last_update_login := fnd_global.LOGIN_ID;
    l_header_row.creation_date     := sysdate;
    l_header_row.created_by        := fnd_global.USER_ID;
  
    l_header_row.summary_flag := 'N';
    l_header_row.enabled_flag := 'Y';
  
    l_header_row.APPS_SOURCE_CODE          := 'POR';
    l_header_row.ACTIVE_SHOPPING_CART_FLAG := 'Y'; --активная корзинка
  
    if l_header_row.attribute1 = 6 then
      l_header_row.type_lookup_code          := 'PURCHASE'; --покупка из ИМ
      l_header_row.INTERFACE_SOURCE_CODE     := 'XXPHA_SN775_' ||
                                                v_store_id;
      l_header_row.authorization_status      := 'INCOMPLETE';
      l_header_row.UDA_TEMPLATE_DATE         := sysdate;
      l_header_row.TAX_ATTRIBUTE_UPDATE_CODE := 'CREATE';
    else
    
      --l_header_row.transferred_to_oe_flag     := 'N'; --без него не отображаются заяка в корзине по условию
      --and (nvl(ph.transferred_to_oe_flag,'N') <> 'Y' or pl.source_type_code = 'VENDOR')
      l_header_row.type_lookup_code      := 'INTERNAL';
      l_header_row.INTERFACE_SOURCE_CODE := 'XXPHA_SN775_1'; --ФосАгро магазин
      l_header_row.authorization_status  := 'INCOMPLETE'; --'SYSTEM_SAVED'; Не знаю почему, но заявки в таком статусе создаёт система
    end if;
  
    --Если корзина не для ЕАМ, то перетираем значениями с профиля
    if p_eam_flag != 'Y' then
      l_header_row.attribute3 := fnd_profile.value('XXPHA_SN775_USER_MVZ');
      l_header_row.attribute4 := fnd_profile.value('XXPHA_SN775_USER_CFO');
    end if;
  
    l_header_row.attribute8 := 'SN1041';
  
    p_header_row := l_header_row;
    return true;
  exception
    when others then
      add_log('header ' || sqlerrm || ' ' ||
              dbms_utility.format_error_backtrace);
      x_msg := 'Ошибка при заполнении заголовка заявки: ' + sqlerrm;
      return false;
  end;

  function fill_req_lines(p_header_row   in OUT XXPHA_SN1041_CREATE_REQ_PKG.Header_Rec_Type,
                          p_sub_inv      varchar2,
                          p_need_by_date date,
                          p_line_table   out XXPHA_SN1041_CREATE_REQ_PKG.Line_Tbl_type,
                          x_msg          out varchar2
                          --для EAM
                         ,
                          p_eam_flag in varchar2) return boolean is
  
    v_line_num number;
    l_line_tbl XXPHA_SN1041_CREATE_REQ_PKG.Line_Tbl_type;
  begin
    select nvl(max(l.LINE_NUM), 0)
      into v_line_num
      from po_requisition_lines_all l
     where l.REQUISITION_HEADER_ID = p_header_row.requisition_header_id;
  
    for i in (select t.*,
                     b.DESCRIPTION item_descr,
                     b.PRIMARY_UNIT_OF_MEASURE,
                     b.BUYER_ID,
                     b.PRIMARY_UOM_CODE
                     /*, (
                     select S.SECONDARY_INVENTORY_NAME
                     from mtl_secondary_inventories s
                      inner join HR_ORGANIZATION_UNITS_V o on s.ORGANIZATION_ID = o.organization_id
                     where sysdate <= nvl(disable_date, sysdate)
                     and asset_inventory = 1
                     and S.ORGANIZATION_ID = t.dest_organization_id
                     and S.SECONDARY_INVENTORY_NAME = fnd_profile.value('POR_DEFAULT_SUBINVENTORY')
                     ) SECONDARY_INVENTORY_NAME*/,
                     rownum rn
                from xxpha.xxpha_sn1041_req_temp_t t
               inner join mtl_system_items_b b
                  on t.item_id = b.INVENTORY_ITEM_ID
                 and t.dest_organization_id = b.ORGANIZATION_ID) loop
      declare
        --v_row po_requisition_lines_all%rowtype;
      begin
        add_log('creating row for i.req_item_id = ' || i.req_item_id);
        
        IF p_header_row.description IS NULL THEN 
          p_header_row.description:= i.item_descr;
        END IF;
      
        v_line_num := v_line_num + 1;
      
        --для EAM
        if p_eam_flag = 'Y' then
          --Заполняем Связь с ЗВР
          select listagg(we.wip_entity_name || '/' || d.operation_seq_num,
                         ', ') within group(order by we.wip_entity_name) material_id
            into l_line_tbl(i.rn).attribute1
            from xxpha.xxpha_sn1041_eam_distr_temp_t d
           inner join apps.wip_entities we
              on d.wip_entity_id = we.wip_entity_id
           where d.line_req_item_id = i.req_item_id;
        
          /* --Заполняем Номер и Дату ОЛ
          select d.ol_num, d.ol_date
          into l_line_tbl(i.rn).attribute6, l_line_tbl(i.rn).attribute7
          from       xxpha.xxpha_sn1041_eam_distr_temp_t d
          inner join apps.wip_entities                   we on d.wip_entity_id = we.wip_entity_id
          where d.line_req_item_id = i.req_item_id
            and rownum = 1;*/
        
        end if;
      
        l_line_tbl(i.rn).org_id := i.org_id;
        --l_line_tbl(i.rn).requisition_line_id            := po_requisition_lines_s.nextval;
        l_line_tbl(i.rn).requisition_header_id := p_header_row.requisition_header_id;
        l_line_tbl(i.rn).line_num := v_line_num;
        l_line_tbl(i.rn).line_type_id := 1; --товары
        --v_row.category_id                    := ;--?
        l_line_tbl(i.rn).item_description := i.item_descr;
        l_line_tbl(i.rn).uom_code := i.PRIMARY_UOM_CODE;
        l_line_tbl(i.rn).unit_meas_lookup_code := i.PRIMARY_UNIT_OF_MEASURE;
        l_line_tbl(i.rn).unit_price := i.unit_price;
        l_line_tbl(i.rn).quantity := i.quantity;
        l_line_tbl(i.rn).deliver_to_location_id := i.deliver_to_location_id;
        l_line_tbl(i.rn).TO_PERSON_ID := i.preparer_id;
      
        l_line_tbl(i.rn).last_update_date := sysdate;
        l_line_tbl(i.rn).last_updated_by := fnd_global.USER_ID;
        l_line_tbl(i.rn).last_update_login := fnd_global.LOGIN_ID;
        l_line_tbl(i.rn).creation_date := sysdate;
        l_line_tbl(i.rn).created_by := fnd_global.USER_ID;
      
        if i.requisition_type = 6 then
          l_line_tbl(i.rn).source_type_code := 'VENDOR';
          l_line_tbl(i.rn).SUGGESTED_BUYER_ID := i.BUYER_ID; --ой не факт, но ничего лучше у меня нет
          l_line_tbl(i.rn).DOCUMENT_TYPE_CODE := 'BLANKET';
        
          --Выборка из ОСЗ
          --должен железно вернуть 1 строку, иначе я не я!
          select l.PO_HEADER_ID,
                 l.LINE_NUM
                 --, h.CURRENCY_CODE
                ,
                 h.VENDOR_ID,
                 v.VENDOR_NAME,
                 h.VENDOR_SITE_ID,
                 vs.VENDOR_SITE_CODE,
                 h.agent_id --из BuyerFromSourceDocVVO и oracle.apps.icx.por.schema.server.BuyerHelper
            into l_line_tbl(i.rn).BLANKET_PO_HEADER_ID,
                 l_line_tbl(i.rn).BLANKET_PO_LINE_NUM,
                 l_line_tbl(i.rn).VENDOR_ID,
                 l_line_tbl(i.rn).SUGGESTED_VENDOR_NAME,
                 l_line_tbl(i.rn).VENDOR_SITE_ID,
                 l_line_tbl(i.rn).SUGGESTED_VENDOR_LOCATION,
                 l_line_tbl(i.rn).SUGGESTED_BUYER_ID
            from po_lines_all l
           inner join po_headers_all h
              on l.PO_HEADER_ID = h.PO_HEADER_ID
           inner join po_vendors v
              on v.VENDOR_ID = h.VENDOR_ID
           inner join po_vendor_sites_all vs
              on vs.VENDOR_SITE_ID = h.VENDOR_SITE_ID
           where l.PO_LINE_ID = i.po_line_id;
        
          l_line_tbl(i.rn).SUGGESTED_VENDOR_PRODUCT_CODE := i.catalog_num; --не уверен
          l_line_tbl(i.rn).NEW_SUPPLIER_FLAG := 'N';
          l_line_tbl(i.rn).NEGOTIATED_BY_PREPARER_FLAG := 'Y';
          l_line_tbl(i.rn).NEW_SUPPLIER_FLAG := 'N'; --не уверен
          --
          l_line_tbl(i.rn).CATALOG_TYPE := 'CATALOG';
          l_line_tbl(i.rn).CATALOG_SOURCE := 'INTERNAL';
          l_line_tbl(i.rn).CURRENCY_CODE := 'RUB';
        
          --
          -- l_line_tbl(i.rn).TAX_ATTRIBUTE_UPDATE_CODE      := 'CREATE';
        else
          l_line_tbl(i.rn).source_type_code := 'INVENTORY';
          l_line_tbl(i.rn).source_organization_id := i.source_organization_id;
          l_line_tbl(i.rn).attribute11 := i.source_organization_id;
          l_line_tbl(i.rn).NEGOTIATED_BY_PREPARER_FLAG := 'N';
          l_line_tbl(i.rn).CONTRACT_TYPE := 'FP_FIRM';
          l_line_tbl(i.rn).BASE_UNIT_PRICE := i.unit_price;
        end if;
      
        l_line_tbl(i.rn).CLM_INFO_FLAG := 'N';
        l_line_tbl(i.rn).CATALOG_TYPE := 'CATALOG';
        l_line_tbl(i.rn).CATALOG_SOURCE := 'INTERNAL';
        l_line_tbl(i.rn).URGENT_FLAG := 'N';
        l_line_tbl(i.rn).item_id := i.item_id;
        l_line_tbl(i.rn).encumbered_flag := 'N';
        l_line_tbl(i.rn).rfq_required_flag := 'N';
        l_line_tbl(i.rn).need_by_date := p_need_by_date; --Нужная дата
        l_line_tbl(i.rn).DESTINATION_CONTEXT := 'INVENTORY';
        l_line_tbl(i.rn).destination_type_code := 'INVENTORY';
        l_line_tbl(i.rn).destination_organization_id := i.dest_organization_id;
        l_line_tbl(i.rn).DESTINATION_SUBINVENTORY := p_sub_inv; --i.SECONDARY_INVENTORY_NAME;
      
        l_line_tbl(i.rn).order_type_lookup_code := 'QUANTITY';
        l_line_tbl(i.rn).purchase_basis := 'GOODS';
        l_line_tbl(i.rn).matching_basis := 'QUANTITY';
      
        l_line_tbl(i.rn).req_item_id := i.req_item_id;
      
        --PO_CREATE_REQUISITION_SV
        --CSP_PARTS_ORDER
        --PO_REQUISITION_LINES_PKG2
        --POR_AMENDMENT_PKG
        --PO_CREATE_REQUISITION_SV
      
        --insert into po_requisition_lines_all values v_row;
      
        /* update xxpha.xxpha_sn1041_req_temp_t t
        set t.req_line_id = v_row.requisition_line_id
        where t.req_item_id = i.req_item_id;*/
      
      end;
    end loop;
  
    p_line_table := l_line_tbl;
  
    add_log('p_line_table.count = ' || p_line_table.count);
    return true;
  exception
    when others then
      add_log('line ' || sqlerrm || ' ' ||
              dbms_utility.format_error_backtrace);
      x_msg := 'Ошибка при заполнении строк заявки';
      return false;
  end;

  --Создание распределений
  function fill_req_dist(p_line_table in XXPHA_SN1041_CREATE_REQ_PKG.Line_Tbl_type,
                         x_dist_table out XXPHA_SN1041_CREATE_REQ_PKG.Dist_Tbl_Type,
                         x_msg        out varchar2
                         --для EAM
                        ,
                         p_eam_flag in varchar2) return boolean is
    v_dist_count number := 0;
  begin
    if p_eam_flag = 'Y' then
      x_dist_table := XXPHA_SN1041_CREATE_REQ_PKG.Dist_Tbl_Type();
      --для каждого лайна надо перебрать свои распределения
      for i in p_line_table.first .. p_line_table.last loop
        --Распределения
        for j in (select *
                    from xxpha.xxpha_sn1041_eam_distr_temp_t t
                   where t.req_item_id = p_line_table(i).req_item_id) loop
          declare
            l_row XXPHA_SN1041_CREATE_REQ_PKG.Dist_Rec_type;
          begin
            --Получаем особые поля из ЕАМ
            l_row := XXPHA_SN1041_EAM_PKG.Get_distr_values(p_wip_entity_id => j.wip_entity_id,
                                                           p_item_id       => p_line_table(i)
                                                                              .item_id,
                                                           p_operation     => j.operation_seq_num);
          
            --Обогощает техническими полями
            l_row.requisition_line_num := p_line_table(i).line_num;
            l_row.req_line_quantity    := j.quantity;
          
            --Заполняем коллекцию
            x_dist_table.extend;
            v_dist_count := v_dist_count + 1;
            x_dist_table(v_dist_count) := l_row;
          
          end;
        end loop;
      end loop;
    end if;
  
    return true;
  
  exception
    when others then
      add_log('dist ' || sqlerrm || ' ' ||
              dbms_utility.format_error_backtrace);
      x_msg := 'Ошибка при заполнении распределений';
      return false;
  end;

  --функция создания корзинки
  function create_shoping_cart(p_sub_inv      varchar2,
                               p_need_by_date date,
                               x_msg          out varchar2,
                               --для EAM
                               p_eam_flag in varchar2) return number is
    --v_req_header_id number;
    --v_org_id        number;
    v_count         number;
    v_header_row    XXPHA_SN1041_CREATE_REQ_PKG.Header_Rec_Type;
    v_line_table    XXPHA_SN1041_CREATE_REQ_PKG.Line_Tbl_type;
    v_dist_table    XXPHA_SN1041_CREATE_REQ_PKG.Dist_Tbl_Type; --:= XXPHA_SN1041_CREATE_REQ_PKG.Dist_Tbl_Type();
    v_return_status varchar2(100);
    v_msg_count     number;
    v_msg_data      varchar2(100);
  begin
    -- org_id на всех строках одинаковый
    select t.org_id
      into v_header_row.org_id
      from xxpha.xxpha_sn1041_req_temp_t t
     where rownum = 1;
  
    --получение актуальной корзинки
    v_header_row.requisition_header_id := get_shop_cart(v_header_row.org_id);
    add_log('v_req_header_id = ' || v_header_row.requisition_header_id);
  
    --если корзинка есть:
    if v_header_row.requisition_header_id != -1 then
    
      --проверить на совместимость строк с корзинкой
      select count(*)
        into v_count
        from po_requisition_headers_all p
       inner join po_requisition_lines_all l
          on p.REQUISITION_HEADER_ID = l.REQUISITION_HEADER_ID
       where 1 = 1
         and p.REQUISITION_HEADER_ID = v_header_row.requisition_header_id
            --есть строка, которая не удовлетворяет условиям корзины
         and exists
       (select 1
                from xxpha.xxpha_sn1041_req_temp_t t
               where t.requisition_type != p.ATTRIBUTE1 --не совпадают типы
                  or t.deliver_to_location_id != l.DELIVER_TO_LOCATION_ID --не совпадает направление
                    --не совпадают поставщики
                  or nvl((select ph.VENDOR_ID
                           from po_lines_all pl
                          inner join po_headers_all ph
                             on pl.PO_HEADER_ID = ph.PO_HEADER_ID
                          where pl.PO_LINE_ID = t.po_line_id),
                         -1) != l.VENDOR_ID
              
              );
      add_log('v_count = ' || v_count);
      --если не совместимы, выдать ошибку
      if v_count > 0 then
        x_msg := 'Невозможно выбранные позиции добавить в корзину. Очистите активную корзину, чтобы создать новую.';
        return 2;
      end if;
      --если корзинки нет:
    else
      --создать заголовок заявки
      --v_req_header_id:= create_req_header(x_msg);
      if not fill_req_header(v_header_row, x_msg, p_eam_flag) then
        return 2;
      end if;
    
    end if;
  
    --создать строки для header_id
    if not fill_req_lines(v_header_row,
                          p_sub_inv,
                          p_need_by_date,
                          v_line_table,
                          x_msg,
                          p_eam_flag) --create_req_lines(v_req_header_id, x_msg)
     then
      return 2;
    end if;
  
    --создать распределения (если нужно)
    if not fill_req_dist(v_line_table, v_dist_table, x_msg, p_eam_flag) --create_req_lines(v_req_header_id, x_msg)
     then
      return 2;
    end if;
  
    --вывоз API по созданию/добавлению заявки
    mo_global.set_policy_context('S', v_header_row.org_id);
    XXPHA_SN1041_CREATE_REQ_PKG.process_requisition(px_header_rec   => v_header_row,
                                                    px_line_table   => v_line_table,
                                                    px_dist_table   => v_dist_table,
                                                    x_return_status => v_return_status,
                                                    x_msg_count     => v_msg_count,
                                                    x_msg_data      => v_msg_data);
  
    if v_return_status != FND_API.G_RET_STS_SUCCESS then
      x_msg := 'Ошибка при создании корзины. ' || v_msg_data;
      add_log(x_msg);
      return 2;
    else
      add_log('Заявка создана ' || v_return_status);
    end if;
  
    --Постобработка
    upd_shop_flag(v_line_table, p_eam_flag);
  
    return 1;
  
  end;

  function main(p_row_list     in fnd_table_of_number,
                p_sub_inv      varchar2,
                p_need_by_date date,
                x_msg          out varchar2,
                --для EAM
                p_eam_flag in varchar2) return varchar2
  
   is
    c_req_line_filler constant number := -1;
    l_result varchar2(1);
    l_msg    varchar2(300);
    l_chk_error exception;
    l_req_line_filled boolean := false;
  
    /*function hold_rows(p_row_list in fnd_table_of_number) return boolean is
      pragma autonomous_transaction;
      l_result boolean := false;
    begin
    
      update xxpha.xxpha_sn1041_req_items ri
      set ri.req_line_id = c_req_line_filler,
          ri.object_version_number = ri.object_version_number + 1 -- чтобы OAF подхватил изменения
      where ri.req_item_id in (select c.column_value from table(p_row_list) c);
    
      if sql%rowcount > 0 then
        l_result := true;
      end if;
      commit;
    
      return l_result;
    end;*/
  
  begin
    --return 'OK';
    savepoint S1;
  
    --Заполняем типы заявки, если не выбраны
    set_requisition_types;
  
    if p_eam_flag = 'Y' then
      set_subinv(p_sub_inv);
    end if;
  
    --Заполнение темповой таблицы
    l_result := fill_temp_table(p_row_list, l_msg, p_eam_flag);
    if l_result = '2' then
      raise l_chk_error;
    end if;
  
    --Проверки данных
    l_result := check_data(p_sub_inv, p_need_by_date, l_msg, p_eam_flag);
    if l_result = '2' then
      raise l_chk_error;
    end if;
  
    --Помечаем строки как отправленные на обработку,
    --чтобы проверки не позволяли повторный запуск по этим строкам
    --l_req_line_filled := hold_rows(p_row_list);
  
    update xxpha.xxpha_sn1041_req_items ri
       set ri.req_line_id           = c_req_line_filler,
           ri.object_version_number = ri.object_version_number + 1 -- чтобы OAF подхватил изменения
     where ri.req_item_id in
           (select c.column_value from table(p_row_list) c);
  
    if sql%rowcount > 0 then
      l_req_line_filled := true;
    end if;
    --commit;
  
    --Создание заявки
    if p_eam_flag = 'Y' then
      --Логика для ремонтов
      l_result := XXPHA_SN1041_EAM_PKG.create_wip_req(l_msg);
      x_msg    := l_msg;
    else
      --Логика для снабжения
      l_result := create_shoping_cart(p_sub_inv,
                                      p_need_by_date,
                                      l_msg,
                                      p_eam_flag);
      x_msg    := 'Позиции успешно перенесены в корзину';
    end if;
    if l_result = '2' then
      raise l_chk_error;
    end if;
    add_log(x_msg);
    commit;
  
    return l_result;
  
  exception
    when l_chk_error then
      x_msg := l_msg;
      add_log(x_msg);
    
      if nvl(p_eam_flag, 'N') != 'Y' then
        rollback to S1; --типа ничё не было
        --null;
      end if;
    
      --Снимаем метки со строк, подготовленных к обработке обратно.
      if l_req_line_filled then
        update xxpha.xxpha_sn1041_req_items ri
           set ri.req_line_id           = null,
               ri.object_version_number = ri.object_version_number + 1 -- чтобы OAF подхватил изменения
         where ri.req_line_id = c_req_line_filler
           and ri.req_item_id in
               (select c.column_value from table(p_row_list) c);
        commit;
      end if;
    
      return l_result;
  end main;

  --Проверка и очистка таблиц
  procedure refresh_req_table is
    v_sql number;
  begin
    update xxpha.xxpha_sn1041_req_items ri
       set ri.req_line_id    = null,
           ri.REQ_HEADER_NUM = null,
           ri.REQ_LINE_QTY   = null,
           ri.STATUS         = 'Корзина очищена'
     where 1 = 1
       and nvl(ri.req_line_id, -1) != -1 --при рефреше стартует PR, который стирает ссылки и приводит к повторному запуску канкаретов
       and not exists
     (select 1
              from po_requisition_lines_all rl
             inner join po_requisition_headers_all rh
                on rl.REQUISITION_HEADER_ID = rh.REQUISITION_HEADER_ID
             where rl.REQUISITION_LINE_ID = ri.req_line_id
            --and rh.active_shopping_cart_flag = 'Y'
            );
  
    commit;
    v_sql := sql%rowcount;
    add_log('Очищено ссылок на заявку для строк: ' || v_sql);
  
  end;

begin
  $if xxpha_sn1041_pkg.debug
                                  $then
  xxpha_pnaumov_pkg.gb_log_mark := 'XXPHA_SN1041_LST_REQ_BSKT_PKG';
  $end

end xxpha_sn1041_lst_req_bskt_pkg;
/
