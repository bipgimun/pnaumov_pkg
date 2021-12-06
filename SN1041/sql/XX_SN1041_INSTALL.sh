#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		17.04.2020	SN1041
#==================================================================
read APPSID
echo "Start install SN1041 ..."

# some debug flags
oaf_install="Y"

download_extrafile 'OEBS_SN' 'SN775' 'sql' 'XX_SN775_ELASTIC_PROXY_PKG.pck'

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL.sql
echo "Install completed (SQL)..."

if [ "$oaf_install" = "Y" ]
then
echo "---------------------------------------------------"
echo "Start installing OAF-artefacts..."

oafJava  'XXPHA' 'icx/sn1041/utils' 'Sn1041Utils.java' '-encoding UTF-8'

oafJava  'XXPHA' 'icx/sn1041/server/common' 'SearchResultsVORow.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'SearchResultsVOImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'SearchResultsVORowImpl.java'  '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/utils' 'ResultForInvoce.java'
cp -r XXPHA/icx/sn1041/server/SearchResultsVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

oafJava  'XXPHA' 'icx/sn1041/server' 'ParametersVORowImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'ParametersVOImpl.java' 
cp -r XXPHA/icx/sn1041/server/ParametersVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

oafJava  'XXPHA' 'icx/sn1041/lov/server' 'RequisitionTypesVOImpl.java' 
cp -r XXPHA/icx/sn1041/lov/server/RequisitionTypesVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server
#----------------------------------------------------------------------------------------------
# Analog
cp -r XXPHA/icx/sn1041/server/AnalogVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server/common' 'AnalogVO.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'AnalogVORowImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'AnalogVOImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'AnalogAMImpl.java' '-encoding UTF-8'
cp -r XXPHA/icx/sn1041/server/AnalogAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
#----------------------------------------------------------------------------------------------
# Req Status Detail
cp -r XXPHA/icx/sn1041/server/ReqStatusDetailVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'ReqStatusDetailVOImpl.java' 
#----------------------------------------------------------------------------------------------
# Store Detail
cp -r XXPHA/icx/sn1041/server/ReqQuantityDetailVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'ReqQuantityDetailVOImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'DetailedAMImpl.java'
cp -r XXPHA/icx/sn1041/server/DetailedAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
#----------------------------------------------------------------------------------------------
# Table5 
oafJava  'XXPHA' 'icx/sn1041/server' 'Table5SourceEOImpl.java' 
cp -r XXPHA/icx/sn1041/server/Table5SourceEO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'Table5SourceVORowImpl.java' 
cp -r XXPHA/icx/sn1041/server/Table5SourceVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'Table5SourceVOImpl.java' 
cp -r XXPHA/icx/sn1041/server/Table5SourceVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

if [ ! -d $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/poplist/server ]; then
  mkdir -p $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/poplist/server
fi 
cp XXPHA/icx/sn1041/poplist/server/StoreListVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/poplist/server
cp XXPHA/icx/sn1041/poplist/server/server.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/poplist/server
#----------------------------------------------------------------------------------------------
# Session 
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionEOImpl.java' 
cp -r XXPHA/icx/sn1041/server/SessionEO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionVORowImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionVOImpl.java'
cp -r XXPHA/icx/sn1041/server/SessionVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionAMImpl.java' 
cp -r XXPHA/icx/sn1041/server/SessionAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
 
oafJava  'XXPHA' 'icx/sn1041/lov/server' 'SubInvVOImpl.java' 
cp -r XXPHA/icx/sn1041/lov/server/SubInvVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server


cp -r XXPHA/icx/sn1041/server/ActiveCart.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'ActiveCartImpl.java' 

#----------------------------------------------------------------------------------------------
# SearchAM
oafJava  'XXPHA' 'icx/sn1041/server' 'SearchAMImpl.java' 
cp -r XXPHA/icx/sn1041/server/SearchAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

cp -r XXPHA/icx/sn1041/server/server.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
#----------------------------------------------------------------------------------------------
# Lovs
oafJava  'XXPHA' 'icx/sn1041/lov/server' 'StorListVOImpl.java' 
cp -r XXPHA/icx/sn1041/lov/server/StorListVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server


oafJava  'XXPHA' 'icx/sn1041/lov/server' 'LovsAMImpl.java'
cp -r XXPHA/icx/sn1041/lov/server/LovsAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server
cp -r XXPHA/icx/sn1041/lov/server/server.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server

oafJava  'XXPHA' 'icx/sn1041/webui' 'SearchHomeCO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'SearchResultsCO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'Table5CO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'AnalogCO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'DetailedCO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'StatusDetailedCO.java' '-encoding UTF-8'

oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'RequisitionItemsListPG.xml'
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'SearchHomePG.xml'
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'AnalogRN.xml'
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'DetailedRN.xml'
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'StatusDetailedRN.xml'


oafJava  'XXPHA' 'xxpha/SN775/webui' 'SN775crItemCO.java' '-encoding UTF-8'

#----------------------------------------------------------------------------------------------
# OAF Pers
oafJava  'XXPHA' 'icx/sn1041/webui' 'xxPersEditSubmitCO.java' 
oafJava  'XXPHA' 'icx/icatalog/shopping/webui' 'xxShoppingHomeCO.java' 

echo "-- Install OAF artefacts - done"
fi
#----------------------------------------------------------------------------------------------
# JavaScript
mkdir -p $OA_HTML/sn1041
chmod 755 XXPHA/HTML/sn1041/sn1041.js
cp -r XXPHA/HTML/sn1041/sn1041.js $OA_HTML/sn1041/sn1041.js

chmod 755 XXPHA/HTML/sn1041/sn1041_req.js
cp -r XXPHA/HTML/sn1041/sn1041_req.js $OA_HTML/sn1041/sn1041_req.js

chmod 755 XXPHA/HTML/sn1041/sn1041_analog.js
cp -r XXPHA/HTML/sn1041/sn1041_analog.js $OA_HTML/sn1041/sn1041_analog.js

chmod 755 XXPHA/HTML/sn1041/jquery-migrate-1.4.1.js
cp -r XXPHA/HTML/sn1041/jquery-migrate-1.4.1.js $OA_HTML/sn1041/jquery-migrate-1.4.1.js

chmod 755 XXPHA/HTML/sn1041/jquery-3.4.1.js
cp -r XXPHA/HTML/sn1041/jquery-3.4.1.js $OA_HTML/sn1041/jquery-3.4.1.js

chmod 755 XXPHA/HTML/sn1041/jquery-ui.js
cp -r XXPHA/HTML/sn1041/jquery-ui.js $OA_HTML/sn1041/jquery-ui.js

chmod 755 XXPHA/HTML/sn1041/jquery-ui.css
cp -r XXPHA/HTML/sn1041/jquery-ui.css $OA_HTML/sn1041/jquery-ui.css

echo "---------------------------------------------------"
echo "-- Install media files"
if [ ! -d $OA_MEDIA/sn1041 ]; then
  mkdir -p $OA_MEDIA/sn1041
fi 
cp -r XXPHA/MEDIA/* $OA_MEDIA/sn1041
echo "-- Install media files - done"

echo "---------------------------------------------------"
echo "-- Import FNDLOAD objects"
NLS_LANG_TEMP=$NLS_LANG;
export NLS_LANG_TEMP;
#NLS_LANG=Russian_CIS.CL8ISO8859P5;
NLS_LANG=Russian_CIS.CL8MSWIN1251;
export NLS_LANG;
echo "NLS_LANG set before ldt upload to "$NLS_LANG 

$FND_TOP/bin/FNDLOAD apps/$APPSID 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct XX_SN1041_SELECT_ITEMS_VIEW.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE

$FND_TOP/bin/FNDLOAD apps/$APPSID 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct XX_SN1041_HOME.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE

export NLS_LANG_TEMP;
echo "NLS_LANG reset after ldt upload to "$NLS_LANG_TEMP 

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_MENU_ENTRY.sql

echo "---------------------------------------------------"
echo "Install of SN1041 completed ... Check it by the logs, please"