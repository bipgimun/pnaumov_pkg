#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		20.11.2020	SN1041-12
#==================================================================
read APPSID
echo "Start install SN1041 patch 7..."

oafJava  'XXPHA' 'icx/sn1041/server' 'SearchResultsVOImpl.java'
cp -r XXPHA/icx/sn1041/server/SearchResultsVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'SearchHomeEAMPG.xml'

oafJava  'XXPHA' 'icx/sn1041/webui' 'StatusDetailedCO.java' '-encoding UTF-8'
oafJava  'XXPHA' 'icx/sn1041/webui' 'SearchHomeCO.java' '-encoding UTF-8'

oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'RequisitionItemsListEamPG.xml'

echo "---------------------------------------------------"
echo "Install of SN1041 patch 7 completed ... Check it by the logs, please"