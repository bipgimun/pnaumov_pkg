#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		15.02.2021	SN1041-14
#==================================================================
read APPSID
echo "Start install SN1041 patch 11..."

# some debug flags
oaf_install="Y"

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_11.sql
echo "Install completed (SQL)..."

if [ "$oaf_install" = "Y" ]
then
echo "---------------------------------------------------"
echo "Start installing OAF-artefacts..."

cp -r XXPHA/icx/sn1041/server/SearchResultsVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/Table5SourceVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server
cp -r XXPHA/icx/sn1041/server/Table5SourceEO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

oafJava  'XXPHA' 'icx/sn1041/server' 'SearchResultsVORowImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'SearchResultsVOImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'SearchAMImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'Table5SourceEOImpl.java' 
oafJava  'XXPHA' 'icx/sn1041/server' 'Table5SourceVORowImpl.java' 

oafJava  'XXPHA' 'icx/sn1041/webui' 'Table5CO.java' '-encoding UTF-8'

oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'RequisitionItemsListEamPG.xml'
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'SearchHomeEAMPG.xml'

echo "-- Install OAF artefacts - done"
fi
echo "---------------------------------------------------"
echo "Install of SN1041 patch 11 completed ... Check it by the logs, please"