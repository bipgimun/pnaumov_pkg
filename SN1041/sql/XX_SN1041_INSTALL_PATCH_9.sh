#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		01.12.2020	SN1041-10
#==================================================================
read APPSID
echo "Start install SN1041 patch 9..."

echo "Start installing package body XXPHA_SN1041_PKG"
sqlplus apps/$APPSID @XX_SN1041_PKG.pkb
echo "Install completed (package body XXPHA_SN1041_PKG)..."

echo "---------------------------------------------------"
echo "Install of SN1041 patch 9 completed ... Check it by the logs, please"