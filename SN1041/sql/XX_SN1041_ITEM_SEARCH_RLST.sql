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
  is '�������������� ����� �������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.catalog_code
  is '���������� ����� �������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.description
  is '�������� ������ ���';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.sup_description
  is '�������� ������� ����������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.price
  is '����';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.uom
  is '��';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.cs_quantity
  is '����������� ����� �����';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.cs_available_quantity
  is '����������� ����� ��������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.store_quantity
  is '������� ����� ��������� �����';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.store_available_quantity
  is '������� ����� ��������� ��������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.holding_quantity
  is '������ �������� �����';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.holding_available_quantity
  is '������ �������� ��������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.deliveries
  is '��������� ��������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.supplier
  is '���������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.image
  is '������������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.analog
  is '������';
comment on column XXPHA.XXPHA_SN1041_ITEM_SEARCH_RSLT.deactivation
  is '� �����������';
