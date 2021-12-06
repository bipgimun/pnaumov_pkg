#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		08.08.2020	SN1041
#==================================================================
read APPSID
echo "Start install SN1041 patch 10..."

echo "---------------------------------------------------"
download_extrafile 'OEBS_EAM' 'EAM517' 'sql' 'XX_EAM517_PKG.sql'
echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @EAM517/sql/XX_EAM517_PKG.sql
sqlplus apps/$APPSID @XX_SN1041_EAM_PKG.pkb
sqlplus apps/$APPSID @XX_SN1041_LST_REQ_BSKT_PKG.pkb
echo "Install completed (SQL)..."

echo "---------------------------------------------------"
echo "Install of SN1041 patch 10 completed ... Check it by the logs, please"




#----------------------------------------------------------------------------------------------