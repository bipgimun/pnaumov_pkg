#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		23.11.2020	SN1041-10
#==================================================================
read APPSID
echo "Start install SN1041 patch 8..."

echo "Start installing view XXPHA_SN1041_ACTIVE_CART_V"
sqlplus apps/$APPSID @XX_SN1041_ACTIVE_CART_V.sql
echo "Install completed (view XXPHA_SN1041_ACTIVE_CART_V)..."

echo "---------------------------------------------------"
echo "Install of SN1041 patch 8 completed ... Check it by the logs, please"