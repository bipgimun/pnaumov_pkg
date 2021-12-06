#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		20.10.2020	Jira: SN1041-8
#==================================================================
read APPSID
echo "Start install SN1041 patch 4..."

#download_extrafile 'OEBS_SN' 'SN976' 'sql' 'XX_SN976_ADD_IDX0.sql'

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_4.sql
echo "Install completed (SQL)..."


cp -r XXPHA/icx/sn1041/server/ReqStatusDetailVO.xml $JAVA_TOP/xxpha/oracle/apps/icx/sn1041/server

echo "---------------------------------------------------"
echo "Install of SN1041 patch 4 completed ... Check it by the logs, please"