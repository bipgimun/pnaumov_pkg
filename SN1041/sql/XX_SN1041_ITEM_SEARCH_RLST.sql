begin
execute immediate 'drop table XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT';
exception
   when others then
     null;
end;
/
sho err

--create table XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT
create global temporary table XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT
(
  score                      NUMBER,
  inventory_item_id          NUMBER,
  po_line_id                 NUMBER,
  item_code                  VARCHAR2(50),
  catalog_code               VARCHAR2(50),
  description                VARCHAR2(4000),
  sup_description            VARCHAR2(4000),
  price                      NUMBER,
  uom                        VARCHAR2(200),
  cs_quantity                NUMBER,
  cs_available_quantity      NUMBER,
  store_quantity             NUMBER,
  store_available_quantity   NUMBER,
  holding_quantity           NUMBER,
  holding_available_quantity NUMBER,
  deliveries                 NUMBER,
  supplier                   VARCHAR2(250),
  image                      VARCHAR2(1000),
  analog                     VARCHAR2(250),
  deactivation               VARCHAR2(20),
  last_update_date           TIMESTAMP(6) default systimestamp,
  index_name                 VARCHAR2(100),
  score_str                  VARCHAR2(20),
  search_item_id             NUMBER generated always as identity,
  vendor_id                  NUMBER
) on commit preserve rows
/
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.item_code
  is 'Номенклатурный номер позиции';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.catalog_code
  is 'Каталожный номер позиции';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.description
  is 'Описание позици КИС';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.sup_description
  is 'Описание позиции поставщика';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.price
  is 'Цена';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.uom
  is 'ЕИ';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.cs_quantity
  is 'Центральный склад Всего';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.cs_available_quantity
  is 'Центральный склад Доступно';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.store_quantity
  is 'Цеховой склад заявителя Всего';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.store_available_quantity
  is 'Цеховой склад заявителя Доступно';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.holding_quantity
  is 'Склады холдинга Всего';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.holding_available_quantity
  is 'Склады холдинга Доступно';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.deliveries
  is 'Ожидаемые поставки';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.supplier
  is 'Поставщик';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.image
  is 'Визуализация';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.analog
  is 'Аналог';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.deactivation
  is 'К деактивации';
