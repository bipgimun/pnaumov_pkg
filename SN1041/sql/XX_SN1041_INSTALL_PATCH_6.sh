#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		19.11.2020	SN1041-10
#==================================================================
read APPSID
echo "Start install SN1041 patch 6..."

download_extrafile 'OEBS_COM' 'POR_CUSTOM' 'sql' 'POR_CUSTOM_PKG.sql'

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_6.sql
echo "Install completed (SQL)..."

echo "---------------------------------------------------"
echo "Install of SN1041 patch 6 completed ... Check it by the logs, please"