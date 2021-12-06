create or replace package XXPHA_SN1041_INNER_REQ_PKG IS  
  FUNCTION concat_to_list(p_concat VARCHAR2) RETURN fnd_table_of_number;     
  FUNCTION call_conc(p_requisition_lines_id_list fnd_table_of_number) return VARCHAR2;
  PROCEDURE MAIN(x_errbuf                  OUT NOCOPY VARCHAR2,
                 x_retcode                 OUT NOCOPY NUMBER,                                     
                 p_req_lines_id_concat      in VARCHAR2                                      
                 );
  FUNCTION run_conc return VARCHAR2;
  FUNCTION add_rows(p_requisition_lines_id_list fnd_table_of_number) return VARCHAR2;              
                 
                 
end XXPHA_SN1041_INNER_REQ_PKG;
/
create or replace package body XXPHA_SN1041_INNER_REQ_PKG IS

  C_NEW CONSTANT VARCHAR2(100):= 'NEW';
  C_DELIMITER CONSTANT VARCHAR2(100):= ', ';
  C_ADD_ROW_SUCC CONSTANT VARCHAR2(100):= 'Строки успешно отобраны';

  PROCEDURE log(p_mess VARCHAR2, p_mode VARCHAR2 DEFAULT NULL) IS 
  BEGIN 
    xxpha_log(p_mess, p_mode);
  END;

  FUNCTION get_req_line_concat(p_list fnd_table_of_number) RETURN VARCHAR2 IS 
    v_concat VARCHAR2(4000);
  BEGIN 
    SELECT listagg(COLUMN_VALUE, C_DELIMITER) WITHIN GROUP (ORDER BY COLUMN_VALUE) conc 
    INTO v_concat
    FROM (
         SELECT DISTINCT COLUMN_VALUE
         FROM TABLE(p_list))
    WHERE 1=1
    --Проверка есть ли такие строки уже в обработке
    AND NOT EXISTS (
    SELECT * 
    FROM xxpha_sn1041_run_req_lines_v rrl
    WHERE rrl.requisition_lines_id = COLUMN_VALUE);
    
   RETURN v_concat;
  END get_req_line_concat;
  
  FUNCTION concat_to_list(p_concat VARCHAR2) RETURN fnd_table_of_number IS 
    v_list_of_number fnd_table_of_number;
  BEGIN 
    select regexp_substr(cc.str, '[^'||C_DELIMITER||']+', 1, level)
    BULK COLLECT INTO v_list_of_number
    from (SELECT p_concat str from dual) cc
    connect by instr(str, C_DELIMITER, 1, level-1 ) > 0;
   RETURN v_list_of_number;
  END concat_to_list; 

  PROCEDURE MAIN(x_errbuf                  OUT NOCOPY VARCHAR2,
                 x_retcode                 OUT NOCOPY NUMBER,                                     
                 p_req_lines_id_concat      in VARCHAR2                                      
                 ) IS
   v_requisition_lines_id_list fnd_table_of_number;                 
  BEGIN 
  
    v_requisition_lines_id_list:= concat_to_list(p_req_lines_id_concat);
    BEGIN     
    XXPHA_SN964_UTILS_PKG.Create_inv_itemsfrom_temp(errbuf                      => x_errbuf,
                                                    retcode                     => x_retcode,
                                                    p_requisition_header_id     => NULL,
                                                    p_requisition_lines_id_list => v_requisition_lines_id_list);
    EXCEPTION
      WHEN OTHERS THEN 
        log ('Ошибка при работе XXPHA_SN964_UTILS_PKG.Create_inv_itemsfrom_temp', 'E');
    END;  
      
   DELETE  xxpha_sn1041_run_req_lines l
   WHERE l.conc_request_id = fnd_global.CONC_REQUEST_ID;   
   COMMIT;                                            
  END MAIN;                


  FUNCTION call_conc(p_requisition_lines_id_list fnd_table_of_number) return VARCHAR2 IS 
    v_return_mess VARCHAR2(4000);
  BEGIN 
   v_return_mess:= add_rows(p_requisition_lines_id_list);
   
   IF v_return_mess = C_ADD_ROW_SUCC THEN 
     v_return_mess:= run_conc;
   END IF;    
  
    RETURN v_return_mess;
  END call_conc;
  
  
  FUNCTION add_rows(p_requisition_lines_id_list fnd_table_of_number) return VARCHAR2 IS 
    v_return_mess VARCHAR2(4000);
    v_req_lines_id_concat VARCHAR2(4000);    
  BEGIN 
    v_req_lines_id_concat:= get_req_line_concat(p_requisition_lines_id_list);
    IF v_req_lines_id_concat IS NOT NULL THEN 
        INSERT INTO xxpha_sn1041_run_req_lines 
       (SELECT COLUMN_VALUE, C_NEW, -1, fnd_global.USER_NAME, SYSDATE
        FROM TABLE(XXPHA_SN1041_INNER_REQ_PKG.concat_to_list(v_req_lines_id_concat)));
     COMMIT;
     v_return_mess:= C_ADD_ROW_SUCC;
    ELSE 
      v_return_mess:= 'Нет строк для отбора. Или выбранные строки уже отобраные ранее';
    END IF;
    RETURN v_return_mess;
  END add_rows;
  
  
  FUNCTION run_conc return VARCHAR2 IS 
    v_return_mess VARCHAR2(4000);
    v_req_lines_id_concat VARCHAR2(4000);
    v_request_id NUMBER;
  BEGIN 
    --v_req_lines_id_concat:= get_req_line_concat(p_requisition_lines_id_list);
    
    SELECT listagg(rl.requisition_lines_id, C_DELIMITER) within GROUP (ORDER BY rl.requisition_lines_id)
    INTO v_req_lines_id_concat
    FROM (SELECT DISTINCT rl.requisition_lines_id 
          FROM xxpha_sn1041_run_req_lines_v rl
          WHERE rl.status = C_NEW) rl
    WHERE 1=1;
    
    IF v_req_lines_id_concat IS NOT NULL THEN 
        v_request_id:= fnd_request.submit_request ( application      => 'XXPHA'
                                                   ,program          => 'XXPHA_SN1041_INNER_REQ'
                                                   ,argument1        => v_req_lines_id_concat --Number of Instances
                                                   );  
        --Защита от повторного запуска       
        UPDATE  xxpha_sn1041_run_req_lines_v rl
        SET rl.status = 'RUN'                                    
           ,rl.conc_request_id = v_request_id
        WHERE 1=1
          AND rl.status = C_NEW;
          
     COMMIT;
     v_return_mess:= 'Запущено создание внутренней заявки. Номер запроса '||v_request_id;
    ELSE 
      v_return_mess:= 'Нет строк для запуска';
    END IF;
    RETURN v_return_mess;
  END run_conc;

end XXPHA_SN1041_INNER_REQ_PKG;
/
