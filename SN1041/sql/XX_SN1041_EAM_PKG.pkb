create or replace package body XXPHA_SN1041_EAM_PKG is

  -- Дописывает текст к переменной из другой переменной
  procedure Append_text(p_dest in out varchar2, p_source in varchar2) is
  begin
  
    if p_dest is not null then
      p_dest := p_dest || chr(10) || p_source;
    else
      p_dest := p_source;
    end if;
  
  end Append_text;

  function get_ou(p_organization_id number) return number is
    v_ou number;
  begin
    select o.OPERATING_UNIT
      into v_ou
      from xxpha_organizations_v o
     where o.ORGANIZATION_ID = p_organization_id;
  
    return v_ou;
  end;

  -- Находит МВЗ и ЦФО для ЗВР
  function Get_MVZ_CFO(p_wip_entity_id in number) return EAM_rec is
    l_rec EAM_rec;
  begin
  
    select att.c_attribute1, --МВЗ
           lv.tag --ЦФО
      into l_rec.mvz, l_rec.cfo
      from apps.wip_entities we
     inner join apps.wip_discrete_jobs wdj
        on we.wip_entity_id = wdj.wip_entity_id
       and we.organization_id = wdj.organization_id
     inner join apps.mtl_eam_asset_attr_values att
        on wdj.maintenance_object_id = att.maintenance_object_id
     inner join apps.eam_work_order_details ewod
        on ewod.wip_entity_id = wdj.wip_entity_id
       and ewod.organization_id = wdj.organization_id
     inner join apps.fnd_lookup_values lv
        on lv.lookup_code = ewod.planner_maintenance
     where we.wip_entity_id = p_wip_entity_id
       and att.attribute_category = 'XXPHA_EAM_ACCOUNTING'
       and lv.lookup_type = 'EAM_PLANNER'
       and lv.language = userenv('LANG');
  
    return l_rec;
  exception
    when no_data_found then
    
      l_rec.mvz := null;
      l_rec.cfo := null;
      return l_rec;
  end Get_MVZ_CFO;

  --Очистка необработанных строк (всех ранее запущенных, но не имеющих ссылки на заявку)
  procedure clean_error_rows(p_wip_entity_id number) is
  begin
    update xxpha.xxpha_sn1041_req_items sri
       set sri.req_line_id = null
     where sri.wip_entity_id = p_wip_entity_id
       and sri.req_line_id = -1;
  end;

  --Очистка строк интерфейса заявок
  procedure clean_interface(p_wip_entity_id in number) is
  begin
    delete from apps.po_requisitions_interface_all i
     where i.interface_source_code in ('XXPHA_EAM517', 'XXPHA_EAM518')
       and i.batch_id = p_wip_entity_id;
  end clean_interface;

  --Расчёт даты ГК. Спёр к фигам из EAM518
  function get_gl_date(p_organization_id      number,
                       p_scheduled_start_date date,
                       p_wro_attribute4       varchar2,
                       p_DATE_REQUIRED        date) return date is
    v_attribute4_count number := 0;
    v_gl_date          date;
    v_wip_period       varchar2(100);
    v_current_period   varchar2(100);
    v_count1           number;
    v_count2           number;
    v_ledger_id        number;
  begin
  
    /*GL_DATE –заполняем дату ГК в заявке по следующему алгоритму:
    Анализируем период, в который попадает плановая дата начала ЗвР.
    Т.е. сравниваем месяц/год плановой даты начала ЗвР с текущим месяцем/годом!!!!
    1)  Если период будущий:
    •   В случае если данный период ГК и период закупок открыты, дата ГК в заявке = плановая дата начала работ;
    •   В случае если данный период ГК или период закупок не открыты (статус <> «Открыто», то дата ГК в заявке = системной дате.
    
    2)  Если период прошедший:
    дата ГК в заявке = Нужная дата, если этот период открыт, или первое число ближайшего будущего открытого периода.
    В обоих случаях берутся даты начиная с 1 апреля 2017 и позднее.
    
    3)  В текущем периоде:
    дата ГК в заявке = нужной дате поставки по строке материала в ЗВР («Нужная дата» в ЗвР, см. Рисунок 7).
    */
  
    --Определим ledger_id
  
    Select t.ORG_INFORMATION1
      Into v_ledger_id
      From hr_organization_information t
     Where organization_id = p_organization_id
       and org_information_context = 'Accounting Information';
  
    -- Определяем периоды
    v_wip_period     := to_char(p_scheduled_start_date, 'yyyy.mm');
    v_current_period := to_char(sysdate, 'yyyy.mm');
  
    --Если значение поля "Дата ГК" (рис.14а ниже, атрибут 4 ОГП) заполнено,
    --то брать это значение в качестве значения GL_DATE для строки,
    --при условии, что периоды в закупках и ГК открыты для нее
    Select count(1)
      into v_attribute4_count
      FROM GL_PERIOD_STATUSES t
     WHERE 1 = 1
       and application_id in (101, 201)
       and ledger_id = v_ledger_id
       and closing_status = 'O'
       and fnd_date.canonical_to_date(p_wro_attribute4) between
           t.START_DATE and t.END_DATE;
  
    if v_attribute4_count = 2 then
      v_gl_date := fnd_date.canonical_to_date(p_wro_attribute4);
    else
    
      --Сравниваем их как строки в формате год-месяц
      if v_wip_period = v_current_period then
        --текущий
        v_gl_date := p_DATE_REQUIRED;
      elsif v_wip_period > v_current_period then
        --будущий.
        -- Определим открытость периода ГК и периода закупок
        Select count(1)
          into v_count1
          FROM /*GL.*/ GL_PERIOD_STATUSES t
         WHERE application_id = 201
           AND ledger_id = v_ledger_id
           AND closing_status = 'O'
           and trunc(p_DATE_REQUIRED) between t.START_DATE and t.END_DATE; -- 24.01.2018 Спелицин - обрезано время в DATE_REQUIRED
        --      and rc.scheduled_start_date between t.START_DATE and t.END_DATE;   -- 09.10.2017  Корупаев Ю.Н.
      
        Select count(1)
          into v_count2
          FROM /*GL.*/ GL_PERIOD_STATUSES t
         WHERE application_id = 101
           AND ledger_id = v_ledger_id
           AND closing_status = 'O'
           and trunc(p_DATE_REQUIRED) between t.START_DATE and t.END_DATE; -- 24.01.2018 Спелицин - обрезано время в DATE_REQUIRED
        --      and rc.scheduled_start_date between t.START_DATE and t.END_DATE; -- 09.10.2017  Корупаев Ю.Н.
      
        -- и проставим дату
        if v_count1 > 0 and v_count2 > 0 then
          v_gl_date := p_DATE_REQUIRED;
        else
          v_gl_date := sysdate;
        end if;
      else
        -- прошедший
      
        -- Если период с заказа открыт, то ставим дату с заказа(как в текущем периоде)
        begin
          Select p_DATE_REQUIRED
            into v_gl_date
            From dual
           Where exists
           (Select 1
                    FROM GL_PERIOD_STATUSES t
                   WHERE application_id = 201
                     AND ledger_id = v_ledger_id
                     AND closing_status = 'O'
                     and t.START_DATE >= to_date('01.04.2017', 'dd.mm.yyyy')
                     and p_DATE_REQUIRED between t.START_DATE and t.end_date)
             and exists
           (Select 1
                    FROM GL_PERIOD_STATUSES t
                   WHERE application_id = 101
                     AND ledger_id = v_ledger_id
                     AND closing_status = 'O'
                     and t.START_DATE >= to_date('01.04.2017', 'dd.mm.yyyy')
                     and p_DATE_REQUIRED between t.START_DATE and t.end_date);
        exception
          when no_data_found then
            begin
              select max(st_date)
                into v_gl_date
                from (select min(t.START_DATE) st_date
                        FROM GL.GL_PERIOD_STATUSES t
                       WHERE application_id = 101
                         AND ledger_id = v_ledger_id
                         AND closing_status = 'O'
                         and t.START_DATE >=
                             to_date('01.04.2017', 'dd.mm.yyyy')
                         and t.START_DATE >= p_DATE_REQUIRED
                      union
                      select min(t.START_DATE) st_date
                        FROM GL.GL_PERIOD_STATUSES t
                       WHERE application_id = 201
                         AND ledger_id = v_ledger_id
                         AND closing_status = 'O'
                         and t.START_DATE >=
                             to_date('01.04.2017', 'dd.mm.yyyy')
                         and t.START_DATE >= p_DATE_REQUIRED);
            exception
              when too_many_rows then
                v_gl_date := NULL;
            end;
        end;
      end if;
    end if;
  
    return v_gl_date;
  end;

  -- Расчитывает значения для распределений заявки
  function Get_distr_values(p_wip_entity_id in number,
                            p_item_id       in number,
                            p_operation     in number)
    return XXPHA_SN1041_CREATE_REQ_PKG.Dist_Rec_type is
    l_return_row XXPHA_SN1041_CREATE_REQ_PKG.Dist_Rec_type;
    --l_wip_rec EAM_rec;
    l_bdg_element apps.mtl_item_categories_v.category_concat_segs%type;
    l_bdg_item    apps.pa_projects_all.attribute5%type;
    l_company     apps.gl_code_combinations.segment1%type;
    --l_error_msg varchar2(500);
    v_ORGANIZATION_ID      number;
    v_scheduled_start_date date;
    v_wro_attribute4       varchar2(100);
    v_DATE_REQUIRED        date;
  
    v_return_code varchar2(100);
    v_msg         varchar2(1000);
    --l_comb boolean;
  begin
    select nvl(cat1.category_concat_segs, cat2.category_concat_segs) bdg_element, --Бюджетный ресурс
           wdj.project_id,
           wdj.task_id,
           nvl(proj.attribute5, gcc.segment5) bdg_item,
           gcc.segment1, --Компания
           wdj.ORGANIZATION_ID,
           wdj.scheduled_start_date,
           wro.ATTRIBUTE4, --Дата ГК для потребностях
           wro.DATE_REQUIRED
    
      into l_bdg_element,
           l_return_row.project_id,
           l_return_row.task_id,
           l_bdg_item,
           l_company,
           v_ORGANIZATION_ID,
           v_scheduled_start_date,
           v_wro_attribute4,
           v_DATE_REQUIRED
      from apps.wip_entities we
     inner join apps.wip_discrete_jobs wdj
        on we.wip_entity_id = wdj.wip_entity_id
       and we.organization_id = wdj.organization_id
     inner join apps.wip_accounting_classes wac
        on wac.class_code = wdj.class_code
       and wac.organization_id = wdj.organization_id
    --Вообще неуверен в комбинациях
     inner join apps.gl_code_combinations gcc
        on wac.material_account = gcc.code_combination_id
      left join apps.wip_requirement_operations wro
        on wro.wip_entity_id = wdj.wip_entity_id
       and wro.organization_id = wdj.organization_id
       and wro.inventory_item_id = p_item_id
       and wro.operation_seq_num = p_operation
      left join apps.mtl_item_categories_v cat1
        on wro.inventory_item_id = cat1.inventory_item_id
       and wro.organization_id = cat1.organization_id
       and cat1.category_set_name = 'Бюджетный ресурс'
      left join apps.mtl_item_categories_v cat2
        on wro.inventory_item_id = cat2.inventory_item_id
       and cat2.organization_id =
           (select ood.ORGANIZATION_ID
              from org_organization_definitions ood
             where ood.ORGANIZATION_CODE = '000')
       and cat2.category_set_name = 'Бюджетный ресурс'
      left join apps.pa_projects_all proj
        on proj.project_id = wdj.project_id
     where 1 = 1
       and we.wip_entity_id = p_wip_entity_id;
  
    --l_wip_rec := Get_MVZ_CFO(p_wip_entity_id);
  
    --Расчёт буджетного счета
    XXPHA_EAM518_PKG.get_acct_id(p_wip_entity_id   => p_wip_entity_id,
                                 p_organization_id => v_ORGANIZATION_ID,
                                 p_item_id         => p_item_id,
                                 x_cc_id           => l_return_row.budget_account_id,
                                 x_return_code     => v_return_code,
                                 x_msg             => v_msg);
  
    /*-- Если нет указанного материала в ЗВР, то создаст новый счет.
    -- Возможно так не надо.
    if not xxpha_bc517_pkg.get_budget_combination_id(i_company        => l_company,
                                                        i_mvz            => l_wip_rec.mvz,
                                                        i_cfo            => l_wip_rec.cfo,
                                                        i_bdg_item       => l_bdg_item,
                                                        i_bdg_element    => l_bdg_element,
                                                        i_project_id     => l_wip_rec.project_id,
                                                        --i_party          => ,
                                                        o_return_comb_id => l_wip_rec.code_combination_id,
                                                        o_error_msg      => l_error_msg)
    then
      null; --ошибка
    end if;      */
  
    --мапинг wip row на dist row
  
    --l_return_row.budget_account_id:= l_wip_rec.code_combination_id;
    l_return_row.gl_encumbered_date := get_gl_date(p_organization_id      => v_ORGANIZATION_ID,
                                                   p_scheduled_start_date => v_scheduled_start_date,
                                                   p_wro_attribute4       => v_wro_attribute4,
                                                   p_DATE_REQUIRED        => v_DATE_REQUIRED);
  
    if l_return_row.gl_encumbered_date is not null then
      select gp.PERIOD_NAME
        into l_return_row.gl_encumbered_period_name
        from gl_periods gp
       where 1 = 1
         and l_return_row.gl_encumbered_date between gp.START_DATE and
             gp.END_DATE
         and gp.PERIOD_SET_NAME = 'PHA_ACC';
    
      l_return_row.prevent_encumbrance_flag := 'N';
    end if;
  
    if l_return_row.project_id is not null then
      l_return_row.PROJECT_ACCOUNTING_CONTEXT := 'Y';
    else
      l_return_row.PROJECT_ACCOUNTING_CONTEXT := 'N';
    end if;
  
    l_return_row.encumbered_flag := 'N';
  
    return l_return_row;
  end Get_distr_values;

  -- Заполняет поля МВЗ и ЦФО в таблице xxpha.xxpha_sn1041_req_items
  procedure Fill_MVZ_CFO(p_req_item_id in number) is
    l_row EAM_rec;
    --l_wip_entity_id xxpha.xxpha_sn1041_req_items.wip_entity_id%type;
    --l_OPERATION_SEQ_NUM xxpha.xxpha_sn1041_req_items.OPERATION_SEQ_NUM%type;
    l_sn1041_row xxpha.xxpha_sn1041_req_items%rowtype;
    v_req_header varchar2(4000);
    v_req_qty    number;
  
  begin
  
    select *
      into l_sn1041_row
      from xxpha.xxpha_sn1041_req_items sri
     where sri.req_item_id = p_req_item_id;
  
    if l_sn1041_row.WIP_ENTITY_ID is not null then
    
      l_row := Get_MVZ_CFO(l_sn1041_row.WIP_ENTITY_ID);
    
      declare
        l_wro_row wip_requirement_operations_v%rowtype;
        l_wip_row wip_entities%rowtype;
        v_org_id  number;
      begin
        select *
          into l_wip_row
          from wip_entities we
         where we.WIP_ENTITY_ID = l_sn1041_row.WIP_ENTITY_ID;
      
        select *
          into l_wro_row
          from wip_requirement_operations_v wro
         where wro.wip_entity_id = l_sn1041_row.WIP_ENTITY_ID
           and wro.operation_seq_num = l_sn1041_row.OPERATION_SEQ_NUM
           and wro.inventory_item_id = l_sn1041_row.ITEM_ID
           and wro.organization_id = l_wip_row.organization_id;
      
        v_org_id := get_ou(l_wip_row.organization_id);
      
        --Получение кол-ва из EAM518
        l_sn1041_row.QUANTITY := XXPHA_EAM518_PKG.get_qty(p_ORGANIZATION_ID   => l_wro_row.ORGANIZATION_ID,
                                                          p_wip_entity_id     => l_wro_row.wip_entity_id,
                                                          p_wip_entity_name   => l_wip_row.wip_entity_name,
                                                          p_inventory_item_id => l_wro_row.inventory_item_id,
                                                          p_operation_seq_num => l_wro_row.operation_seq_num,
                                                          p_REQUIRED_QUANTITY => l_wro_row.REQUIRED_QUANTITY,
                                                          p_QUANTITY_ISSUED   => l_wro_row.QUANTITY_ISSUED,
                                                          p_QUANTITY_OPEN     => l_wro_row.QUANTITY_OPEN);
      
        --Пересмотр типа строки
        l_sn1041_row.requisition_type := XXPHA_SN1041_PKG.get_requisition_type(l_sn1041_row.CATALOG_NUM,
                                                                               l_sn1041_row.CS_AVAILABLE_QUANTITY,
                                                                               l_sn1041_row.QUANTITY);
      
        --Найти заявки из гибкого поля
        with q as
         (select trim(substr(f, 1, instr(f, '/') - 1)) head,
                 trim(substr(f, instr(f, '/') + 1, length(f))) line
            from (select regexp_substr(a, '[^,]+', 1, level) f
                    from (select --'2437 / 2, 18530 / 1, 18530 / 2, 21262 / 2, 21262 / 3'
                          --replace('2918/1;5392/2;6065/2',';',',')
                           replace(l_wro_row.attribute1, ';', ',') --приводим к одному сепаратору
                           a
                            from dual)
                  connect by instr(a, ',', 1, level - 1) > 0))
        --находим заявки и получаем с них инфу
        ,
        req as
         (select rh.SEGMENT1, sum(rl.QUANTITY) QUANTITY
            from po_requisition_headers_all rh
           inner join po_requisition_lines_all rl
              on rh.REQUISITION_HEADER_ID = rl.REQUISITION_HEADER_ID
           inner join q
              on rh.SEGMENT1 = q.head
             and rl.LINE_NUM = q.line
           where 1 = 1
             and rh.ORG_ID = v_org_id --заявок с одним номером может быть много
             and rl.ITEM_ID = l_wro_row.inventory_item_id --проверяем что в WRO и в строке заявки одна позиция (а то мало ли)
           group by rh.SEGMENT1)
        --схлопываем результаты
        select listagg(SEGMENT1, ', ') within group(order by SEGMENT1) SEGMENT1,
               sum(QUANTITY) QUANTITY
          into v_req_header, v_req_qty
          from req;
      
        xxpha_log('l_sn1041_row.QUANTITY = ' || l_sn1041_row.QUANTITY);
      exception
        when no_data_found then
          null; --нет материалов
          xxpha_log('NDF');
      end;
    
      update xxpha.xxpha_sn1041_req_items sri
         set sri.MVZ              = l_row.mvz,
             sri.cfo              = l_row.cfo,
             sri.QUANTITY         = l_sn1041_row.QUANTITY,
             sri.REQUISITION_TYPE = l_sn1041_row.requisition_type,
             sri.REQ_HEADER_NUM   = v_req_header,
             sri.REQ_LINE_QTY     = v_req_qty
       where sri.req_item_id = p_req_item_id;
    
      --commit;
    end if;
  
  end Fill_MVZ_CFO;

  --Процедура создания потребности в материалах
  procedure Fill_WRO is
    -- API specific declarations
    l_eam_wo_rec eam_process_wo_pub.eam_wo_rec_type := null;
  
    l_eam_op_tbl               eam_process_wo_pub.eam_op_tbl_type;
    l_eam_op_network_tbl       eam_process_wo_pub.eam_op_network_tbl_type;
    l_eam_res_tbl              eam_process_wo_pub.eam_res_tbl_type;
    l_eam_res_inst_tbl         eam_process_wo_pub.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl          eam_process_wo_pub.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl        eam_process_wo_pub.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl          eam_process_wo_pub.eam_mat_req_tbl_type;
    l_out_eam_direct_items_tbl eam_process_wo_pub.eam_direct_items_tbl_type;
    --
    x_eam_wo_rec           eam_process_wo_pub.eam_wo_rec_type := null;
    x_eam_op_tbl           eam_process_wo_pub.eam_op_tbl_type;
    x_eam_op_network_tbl   eam_process_wo_pub.eam_op_network_tbl_type;
    x_eam_res_tbl          eam_process_wo_pub.eam_res_tbl_type;
    x_eam_res_inst_tbl     eam_process_wo_pub.eam_res_inst_tbl_type;
    x_eam_sub_res_tbl      eam_process_wo_pub.eam_sub_res_tbl_type;
    x_eam_res_usage_tbl    eam_process_wo_pub.eam_res_usage_tbl_type;
    x_eam_mat_req_tbl      eam_process_wo_pub.eam_mat_req_tbl_type;
    x_eam_direct_items_tbl eam_process_wo_pub.eam_direct_items_tbl_type;
    --
    v_status     varchar2(50) := null;
    v_msg_cnt    number := 0;
    v_output_dir varchar2(255);
    --v_str_error varchar2 (4000):= null;
  begin
    for curs in (
                 --Перебираем временную табличку
                 select * from XXPHA_SN1041_EAM_V) loop
      declare
        l_eam_mat_req_rec eam_process_wo_pub.eam_mat_req_rec_type := null;
        v_need_qty        number;
        v_new_qty         number;
      begin
        l_eam_mat_req_rec.header_id         := curs.wip_entity_id;
        l_eam_mat_req_rec.batch_id          := 1;
        l_eam_mat_req_rec.row_id            := null;
        l_eam_mat_req_rec.wip_entity_id     := curs.wip_entity_id;
        l_eam_mat_req_rec.organization_id   := curs.organization_id;
        l_eam_mat_req_rec.operation_seq_num := curs.operation_seq_num;
        l_eam_mat_req_rec.inventory_item_id := curs.item_id;
      
        --Определяем тип операции (есть ВРО или нет)
        -- и заполняем остальные аттрибуты
      
        --обновления полей
      
        --Надо заполнять скл. подр, если пустое
        l_eam_mat_req_rec.SUPPLY_SUBINVENTORY := nvl(curs.SUPPLY_SUBINVENTORY,
                                                     curs.wip_subinventory);
      
        l_eam_mat_req_rec.DATE_REQUIRED := curs.wip_date_required;
        --Заполняю дату ГК для обновления и создания строки WRO, а не только для создания
        l_eam_mat_req_rec.ATTRIBUTE4 := fnd_date.date_to_canonical(curs.wip_gl_date); --fnd_date.date_to_canonical(curs.wip_date_required);
      
        --Обновляем аттрибуты SN1041-14
        -- ATTRIBUTE5 (Номер ОЛ) значение сегмента XXPHA_EAM518_OL_NUM ОГП формы "Потребности в материалах" строки материала в ЗВР.
        -- ATTRIBUTE6 (Дата ОЛ) значение сегмента XXPHA_EAM518_OL_DATE ОГП формы "Потребности в материалах" строки материала в ЗВР.
        l_eam_mat_req_rec.comments   := curs.wip_buyer_notes;
        l_eam_mat_req_rec.ATTRIBUTE5 := curs.wip_ol_num;
        l_eam_mat_req_rec.ATTRIBUTE6 := fnd_date.date_to_canonical(curs.wip_ol_date);
      
        --Добавление новой потребности
        if curs.wro is null then
          l_eam_mat_req_rec.DEPARTMENT_ID := curs.DEPARTMENT_ID;
          --l_eam_mat_req_rec.DATE_REQUIRED:= curs.wip_date_required;
          l_eam_mat_req_rec.AUTO_REQUEST_MATERIAL := 'Y';
          l_eam_mat_req_rec.QUANTITY_ISSUED       := 0; --Выпущено
          l_eam_mat_req_rec.WIP_SUPPLY_TYPE       := 1; --Выдача материала до сборки
          l_eam_mat_req_rec.MRP_NET_FLAG          := 1; --Чистое ППМ Yes
          --Под вопросом апдейта
        
          --Пока закомментил, может дату ГК надо заполнять только для создания новой потребности
          --l_eam_mat_req_rec.ATTRIBUTE4:= fnd_date.date_to_canonical(curs.wip_gl_date); --fnd_date.date_to_canonical(curs.wip_date_required);
        
          l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_CREATE;
        
          l_eam_mat_req_rec.REQUIRED_QUANTITY     := curs.quantity; -- TODO Рассчитать количество в зависимости от уже созданных заявок по ТМЦ и выбранного пользователем
          l_eam_mat_req_rec.QUANTITY_PER_ASSEMBLY := curs.quantity;
          l_eam_mat_req_rec.RELEASED_QUANTITY     := curs.quantity;
        else
          --обновление
          l_eam_mat_req_rec.transaction_type := EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
        
          --Рассчитать количество в зависимости от уже созданных заявок по ТМЦ и выбранного пользователем
          --TODO 2. Сколько незаказано?
          v_need_qty := XXPHA_EAM518_PKG.get_qty(p_ORGANIZATION_ID   => curs.organization_id,
                                                 p_wip_entity_id     => curs.wip_entity_id,
                                                 p_wip_entity_name   => curs.wip_entity_name,
                                                 p_inventory_item_id => curs.item_id,
                                                 p_operation_seq_num => curs.operation_seq_num,
                                                 p_REQUIRED_QUANTITY => curs.REQUIRED_QUANTITY,
                                                 p_QUANTITY_ISSUED   => curs.QUANTITY_ISSUED,
                                                 p_QUANTITY_OPEN     => curs.QUANTITY_OPEN);
          --Если раздница между нужно заказать и недозакано больше нуля, увелииваем WRO на эту сумму
          v_new_qty := nvl(curs.quantity, 0) - nvl(v_need_qty, 0);
          if v_new_qty > 0 then
            l_eam_mat_req_rec.REQUIRED_QUANTITY     := curs.REQUIRED_QUANTITY +
                                                       v_new_qty;
            l_eam_mat_req_rec.QUANTITY_PER_ASSEMBLY := curs.QUANTITY_ISSUED +
                                                       v_new_qty;
            l_eam_mat_req_rec.RELEASED_QUANTITY     := curs.QUANTITY_OPEN +
                                                       v_new_qty;
          end if;
          --Если раздница меньше 0, то оставляем без изменения
        
        end if;
      
        --Заполняем коллекцию
        l_eam_mat_req_tbl(curs.rn) := l_eam_mat_req_rec;
      
        XXPHA_SN1041_PKG.add_log('operation_seq_num =' ||
                                 l_eam_mat_req_rec.operation_seq_num ||
                                 ', inventory_item_id = ' ||
                                 l_eam_mat_req_rec.inventory_item_id ||
                                 ', transaction_type = ' ||
                                 l_eam_mat_req_rec.transaction_type);
      end;
    end loop;
  
    eam_process_wo_pub.process_wo(p_bo_identifier        => 'EAM',
                                  p_api_version_number   => 1.0,
                                  p_init_msg_list        => TRUE,
                                  p_commit               => 'N',
                                  p_eam_wo_rec           => l_eam_wo_rec,
                                  p_eam_op_tbl           => l_eam_op_tbl,
                                  p_eam_op_network_tbl   => l_eam_op_network_tbl,
                                  p_eam_res_tbl          => l_eam_res_tbl,
                                  p_eam_res_inst_tbl     => l_eam_res_inst_tbl,
                                  p_eam_sub_res_tbl      => l_eam_sub_res_tbl,
                                  p_eam_res_usage_tbl    => l_eam_res_usage_tbl,
                                  p_eam_mat_req_tbl      => l_eam_mat_req_tbl,
                                  p_eam_direct_items_tbl => l_out_eam_direct_items_tbl,
                                  x_eam_wo_rec           => x_eam_wo_rec,
                                  x_eam_op_tbl           => x_eam_op_tbl,
                                  x_eam_op_network_tbl   => x_eam_op_network_tbl,
                                  x_eam_res_tbl          => x_eam_res_tbl,
                                  x_eam_res_inst_tbl     => x_eam_res_inst_tbl,
                                  x_eam_sub_res_tbl      => x_eam_sub_res_tbl,
                                  x_eam_res_usage_tbl    => x_eam_res_usage_tbl,
                                  x_eam_mat_req_tbl      => x_eam_mat_req_tbl,
                                  x_eam_direct_items_tbl => x_eam_direct_items_tbl,
                                  x_return_status        => v_status,
                                  x_msg_count            => v_msg_cnt,
                                  p_debug                => NVL(fnd_profile.value('EAM_DEBUG'),
                                                                'N'),
                                  p_output_dir           => v_output_dir,
                                  p_debug_filename       => 'EAMOPTHB.log',
                                  p_debug_file_mode      => 'a');
  
    /**/
    XXPHA_SN1041_PKG.add_log('Обновление WRO Вернулся статус = ' ||
                             v_status);
    XXPHA_SN1041_PKG.add_log('Обновление WRO - Вернулся v_msg_cnt = ' ||
                             to_char(v_msg_cnt));
  
    if v_msg_cnt > 0 then
      XXPHA_SN1041_PKG.add_log('Обновление WRO - Возникла ошибка в процесе удаления ресурса : ' ||
                               SQLERRM || ' : ' || sqlcode);
      --TODO Print error
      FOR i IN 1 .. NVL(v_msg_cnt, 0) LOOP
        XXPHA_SN1041_PKG.add_log(fnd_msg_pub.get(i, fnd_api.g_false));
      END LOOP;
    end if;
  
    if v_status <> 'S' then
      raise_application_error(-20000, 'WRO Error!');
      --xxpha_log( 'p_error_message = ' || p_error_message, 'T');
    end if;
  end;

  -- Апдейт строк таблицы 5 значениями созданной заявки
  procedure Update_req_items(p_row_list in fnd_table_of_number) is
  begin
    XXPHA_SN1041_PKG.add_log('Обновление ссылок на строку заявки во второй форме ЕФПП');
    for rec in (with items as
                   (select we.wip_entity_name || '/' || e.operation_seq_num comb,
                          e.item_id,
                          e.rowid,
                          e.req_item_id
                     from xxpha.xxpha_sn1041_req_items e
                    inner join wip_entities we
                       on e.wip_entity_id = we.wip_entity_id)
                  
                  select h.segment1, l.requisition_line_id, l.quantity, i.*
                    from apps.po_requisition_lines_all l
                   inner join apps.po_requisition_headers_all h
                      on l.requisition_header_id = h.requisition_header_id
                   inner join table (p_row_list) c
                      on c.column_value = l.request_id
                   inner join items i
                      on i.comb = l.attribute1
                     and i.item_id = l.item_id) loop
      XXPHA_SN1041_PKG.add_log('Для req_item_id ' || rec.req_item_id ||
                               chr(10) || '  req_line_id    -> ' ||
                               rec.requisition_line_id || chr(10) ||
                               '  req_header_num -> ' || rec.segment1 ||
                               chr(10) || '  req_line_qty   -> ' ||
                               rec.quantity);
      update xxpha.xxpha_sn1041_req_items sri
         set sri.req_line_id    = rec.requisition_line_id,
             sri.req_header_num = rec.segment1,
             sri.req_line_qty   = rec.quantity
       where sri.rowid = rec.rowid;
    end loop;
  end Update_req_items;

  --Апдейт строк WRO для связки с созданными заявками
  procedure Update_WRO_with_req_num is
  begin
    update apps.wip_requirement_operations wro
       set wro.attribute1 =
           (select nvl2(wro.attribute1, wro.attribute1 || '; ', null) ||
                   sri.req_header_num || '/' || l.line_num
              from apps.po_requisition_lines_all l
             inner join xxpha.xxpha_sn1041_req_items sri
                on l.requisition_line_id = sri.req_line_id
             where sri.req_line_id is not null
               and wro.wip_entity_id = sri.wip_entity_id
               and wro.inventory_item_id = sri.item_id
               and wro.operation_seq_num = sri.operation_seq_num
               and wro.organization_id = sri.dest_organization_id)
     where exists
     (select 1
              from xxpha.xxpha_sn1041_req_items sri
             where sri.req_line_id is not null
               and wro.wip_entity_id = sri.wip_entity_id
               and wro.inventory_item_id = sri.item_id
               and wro.operation_seq_num = sri.operation_seq_num
               and wro.organization_id = sri.dest_organization_id);
  end Update_WRO_with_req_num;

  -- Обрабатывает строки Из наличного количества
  function Process_available_qty(p_msg out varchar2) return number is
    l_msg       varchar2(4000);
    l_total_msg varchar2(4000);
    l_count     number;
  begin
    --Проверяем есть ли строки для обработки
    select count(*)
      into l_count
      from XXPHA_SN1041_EAM_V e
     where 1 = 1
       and e.wro is not null
       and e.requisition_type = 2; --Из наличного количества
  
    if l_count = 0 then
      p_msg := null;
      return 3;
    end if;
  
    --Для строк из запаса запускаем EAM517
    for i in (select *
                from XXPHA_SN1041_EAM_V e
               where 1 = 1
                 and e.wro is not null
                 and e.requisition_type = 2 --Из наличного количества
              ) loop
      XXPHA_EAM517_PKG.create_requisitions(p_wip_entity_id          => i.wip_entity_id,
                                           p_operation_num          => i.operation_seq_num,
                                           p_item_id                => i.item_id,
                                           p_request_quantity       => i.quantity,
                                           p_source_organization_id => i.source_organization_id,
                                           p_source_subinventory    => null, --?
                                           p_msg                    => l_msg);
      if l_msg is not null then
        Append_text(l_total_msg, l_msg);
      end if;
    
    end loop;
  
    if l_total_msg is not null then
      p_msg := l_total_msg;
      return 2;
    end if;
  
    return 1;
  end Process_available_qty;

  -- Обрабатывает строки внутренних закупок
  function Process_eam518_purch(p_msg out varchar2) return number is
    l_result_code varchar2(30);
    l_msg         varchar2(4000);
    l_total_msg   varchar2(4000);
    l_count       number;
  begin
    --Очищаю переменную, чтобы в сессии не хранить лишние сообщения
    XXPHA_EAM518_PKG.g_total_msg := null;
  
    --Проверяем есть ли строки для обработки
    select count(*)
      into l_count
      from XXPHA_SN1041_EAM_V e
     where 1 = 1
       and e.wro is not null
       and trunc(e.requisition_type) in (1, 6); --В закупку
  
    if l_count = 0 then
      p_msg := null;
      return 3;
    end if;
    ---------Отбор строк для внутренних закупок-------------
    ----Для строк внутренней закупки запускаем EAM518
    for i in (select v.flex_value type_code, e.*
                from xxpha_sn1041_eam_v e
               inner join xxpha_sn1041_eam_req_type_v v
                  on e.requisition_type = v.requisition_type
               where 1 = 1
                 and e.wro is not null
                 and trunc(e.requisition_type) in (1, 6) --Все типы, относящиеся к внутренним закупкам. Проверяем по цифре до запятой.
              ) loop
      Xxpha_Eam518_Pkg.create_requisitions(p_wip_entity_id => i.wip_entity_id,
                                           p_result_code   => l_result_code,
                                           p_msg           => l_msg,
                                           --Для вызова по контретной потребности, например из SN1041
                                           p_inventory_item_id => i.item_id,
                                           p_operation_seq_num => i.operation_seq_num,
                                           p_qty               => i.quantity,
                                           p_req_type_code     => i.type_code,
                                           p_blanket_line_id   => i.po_line_id);
      --Записываем явные ошибки подготовки данных
      if l_result_code in ('S', 'E') then
        Append_text(l_total_msg, l_msg);
      end if;
    end loop;
  
    --Записываем ошибки проверок интерфейса
    if XXPHA_EAM518_PKG.g_total_msg is not null then
      Append_text(l_total_msg, XXPHA_EAM518_PKG.g_total_msg);
    end if;
  
    if l_total_msg is not null then
      p_msg := l_total_msg;
      return 2;
    end if;
  
    return 1;
  end Process_eam518_purch;

  --Блокирует строки WRO для последующей работы с ними
  function lock_rows return boolean is
    ex_rows_locked exception;
    pragma exception_init(ex_rows_locked, -54);
    l_item_ids fnd_table_of_number;
  begin
  
    select wro.inventory_item_id
      bulk collect
      into l_item_ids
      from wip_requirement_operations wro
     inner join xxpha_sn1041_eam_v v
        on wro.inventory_item_id = v.item_id
       and wro.operation_seq_num = v.operation_seq_num
       and wro.wip_entity_id = v.wip_entity_id
       and wro.organization_id = v.organization_id
       for update of wro.inventory_item_id nowait;
  
    return true;
  exception
    when ex_rows_locked then
      return false;
    when others then
      XXPHA_SN1041_PKG.add_log(sqlerrm);
      XXPHA_SN1041_PKG.add_log(dbms_utility.format_error_backtrace);
      return false;
  end lock_rows;

  -- Запуск конкаррентов по заполненным интерфейсам
  procedure Run_concurrent(x_errbuf        out nocopy varchar2,
                           x_retcode       out nocopy number,
                           p_wip_entity_id in number,
                           p_org_id        in number,
                           p_517_int_ready varchar2,
                           p_518_ready     varchar2) is
    l_msg          varchar2(4000);
    l_req_id       number;
    l_req_list     fnd_table_of_number := fnd_table_of_number();
    l_result_code  varchar2(1);
    l_total_msg    varchar2(4000);
    l_count        number;
    l_created_reqs varchar2(1000);
  begin
  
    XXPHA_SN1041_PKG.add_log('Начало работы XX_SN1041_EAM...');
  
    if p_517_int_ready = 'Y' then
      --Обрабатывает строки с INTERFACE_SOURCE_CODE = 'XXPHA_EAM517'
      XXPHA_EAM517_PKG.create_requisitions_conc(p_entity_id => p_wip_entity_id,
                                                p_req_id    => l_req_id,
                                                p_msg       => l_msg);
    
      -- Анализ ошибок/лога конкарента
      Select Count(1)
        Into l_count
        From po_interface_errors e
       Where e.REQUEST_ID = l_req_id;
    
      if l_count > 0 then
        Append_text(l_msg,
                    'Ошибки создания заявок . См. интерфейсные таблицы po_interface_errors для конкарента REQUEST_ID = ' ||
                    l_req_id);
      end if;
    
      --Выводим лог по ошибкам обработки в конкаррент наверх, для пользователя
      XXPHA_SN1041_PKG.add_log('----------------------------------------');
      XXPHA_SN1041_PKG.add_log('Результаты обработки строк для заявок из наличного количества:');
      XXPHA_SN1041_PKG.add_log(l_msg);
    
      --Ищем список созданных заявок
      select listagg(h.segment1, ', ') within group(order by h.segment1)
        into l_created_reqs
        from apps.po_requisition_headers_all h
       where 1 = 1
         and h.REQUEST_ID = l_req_id
         and exists
       (select 1
                from apps.po_requisition_lines_all l
               where l.requisition_header_id = h.requisition_header_id);
    
      if l_created_reqs is not null then
        --Выводим список созданных заявок в конкаррент наверх, для пользователя
        XXPHA_SN1041_PKG.add_log('Созданы заявки: ' || l_created_reqs);
        l_req_list.extend;
        l_req_list(l_req_list.last) := l_req_id;
      end if;
      XXPHA_SN1041_PKG.add_log('----------------------------------------');
    end if;
  
    if p_518_ready = 'Y' --or p_518_vend_ready = 'Y'
     then
      --Обрабатывает строки с INTERFACE_SOURCE_CODE = 'XXPHA_EAM518'
      l_req_id := Xxpha_Eam518_Pkg.run_concurent(v_ins_flag      => 'Y', --Флаг что строки есть в интерфейсе
                                                 v_req_flag      => 'N', --Ни на что не повлияет при v_ins_flag => 'Y' (нужен для вывода сообщения)
                                                 v_org_id        => p_org_id,
                                                 p_wip_entity_id => p_wip_entity_id,
                                                 p_result_code   => l_result_code,
                                                 p_msg           => l_msg,
                                                 v_total_msg     => l_total_msg);
    
      --Передаем лог в конкаррент наверх, для пользователя
      XXPHA_SN1041_PKG.add_log('----------------------------------------');
      XXPHA_SN1041_PKG.add_log('Результаты обработки строк для заявок внутренних закупок и заявок на приобретение');
      XXPHA_SN1041_PKG.add_log(l_msg);
      XXPHA_SN1041_PKG.add_log('----------------------------------------');
      --Ищем список созданных заявок
      select listagg(h.segment1, ', ') within group(order by h.segment1)
        into l_created_reqs
        from apps.po_requisition_headers_all h
       where 1 = 1
         and h.REQUEST_ID = l_req_id
         and exists
       (select 1
                from apps.po_requisition_lines_all l
               where l.requisition_header_id = h.requisition_header_id);
    
      if l_created_reqs is not null then
        --список выводить не надо, если заявки создались 518 пакет сам их кладет в l_msg
        l_req_list.extend;
        l_req_list(l_req_list.last) := l_req_id;
      end if;
    
    end if;
  
    if l_req_list.count != 0 then
      --Апдейт строк таблицы 5 для отображения созданной текущей заявки
      Update_req_items(l_req_list);
      --Добавляет в потребности в материалах связку со строкой заявки
      Update_WRO_with_req_num;
    
    end if;
  
    clean_interface(p_wip_entity_id);
    clean_error_rows(p_wip_entity_id);
    commit;
  
  exception
    when others then
      XXPHA_SN1041_PKG.add_log(SQLERRM);
      XXPHA_SN1041_PKG.add_log(dbms_utility.format_error_backtrace);
      clean_interface(p_wip_entity_id);
      clean_error_rows(p_wip_entity_id);
      commit;
      x_errbuf  := SQLERRM;
      x_retcode := 2; --ошибка
  end Run_concurrent;

  --Создание заявки для ремонтов
  function Create_Wip_Req(x_msg out varchar2) return varchar2 is
    l_wip_entity_id number;
    l_org_id        number; --Достать из вьюхи.
    l_error exception;
    l_msg           varchar2(4000) := null;
    l_total_msg     varchar2(4000) := null;
    l_result        number;
    l_req_id        number;
    l_517_int_ready varchar2(1) := 'N';
    l_518_ready     varchar2(1) := 'N';
  begin
    --Обновление ВРО для ЗВР
    Fill_WRO;
    x_msg := 'Потребности в материалах в ЗВР успешно обновлены';
  
    --Находим wip_entity_id ЗВР для дальнейшей обработки интерфейсов
    select e.wip_entity_id, e.org_id
      into l_wip_entity_id, l_org_id
      from XXPHA_SN1041_EAM_V e fetch first 1 row only; --Т.к. сейчас заявки создаем для одного ЗВР, то можно взять с любой строки
  
    --Очищаем интерфейс от необработанных строк по ЗВР.
    clean_interface(l_wip_entity_id);
    commit;
  
    --Обработка строк для Внутренних закупок and Заявка на приобретение (ЗЗ)
    l_result := Process_eam518_purch(l_msg);
    if l_result = 2 then
      Append_text(l_total_msg, l_msg);
    elsif l_result = 1 then
      l_518_ready := 'Y';
    end if;
  
    --Обработка строк для заявок Из наличного количества
    l_result := Process_available_qty(l_msg);
    if l_result = 2 then
      Append_text(l_total_msg, l_msg);
    elsif l_result = 1 then
      l_517_int_ready := 'Y';
    end if;
  
    if l_total_msg is not null then
      clean_interface(l_wip_entity_id);
      --commit;
      x_msg := l_total_msg;
      return '2';
    end if;
  
    if l_517_int_ready = 'Y' or l_518_ready = 'Y' then
      --Запуск конкаррента для запуска конкаррентов 517, 518
      fnd_request.set_org_id(l_org_id);
      l_req_id := fnd_request.submit_request(application => 'XXPHA',
                                             program     => 'XXPHA_SN1041_EAM_CONC',
                                             sub_request => false,
                                             argument1   => l_wip_entity_id,
                                             argument2   => l_org_id,
                                             argument3   => l_517_int_ready,
                                             argument4   => l_518_ready);
      commit;
      x_msg := 'Строки успешно обработаны. Для создания заявок запущен конкаррент с Request_id = ' ||
               l_req_id;
    
    else
      l_msg := 'Нет строк для обработки!';
      raise l_error;
    end if;
  
    return '1';
  exception
    when l_error then
      x_msg := l_msg;
      XXPHA_SN1041_PKG.add_log(x_msg);
      clean_interface(l_wip_entity_id);
      commit;
      return '2';
    when others then
      x_msg := 'Ошибка при создании заявок! ' || Sqlerrm;
      XXPHA_SN1041_PKG.add_log(x_msg);
      XXPHA_SN1041_PKG.add_log(Sqlerrm);
      XXPHA_SN1041_PKG.add_log(dbms_utility.format_error_backtrace);
      clean_interface(l_wip_entity_id);
      commit;
      return '2';
  end;

end XXPHA_SN1041_EAM_PKG;
/
