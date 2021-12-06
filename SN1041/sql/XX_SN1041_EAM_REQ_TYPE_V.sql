create or replace view xxpha_sn1041_eam_req_type_v as
select case f.FLEX_VALUE
       when '5' then '1.05'
       when '9' then '1.09'
       when '10' then '1.10'
       else f.FLEX_VALUE
       end REQUISITION_TYPE
     , case f.FLEX_VALUE
       when '1' then 'В закупку'
       else f.DESCRIPTION
       end DESCRIPTION
     , f.FLEX_VALUE
from xxpha_flex_values_v f
where f.FLEX_VALUE_SET_NAME = 'XXPHA_REQ_TYPE_VALUESET'
and f.FLEX_VALUE in (1,2,6,5,9,10)
order by REQUISITION_TYPE;
