create or replace view XXPHA_SN1041_ACTIVE_CART_V as
select prha.SEGMENT1 req_num, prha.REQUISITION_HEADER_ID
  from po_requisition_headers_all prha
 where 1 = 1
   and prha.LAST_UPDATED_BY = fnd_global.USER_ID
   and prha.active_shopping_cart_flag = 'Y'
   and prha.AUTHORIZATION_STATUS in ('INCOMPLETE', 'SYSTEM_SAVED');
