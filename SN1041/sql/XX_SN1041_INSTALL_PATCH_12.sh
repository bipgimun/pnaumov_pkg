#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		25.03.2021	SN1041-25
#==================================================================
read APPSID
echo "Start install SN1041 patch 12..."

# some debug flags
oaf_install="Y"

echo "Start installing DB-objects (SQL / PLSQL)..."
sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_12.sql
echo "Install completed (SQL)..."

if [ "$oaf_install" = "Y" ]
then
echo "---------------------------------------------------"
echo "Start installing OAF-artefacts..."

oafJava  'XXPHA' 'icx/sn1041/server' 'SearchResultsVORowImpl.java' '-encoding UTF-8' 

echo "-- Install OAF artefacts - done"
fi

chmod 755 XXPHA/HTML/sn1041/sn1041.js
cp -r XXPHA/HTML/sn1041/sn1041.js $OA_HTML/sn1041/sn1041.js

echo "---------------------------------------------------"
echo "Install of SN1041 patch 12 completed ... Check it by the logs, please"