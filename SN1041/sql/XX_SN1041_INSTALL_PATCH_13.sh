#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE	    04.06.2021	SN1041-31
#==================================================================
read APPSID
echo "Start install SN1041 patch 13..."

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_13.sql
echo "Install completed (SQL)..."

echo "---------------------------------------------------"
echo "Install of SN1041 patch 13 completed ... Check it by the logs, please"