--DROP TABLE xxpha_sn1041_run_req_lines
CREATE TABLE xxpha_sn1041_run_req_lines
(requisition_lines_id NUMBER
,status VARCHAR2(255)
,conc_request_id NUMBER
,created_by VARCHAR2(255)
,created_date DATE)
/
CREATE INDEX xxpha_sn1041_run_req_lines_N1 ON xxpha_sn1041_run_req_lines(requisition_lines_id)
/
CREATE INDEX xxpha_sn1041_run_req_lines_N2 ON xxpha_sn1041_run_req_lines(conc_request_id)
/
