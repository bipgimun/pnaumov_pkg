#==================================================================
# MAIN CODE
# MODIFICATION HISTORY
# Person 	Date 		Comments
# MAE		02.11.2020	SN1041
#==================================================================
read APPSID
echo "Start install SN1041 patch 5..."

echo "---------------------------------------------------"
echo "-- Import FNDLOAD objects"
NLS_LANG_TEMP=$NLS_LANG;
export NLS_LANG_TEMP;
#NLS_LANG=Russian_CIS.CL8ISO8859P5;
NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251;
export NLS_LANG;
echo "NLS_LANG set before ldt upload to "$NLS_LANG 

# some DEBUG flags
oaf_install="Y"
sql_install="Y"

#if [ "$sql_install" = "Y" ]
#then
#echo "Start installing DB-objects (SQL / PLSQL)..."
#sqlplus apps/$APPSID @XX_SN1041_INSTALL_PATCH_3.sql
#echo "Install completed (SQL)..."
#fi

if [ "$oaf_install" = "Y" ]
then
oafPageXMLImport  'XXPHA' 'icx/sn1041/webui' 'SearchHomeEAMPG.xml'
echo "-- Install OAF artefacts - done"
fi



echo "---------------------------------------------------"
echo "Install of SN1041 patch 5 completed ... Check it by the logs, please"




#----------------------------------------------------------------------------------------------