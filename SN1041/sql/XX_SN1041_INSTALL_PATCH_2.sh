#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		23.07.2020	SN1041
#==================================================================
read APPSID
echo "Start install SN1041 patch 2..."

download_extrafile 'OEBS_SN' 'SN976' 'sql' 'XX_SN976_ADD_IDX0.sql'

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_2.sql
echo "Install completed (SQL)..."

echo "---------------------------------------------------"
echo "Install of SN1041 patch 2 completed ... Check it by the logs, please"