create or replace package XXPHA_SN1041_LST_REQ_BSKT_PKG is
  /* $Id: XXPHA_SN1041_LST_REQ_BSKT_PKG.sql 1.0 09/04/2020-10:01 GDAVYDENKO $ */

  DEBUG constant boolean := true;

  procedure add_log(p_msg in varchar2);

  function main(p_row_list     in fnd_table_of_number,
                p_sub_inv      varchar2,
                p_need_by_date date,
                x_msg          out varchar2,
                --для EAM
                p_eam_flag in varchar2) return varchar2;

  procedure upd_shop_flag(p_line_tbl XXPHA_SN1041_CREATE_REQ_PKG.Line_Tbl_type,
                          p_eam_flag in varchar2);

  --Проверка и очистка ссылок на неактивные строки заявок
  procedure refresh_req_table;

end XXPHA_SN1041_LST_REQ_BSKT_PKG;
/
