create or replace view xxpha_sn1041_parameters_v as
with rp as
 (select max(cr.ACTUAL_COMPLETION_DATE) last_update,
         max(cr.ACTUAL_COMPLETION_DATE - cr.ACTUAL_START_DATE) max_update_time,
         avg(cr.ACTUAL_COMPLETION_DATE - cr.ACTUAL_START_DATE) avg_update_time
    from fnd_concurrent_requests cr, fnd_concurrent_programs cp
   where cr.CONCURRENT_PROGRAM_ID = cp.CONCURRENT_PROGRAM_ID
     and cp.CONCURRENT_PROGRAM_NAME = 'XXPHA_SN976_MVIEW_REFRESH'
     and cr.STATUS_CODE = 'C'),
comletion_estimate as
 (select min(nvl(cr.ACTUAL_START_DATE, cr.REQUESTED_START_DATE) + (select avg_update_time from rp)) GUESS
    from fnd_concurrent_requests cr, fnd_concurrent_programs cp
   where cr.CONCURRENT_PROGRAM_ID = cp.CONCURRENT_PROGRAM_ID
     and cp.CONCURRENT_PROGRAM_NAME = 'XXPHA_SN976_MVIEW_REFRESH'
     and cr.STATUS_CODE not in ('E', 'G', 'T', 'C', 'D', 'U', 'H', 'W')
  --and cr.PHASE_CODE in ('R', 'P')
  )
select ou.name,
       cast(null as number) as store_receiver,
       fnd_profile.value('XXPHA_SN1041_SERV_URL') SERV_URL,
       cast(null as varchar2(255)) store_name,
       ou.ORGANIZATION_ID,
       (select to_char(rp.last_update, 'dd.mm.yyyy hh24:mi') from rp) QUANTITY_LAST_UPDATE,
       (select to_char(ce.GUESS, 'dd.mm.yyyy hh24:mi')
          from comletion_estimate ce) QUANTITY_NEXT_UPDATE
  from xxpha_ou_v ou
 where 1 = 1
;
