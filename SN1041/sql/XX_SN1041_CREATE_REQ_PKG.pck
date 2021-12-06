CREATE OR REPLACE Package XXPHA_SN1041_CREATE_REQ_PKG AUTHID CURRENT_USER AS
/* $Header: POXCARQS.pls 120.1 2005/06/10 01:46:43 kpsingh noship $ */
--Вывший PO_CREATE_REQUISITION_SV
-- Purpose: To create approved internal / purchase requisition
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- kperiasa    08/01/01 Created Package
-- davidng     05/24/02 Changed p_Init_Msg_List to be assigned the value FND_API.G_TRUE instead of FND_API.G_FALSE
-- davidng     10/08/03 <SERVICES FPJ> Added order_type_lookup_code, purchase_basis
--                      and matching_basis record type line_rec_type

TYPE Header_Rec_Type IS RECORD
(requisition_header_id		po_requisition_headers_all.requisition_header_id%TYPE
,preparer_id			po_requisition_headers_all.preparer_id%TYPE
,last_update_date		po_requisition_headers_all. last_update_date%TYPE
,last_updated_by		po_requisition_headers_all.last_updated_by%TYPE
,segment1			po_requisition_headers_all.segment1%TYPE
,summary_flag			po_requisition_headers_all.summary_flag%TYPE
,enabled_flag			po_requisition_headers_all.enabled_flag%TYPE
,segment2			po_requisition_headers_all.segment2%TYPE
,segment3			po_requisition_headers_all.segment3%TYPE
,segment4			po_requisition_headers_all.segment4%TYPE
,segment5			po_requisition_headers_all.segment5%TYPE
,start_date_active		po_requisition_headers_all.start_date_active%TYPE
,end_date_active		po_requisition_headers_all.end_date_active%TYPE
,last_update_login		po_requisition_headers_all.last_update_login%TYPE
,creation_date			po_requisition_headers_all.creation_date%TYPE
,created_by			po_requisition_headers_all.created_by%TYPE
,description			po_requisition_headers_all.description%TYPE
,authorization_status		po_requisition_headers_all.authorization_status%TYPE
,note_to_authorizer		po_requisition_headers_all.note_to_authorizer%TYPE
,type_lookup_code		po_requisition_headers_all.type_lookup_code%TYPE
,transferred_to_oe_flag		po_requisition_headers_all.transferred_to_oe_flag%TYPE
,attribute_category		po_requisition_headers_all.attribute_category%TYPE
,attribute1			po_requisition_headers_all.attribute1%TYPE
,attribute2			po_requisition_headers_all.attribute2%TYPE
,attribute3			po_requisition_headers_all.attribute3%TYPE
,attribute4			po_requisition_headers_all.attribute4%TYPE
,attribute5			po_requisition_headers_all.attribute5%TYPE
,on_line_flag			po_requisition_headers_all.on_line_flag%TYPE
,attribute6			po_requisition_headers_all.attribute6%TYPE
,attribute7			po_requisition_headers_all.attribute7%TYPE
,attribute8			po_requisition_headers_all.attribute8%TYPE
,attribute9			po_requisition_headers_all.attribute9%TYPE
,attribute10			po_requisition_headers_all.attribute10%TYPE
,attribute11			po_requisition_headers_all.attribute11%TYPE
,attribute12			po_requisition_headers_all.attribute12%TYPE
,attribute13			po_requisition_headers_all.attribute13%TYPE
,attribute14			po_requisition_headers_all.attribute14%TYPE
,attribute15			po_requisition_headers_all.attribute15%TYPE
,government_context		po_requisition_headers_all.government_context%TYPE
,closed_code			po_requisition_headers_all.closed_code%TYPE
,org_id				org_organization_definitions.organization_id%TYPE
,emergency_po_num		po_requisition_headers_all.emergency_po_num%type
--add fields P.Naumov
,INTERFACE_SOURCE_CODE po_requisition_headers_all.INTERFACE_SOURCE_CODE%type
,APPS_SOURCE_CODE           po_requisition_headers_all.APPS_SOURCE_CODE%type
,ACTIVE_SHOPPING_CART_FLAG  po_requisition_headers_all.ACTIVE_SHOPPING_CART_FLAG%type
,UDA_TEMPLATE_DATE          po_requisition_headers_all.UDA_TEMPLATE_DATE%type
,TAX_ATTRIBUTE_UPDATE_CODE  po_requisition_headers_all.TAX_ATTRIBUTE_UPDATE_CODE%type

);

TYPE Line_Rec_type IS RECORD
(requisition_line_id 		po_requisition_lines_all.requisition_line_id%TYPE
,requisition_header_id		po_requisition_headers_all.requisition_header_id%TYPE
,line_num	 		po_requisition_lines_all.line_num%TYPE
,line_type_id	 		po_requisition_lines_all.line_type_id%TYPE
,category_id	 		mtl_categories.category_id%TYPE
,item_description	 	mtl_system_items.description%TYPE
,unit_meas_lookup_code		po_requisition_lines_all.unit_meas_lookup_code%TYPE
,unit_price	 		po_requisition_lines_all.unit_price%TYPE
,quantity	 		po_requisition_lines_all.quantity%TYPE
,deliver_to_location_id	 	po_requisition_lines_all.deliver_to_location_id%TYPE
,to_person_id	 		po_requisition_lines_all.to_person_id%TYPE
,last_update_date	 	po_requisition_lines_all.last_update_date%TYPE
,last_updated_by	 	po_requisition_lines_all.last_updated_by%TYPE
,source_type_code	 	po_requisition_lines_all.source_type_code%TYPE
,last_update_login	 	po_requisition_lines_all.last_update_login%TYPE
,creation_date	 		po_requisition_lines_all.creation_date%TYPE
,created_by	 		po_requisition_lines_all.created_by%TYPE
,item_id		 	po_requisition_lines_all.item_id%TYPE
,item_revision	 		po_requisition_lines_all.item_revision%TYPE
,quantity_delivered	 	po_requisition_lines_all.quantity_delivered%TYPE
,suggested_buyer_id	 	po_requisition_lines_all.suggested_buyer_id%TYPE
,encumbered_flag	 	po_requisition_lines_all.encumbered_flag%TYPE
,rfq_required_flag	 	po_requisition_lines_all.rfq_required_flag%TYPE
,need_by_date	 		po_requisition_lines_all.need_by_date%TYPE
,line_location_id	 	po_requisition_lines_all.line_location_id%TYPE
,modified_by_agent_flag	 	po_requisition_lines_all.modified_by_agent_flag%TYPE
,parent_req_line_id	 	po_requisition_lines_all.parent_req_line_id%TYPE
,justification	 		po_requisition_lines_all.justification%TYPE
,note_to_agent	 		po_requisition_lines_all.note_to_agent%TYPE
,note_to_receiver	 	po_requisition_lines_all.note_to_receiver%TYPE
,purchasing_agent_id	 	po_requisition_lines_all.purchasing_agent_id%TYPE
,document_type_code	 	po_requisition_lines_all.document_type_code%TYPE
,blanket_po_header_id	 	po_requisition_lines_all.blanket_po_header_id%TYPE
,blanket_po_line_num	 	po_requisition_lines_all.blanket_po_line_num%TYPE
,currency_code	 		po_requisition_lines_all.currency_code%TYPE
,rate_type	 		po_requisition_lines_all.rate_type%TYPE
,rate_date	 		po_requisition_lines_all.rate_date%TYPE
,rate	 			po_requisition_lines_all.rate%TYPE
,currency_unit_price		po_requisition_lines_all.currency_unit_price%TYPE
,suggested_vendor_name	 	po_requisition_lines_all.suggested_vendor_name%TYPE
,suggested_vendor_location	po_requisition_lines_all.suggested_vendor_location%TYPE
,suggested_vendor_contact	po_requisition_lines_all.suggested_vendor_contact%TYPE
,suggested_vendor_phone	 	po_requisition_lines_all.suggested_vendor_phone%TYPE
,suggested_vendor_product_code	po_requisition_lines_all.suggested_vendor_product_code%TYPE
,un_number_id	 		po_requisition_lines_all.un_number_id%TYPE
,hazard_class_id	 	po_requisition_lines_all.hazard_class_id%TYPE
,must_use_sugg_vendor_flag	po_requisition_lines_all.must_use_sugg_vendor_flag%TYPE
,reference_num	 		po_requisition_lines_all.reference_num%TYPE
,on_rfq_flag	 		po_requisition_lines_all.on_rfq_flag%TYPE
,urgent_flag	 		po_requisition_lines_all.urgent_flag%TYPE
,cancel_flag	 		po_requisition_lines_all.cancel_flag%TYPE
,source_organization_id	 	org_organization_definitions.organization_id%TYPE
,source_subinventory	 	po_requisition_lines_all.source_subinventory%TYPE
,destination_type_code	 	po_requisition_lines_all.destination_type_code%TYPE
,destination_organization_id	org_organization_definitions.organization_id%TYPE
,destination_subinventory	po_requisition_lines_all.destination_subinventory%TYPE
,quantity_cancelled	 	po_requisition_lines_all.quantity_cancelled%TYPE
,cancel_date	 		po_requisition_lines_all.cancel_date%TYPE
,cancel_reason			po_requisition_lines_all.cancel_reason%TYPE
,closed_code	 		po_requisition_lines_all.closed_code%TYPE
,agent_return_note	 	po_requisition_lines_all.agent_return_note%TYPE
,changed_after_research_flag	po_requisition_lines_all.changed_after_research_flag%TYPE
,vendor_id	 		po_vendors.vendor_id%TYPE
,vendor_site_id	 		po_requisition_lines_all.vendor_site_id%TYPE
,vendor_contact_id	 	po_requisition_lines_all.vendor_contact_id%TYPE
,research_agent_id	 	po_requisition_lines_all.research_agent_id%TYPE
,wip_entity_id	 		po_requisition_lines_all.wip_entity_id%TYPE
,wip_line_id	 		po_requisition_lines_all.wip_line_id%TYPE
,wip_repetitive_schedule_id	po_requisition_lines_all.wip_repetitive_schedule_id%TYPE
,wip_operation_seq_num	 	po_requisition_lines_all.wip_operation_seq_num%TYPE
,wip_resource_seq_num	 	po_requisition_lines_all.wip_resource_seq_num%TYPE
,attribute_category	 	po_requisition_lines_all.attribute_category%TYPE
,destination_context	 	po_requisition_lines_all.destination_context%TYPE
,inventory_source_context	po_requisition_lines_all.inventory_source_context%TYPE
,vendor_source_context	 	po_requisition_lines_all.vendor_source_context%TYPE
,attribute1	 		po_requisition_lines_all.attribute1%TYPE
,attribute2	 		po_requisition_lines_all.attribute2%TYPE
,attribute3	 		po_requisition_lines_all.attribute3%TYPE
,attribute4	 		po_requisition_lines_all.attribute4%TYPE
,attribute5	 		po_requisition_lines_all.attribute5%TYPE
,attribute6	 		po_requisition_lines_all.attribute6%TYPE
,attribute7	 		po_requisition_lines_all.attribute7%TYPE
,attribute8	 		po_requisition_lines_all.attribute8%TYPE
,attribute9	 		po_requisition_lines_all.attribute9%TYPE
,attribute10	 		po_requisition_lines_all.attribute10%TYPE
,attribute11	 		po_requisition_lines_all.attribute11%TYPE
,attribute12	 		po_requisition_lines_all.attribute12%TYPE
,attribute13	 		po_requisition_lines_all.attribute13%TYPE
,attribute14	 		po_requisition_lines_all.attribute14%TYPE
,attribute15	 		po_requisition_lines_all.attribute15%TYPE
,bom_resource_id	 	po_requisition_lines_all.bom_resource_id%TYPE
,government_context	 	po_requisition_lines_all.government_context%TYPE
,closed_reason	 		po_requisition_lines_all.closed_reason%TYPE
,closed_date	 		po_requisition_lines_all.closed_date%TYPE
,transaction_reason_code 	po_requisition_lines_all.transaction_reason_code%TYPE
,quantity_received	 	po_requisition_lines_all.quantity_received%TYPE
,source_req_line_id	 	po_requisition_lines_all.source_req_line_id%TYPE
,org_id	 			po_requisition_lines_all.org_id%TYPE
,kanban_card_id	 		po_requisition_lines_all.kanban_card_id%TYPE
,catalog_type	 		po_requisition_lines_all.catalog_type%TYPE
,catalog_source	 		po_requisition_lines_all.catalog_source%TYPE
,manufacturer_id		po_requisition_lines_all.manufacturer_id%TYPE
,manufacturer_name	 	po_requisition_lines_all.manufacturer_name%TYPE
,manufacturer_part_number	po_requisition_lines_all.manufacturer_part_number%TYPE
,requester_email	 	po_requisition_lines_all.requester_email%TYPE
,requester_fax	 		po_requisition_lines_all.requester_fax%TYPE
,requester_phone	 	po_requisition_lines_all.requester_phone%TYPE
,unspsc_code	 		po_requisition_lines_all.unspsc_code%TYPE
,other_category_code	 	po_requisition_lines_all.other_category_code%TYPE
,supplier_duns	 		po_requisition_lines_all.supplier_duns%TYPE
,tax_status_indicator	 	po_requisition_lines_all.tax_status_indicator%TYPE
,pcard_flag	 		po_requisition_lines_all.pcard_flag%TYPE
,new_supplier_flag	 	po_requisition_lines_all.new_supplier_flag%TYPE
,auto_receive_flag	 	po_requisition_lines_all.auto_receive_flag%TYPE
,tax_user_override_flag	 	po_requisition_lines_all.tax_user_override_flag%TYPE
,tax_code_id	 		po_requisition_lines_all.tax_code_id%TYPE
,note_to_vendor	 		po_requisition_lines_all.note_to_vendor%TYPE
,oke_contract_version_id 	po_requisition_lines_all.oke_contract_version_id%TYPE
,oke_contract_header_id	 	po_requisition_lines_all.oke_contract_header_id%TYPE
,item_source_id	 		po_requisition_lines_all.item_source_id%TYPE
,supplier_ref_number	 	po_requisition_lines_all.supplier_ref_number%TYPE
,source_doc_line_reference	number
,uom_code		 	VARCHAR2(3)
,order_type_lookup_code         po_requisition_lines_all.order_type_lookup_code%TYPE
,purchase_basis                 po_requisition_lines_all.purchase_basis%TYPE
,matching_basis                 po_requisition_lines_all.matching_basis%type
-----
,NEGOTIATED_BY_PREPARER_FLAG    po_requisition_lines_all.matching_basis%type
,CONTRACT_TYPE                  po_requisition_lines_all.matching_basis%type
,CLM_INFO_FLAG                  po_requisition_lines_all.matching_basis%type
,req_item_id                    xxpha.xxpha_sn1041_req_temp_t.req_item_id%type
,BASE_UNIT_PRICE                po_requisition_lines_all.BASE_UNIT_PRICE%type
);

 TYPE Line_Tbl_Type IS TABLE OF Line_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Dist_Rec_type IS RECORD
(distribution_id 		po_req_distributions_all.distribution_id%TYPE
,last_update_date		po_req_distributions_all.last_update_date%TYPE
,last_updated_by 		po_req_distributions_all.last_updated_by%TYPE
,requisition_line_id		po_req_distributions_all.requisition_line_id%type
,requisition_line_num   po_requisition_lines_all.LINE_NUM%type
,set_of_books_id		po_req_distributions_all.set_of_books_id%TYPE
,code_combination_id		po_req_distributions_all.code_combination_id%TYPE
,req_line_quantity		po_req_distributions_all.req_line_quantity%TYPE
,last_update_login		po_req_distributions_all.last_update_login%TYPE
,creation_date			po_req_distributions_all.creation_date%TYPE
,created_by			po_req_distributions_all.created_by%TYPE
,encumbered_flag		po_req_distributions_all.encumbered_flag%TYPE
,gl_encumbered_date		po_req_distributions_all.gl_encumbered_date%TYPE
,gl_encumbered_period_name	po_req_distributions_all.gl_encumbered_period_name%TYPE
,gl_cancelled_date		po_req_distributions_all.gl_cancelled_date%TYPE
,failed_funds_lookup_code	po_req_distributions_all.failed_funds_lookup_code%TYPE
,encumbered_amount		po_req_distributions_all.encumbered_amount%TYPE
,budget_account_id		po_req_distributions_all.budget_account_id%TYPE
,accrual_account_id		po_req_distributions_all.accrual_account_id%TYPE
,variance_account_id		po_req_distributions_all.variance_account_id%TYPE
,prevent_encumbrance_flag	po_req_distributions_all.prevent_encumbrance_flag%TYPE
,attribute_category		po_req_distributions_all.attribute_category%TYPE
,attribute1			po_req_distributions_all.attribute1%TYPE
,attribute2			po_req_distributions_all.attribute2%TYPE
,attribute3			po_req_distributions_all.attribute3%TYPE
,attribute4			po_req_distributions_all.attribute4%TYPE
,attribute5			po_req_distributions_all.attribute5%TYPE
,attribute6			po_req_distributions_all.attribute6%TYPE
,attribute7			po_req_distributions_all.attribute7%TYPE
,attribute8			po_req_distributions_all.attribute8%TYPE
,attribute9			po_req_distributions_all.attribute9%TYPE
,attribute10			po_req_distributions_all.attribute10%TYPE
,attribute11			po_req_distributions_all.attribute11%TYPE
,attribute12	 		po_req_distributions_all.attribute12%TYPE
,attribute13	 		po_req_distributions_all.attribute13%TYPE
,attribute14	 		po_req_distributions_all.attribute14%TYPE
,attribute15	 		po_req_distributions_all.attribute15%TYPE
,government_context		po_req_distributions_all.government_context%TYPE
,project_id	 		po_req_distributions_all.project_id%TYPE
,task_id	  		po_req_distributions_all.task_id%TYPE
,expenditure_type		po_req_distributions_all.expenditure_type%TYPE
,project_accounting_context	po_req_distributions_all.project_accounting_context%TYPE
,expenditure_organization_id	po_req_distributions_all.expenditure_organization_id%TYPE
,gl_closed_date	 		po_req_distributions_all.gl_closed_date%TYPE
,source_req_distribution_id	po_req_distributions_all.source_req_distribution_id%TYPE
,distribution_num		po_req_distributions_all.distribution_num%TYPE
,project_related_flag		po_req_distributions_all.project_related_flag%TYPE
,expenditure_item_date		po_req_distributions_all.expenditure_item_date%TYPE
,org_id	 	 		po_req_distributions_all.org_id%TYPE
,allocation_type	 	po_req_distributions_all.allocation_type%TYPE
,allocation_value		po_req_distributions_all.allocation_value%TYPE
,award_id	 		po_req_distributions_all.award_id%TYPE
,end_item_unit_number		po_req_distributions_all.end_item_unit_number%TYPE
,recoverable_tax	 	po_req_distributions_all.recoverable_tax%TYPE
,nonrecoverable_tax		po_req_distributions_all.nonrecoverable_tax%TYPE
,recovery_rate	 		po_req_distributions_all.recovery_rate%TYPE
,tax_recovery_override_flag	po_req_distributions_all.tax_recovery_override_flag%TYPE
,oke_contract_line_id		po_req_distributions_all.oke_contract_line_id%TYPE
,oke_contract_deliverable_id	po_req_distributions_all.oke_contract_deliverable_id%TYPE
);

 TYPE Dist_Tbl_Type IS TABLE OF Dist_Rec_Type;


  PROCEDURE process_requisition(
          p_api_version             IN NUMBER       := 1.0
         ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_TRUE
         ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
         ,px_header_rec             IN OUT NOCOPY XXPHA_SN1041_CREATE_REQ_PKG.Header_rec_type
         ,px_line_table             IN OUT NOCOPY XXPHA_SN1041_CREATE_REQ_PKG.Line_Tbl_type
         ,px_dist_table             IN OUT NOCOPY XXPHA_SN1041_CREATE_REQ_PKG.Dist_Tbl_Type
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
        );

 END; -- Package spec
/
CREATE OR REPLACE Package Body XXPHA_SN1041_CREATE_REQ_PKG AS
/* $Header: POXCARQB.pls 120.12.12020000.3 2013/05/11 10:51:12 rkandima ship $ */
--
-- Purpose: Create Internal Requisitions
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- kperiasa    08/01/01 Created new package body

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'XXPHA_SN1041_CREATE_REQ_PKG';
  --G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POXCARQB.pls';

  -- Logging global constants
  D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(G_PKG_NAME);

-- This procedure is to get the Unit Price for Internal Requisition
-- If the Currency Code is same for both Source and Destination Organization
-- get the Unit Cost for the Source Organization, otherwise
-- derive Unit Price based on the List Price and Conversion Rate
-- This procedure will have 2 OUT parameters viz. Currency Code and Unit Price

PROCEDURE get_unit_price_prc (p_item_id                     IN NUMBER,
            p_source_organization_id      IN NUMBER,
            p_destination_organization_id IN NUMBER,
            p_set_of_books_id             IN NUMBER,
            x_chart_of_account_id         IN OUT NOCOPY NUMBER,
                              x_currency_code               IN OUT NOCOPY VARCHAR2,
                              x_unit_price                  IN OUT NOCOPY NUMBER,
                              x_unit_of_measure	 IN  	VARCHAR2) IS -- for 16780490

-- Get Functional Currency and Chart of Accounts ID of the SOB for Internal Requsitions
   CURSOR currency_code_cur (p_organization_id NUMBER) IS
     SELECT glsob.currency_code
           ,glsob.chart_of_accounts_id
     FROM   gl_sets_of_books glsob,
            org_organization_definitions ood
     WHERE  glsob.set_of_books_id = ood.set_of_books_id
     AND    ood.organization_id = p_organization_id;

   -- Get Unit Price for Internal Requsitions
   CURSOR unit_price_cur (p_item_id NUMBER, p_source_organization_id NUMBER) IS
     SELECT cic.item_cost
     FROM cst_item_costs_for_gl_view cic,
          mtl_parameters mp
     WHERE cic.inventory_item_id = p_item_id
     AND cic.organization_id = mp.cost_organization_id
     AND cic.inventory_asset_flag = 1
     AND mp.organization_id= p_source_organization_id;

   -- Get Converted Unit Price for Purchase Requsitions
     CURSOR converted_unit_price_int_csr (p_item_id NUMBER, p_source_organization_id NUMBER,
                                               s_currency_code VARCHAR2, d_currency_code varchar2 ) IS
     SELECT cic.item_cost *
             round(gl_currency_api.get_closest_rate_sql
                    (s_currency_code,
                     d_currency_code,
                     trunc(sysdate),
                     psp.DEFAULT_RATE_TYPE,
                     30),10)
     FROM cst_item_costs_for_gl_view cic,
          mtl_parameters mp,
          po_system_parameters psp
     WHERE cic.inventory_item_id = p_item_id
     AND cic.organization_id = mp.cost_organization_id
     AND cic.inventory_asset_flag = 1
     AND mp.organization_id= p_source_organization_id;

   -- Get Converted Unit Price for Purchase Requsitions
   CURSOR converted_unit_price_pur_cur (p_item_id NUMBER, p_source_organization_id NUMBER,
                                    p_set_of_books_id NUMBER) IS
     SELECT msi.list_price_per_unit  *
            round(gl_currency_api.get_closest_rate_sql
                    (p_set_of_books_id,
                     glsob.currency_code,
                     trunc(sysdate),
                     psp.DEFAULT_RATE_TYPE,
                     30),10)
     FROM   mtl_system_items msi,
            gl_sets_of_books glsob,
            org_organization_definitions ood,
            po_system_parameters psp
     WHERE  msi.inventory_item_id = p_item_id
     AND    ood.organization_id = p_source_organization_id
     AND    msi.organization_id = ood.organization_id
     AND    glsob.set_of_books_id = ood.set_of_books_id;

   s_currency_code          VARCHAR2(15);
   d_currency_code          VARCHAR2(15);
   d_chart_of_accounts_id   NUMBER;
   s_chart_of_accounts_id   NUMBER;
   l_unit_price             NUMBER;
   UNIT_PRICE_LT_0          EXCEPTION;
   INVALID_UNIT_PRICE       EXCEPTION;

  l_module_name CONSTANT VARCHAR2(100) := 'get_unit_price_prc';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  --d_progress NUMBER;

--for bug 16780490 start

  l_src_process_enabled_flag 	varchar2(1) := NULL;
  l_dest_process_enabled_flag   varchar2(1) := NULL;
  l_from_ou                     Number;
  l_to_ou                       Number;
  l_ret_val                     NUMBER;
  l_return_status VARCHAR2(10);
  x_msg_count                 NUMBER;
  x_msg_data                  VARCHAR2(3000);
  x_cost_method               VARCHAR2(10);
  x_cost_component_class_id   NUMBER;
  x_cost_analysis_code        VARCHAR2(10);
  x_no_of_rows                NUMBER;
  l_uom_code                  mtl_material_transactions.transaction_uom%TYPE;
  x_trans_qty                 NUMBER ;
  x_unit_price_priuom         NUMBER := 0;
  x_incr_transfer_price       NUMBER;
  x_incr_currency_code        VARCHAR2(4);
  l_dest_currency             VARCHAR2(50);
  l_set_of_books_id           NUMBER;
  l_def_rate_type             VARCHAR2(50);

  -- bug 16780490 end

BEGIN

     IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_begin(d_module_base);
       PO_LOG.proc_begin(d_module_base, 'p_item_id', p_item_id);
       PO_LOG.proc_begin(d_module_base, 'p_source_organization_id', p_source_organization_id);
       PO_LOG.proc_begin(d_module_base, 'p_destination_organization_id', p_destination_organization_id);
       PO_LOG.proc_begin(d_module_base, 'p_set_of_books_id', p_set_of_books_id);
       PO_LOG.proc_begin(d_module_base, 'x_chart_of_account_id', x_chart_of_account_id);
       PO_LOG.proc_begin(d_module_base, 'x_currency_code', x_currency_code);
       PO_LOG.proc_begin(d_module_base, 'x_unit_price', x_unit_price);
     END IF;

     -- Get the SOB Currency Code of the Source Organization ID
     OPEN currency_code_cur(p_source_organization_id);
     FETCH currency_code_cur INTO s_currency_code, s_chart_of_accounts_id;
     CLOSE currency_code_cur;



     -- Get SOB Currency Code of the Destination (Inventory)  Organization
     OPEN currency_code_cur(p_destination_organization_id);
     FETCH currency_code_cur INTO d_currency_code, d_chart_of_accounts_id;
     CLOSE currency_code_cur;

      x_chart_of_account_id      := d_chart_of_accounts_id; -- Bug 5637277

  -- changes for bug 16780490 start

SELECT NVL(src.process_enabled_flag,'N'), NVL(dest.process_enabled_flag,'N')
INTO l_src_process_enabled_flag, l_dest_process_enabled_flag
FROM mtl_parameters src, mtl_parameters dest
WHERE src.organization_id  = p_source_organization_id
AND dest.organization_id = p_destination_organization_id;


IF (l_src_process_enabled_flag <> l_dest_process_enabled_flag)
  OR (l_src_process_enabled_flag = 'Y' AND l_dest_process_enabled_flag = 'Y')
  THEN
    -- for process-discrete and vice-versa orders. Call get transfer price API
    -- for process-process orders. Call get cost API

    -- get the from ou and to ou
    -- B7462235 - Changed org_information2 to org_information3 to fetch OU Id
    SELECT to_number(src.org_information3) src_ou, to_number(dest.org_information3) dest_ou
      INTO l_from_ou, l_to_ou
      FROM hr_organization_information src, hr_organization_information dest
     WHERE src.organization_id = p_source_organization_id
       AND src.org_information_context = 'Accounting Information'
       AND dest.organization_id = p_destination_organization_id
       AND dest.org_information_context = 'Accounting Information';

    IF (l_src_process_enabled_flag = 'Y' AND l_dest_process_enabled_flag = 'Y') AND
       (l_from_ou = l_to_ou)
    THEN
    -- process/process within same OU

      l_ret_val := GMF_CMCOMMON.Get_Process_Item_Cost (
                       p_api_version              => 1.0
                     , p_init_msg_list            => 'T'
                     , x_return_status            => l_return_status
                     , x_msg_count                => x_msg_count
                     , x_msg_data                 => x_msg_data
                     , p_inventory_item_id        => p_item_id
                     , p_organization_id          => p_source_organization_id
                     , p_transaction_date         => sysdate
                     , p_detail_flag              => 1          -- returns unit_price
                     , p_cost_method              => x_cost_method
                     , p_cost_component_class_id  => x_cost_component_class_id
                     , p_cost_analysis_code       => x_cost_analysis_code
                     , x_total_cost               => l_unit_price
                     , x_no_of_rows               => x_no_of_rows
                   );

       IF l_ret_val <> 1
       THEN
         l_unit_price := 0;
       END IF;



    ELSE
       -- process to discrete or descrete to process or process to process across OUs
       -- then invoke transfer price API
       -- pmarada bug 4687787

       SELECT uom_code
         INTO l_uom_code
         FROM mtl_units_of_measure
        WHERE unit_of_measure = x_unit_of_measure ;



       GMF_get_transfer_price_PUB.get_transfer_price (
            p_api_version             => 1.0
          , p_init_msg_list           => 'F'

          , p_inventory_item_id       => p_item_id
          , p_transaction_qty         => x_trans_qty
          , p_transaction_uom         => l_uom_code

          , p_transaction_id          => NULL
          , p_global_procurement_flag => 'N'
          , p_drop_ship_flag          => 'N'

          , p_from_organization_id    => p_source_organization_id
          , p_from_ou                 => l_from_ou
          , p_to_organization_id      => p_destination_organization_id
          , p_to_ou                   => l_to_ou

          , p_transfer_type           => 'INTORD'
          , p_transfer_source         => 'INTREQ'

          , x_return_status           => l_return_status
          , x_msg_data                => x_msg_data
          , x_msg_count               => x_msg_count

          , x_transfer_price          => l_unit_price
          , x_transfer_price_priuom   => x_unit_price_priuom
          , x_currency_code           => s_currency_code
          , x_incr_transfer_price     => x_incr_transfer_price  /* not used */
          , x_incr_currency_code      => x_incr_currency_code  /* not used */
          );

        IF l_return_status <> 'S' OR
          l_unit_price IS NULL
        THEN
          l_unit_price    := 0;
        ELSE
           --Added the following code for bug 12914933 to convert the price
          --if dest and source currency are different
		        BEGIN
				        select gsob.currency_code
				        ,ood.set_of_books_id,
				        psp.DEFAULT_RATE_TYPE
				        into l_dest_currency
				        ,l_set_of_books_id,
				        l_def_rate_type
								from gl_sets_of_books gsob,
								org_organization_definitions ood,
								po_system_parameters psp
								where ood.set_of_books_id = gsob.set_of_books_id
								and ood.organization_id = p_destination_organization_id;

						EXCEPTION
							WHEN OTHERS THEN
							   --l_dest_currency := NULL;
							   null;
					  END;

			      IF l_dest_currency <>  s_currency_code THEN

			  	  l_unit_price :=  l_unit_price * gl_currency_api.get_closest_rate_sql( l_set_of_books_id ,
                                                            s_currency_code,trunc(sysdate),l_def_rate_type,30);
        END IF;
        END IF;
       END IF;
    --<INVCONV R12 END OPM INVCONV  umoogala>
  ELSE

 -- bug 16780490 end

     -- If Currency Code is same for both Destination and Source Organization
     -- Get Item Cost of the Source Organization ID from  cst_item_costs__for_gl_view
     IF NVL(s_currency_code,'X') = NVL(d_currency_code,'X') THEN
        -- Get Unit Cost
        OPEN unit_price_cur (p_item_id, p_source_organization_id);
        FETCH unit_price_cur INTO l_unit_price;
        IF unit_price_cur%NOTFOUND THEN
           CLOSE unit_price_cur;
           Raise INVALID_UNIT_PRICE;
        END IF;
        CLOSE unit_price_cur;
        IF l_unit_price < 0 THEN
           Raise UNIT_PRICE_LT_0;
        END IF;
     ELSE /* Currency Code is different for Source and Destination Organization */
        -- Get converted Unit price  for internal requisition
        -- Bug 7313047 - When creating internal requisition from Advance Planning workbench if the
        -- source and destination org, have different functional currency,
        -- then, we need to get the item cost from source org and convert it
        -- to destination org's currency type.
        IF  p_source_organization_id IS NOT NULL THEN   -- Bug 7313047
          OPEN converted_unit_price_int_csr (p_item_id, p_source_organization_id, s_currency_code, d_currency_code);
          FETCH converted_unit_price_int_csr INTO l_unit_price;
          IF converted_unit_price_int_csr%NOTFOUND THEN
            CLOSE converted_unit_price_int_csr; -- Bug 3468739
            Raise INVALID_UNIT_PRICE;
          END IF;
          CLOSE converted_unit_price_int_csr; -- Bug 3468739
          IF l_unit_price < 0 THEN
            Raise UNIT_PRICE_LT_0;
          END IF;
        ELSE
          -- Get converted Unit price  for purchase requisition
          OPEN converted_unit_price_pur_cur (p_item_id, p_source_organization_id, p_set_of_books_id);
          FETCH converted_unit_price_pur_cur INTO l_unit_price;
          IF converted_unit_price_pur_cur%NOTFOUND THEN
            CLOSE converted_unit_price_pur_cur; -- Bug 3468739
            Raise INVALID_UNIT_PRICE;
          END IF;
          CLOSE converted_unit_price_pur_cur; -- Bug 3468739
          IF l_unit_price < 0 THEN
            Raise UNIT_PRICE_LT_0;
          END IF;
       END IF;  /*  p_source_organization_id check */
     END IF; /* Currency Check */

   END IF; -- bug 16780490

     x_currency_code    := d_currency_code;
     x_unit_price       := l_unit_price;
     x_chart_of_account_id      := d_chart_of_accounts_id; /* bug 5637277 replaced s_chart_of_accounts_id with d_chart_of_accounts_id */

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'x_currency_code',x_currency_code);
      PO_LOG.proc_end(d_module_base, 'x_unit_price',x_unit_price);
      PO_LOG.proc_end(d_module_base, 'x_chart_of_account_id',x_chart_of_account_id);
    END IF;

EXCEPTION

   WHEN UNIT_PRICE_LT_0 THEN
        po_message_s.app_error('PO_RI_UNIT_PRICE_LT_0');
        raise;

   WHEN INVALID_UNIT_PRICE THEN
        x_unit_price := 0;

END get_unit_price_prc;

-- This function is to check the subinventory type to derive
-- Code Combinatin ID.  Function Returns Sub Inventory Type
-- 'ASSET' or 'EXPENSE'.  If EXCEPTION, Returns 'X'

FUNCTION check_sub_inv_type_fun (p_destination_subinventory     IN VARCHAR2,
               p_destination_organization_id IN NUMBER )
RETURN VARCHAR2 IS

CURSOR asset_inventory_cur IS
  SELECT  asset_inventory
  FROM  mtl_secondary_inventories
  WHERE   secondary_inventory_name = NVL(p_destination_subinventory,'X')
  AND     organization_id          = p_destination_organization_id;

l_asset_inventory NUMBER;
l_subinventory_type VARCHAR2(10) := 'X';

BEGIN
        OPEN asset_inventory_cur;
  FETCH asset_inventory_cur INTO l_asset_inventory;
  CLOSE asset_inventory_cur;

  IF    (l_asset_inventory = 1) THEN
         l_subinventory_type :=  'ASSET';
  ELSIF (l_asset_inventory = 2) then
         l_subinventory_type :=  'EXPENSE';
  END IF;

        RETURN l_subinventory_type;

EXCEPTION

  WHEN OTHERS THEN
       RETURN 'X';

END check_sub_inv_type_fun ;

-- This function is to check the item  type to derive
-- Code Combinatin ID.  Function Returns Item Type
-- 'ASSET' or 'EXPENSE'.  If EXCEPTION, Returns 'X'

FUNCTION check_inv_item_type_fun ( p_destination_organization_id  IN NUMBER,
                 p_item_id                    IN NUMBER)
RETURN VARCHAR2 IS

CURSOR item_type_cur IS
  SELECT  inventory_asset_flag
  FROM  mtl_system_items
  WHERE organization_id   = p_destination_organization_id
  AND   inventory_item_id = p_item_id;

l_item_type         VARCHAR2(10) := 'X';
l_asset_flag        VARCHAR2(1);

BEGIN

   OPEN item_type_cur;
   FETCH item_type_cur INTO l_asset_flag;
   CLOSE item_type_cur;

   IF l_asset_flag = 'Y' then
      l_item_type := 'ASSET';
   ELSE
      l_item_type :=  'EXPENSE';
   END IF;

   RETURN l_item_type;

EXCEPTION

  WHEN OTHERS THEN
      RETURN 'X';

END check_inv_item_type_fun;

-- This function is to default Code Combination ID for
-- Destination Type Code INVENTORY
-- Called in Process_Requisition

FUNCTION get_charge_account_fun (p_destination_organization_id IN NUMBER,
                                 p_item_id IN NUMBER,
                                 p_destination_subinventory  IN VARCHAR DEFAULT NULL)
RETURN NUMBER IS

l_charge_account    NUMBER := NULL;
l_item_type         VARCHAR2(10);
l_subinventory_type VARCHAR2(10) := 'X';

  l_module_name CONSTANT VARCHAR2(100) := 'get_charge_account_fun';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;

BEGIN

  d_progress := 10;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_destination_organization_id', p_destination_organization_id);
    PO_LOG.proc_begin(d_module_base, 'p_item_id', p_item_id);
    PO_LOG.proc_begin(d_module_base, 'p_destination_subinventory', p_destination_subinventory);
  END IF;

  d_progress := 20;

  l_item_type := check_inv_item_type_fun (p_destination_organization_id, p_item_id);

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_module_base,d_progress,'l_item_type='||l_item_type);
  END IF;

  d_progress := 30;
  IF l_item_type = 'EXPENSE' then

    d_progress := 40;
    -- Subinventory is provided
    IF (p_destination_subinventory IS NOT NULL) THEN
      BEGIN
        d_progress := 50;
        SELECT expense_account
          INTO l_charge_account
          FROM mtl_secondary_inventories
         WHERE secondary_inventory_name = p_destination_subinventory
           AND organization_id = p_destination_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          d_progress := 60;
      END;
    END IF;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'l_charge_account',l_charge_account);
    END IF;

    -- If Expense Account not available for the Subinventory and Org,
    -- get expense account from Item Master for the Item and the Org
    IF (l_charge_account IS NULL) THEN
      BEGIN
        d_progress := 70;
        SELECT expense_account
          INTO l_charge_account
          FROM mtl_system_items
         WHERE organization_id = p_destination_organization_id
          AND inventory_item_id = p_item_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          d_progress := 80;
      END;
    END IF;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'l_charge_account',l_charge_account);
    END IF;

    -- If Expense Account not available in Item Master,  get account
    -- from MTL_PARAMETERS for the Destination Organization
    IF (l_charge_account IS NULL) THEN
      BEGIN
        d_progress := 90;
        SELECT expense_account
          INTO l_charge_account
          FROM mtl_parameters
         WHERE organization_id = p_destination_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          d_progress := 100;
      END;
    END IF;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'l_charge_account',l_charge_account);
    END IF;

  ELSE -- item type is ASSET

    d_progress := 110;
    --Check subinventory for Asset or Expense tracking.
    IF (p_destination_subinventory IS NOT NULL) THEN
      d_progress := 120;
      l_subinventory_type := check_sub_inv_type_fun(p_destination_subinventory,
                                                    p_destination_organization_id);
    END IF;

    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_base,d_progress,'l_subinventory_type' , l_subinventory_type);
    END IF;

    d_progress := 130;
    -- Get the default account from the Organization if Subinventory Type is NOT
    -- EXPENSE or ASSET
    IF l_subinventory_type = 'X' then
      BEGIN
        d_progress := 140;
        SELECT material_account
          INTO l_charge_account
          FROM mtl_parameters
         WHERE organization_id = p_destination_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          d_progress := 150;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_charge_account',l_charge_account);
      END IF;

    ELSIF l_subinventory_type = 'EXPENSE' THEN
           -- Get Expense Account for the Subinventory
      BEGIN
          d_progress := 160;
          SELECT expense_account
            INTO l_charge_account
            FROM mtl_secondary_inventories
           WHERE secondary_inventory_name = p_destination_subinventory
             AND organization_id = p_destination_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          d_progress := 170;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_charge_account',l_charge_account);
      END IF;

      -- If charge account is NULL for the Subinventory, get the default account
      -- for the Organization from MTL_PARAMETERS
      IF (l_charge_account is NULL) THEN
        BEGIN
          d_progress := 180;
          SELECT expense_account
            INTO l_charge_account
            FROM mtl_parameters
           WHERE organization_id = p_destination_organization_id;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
            d_progress := 190;
        END;
      END IF;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_charge_account',l_charge_account);
      END IF;

    ELSE  -- destination sub inventory type is ASSET
          -- Get the Charge_Account for the Subinventory
      BEGIN
        d_progress := 200;
        SELECT material_account
          INTO l_charge_account
          FROM mtl_secondary_inventories
         WHERE secondary_inventory_name = p_destination_subinventory
           AND organization_id = p_destination_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
          d_progress := 210;
      END;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_charge_account',l_charge_account);
      END IF;

      -- If Charge_account is not availabe for the Subinventory,
      -- get it for the Destination Organization from MTL_PARAMETERS
      IF (l_charge_account IS NULL) THEN
        BEGIN
          d_progress := 220;
          SELECT material_account
            INTO l_charge_account
            FROM mtl_parameters
           WHERE organization_id = p_destination_organization_id;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
            d_progress := 230;
        END;
      END IF;

      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_module_base,d_progress,'l_charge_account',l_charge_account);
      END IF;
    END IF; /* Sub Inventory Type */
  END IF; /* Item Type Check */

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'l_charge_account',l_charge_account);
  END IF;

  RETURN (l_charge_account);
EXCEPTION
  WHEN OTHERS then
    xxpha_sn1041_lst_req_bskt_pkg.add_log('header '||sqlerrm||' '||dbms_utility.format_error_backtrace);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, 'Unhandled exception in '||l_module_name||': '||SQLERRM);
    END IF;
    NULL;
END get_charge_account_fun;


/*
  Function to validate Code Combination IDs.
  If INVALID function will return FALSE
*/

FUNCTION valid_account_id_fun (p_ccid IN NUMBER,
                               p_gl_date IN DATE,
                               p_chart_of_accounts_id IN NUMBER)
  RETURN BOOLEAN IS


  l_module_name CONSTANT VARCHAR2(100) := 'valid_account_id_fun';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE, l_module_name);
  d_progress NUMBER;

CURSOR validate_ccid_cur IS
  SELECT  'X'
  FROM    gl_code_combinations gcc
  WHERE   gcc.code_combination_id = p_ccid
  AND     gcc.enabled_flag = 'Y'
  AND     trunc(nvl(p_gl_date,SYSDATE))
             BETWEEN trunc(nvl(start_date_active, nvl(p_gl_date,SYSDATE) ))
             AND     trunc(nvl (end_date_active, SYSDATE+1))
  AND gcc.detail_posting_allowed_flag = 'Y'
  AND gcc.chart_of_accounts_id= p_chart_of_accounts_id
  AND gcc.summary_flag = 'N';

  l_dummy   VARCHAR2(1);

BEGIN

  d_progress := 10;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_ccid', p_ccid);
    PO_LOG.proc_begin(d_module_base, 'p_gl_date', p_gl_date);
    PO_LOG.proc_begin(d_module_base, 'p_chart_of_accounts_id', p_chart_of_accounts_id);
  END IF;

  d_progress := 20;
  OPEN validate_ccid_cur;

  d_progress := 30;
  FETCH validate_ccid_cur INTO l_dummy;
  d_progress := 40;
  IF validate_ccid_cur%FOUND THEN
    CLOSE validate_ccid_cur;

    d_progress := 50;
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return TRUE',0);
    END IF;


    RETURN TRUE;
  ELSE
    CLOSE validate_ccid_cur;

    d_progress := 60;
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'return FALSE',1);
    END IF;

    RETURN FALSE;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, 'Unhandled exception in '||l_module_name||': '||SQLERRM);
    END IF;

     return (FALSE);

END valid_account_id_fun;


/* Procedure to Process Internal Requisition.  Most of the values will come from
   the colling routine, however, PO_REQ_DISTRIBUTIONS table will be populated
   within this Package.

   This package assumes that there is only one distribution per order line, since
   Order Line cannot be shipped to multiple locations.

   Minimum validations are considered when populating PO_REQUISITION_HEADERS and
   PO_REQUISITION_LINES.  However, when populating PO_REQ_DISTRIBUTIONS,validations
   related to ACCOUNTS are done.

   This package assumes that Inventory Item ID will always be passed from the
   calling routine, since ITEM_DESCRIPTION is a mandatory column in PO_REQUISITION_LINES.
*/

PROCEDURE process_requisition(
          p_api_version             IN NUMBER       := 1.0
         ,p_Init_Msg_List           IN VARCHAR2     := FND_API.G_TRUE
         ,p_commit                  IN VARCHAR2     := FND_API.G_FALSE
         ,px_header_rec             IN OUT NOCOPY XXPHA_SN1041_CREATE_REQ_PKG.header_rec_type
         ,px_line_table             IN OUT NOCOPY XXPHA_SN1041_CREATE_REQ_PKG.Line_Tbl_type
         ,px_dist_table             IN OUT NOCOPY XXPHA_SN1041_CREATE_REQ_PKG.Dist_Tbl_Type
         ,x_return_status           OUT NOCOPY VARCHAR2
         ,x_msg_count               OUT NOCOPY NUMBER
         ,x_msg_data                OUT NOCOPY VARCHAR2
        )
  IS

   l_api_version_number     CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'process_requisition';
   l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   --l_msg_count              NUMBER;
   --l_msg_data               VARCHAR2(2000);
   --l_commit                 VARCHAR2(1) := FND_API.G_FALSE;
   l_user_id                NUMBER;
   l_login_id               NUMBER;
   l_today                  DATE;
   v_count                  number;

   EXCP_USER_DEFINED        EXCEPTION;
   INVALID_ITEM             EXCEPTION;
   INVALID_ITEM_CATEGORY    EXCEPTION;
   INVALID_QUANTITY         EXCEPTION;
   INVALID_SOURCE_TYPE      EXCEPTION;
   INVALID_DESTINATION_TYPE EXCEPTION;
   UNIT_PRICE_LT_0          EXCEPTION;
   INVALID_UNIT_PRICE       EXCEPTION;
   INVALID_CHARGE_ACCOUNT   EXCEPTION;
   INVALID_ACCRUAL_ACCOUNT  EXCEPTION;
   INVALID_BUDGET_ACCOUNT   EXCEPTION;
   INVALID_VARIANCE_ACCOUNT EXCEPTION;
   INVALID_AUTH_STATUS      EXCEPTION;
   INVALID_PREPARER_ID      EXCEPTION;
   INVALID_LOCATION_ID      EXCEPTION;
   INVALID_DESTINATION_ORG  EXCEPTION;
   INVALID_UNIT_OF_MEASURE  EXCEPTION;

   --s_chart_of_accounts_id   NUMBER;
   --s_currency_code          VARCHAR2(15);
   l_dummy                  VARCHAR2(1);
   l_line_type_id           po_requisition_lines.line_type_id%TYPE;
   --l_create_req_supply      BOOLEAN;
   l_set_of_books_id        NUMBER;

   l_header_rec             XXPHA_SN1041_CREATE_REQ_PKG.Header_Rec_Type;
   --l_line_rec               XXPHA_SN1041_CREATE_REQ_PKG.Line_Rec_Type;
   l_line_tbl               XXPHA_SN1041_CREATE_REQ_PKG.Line_tbl_Type;
   

   --l_msg varchar2(2000);

   d_chart_of_accounts_id   NUMBER; /* bug 5637277 - Please refer the bug for the details */


     l_manufacturer_id         po_requisition_lines_All.MANUFACTURER_ID%TYPE;
    l_manufacturer_name       PO_ATTRIBUTE_VALUES_TLP.manufacturer%TYPE;
    l_manufacturer_pn         PO_ATTRIBUTE_VALUES.manufacturer_part_num%TYPE;
    l_lead_time               PO_ATTRIBUTE_VALUES.lead_time%TYPE;

 --Added for bug 13254403
    l_return_value BOOLEAN;


   -- bug5176308
   -- removed the cursor to get req number as the logic is moved to
   -- an API

   -- Cursor to get unique Requisition_Header_ID
   CURSOR req_header_id_cur IS
     SELECT po_requisition_headers_s.nextval
     FROM sys.dual;

   -- Cursor to get unique Requisition_Line_ID
   CURSOR req_line_id_cur IS
     SELECT po_requisition_lines_s.nextval
     FROM sys.dual;

   -- Cursor to get unique Distribution_id
   CURSOR dist_line_id_cur IS
     SELECT po_req_distributions_s.nextval
     FROM sys.dual;

   -- Cursor to get Accrual Account ID and Variance Account ID
   -- For Destination Type Code INVENTORY get accrual account id
   -- from MTL_PARAMETERS
   -- Per Requisition Import program (pocis.opc).
   CURSOR accrual_account_id_cur (p_destination_organization_id NUMBER) IS
     SELECT mp.ap_accrual_account,
            mp.invoice_price_var_account
     FROM   mtl_parameters mp
     WHERE  mp.organization_id = p_destination_organization_id;

   -- Get Default Line Type
   CURSOR line_type_cur (p_org_id NUMBER) IS
     SELECT line_type_id
     FROM PO_SYSTEM_PARAMETERS
     WHERE org_id = p_org_id;

   -- Get Item Description for a given Item ID
   -- For the purpose of creating Approve Internal Requisition
   -- it is assumed that the calling procedure will always pass the Item ID
   -- so that Item Description can be derived.
   CURSOR item_desc_cur(p_item_id NUMBER, p_orgn_id NUMBER) IS
     SELECT description
     FROM mtl_system_items_b
     WHERE inventory_item_id = p_item_id
     AND organization_id = p_orgn_id;

   -- Get Item Category ID
   -- As in Requisition Import
   CURSOR item_category_cur(p_item_id NUMBER, p_destination_org_id NUMBER) IS
     SELECT mic.category_id
     FROM   mtl_item_categories mic,
            mtl_default_sets_view mdsv
     WHERE  mic.inventory_item_id = p_item_id
     AND    mic.organization_id = p_destination_org_id
     AND    mic.category_set_id = mdsv.category_set_id
     AND    mdsv.functional_area_id = 2;

   -- For Source Type Code validation, if passed to the procedure
   CURSOR source_type_cur (p_source_type_code VARCHAR2) IS
     SELECT 'X'
     FROM   po_lookup_codes plc
     WHERE  plc.lookup_type = 'REQUISITION SOURCE TYPE'
     AND    plc.lookup_code = p_source_type_code;

   -- For Destination Type Code validation, if passed to the procedure
   CURSOR destination_type_cur (p_destination_type_code VARCHAR2) IS
     SELECT 'X'
     FROM   po_lookup_codes plc
     WHERE  plc.lookup_type = 'DESTINATION TYPE'
     AND    plc.lookup_code = p_destination_type_code;

   -- For Authorization Status validation, if passed to the procedure
   CURSOR authorization_status_cur (p_authorization_status VARCHAR2) IS
     SELECT 'X'
     FROM   po_lookup_codes plc
     WHERE  plc.lookup_type = 'AUTHORIZATION STATUS'
     AND    plc.lookup_code = p_authorization_status;

   -- Get Set of Books ID for a given Org_ID - Mandatory in PO_REQ_DISTRIBUTIONS
   CURSOR set_of_books_cur (p_organization_id NUMBER) IS
     SELECT set_of_books_id
     FROM   hr_operating_units
     WHERE  organization_id = p_organization_id;

   -- If encumbrance flag is 'Y' get the budget account
   -- For Internal Req, Destination Type Code will be INVENTORY
   -- Hence, it is assumed that the budget account will come
   -- from MTL_PARAMETERS for the Item and the Destination Organization
   /*CURSOR budget_account_cur (p_destination_organization_id NUMBER,
                              p_item_id NUMBER) IS
     SELECT nvl (msi.encumbrance_account,mp.encumbrance_account)
     FROM   mtl_system_items msi,
            mtl_parameters mp
     WHERE  msi.inventory_item_id = p_item_id
     AND    msi.organization_id = p_destination_organization_id
     AND    mp.organization_id = msi.organization_id;*/

   -- Get Requisition Encumbrance Flag for the Set of Books
   -- Based of this flag Budget Account will be populated
   -- in PO_REQ_DISTRIBUTIONS
   CURSOR req_encumbrance_cur (p_set_of_books_id NUMBER) IS
     SELECT nvl (fsp.req_encumbrance_flag,'N')
     FROM   financials_system_parameters fsp
     WHERE  fsp.set_of_books_id = p_set_of_books_id;

   -- Get Charge Account for the Item and Organization
   /*CURSOR charge_account_cur (p_destination_organization_id NUMBER,
                              p_item_id NUMBER) IS
      SELECT NVL(expense_account,-1)
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_item_id
      AND    organization_id   = p_destination_organization_id;*/

   -- Get Unit_of_Measure from MTL_UNIT_OF_MEASURES, since OM passes
   -- only UOM_CODE and PO requires UNIT_OF_MEASURE.  This is being done
   -- to fix the problem of line not showing up from POXRQVRQ form
   CURSOR unit_of_measure_cur (p_uom_code VARCHAR2) IS
     SELECT mum.unit_of_measure
     FROM   mtl_units_of_measure mum
     WHERE  mum.uom_code = p_uom_code;

 CURSOR currency_code_cur (p_organization_id NUMBER) IS
     SELECT glsob.currency_code
           ,glsob.chart_of_accounts_id
     FROM   gl_sets_of_books glsob,
            org_organization_definitions ood
     WHERE  glsob.set_of_books_id = ood.set_of_books_id
     AND    ood.organization_id = p_organization_id;



  BEGIN

    IF fnd_api.to_boolean(P_Init_Msg_List) THEN
        -- initialize message list
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_header_rec := px_header_rec;
    l_line_tbl := px_line_table;

    -- get all the values required to insert into po_requisition_header table
    SELECT Sysdate INTO l_today FROM dual;

    l_user_id :=  fnd_global.user_id;
    l_login_id := fnd_global.login_id;

   if l_header_rec.requisition_header_id is null then
          -- Get Requisition_header_id
          OPEN req_header_id_cur;
          FETCH req_header_id_cur into l_header_rec.requisition_header_id;
          CLOSE req_header_id_cur;

          -- bug5176308
          l_header_rec.segment1 :=
            PO_CORE_SV1.default_po_unique_identifier
            ( p_table_name => 'PO_REQUISITION_HEADERS',
              p_org_id     => l_header_rec.org_id --xx
            );

          -- check for uniqueness of requisition_number
          BEGIN

            SELECT 'X' INTO l_dummy
            FROM   DUAL
            WHERE NOT EXISTS
              ( SELECT 'X'
                FROM po_requisition_headers
                WHERE Segment1 = l_header_rec.segment1);

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              po_message_s.app_error('PO_ALL_ENTER_UNIQUE_VAL');
              raise;
            WHEN OTHERS THEN
              po_message_s.sql_error('check_unique','010',sqlcode);
              raise;
          END;

          -- Raise Error, if preparer_id IS NULL
          IF l_header_rec.preparer_id IS NULL THEN
             Raise INVALID_PREPARER_ID;
          END IF;

          -- Default Summary Flag to 'N', if NULL
          IF l_header_rec.summary_flag IS NULL THEN
             l_header_rec.summary_flag := 'N';
          END IF;

          -- Default Enabled Flag to 'Y', if NULL
          IF l_header_rec.enabled_flag IS NULL THEN
             l_header_rec.enabled_flag := 'Y';
          END IF;

          -- Default Transferred to OE Flag to 'Y', if NULL
          -- This is done to make sure that these requisitions don't get
          -- picked up at the time of populating order interface
          --IF l_header_rec.transferred_to_oe_flag IS NULL THEN
          --   l_header_rec.transferred_to_oe_flag := 'Y';
          --END IF;

          -- Default Authorization to APPROVED, if NULL
          IF l_header_rec.authorization_status IS NULL THEN
             l_header_rec.authorization_status := 'APPROVED';
          ELSE
             OPEN authorization_status_cur (l_header_rec.authorization_status);
             FETCH authorization_status_cur INTO l_dummy;
             IF authorization_status_cur%NOTFOUND then
               null;
                --CLOSE authorization_status_cur;
              --  Raise INVALID_AUTH_STATUS; --xx Корзина почему то создаёт заявки типа SYSTEM_SAVED, которой нет в коде поиска
             END IF;
                CLOSE authorization_status_cur;
          END IF;

          -- create approved requisition headers
          -- insert into PO_REQUISITION_HEADERS



          INSERT INTO po_requisition_headers_all(
                   org_id,
                   requisition_header_id,
                   preparer_id,
                   last_update_date,
                   last_updated_by,
                   segment1,
                   summary_flag,
                   enabled_flag,
                   segment2,
                   segment3,
                   segment4,
                   segment5,
                   start_date_active,
                   end_date_active,
                   last_update_login,
                   creation_date,
                   created_by,
                   description,
                   authorization_status,
                   note_to_authorizer,
                   type_lookup_code,
                   transferred_to_oe_flag,
                   attribute_category,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   government_context,
                   closed_code,
                   tax_attribute_update_code, --<eTax Integration R12>
                   --xx field
                   INTERFACE_SOURCE_CODE,
                   APPS_SOURCE_CODE,
                   ACTIVE_SHOPPING_CART_FLAG,
                   UDA_TEMPLATE_DATE
                   --
                  ) VALUES (
      l_header_rec.org_id,
            l_header_rec.requisition_header_id,
            l_header_rec.preparer_id,
      l_today,
      l_user_id,
      l_header_rec.segment1,
      l_header_rec.summary_flag,
      l_header_rec.enabled_flag,
      l_header_rec.segment2,
      l_header_rec.segment3,
      l_header_rec.segment4,
      l_header_rec.segment5,
      l_header_rec.start_date_active,
      l_header_rec.end_date_active,
      l_header_rec.last_update_login,
      l_today,
      l_user_id,
      l_header_rec.description,
      l_header_rec.authorization_status,
      l_header_rec.note_to_authorizer,
      l_header_rec.type_lookup_code,
      l_header_rec.transferred_to_oe_flag,
      l_header_rec.attribute_category,
      l_header_rec.attribute1,
      l_header_rec.attribute2,
      l_header_rec.attribute3,
      l_header_rec.attribute4,
            l_header_rec.attribute5,
      l_header_rec.attribute6,
      l_header_rec.attribute7,
      l_header_rec.attribute8,
      l_header_rec.attribute9,
      l_header_rec.attribute10,
      l_header_rec.attribute11,
      l_header_rec.attribute12,
      l_header_rec.attribute13,
      l_header_rec.attribute14,
      l_header_rec.attribute15,
      l_header_rec.government_context,
      l_header_rec.closed_code ,
      --xx field
       l_header_rec.TAX_ATTRIBUTE_UPDATE_CODE,--    'CREATE',  --<eTax Integration R12>
       l_header_rec.INTERFACE_SOURCE_CODE,
       l_header_rec.APPS_SOURCE_CODE,
       l_header_rec.ACTIVE_SHOPPING_CART_FLAG,
       l_header_rec.UDA_TEMPLATE_DATE
       ------------------
                   );
       end if;

        -- get all the values required to insert into po_requisition_lines table

        -- line_type_id for Requisition
        OPEN line_type_cur (l_header_rec.org_id);
        FETCH line_type_cur INTO l_line_type_id;
        CLOSE line_type_cur;

        FOR I IN 1..l_line_tbl.COUNT LOOP

            -- Get Set of Books Id
            OPEN set_of_books_cur (l_line_tbl(i).org_id);
            FETCH set_of_books_cur INTO l_set_of_books_id;
            CLOSE set_of_books_cur;

            -- get requisition_line_id
            IF (l_line_tbl(i).Requisition_Line_Id is NULL) THEN
              OPEN req_line_id_cur;
              FETCH req_line_id_cur INTO l_line_tbl(i).requisition_line_id;
              CLOSE req_line_id_cur;
            END IF;

            -- Assign Requisition Header ID
            IF (l_line_tbl(i).requisition_header_id IS NULL) THEN
                l_line_tbl(i).requisition_header_id := l_header_rec.requisition_header_id;
            END IF;

            -- Assign the default line_type_id if there isn't one
            IF (l_line_tbl(i).line_type_id IS NULL) THEN
                l_line_tbl(i).line_type_id := l_line_type_id;
            END IF;

            -- <SERVICES FPJ START>
            -- Populate the values of order_type_lookup_code, purchase_basis
            -- and matching_basis based on the line_type_id
            BEGIN
                SELECT order_type_lookup_code,
                       purchase_basis,
                       matching_basis
                INTO   l_line_tbl(i).order_type_lookup_code,
                       l_line_tbl(i).purchase_basis,
                       l_line_tbl(i).matching_basis
                FROM   po_line_types
                WHERE  line_type_id = l_line_tbl(i).line_type_id;
            EXCEPTION
                WHEN OTHERS THEN
                    null;
            END;
            -- <SERVICES FPJ END>

            -- INVALID_LOCATION_ID and INVALID_DESTINATION_ORG exceptions
            -- were added as part of this package to avoid seeding new messages
            -- in OM when validating deliver_to_location_id and destination_organization_id

            IF l_line_tbl(i).deliver_to_location_id IS NULL THEN
    Raise INVALID_LOCATION_ID;
            END IF;

            IF l_line_tbl(i).destination_organization_id IS NULL THEN
    Raise INVALID_DESTINATION_ORG;
            END IF;

            -- Get Item Description, if NULL
            -- It is assumed that whenever this procedure is called, Item ID will be
            -- passed.  If Item Description is NULL, Raise ERROR.
            IF (l_line_tbl(i).item_description IS NULL) THEN
              OPEN item_desc_cur(l_line_tbl(i).item_id, l_line_tbl(i).destination_organization_id);
              FETCH item_desc_cur INTO l_line_tbl(i).item_description;
              IF item_desc_cur%NOTFOUND THEN
                 CLOSE item_desc_cur;
     Raise INVALID_ITEM;
              END IF;
              CLOSE item_desc_cur;
            END IF;

            -- Get Category ID of the Item
            IF (l_line_tbl(i).category_id IS NULL) THEN
               OPEN item_category_cur (l_line_tbl(i).item_id, l_line_tbl(i).destination_organization_id);
               FETCH item_category_cur INTO l_line_tbl(i).category_id;
               IF item_category_cur%NOTFOUND THEN
                  CLOSE item_category_cur;
      Raise INVALID_ITEM_CATEGORY;
               END IF;
               CLOSE item_category_cur;
            END IF;

            -- Derive Unit_of_Measure from Uom_Code passed from OM
      OPEN unit_of_measure_cur(l_line_tbl(i).uom_code);
      FETCH unit_of_measure_cur INTO l_line_tbl(i).unit_meas_lookup_code;
            IF unit_of_measure_cur%NOTFOUND THEN
               CLOSE unit_of_measure_cur;
               Raise INVALID_UNIT_OF_MEASURE;
            ELSE
               CLOSE unit_of_measure_cur;
            END IF;

            /* Get Unit Price and Currency Code*/
            --глушим эту проверку
            --т.к. прайс мы и без них знаем где взять
            /*if nvl(l_line_tbl(i).attribute1)), '0')!= 6 then
              get_unit_price_prc (l_line_tbl(i).item_id
               ,l_line_tbl(i).source_organization_id
               ,l_line_tbl(i).destination_organization_id
               ,l_set_of_books_id
               ,d_chart_of_accounts_id
                                 ,l_line_tbl(i).currency_code
                                 ,l_line_tbl(i).unit_price
                                 ,l_line_tbl(i).unit_meas_lookup_code ); -- for bug 16780490

            end if; */

            OPEN currency_code_cur(l_line_tbl(i).destination_organization_id);
             FETCH currency_code_cur INTO l_line_tbl(i).currency_code, d_chart_of_accounts_id;
             CLOSE currency_code_cur;

            -- Quantity MUST be > 0 for Requisition
            IF (l_line_tbl(i).quantity <= 0) THEN
                Raise INVALID_QUANTITY;
            END IF;

            -- Default INVENTORY as Source_Type_Code for Internal Requisitions if not passed
            -- If passed, validate Source Type Code from PO_LOOKUP_CODES
            -- If Invalid, Raise Error
            IF (l_line_tbl(i).source_type_code IS NULL ) THEN
                 l_line_tbl(i).source_type_code := 'INVENTORY';
            ELSE
                OPEN source_type_cur(l_line_tbl(i).source_type_code);
                FETCH source_type_cur INTO l_dummy;
                IF source_type_cur%NOTFOUND THEN
                   CLOSE source_type_cur;
                   Raise INVALID_SOURCE_TYPE;
                END IF;
                CLOSE source_type_cur;
            END IF;

            -- Default Encumbered_Flag to 'N'
            -- Since the funds reservation API is not called from here, this flag is
            -- set to 'N'
            IF (l_line_tbl(i).encumbered_flag IS NULL) THEN
    l_line_tbl(i).encumbered_flag := 'N';
            END IF;

            -- Default Cancel_flag to 'N' --Стандартно магазином выставляется в null, сделаем также
           --IF (l_line_tbl(i).cancel_flag IS NULL) THEN
           --    l_line_tbl(i).cancel_flag := 'N';
           -- END IF;

            -- Default INVENTORY as Destination_Type_Code for Internal Requisitions if not passed
            -- If passed, validate Destination Type Code from PO_LOOKUP_CODES
            -- If Invalid, Raise Error
            IF (l_line_tbl(i).destination_type_code IS NULL ) THEN
                 l_line_tbl(i).destination_type_code := 'INVENTORY';
            ELSE
                OPEN destination_type_cur(l_line_tbl(i).destination_type_code);
                FETCH destination_type_cur INTO l_dummy;
                IF destination_type_cur%NOTFOUND THEN
                   CLOSE destination_type_cur;
                   Raise INVALID_DESTINATION_TYPE;
                END IF;
                CLOSE destination_type_cur;
            END IF;

            -- insert into po_requisition_lines table
            -- <SERVICES FPJ>
            -- Added order_type_lookup_code, purchase_basis and
            -- matching_basis


	     IF  (l_line_tbl(i).item_id IS NOT NULL) Then


              po_attribute_values_pvt.get_item_attributes_values(l_line_tbl(i).item_id, l_manufacturer_pn,l_manufacturer_name,
                                          l_lead_time,l_manufacturer_id) ;

            END IF ;


            INSERT INTO po_requisition_lines_all(
                   requisition_line_id,
                   requisition_header_id,
                   line_num,
                   line_type_id,
                   category_id,
                   item_description,
                   unit_meas_lookup_code,
                   unit_price,
                   quantity,
                   deliver_to_location_id,
                   to_person_id,
                   last_update_date,
                   last_updated_by,
                   source_type_code,
                   last_update_login,
                   creation_date,
                   created_by,
                   item_id,
                   item_revision,
                   encumbered_flag,
                   rfq_required_flag,
                   need_by_date,
                   source_organization_id,
                   source_subinventory,
                   destination_type_code,
                   destination_organization_id,
                   destination_subinventory,
                   line_location_id,
                   modified_by_agent_flag,
                   parent_req_line_id,
                   justification,
                   note_to_agent,
                   note_to_receiver,
                   purchasing_agent_id,
                   document_type_code,
                   blanket_po_header_id,
                   blanket_po_line_num,
                   currency_code,
                   rate_type,
                   rate_date,
                   rate,
                   currency_unit_price,
                   suggested_vendor_name,
                   suggested_vendor_location,
                   suggested_vendor_contact,
                   suggested_vendor_phone,
                   suggested_vendor_product_code,
                   un_number_id,
                   hazard_class_id,
                   must_use_sugg_vendor_flag,
                   reference_num,
                   on_rfq_flag,
                   urgent_flag,
                   cancel_flag,
                   quantity_cancelled,
                   cancel_date,
                   cancel_reason,
                   closed_code,
                   agent_return_note,
                   changed_after_research_flag,
                   vendor_id,
                   vendor_site_id,
                   vendor_contact_id,
                   research_agent_id,
                   wip_entity_id,
                   wip_line_id,
                   wip_repetitive_schedule_id,
                   wip_operation_seq_num,
                   wip_resource_seq_num,
                   attribute_category,
                   destination_context,
                   inventory_source_context,
                   vendor_source_context,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   bom_resource_id,
                   government_context,
                   closed_reason,
                   closed_date,
                   transaction_reason_code,
                   quantity_received,
                   order_type_lookup_code,
                   purchase_basis,
                   matching_basis,
       org_id,   -- <R12 MOAC>
                   tax_attribute_update_code,  --<eTax Integration R12>
		    MANUFACTURER_ID,            --bug 7387487
                   MANUFACTURER_NAME,
                   MANUFACTURER_PART_NUMBER,
                   ---xx add field
                    NEGOTIATED_BY_PREPARER_FLAG,
                    CONTRACT_TYPE,
                    CLM_INFO_FLAG,                    
                    CATALOG_TYPE,
                    CATALOG_SOURCE,
                    NEW_SUPPLIER_FLAG,
                    SUGGESTED_BUYER_ID,
                    BASE_UNIT_PRICE
                    

                   ---
                ) VALUES (
              l_line_tbl(i).requisition_line_id,
        l_line_tbl(i).requisition_header_id,
        l_line_tbl(i).line_num,
        l_line_tbl(i).line_type_id,
        l_line_tbl(i).category_id,
        l_line_tbl(i).item_description,
        l_line_tbl(i).unit_meas_lookup_code,
        l_line_tbl(i).unit_price,
        l_line_tbl(i).quantity,
        l_line_tbl(i).deliver_to_location_id,
        l_line_tbl(i).to_person_id,
        l_today,   -- last_update_date
        l_user_id,  --last_updated_by
        l_line_tbl(i).source_type_code,
        l_login_id, --last_update_login
        l_today,   --creation_date
        l_user_id,  --created_by
        l_line_tbl(i).item_id,
        l_line_tbl(i).item_revision,
        l_line_tbl(i).encumbered_flag,
        l_line_tbl(i).rfq_required_flag,
        l_line_tbl(i).need_by_date,
        l_line_tbl(i).source_organization_id,
        l_line_tbl(i).source_subinventory,
        l_line_tbl(i).destination_type_code,
        l_line_tbl(i).destination_organization_id,
        l_line_tbl(i).destination_subinventory,
        l_line_tbl(i).line_location_id,
        l_line_tbl(i).modified_by_agent_flag,
        l_line_tbl(i).parent_req_line_id,
        l_line_tbl(i).justification,
        l_line_tbl(i).note_to_agent,
        l_line_tbl(i).note_to_receiver,
        l_line_tbl(i).purchasing_agent_id,
        l_line_tbl(i).document_type_code,
        l_line_tbl(i).blanket_po_header_id,
        l_line_tbl(i).blanket_po_line_num,
        l_line_tbl(i).currency_code,
        l_line_tbl(i).rate_type,
        l_line_tbl(i).rate_date,
        l_line_tbl(i).rate,
        l_line_tbl(i).currency_unit_price,
        l_line_tbl(i).suggested_vendor_name,
        l_line_tbl(i).suggested_vendor_location,
        l_line_tbl(i).suggested_vendor_contact,
        l_line_tbl(i).suggested_vendor_phone,
        l_line_tbl(i).suggested_vendor_product_code,
        l_line_tbl(i).un_number_id,
        l_line_tbl(i).hazard_class_id,
        l_line_tbl(i).must_use_sugg_vendor_flag,
        l_line_tbl(i).reference_num,
        l_line_tbl(i).on_rfq_flag,
        l_line_tbl(i).urgent_flag,
        l_line_tbl(i).cancel_flag,
        l_line_tbl(i).quantity_cancelled,
        l_line_tbl(i).cancel_date,
        l_line_tbl(i).cancel_reason,
        l_line_tbl(i).closed_code,
        l_line_tbl(i).agent_return_note,
        l_line_tbl(i).changed_after_research_flag,
        l_line_tbl(i).vendor_id,
        l_line_tbl(i).vendor_site_id,
        l_line_tbl(i).vendor_contact_id,
        l_line_tbl(i).research_agent_id,
        l_line_tbl(i).wip_entity_id,
        l_line_tbl(i).wip_line_id,
        l_line_tbl(i).wip_repetitive_schedule_id,
        l_line_tbl(i).wip_operation_seq_num,
        l_line_tbl(i).wip_resource_seq_num,
        l_line_tbl(i).attribute_category,
        l_line_tbl(i).destination_context,
        l_line_tbl(i).inventory_source_context,
        l_line_tbl(i).vendor_source_context,
        l_line_tbl(i).attribute1,
        l_line_tbl(i).attribute2,
        l_line_tbl(i).attribute3,
        l_line_tbl(i).attribute4,
        l_line_tbl(i).attribute5,
        l_line_tbl(i).attribute6,
        l_line_tbl(i).attribute7,
        l_line_tbl(i).attribute8,
        l_line_tbl(i).attribute9,
        l_line_tbl(i).attribute10,
        l_line_tbl(i).attribute11,
        l_line_tbl(i).attribute12,
        l_line_tbl(i).attribute13,
        l_line_tbl(i).attribute14,
        l_line_tbl(i).attribute15,
        l_line_tbl(i).bom_resource_id,
        l_line_tbl(i).government_context,
        l_line_tbl(i).closed_reason,
        l_line_tbl(i).closed_date,
        l_line_tbl(i).transaction_reason_code,
                    l_line_tbl(i).quantity_received,
                    l_line_tbl(i).order_type_lookup_code,
                    l_line_tbl(i).purchase_basis,
                    l_line_tbl(i).matching_basis,
        l_line_tbl(i).org_id,     -- <R12 MOAC>
                    'CREATE', --<eTax Integration R12>
		    l_manufacturer_id,
                    l_manufacturer_name,
                    l_manufacturer_pn,
                    ----xx---
                    l_line_tbl(i).NEGOTIATED_BY_PREPARER_FLAG,
                    l_line_tbl(i).CONTRACT_TYPE,
                    l_line_tbl(i).CLM_INFO_FLAG, 
                    l_line_tbl(i).CATALOG_TYPE,
                    l_line_tbl(i).CATALOG_SOURCE,
                    l_line_tbl(i).NEW_SUPPLIER_FLAG,
                    l_line_tbl(i).SUGGESTED_BUYER_ID,
                    l_line_tbl(i).BASE_UNIT_PRICE
                    --------------

                   );
                   
      if px_dist_table is not empty then 
        --Перебор коллекции по line_num
        v_count:= 0;
        for j in (select t.* from table(px_dist_table)  t
                  where t.requisition_line_num = l_line_tbl(i).line_num)
        loop
         declare 
           l_dist_rec   XXPHA_SN1041_CREATE_REQ_PKG.Dist_rec_Type;           
         begin
                v_count:= v_count +1;  
                --gtht      
                 
               -- v_count:=     
        --Заполнение рекорда
                l_dist_rec:= j;         
                l_dist_rec.requisition_line_id := l_line_tbl(i).requisition_line_id;     
                l_dist_rec.org_id := l_line_tbl(i).org_id;    -- <R12 MOAC>
                
                /*l_dist_rec.project_id           := j.project_id;
                l_dist_rec.task_id              := j.task_id;   
                l_dist_rec.budget_account_id    := j.budget_account_id;  
                l_dist_rec.req_line_quantity    := j.req_line_quantity;
                l_dist_rec.gl_encumbered_date   := j.gl_encumbered_date;*/

                -- It is assumed that only 1 dIstribution line will be there for each
            -- INTERNAL Requisition.  If Multiple Distributions Lines are to created
            -- This procedure should be modified

            -- Get Distribution ID from the Distribution Sequence
                    OPEN dist_line_id_cur;
                    FETCH dist_line_id_cur INTO l_dist_rec.distribution_id;
                    CLOSE dist_line_id_cur;

                
    
                

                -- Assign Requisition Line Number as Distribution Number
                l_dist_rec.distribution_num := v_count;--l_line_tbl(i).line_num;

                
                --s_chart_of_accounts_id := 101;

                --TODO Get Charge Account ID
                l_dist_rec.code_combination_id := get_charge_account_fun
                                                 (l_line_tbl(i).destination_organization_id,
                                                  l_line_tbl(i).item_id,
                                                  l_line_tbl(i).destination_subinventory);

                -- Check for valid charge account.  If Invalid Raise ERROR
                IF NOT valid_account_id_fun (l_dist_rec.code_combination_id,
                                             l_dist_rec.gl_encumbered_date,
                                             d_chart_of_accounts_id) THEN /* bug 5637277 replaced s_chart_of_accounts_id with d_chart_of_accounts_id */
                   --Raise INVALID_CHARGE_ACCOUNT;
                   null;
                END IF;

                -- Get Accrual Account ID and Variance Account ID for the
                --Destination Organization from MTL_PARAMETERS

                OPEN accrual_account_id_cur (l_line_tbl(i).destination_organization_id);
                FETCH accrual_account_id_cur
                      INTO l_dist_rec.accrual_account_id,
                           l_dist_rec.variance_account_id;
                CLOSE accrual_account_id_cur;

                -- Check for valid accrual account.  If Invalid Raise ERROR
                IF NOT valid_account_id_fun (l_dist_rec.accrual_account_id,
                                             l_dist_rec.gl_encumbered_date,
                                             d_chart_of_accounts_id) THEN /* bug 5637277 replaced s_chart_of_accounts_id with d_chart_of_accounts_id */
                --Raise INVALID_ACCRUAL_ACCOUNT;
                null;
                END IF;

                -- Check for valid variance account.  If Invalid Raise ERROR
                IF NOT valid_account_id_fun (l_dist_rec.variance_account_id,
                                             l_dist_rec.gl_encumbered_date,
                                             d_chart_of_accounts_id) THEN /* bug 5637277 replaced s_chart_of_accounts_id with d_chart_of_accounts_id */
                --Raise INVALID_VARIANCE_ACCOUNT;
                null;
                END IF;

                -- Assign Set of Books ID
                l_dist_rec.set_of_books_id := l_set_of_books_id;


                -- Get Requisition Encumbrance Flag for Financial System Parameters
                -- If Req_Encumbrance_flag = 'Y' populate Budget Account ID for
                -- Req Distribution
                -- If gl_encumbered_flag = 'N' then don't populate gl_encumbered_date
                OPEN req_encumbrance_cur (l_dist_rec.set_of_books_id);
                FETCH req_encumbrance_cur INTO l_dist_rec.encumbered_flag;
                CLOSE req_encumbrance_cur;
                
                  
    ---------------------------------------------  
                
           --TODO Assign Requisition Line ID if NULL                
                

    
            
  /*   
  IF l_dist_rec.encumbered_flag = 'Y' then           
 OPEN budget_account_cur (l_line_tbl(i).destination_organization_id,
                                            l_line_tbl(i).item_id);
                   --TODO                         
                   FETCH budget_account_cur INTO l_dist_rec.budget_account_id;
                   CLOSE budget_account_cur;
                   -- Check for valid budget account.  If Invalid Raise ERROR
       IF NOT valid_account_id_fun (l_dist_rec.budget_account_id,
                                             l_dist_rec.gl_encumbered_date,
                                             d_chart_of_accounts_id) THEN -- bug 5637277 replaced s_chart_of_accounts_id with d_chart_of_accounts_id
          Raise INVALID_BUDGET_ACCOUNT;
                   END IF;
                ELSE
                   l_dist_rec.gl_encumbered_date := '';
                END IF;*/

              INSERT INTO po_req_distributions_all
              (
              distribution_id
              ,last_update_date
              ,last_updated_by
              ,requisition_line_id
              ,set_of_books_id
              ,code_combination_id
              ,req_line_quantity
              ,last_update_login
              ,creation_date
              ,created_by
              ,encumbered_flag
              ,gl_encumbered_date
              ,gl_encumbered_period_name
              ,gl_cancelled_date
              ,failed_funds_lookup_code
              ,encumbered_amount
              ,budget_account_id
              ,accrual_account_id
              ,variance_account_id
              ,prevent_encumbrance_flag
              ,attribute_category
              ,attribute1
              ,attribute2
              ,attribute3
              ,attribute4
              ,attribute5
              ,attribute6
              ,attribute7
              ,attribute8
              ,attribute9
              ,attribute10
              ,attribute11
              ,attribute12
              ,attribute13
              ,attribute14
              ,attribute15
              ,government_context
              ,project_id
              ,task_id
              ,expenditure_type
              ,project_accounting_context
              ,expenditure_organization_id
              ,gl_closed_date
              ,source_req_distribution_id
              ,distribution_num
              ,project_related_flag
              ,expenditure_item_date
              ,org_id
              ,allocation_type
              ,allocation_value
              ,award_id
              ,end_item_unit_number
              ,recoverable_tax
              ,nonrecoverable_tax
              ,recovery_rate
              ,tax_recovery_override_flag
              ,oke_contract_line_id
              ,oke_contract_deliverable_id
              )
              VALUES
              (
               l_dist_rec.distribution_id
              ,l_today     --last_update_date
              ,l_user_id      --last_updated_by
              ,l_dist_rec.requisition_line_id
              ,l_dist_rec.set_of_books_id
              ,l_dist_rec.code_combination_id
              ,l_dist_rec.req_line_quantity
              ,l_login_id  --last_update_login
              ,l_today     --creation_date
              ,l_user_id   --created_by
              ,l_dist_rec.encumbered_flag  --Bug:12393759
              ,l_dist_rec.gl_encumbered_date--xx Дата ГК = требуемой  дате l_dist_rec.gl_encumbered_date --xx Bug:12393759 ;--xx
              ,l_dist_rec.gl_encumbered_period_name  --Bug:12393759
              ,l_dist_rec.gl_cancelled_date
              ,l_dist_rec.failed_funds_lookup_code
              ,NULL--l_dist_rec.encumbered_amount --Bug:12393759
              ,l_dist_rec.budget_account_id
              ,l_dist_rec.accrual_account_id
              ,l_dist_rec.variance_account_id
              ,l_dist_rec.prevent_encumbrance_flag --Bug:12393759
              ,l_dist_rec.attribute_category
              ,l_dist_rec.attribute1
              ,l_dist_rec.attribute2
              ,l_dist_rec.attribute3
              ,l_dist_rec.attribute4
              ,l_dist_rec.attribute5
              ,l_dist_rec.attribute6
              ,l_dist_rec.attribute7
              ,l_dist_rec.attribute8
              ,l_dist_rec.attribute9
              ,l_dist_rec.attribute10
              ,l_dist_rec.attribute11
              ,l_dist_rec.attribute12
              ,l_dist_rec.attribute13
              ,l_dist_rec.attribute14
              ,l_dist_rec.attribute15
              ,l_dist_rec.government_context
              ,l_dist_rec.project_id
              ,l_dist_rec.task_id
              ,l_dist_rec.expenditure_type
              ,l_dist_rec.project_accounting_context
              ,l_dist_rec.expenditure_organization_id
              ,l_dist_rec.gl_closed_date
              ,l_dist_rec.source_req_distribution_id
              ,l_dist_rec.distribution_num
              ,l_dist_rec.project_related_flag
              ,l_dist_rec.expenditure_item_date
              ,l_dist_rec.org_id
              ,l_dist_rec.allocation_type
              ,l_dist_rec.allocation_value
              ,l_dist_rec.award_id
              ,l_dist_rec.end_item_unit_number
              ,l_dist_rec.recoverable_tax
              ,l_dist_rec.nonrecoverable_tax
              ,l_dist_rec.recovery_rate
              ,l_dist_rec.tax_recovery_override_flag
              ,l_dist_rec.oke_contract_line_id
              ,l_dist_rec.oke_contract_deliverable_id
              );    
           end;
          end loop; 
         end if;
        END LOOP;
        
       

        -- Create Supply Record for the Requisition.

 -- l_create_req_supply :=  PO_SUPPLY.create_req(l_header_rec.requisition_header_id,                                                     'REQ HDR');

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
         --Bug 13254403 Added call to maintain_mtl_supply
        ELSE
          l_return_value := PO_SUPPLY.maintain_mtl_supply;
          IF NOT l_return_value THEN
          	 RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;


        fnd_msg_pub.count_and_get
                  ( p_count => x_msg_count
                  , p_data  => x_msg_data);

  px_header_rec := l_header_rec;
      px_line_table := l_line_tbl;

 xxpha_sn1041_lst_req_bskt_pkg.add_log('1767 end');
  EXCEPTION
   WHEN INVALID_ITEM THEN
        po_message_s.app_error('PO_RI_ITEM_DESC_MISMATCH');
        raise;

   WHEN UNIT_PRICE_LT_0 THEN
        po_message_s.app_error('PO_RI_UNIT_PRICE_LT_0');
        raise;

   WHEN INVALID_ITEM_CATEGORY THEN
        po_message_s.app_error('PO_RI_INVALID_CATEGORY_ID');
        raise;

   WHEN INVALID_QUANTITY THEN
        po_message_s.app_error('PO_RI_QUANTITY_LE_0');
        raise;

   WHEN INVALID_SOURCE_TYPE THEN
        po_message_s.app_error('PO_RI_INVALID_SOURCE_TYPE_CODE');
        raise;

   WHEN INVALID_CHARGE_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_CHARGE_ACC_ID');
        raise;

   WHEN INVALID_ACCRUAL_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_ACCRUAL_ACC_ID');
        raise;

   WHEN INVALID_BUDGET_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_BUDGET_ACC_ID');
        raise;

   WHEN INVALID_VARIANCE_ACCOUNT THEN
        po_message_s.app_error('PO_RI_INVALID_VARIANCE_ACC_ID');
        raise;

   WHEN INVALID_AUTH_STATUS THEN
        po_message_s.app_error('PO_RI_INVALID_AUTH_STATUS');
        raise;

   WHEN INVALID_PREPARER_ID THEN
        po_message_s.app_error('PO_RI_INACTIVE_PREPARER');
        raise;

   WHEN INVALID_LOCATION_ID THEN
        po_message_s.app_error('PO_RI_INVALID_LOCATION');
        raise;

   WHEN INVALID_DESTINATION_ORG THEN
        po_message_s.app_error('PO_RI_INVALID_DEST_ORG');
        raise;

   WHEN INVALID_UNIT_OF_MEASURE THEN
        po_message_s.app_error('PO_RI_M_INVALID_UOM');
        raise;

   WHEN FND_API.G_EXC_ERROR then
     xxpha_sn1041_lst_req_bskt_pkg.add_log('1826 '||sqlerrm||' '||dbms_utility.format_error_backtrace);
        NULL;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
      xxpha_sn1041_lst_req_bskt_pkg.add_log('1828 '||sqlerrm||' '||dbms_utility.format_error_backtrace);
      FND_MESSAGE.SET_NAME('PO', 'PO_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS then
      xxpha_sn1041_lst_req_bskt_pkg.add_log('1838 '||sqlerrm||' '||dbms_utility.format_error_backtrace);
      FND_MESSAGE.SET_NAME('PO', 'PO_UNEXPECTED_EXEC_ERRORS');
      FND_MESSAGE.SET_TOKEN('ROUTINE', l_api_name, TRUE);
      FND_MESSAGE.SET_TOKEN('SQLERRM', sqlerrm, TRUE);
      FND_MSG_PUB.ADD;
      fnd_msg_pub.count_and_get
              ( p_count => x_msg_count
              , p_data  => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

  END;

END XXPHA_SN1041_CREATE_REQ_PKG;
/
