begin
execute immediate 'drop table XXPHA.XXPHA_SN1041_REQ_ITEMS_T';
exception
   when others then
     null;
end;
/
sho err
-- Create table
create table XXPHA.XXPHA_SN1041_REQ_ITEMS_T
(
  line_num                NUMBER,
  item_id                 NUMBER not null,
  descriptions            VARCHAR2(500),
  item_code               VARCHAR2(50),
  catalog_num             VARCHAR2(200),
  sup_description         VARCHAR2(4000),
  uom                     VARCHAR2(100),
  need_by_date            DATE,
  quantity                NUMBER,
  unit_price              NUMBER,
  supplier_id             NUMBER,
  source_organization_id  NUMBER,
  dest_organization_id    NUMBER,
  preparer_id             NUMBER,
  deliver_to_location_id  NUMBER,
  deliver_to_requestor_id NUMBER,
  org_id                  NUMBER,
  req_line_id             NUMBER,
  is_processed            VARCHAR2(1) default 'N' not null,
  cs_available_quantity   NUMBER,
  supplier                VARCHAR2(400),
  delivery_date           NUMBER,
  deactivation            VARCHAR2(100),
  index_name              VARCHAR2(100),
  delete_line             VARCHAR2(20),
  requisition_type        VARCHAR2(10),
  created_by              NUMBER not null,
  creation_date           DATE default sysdate not null,
  last_updated_by         NUMBER not null,
  last_update_date        DATE default sysdate not null,
  last_update_login       NUMBER,
  object_version_number   NUMBER,
  req_item_id             NUMBER generated always as identity,
  req_header_num          VARCHAR2(100),
  status                  VARCHAR2(255),
  req_line_qty            NUMBER,
  po_line_id	          NUMBER,
  wip_entity_id         NUMBER,
  operation_seq_num     NUMBER,
  mvz                   VARCHAR2(150),
  cfo                   VARCHAR2(150),
  wip_subinventory        VARCHAR2(50),
  wip_locator_id          NUMBER,
  wip_date_required       DATE,
  wip_gl_date             DATE,
  RESP_ID			NUMBER
)
/

-- Add comments to the columns 
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.line_num
  is '����� ������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.descriptions
  is '�������� ������� ���';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.item_code
  is '�������������� ����� ���';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.catalog_num
  is '���������� �����';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.sup_description
  is '�������� ���������� �������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.uom
  is '��';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.need_by_date
  is '��������� ����';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.quantity
  is '����������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.unit_price
  is '����';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.supplier_id
  is '������������� ����������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.source_organization_id
  is '������������� ��������� ����������� ���������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.dest_organization_id
  is '������������� ��������� ����������� ����������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.preparer_id
  is '������������� ����������� ������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.deliver_to_location_id
  is '������������� ������������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.deliver_to_requestor_id
  is '������������� ������ �������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.org_id
  is '������������� ������������ ������� (��)';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.req_line_id
  is '������������� ��������� ������ ������ (����� ������)';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.cs_available_quantity
  is '�������� �� ��';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.supplier
  is '���������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.delivery_date
  is '���� ��������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.deactivation
  is '� �����������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.index_name
  is '��� ������� ElasticSearch';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.delete_line
  is '������� ������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.created_by
  is 'Keeps track of which user created each row';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.creation_date
  is 'Stores the date on which each row was created';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.last_updated_by
  is 'Keeps track of who last updated each row';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.last_update_date
  is 'Stores the date on which each row was last updated';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.last_update_login
  is 'Provides access to information about the operating system login of the user who last updated each row';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.req_item_id
  is 'Primary key';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.wip_entity_id
  is '������������� ���';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.operation_seq_num
  is '� ��������';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.mvz
  is '��� ��� ���';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.cfo
  is '��� ��� ���';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.wip_subinventory
  is '�. ����������� � ���������� - ����������� - ���. �������.';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.wip_locator_id
  is '�. ����������� � ���������� - ����������� - ���. �����';
comment on column XXPHA.XXPHA_SN1041_REQ_ITEMS_T.wip_date_required
  is '�. ����������� � ���������� - �������� ������ - ������ ����';  
-- Create/Recreate primary, unique and foreign key constraints 
alter table XXPHA.XXPHA_SN1041_REQ_ITEMS_T
  add constraint PK primary key (REQ_ITEM_ID)
  using index;
