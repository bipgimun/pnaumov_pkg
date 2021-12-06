--DROP TABLE xxpha_sn1041_run_req_lines
CREATE OR REPLACE VIEW xxpha_sn1041_run_req_lines_v
AS 
SELECT * FROM xxpha_sn1041_run_req_lines  rl
WHERE NVL(rl.created_by, 'ANONIM') = NVL(fnd_global.USER_NAME, 'ANONIM')
/
