SELECT * FROM hsi.lifecycle
--lifecyclename, lcnum,wfcontenttype*
SELECT * FROM hsi.lcxstate
--statenum, lcnum
SELECT * FROM hsi.itemlc
--lcnum, itemnum, statenum
SELECT * FROM hsi.lcstate
--statenum, statename
SELECT * FROM hsi.workitemlc
--lcnum, statenum, contentnum
SELECT * FROM hsi.schedulertask
--schedtasknum
SELECT * FROM hsi.schedulerjob
--schedjobnum, schedtasknum, lastexecutionend, nextexecutionstart, execservicenum
SELECT * FROM hsi.wfschedulertask
--schedtasknum, statenum
SELECT * FROM hsi.schedulerservice
--schedservicenum, schedservicename, workerpoolnum
SELECT * FROM hsi.schedulerworkerpool
--workerpoolnum, workerpoolname, flags

SELECT lc.lcnum, lc.lifecyclename, wfst.statenum, lcs.statename, scj.schedjobnum,
(CASE scj.jobstatus
WHEN 0 THEN 'None'
WHEN 1 THEN 'ReadyFirstExecution '
WHEN 2 THEN 'Disabling'
WHEN 3 THEN 'Ready'
WHEN 4 THEN 'Executing'
WHEN 5 THEN 'Expired' 
WHEN 6 THEN 'Error'
WHEN 7 THEN 'Disabled'
WHEN 8 THEN 'Cancelling'
WHEN 9 THEN 'Cancelled' 
END) as JobStatus,
ss.schedservicename,
DATEDIFF(MINUTE, (ss.lastheartbeat - '03:00:00'), GETDATE()) as ServiceHeartBeatDiff,
(CASE WHEN DATEDIFF(MINUTE, (ss.lastheartbeat - '03:00:00'), GETDATE()) >= 2 THEN 'Serviço Parado' ELSE 'Serviço Rodando' END) as ServiceStatus,
ss.lastheartbeat-'03:00:00' as lastheartbeat

FROM hsi.lcxstate lcxs
JOIN hsi.lifecycle lc ON lc.lcnum = lcxs.lcnum 
JOIN hsi.lcstate lcs ON lcs.statenum = lcxs.statenum
JOIN hsi.wfschedulertask wfst ON wfst.statenum = lcxs.statenum
JOIN hsi.schedulertask sct ON sct.schedtasknum = wfst.schedtasknum
JOIN hsi.schedulerjob scj ON scj.schedtasknum = sct.schedtasknum
JOIN hsi.schedulerservice ss ON ss.schedservicenum = scj.execservicenum
--JOIN hsi.schedulerworkerpool scwp ON scwp.workerpoolnum = scj.workerpoolnum
