#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		08.08.2020	SN1041
#==================================================================
read APPSID
echo "Start install SN1041 patch 3..."

echo "---------------------------------------------------"
echo "-- Import FNDLOAD objects"
NLS_LANG_TEMP=$NLS_LANG;
export NLS_LANG_TEMP;
#NLS_LANG=Russian_CIS.CL8ISO8859P5;
NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251;
export NLS_LANG;
echo "NLS_LANG set before ldt upload to "$NLS_LANG 

$FND_TOP/bin/FNDLOAD apps/$APPSID 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct XX_SN1041_SEL_ITEMS_EA.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE

$FND_TOP/bin/FNDLOAD apps/$APPSID 0 Y UPLOAD $FND_TOP/patch/115/import/afsload.lct XX_SN1041_EAM_HOME.ldt - WARNING=YES UPLOAD_MODE=REPLACE CUSTOM_MODE=FORCE

export NLS_LANG_TEMP;
echo "NLS_LANG reset after ldt upload to "$NLS_LANG_TEMP 

echo "---------------------------------------------------"

download_extrafile 'OEBS_EAM' 'EAM518' 'sql' 'XX_EAM518_PKG.pks'
download_extrafile 'OEBS_EAM' 'EAM518' 'sql' 'XX_EAM518_PKG.pkb'
download_extrafile 'OEBS_EAM' 'EAM517' 'sql' 'XX_EAM517_PKG.sql'
#download_extrafile 'OEBS_OAF' 'ICX' 'icx/por/req/webui' 'xxEditSubmitCO.java'

# some DEBUG flags
oaf_install="Y"
sql_install="Y"

if [ "$sql_install" = "Y" ]
then
echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_3.sql
echo "Install completed (SQL)..."
fi

if [ "$oaf_install" = "Y" ]
then
oafJava  'XXPHA' 'icx/sn1041/utils' 'Sn1041Utils.java' '-encoding UTF-8'

oafJava  'XXPHA' 'icx/sn1041/server' 'SearchResultsVOImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'SearchResultsVORowImpl.java'  '-encoding UTF-8'
cp -r XXPHA/icx/sn1041/server/SearchResultsVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

#----------------------------------------------------------------------------------------------
# Parameters 
# oafJava  'XXPHA' 'icx/sn1041/server' 'ParametersVORowImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'ParametersVOImpl.java' 
cp -r XXPHA/icx/sn1041/server/ParametersVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

#----------------------------------------------------------------------------------------------
# Session 
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionEOImpl.java' 
cp -r XXPHA/icx/sn1041/server/SessionEO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionVORowImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionVOImpl.java'
cp -r XXPHA/icx/sn1041/server/SessionVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionAMImpl.java' 
cp -r XXPHA/icx/sn1041/server/SessionAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server


cp -r XXPHA/icx/sn1041/server/ReqStatusDetailVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
#----------------------------------------------------------------------------------------------
# Table5 
oafJava  'XXPHA' 'icx/sn1041/server' 'Table5SourceEOImpl.java' 
cp -r XXPHA/icx/sn1041/server/Table5SourceEO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'Table5SourceVORowImpl.java' 
cp -r XXPHA/icx/sn1041/server/Table5SourceVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
oafJava  'XXPHA' 'icx/sn1041/server' 'Table5SourceVOImpl.java' 



#----------------------------------------------------------------------------------------------
# Lovs
oafJava  'XXPHA' 'icx/sn1041/lov/server' 'WipEntitiesListVOImpl.java' 
cp -r XXPHA/icx/sn1041/lov/server/WipEntitiesListVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server

oafJava  'XXPHA' 'icx/sn1041/lov/server' 'StorListVOImpl.java' 
cp -r XXPHA/icx/sn1041/lov/server/StorListVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server

oafJava  'XXPHA' 'icx/sn1041/lov/server' 'OperationsVOImpl.java'
cp -r XXPHA/icx/sn1041/lov/server/OperationsVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server

oafJava  'XXPHA' 'icx/sn1041/lov/server' 'WorkOrdersVOImpl.java'
cp -r XXPHA/icx/sn1041/lov/server/WorkOrdersVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server

oafJava  'XXPHA' 'icx/sn1041/lov/server' 'LovsAMImpl.java'
cp -r XXPHA/icx/sn1041/lov/server/LovsAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server

cp -r XXPHA/icx/sn1041/lov/server/server.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server


oafJava  'XXPHA' 'icx/sn1041/lov/server' 'RequisitionTypesEAMVOImpl.java'
cp -r XXPHA/icx/sn1041/lov/server/RequisitionTypesEAMVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server

#----------------------------------------------------------------------------------------------
oafJava  'XXPHA' 'icx/sn1041/server' 'ActiveCartVOImpl.java'
cp -r XXPHA/icx/sn1041/server/ActiveCartVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

#----------------------------------------------------------------------------------------------
# SearchAM
oafJava  'XXPHA' 'icx/sn1041/server' 'SearchAMImpl.java' 
cp -r XXPHA/icx/sn1041/server/SearchAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

cp -r XXPHA/icx/sn1041/server/server.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server


oafJava  'XXPHA' 'icx/sn1041/webui' 'SearchHomeCO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'SearchResultsCO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'Table5CO.java' '-encoding UTF-8'

oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'SearchHomePG.xml'
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'SearchHomeEAMPG.xml'
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'RequisitionItemsListEamPG.xml'

#----------------------------------------------------------------------------------------------
# Analog
#cp -r XXPHA/icx/sn1041/server/AnalogVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
#oafJava  'XXPHA' 'icx/sn1041/server/common' 'AnalogVO.java' 
#oafJava  'XXPHA' 'icx/sn1041/server' 'AnalogVORowImpl.java' 
#oafJava  'XXPHA' 'icx/sn1041/server' 'AnalogVOImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'AnalogAMImpl.java' '-encoding UTF-8'
#cp -r XXPHA/icx/sn1041/server/AnalogAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

oafJava  'XXPHA' 'icx/sn1041/webui' 'AnalogCO.java' '-encoding UTF-8'

#----------------------------------------------------------------------------------------------
# OAF Pers
oafJava  'XXPHA' 'icx/sn1041/webui' 'xxPersEditSubmitCO.java' 
oafJava  'XXPHA' 'icx/icatalog/shopping/webui' 'xxShoppingHomeCO.java' 
oafJava  'XXPHA' 'icx/por/req/webui' 'xxEditSubmitCO.java' '-encoding UTF-8'

echo "-- Install OAF artefacts - done"
fi



echo "---------------------------------------------------"
echo "Install of SN1041 patch 3 completed ... Check it by the logs, please"




#----------------------------------------------------------------------------------------------