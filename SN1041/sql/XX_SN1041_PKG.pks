create or replace package XXPHA_SN1041_PKG is

  -- Author  :
  -- Created : 18.03.2020 14:31:13
  -- Purpose :

  -- Public type declarations
  -- type <TypeName> is <Datatype>;
  type t_Found_Item is record(
    index_name                 varchar2(50),
    score                      number,
    item_id                    number,
    ITEM_CODE                  varchar2(50),
    ITEM_DESCRIPTION           varchar2(4000),
    ITEM_LONG_DESCR            varchar2(4000),
    SUP_DESCRIPTION            varchar2(4000),
    PRICE                      NUMBER,
    UOM                        VARCHAR2(100),
    VENDOR_ID                  number,
    VENDOR_PRODUCT_NUM         VARCHAR2(100),
    PO_LINE_ID                 NUMBER,
    DEAKT                      VARCHAR2(100),
    CS_QUANTITY                number,
    CS_AVAILABLE_QUANTITY      number,
    STORE_QUANTITY             number,
    STORE_AVAILABLE_QUANTITY   number,
    HOLDING_QUANTITY           number,
    HOLDING_AVAILABLE_QUANTITY number,
    PICTURE                    icx_cat_attribute_values.PICTURE%type,
    AGREEMENT                  VARCHAR2(150));

  type t_found_items is table of t_Found_Item;

  -- Public constant declarations
  DEBUG constant boolean := true;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  procedure Dummy;

  --логирование
  procedure add_log(p_msg in varchar2);

  function get_item_price(p_price_id   number,
                          p_item_id    number,
                          p_po_line_id number) return number;

  function get_requisition_type(p_catalog_code          in varchar2,
                                p_cs_available_quantity in number,
                                p_quantity              in number default null)
    return varchar2 deterministic;

  function get_elastic_items(p_search_str IN varchar2,
                             p_index_name in varchar2,
                             p_org_id     in number default null) return clob;

  procedure Item_Search(p_search_str IN varchar2);
  --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;

  --Поиск с результатами во временной таблице
  procedure get_search_tbl(p_search_str     IN varchar2,
                           p_oe_id          in number,
                           p_store_receiver in number,
                           p_use_elastic    in varchar2 default 'Y');

  function get_items_pipe(p_search_str     IN varchar2,
                          p_oe_id          in number,
                          p_store_receiver number,
                          p_index_name     in varchar2 default xxpha_rgp001_pkg.INDEX_NAME_IPURCH)
    return t_found_items
    pipelined;

  function add_selected_items(p_search_item_id  number,
                              p_oe_id           number,
                              p_organization_id number,
                              p_wip_entity_id   number,
                              p_cs_quantity     number default 0,
                              x_messages        out varchar2) return number;

  function delete_selected_items(line_num in varchar2) return number;

  --Проверка наличия необработанных строк
  function have_draft return varchar2;

  --Удаление черновика
  function delete_draft return number;

  --Получить ID центрального склада
  --По текущей ORG_ID
  function Get_CS_ID(p_org_id varchar2) return number;

  --Получить ID склада текущей сессии
  function Get_Cur_Ses_Store_ID return number;

  --Добавить выбраныне аналоги к поиску
  function Add_Analog(p_item_ids              in fnd_table_of_number,
                      p_item_codes            in fnd_table_of_varchar2_30,
                      p_item_descriptions     in fnd_table_of_varchar2_4000,
                      p_uom                   in fnd_table_of_varchar2_30,
                      p_cs_available_quantity in fnd_table_of_number,
                      p_oe_id                 in number,
                      p_organization_id       in number,
                      p_wip_entity_id         number := NULL,
                      x_out_messages          out fnd_table_of_varchar2_4000)
    return number;

  procedure Refresh_Price(p_org_id       in number,
                          p_vendor_codes in fnd_table_of_varchar2_120,
                          x_out_messages out fnd_table_of_varchar2_4000);

  procedure Clear_Draft;

  function Get_Organization_Id(p_organization_code in varchar2) return number;

  procedure Clear_Search;

  function Get_Wip_Organization_ID(p_wip_entity_id in number) return number;

  function Get_Org_Id_By_Organization_ID(p_organization_id in number)
    return number;
  procedure get_search_tbl_eam(p_wip_entity_id in number);

  function Get_Organization_name(p_organization_id in number) return varchar2;

  function Get_Cur_Wip_Entity_ID return number;

  function Get_Default_Wip_Subinventory(p_wip_entity_id number)
    return Varchar2;

  function Get_Wip_Sheduled_Start_Date(p_wip_entity_id number) return Date;

  --Определение доступного количества на складе второй ОЕ на данной площадке
  FUNCTION get_pair_available_qant(p_organization_id   IN NUMBER,
                                   p_inventory_item_id IN NUMBER)
    RETURN NUMBER deterministic;

end XXPHA_SN1041_PKG;
/
