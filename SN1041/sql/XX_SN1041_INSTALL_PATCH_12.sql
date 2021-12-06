SET TERMOUT  ON
SET ECHO     OFF
SET FEEDBACK ON
SET VERIFY   ON
SET PAUSE    OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

SPOOL XX_SN1041_INSTALL_PATCH_12.log

begin
  xxpha_pnaumov_pkg.find_block_session(p_obj_name=>'XXPHA_SN1041%', p_kill_session=>'Y');
end;
/
SHO ERR

PROMPT RECREATE VIEW XXPHA_SN1041_PARAMETERS_V
@XX_SN1041_PARAMETERS_V.sql
sho err

PROMPT CREATE PACKAGE XXPHA_SN1041_ELASTIC_PROXY_PKG
@XX_SN1041_ELASTIC_PROXY_PKG.pck
SHO ERR

PROMPT CREATE PACKAGE BODY XXPHA_SN1041_PKG
@XX_SN1041_PKG.pkb
SHO ERR

PROMPT RECOMPILE PACKAGE BODY XXPHA_SN1041_EAM_PKG
@XX_SN1041_EAM_PKG.pkb
SHO ERR

--PROMPT CREATE PACKAGE BODY POR_CUSTOM_PKG
--@POR_CUSTOM/sql/POR_CUSTOM_PKG.sql
--SHO ERR

PROMPT RECOMPILE PACKAGE BODY XXPHA_SN1041_CREATE_REQ_PKG
ALTER PACKAGE XXPHA_SN1041_CREATE_REQ_PKG COMPILE BODY
/
SHO ERR



--PROMPT RECOMPILE PACKAGE BODY XXPHA_SN1041_LST_REQ_BSKT_PKG
--ALTER PACKAGE XXPHA_SN1041_LST_REQ_BSKT_PKG COMPILE BODY
--/
--SHO ERR


SPOOL OFF
EXIT