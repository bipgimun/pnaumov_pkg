#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		06.07.2020	SN1041
#==================================================================
read APPSID
echo "Start install SN1041 patch 1..."

download_extrafile 'OEBS_SN' 'SN775' 'sql/XXPHA/xxpha/SN775/server' 'SN775PoRequisitionLinesVORowImpl.java'

# some debug flags
oaf_install="Y"

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_1.sql
echo "Install completed (SQL)..."

if [ "$oaf_install" = "Y" ]
then
echo "---------------------------------------------------"
echo "Start installing OAF-artefacts..."

oafJava  'XXPHA' 'icx/sn1041/utils' 'Sn1041Utils.java' '-encoding UTF-8'
oafJava  'SN775/sql/XXPHA' 'xxpha/SN775/server' 'SN775PoRequisitionLinesVORowImpl.java'


#----------------------------------------------------------------------------------------------
cp -r XXPHA/icx/sn1041/server/SearchResultsVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/ActiveCartVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/AnalogVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/ParametersVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/ReqQuantityDetailVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/ReqStatusDetailVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/SessionVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/Table5SourceVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

cp -r XXPHA/icx/sn1041/poplist/server/StoreListVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/poplist/server

cp -r XXPHA/icx/sn1041/lov/server/RequisitionTypesVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server
cp -r XXPHA/icx/sn1041/poplist/server/StoreListVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/poplist/server
cp -r XXPHA/icx/sn1041/lov/server/SubInvVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/lov/server

oafJava  'XXPHA' 'icx/sn1041/server' 'ActiveCartVOImpl.java' 

#----------------------------------------------------------------------------------------------
# SearchAM
oafJava  'XXPHA' 'icx/sn1041/server' 'SearchAMImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'SessionAMImpl.java' 
cp -r XXPHA/icx/sn1041/server/SearchAM.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/server.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

oafJava  'XXPHA' 'icx/sn1041/webui' 'Table5CO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'SearchResultsCO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'SearchHomeCO.java' '-encoding UTF-8'

echo "-- Install OAF artefacts - done"
fi
#----------------------------------------------------------------------------------------------
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'RequisitionItemsListPG.xml'
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'SearchHomePG.xml'

#----------------------------------------------------------------------------------------------
# OAF Pers
oafJava  'XXPHA' 'icx/sn1041/webui' 'xxPersEditSubmitCO.java' 

echo "---------------------------------------------------"
echo "Install of SN1041 completed ... Check it by the logs, please"