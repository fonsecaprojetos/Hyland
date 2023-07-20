SELECT DISTINCT lc.lcnum, lc.lifecyclename, wfst.statenum, lcs.statename, scj.schedjobnum,
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
ss.lastheartbeat-'03:00:00' as lastheartbeat, 
Conta.ItensOnQueue as ItensOnQueue
FROM hsi.lcxstate lcxs
JOIN hsi.lcstate lcs ON lcs.statenum = lcxs.statenum
JOIN hsi.wfschedulertask wfst ON wfst.statenum = lcxs.statenum
JOIN hsi.schedulertask sct ON sct.schedtasknum = wfst.schedtasknum
JOIN hsi.schedulerjob scj ON scj.schedtasknum = sct.schedtasknum
JOIN hsi.schedulerservice ss ON ss.schedservicenum = scj.execservicenum
LEFT JOIN (SELECT statenum, SUM(ItensOnQueue) as ItensOnQueue
FROM 
(SELECT ilc.statenum as statenum, COUNT(ilc.itemnum) as ItensOnQueue FROM hsi.itemlc ilc
GROUP BY statenum
UNION ALL
SELECT wilc.statenum as statenum, COUNT(wilc.contentnum) as ItensOnQueue FROM hsi.workitemlc wilc
GROUP BY statenum) U
GROUP BY statenum) Conta ON Conta.statenum = lcxs.statenum
--LEFT JOIN hsi.itemlc ilc ON ilc.statenum = lcxs.statenum
--LEFT JOIN hsi.workitemlc wilc ON wilc.statenum = lcxs.statenum
--JOIN hsi.schedulerworkerpool scwp ON scwp.workerpoolnum = scj.workerpoolnum
JOIN hsi.lifecycle lc ON lc.lcnum = lcxs.lcnum 
ORDER BY lcnum

