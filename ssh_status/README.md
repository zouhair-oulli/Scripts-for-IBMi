# Program to check the status of SSH and take action
The objective of these programs (written in RPG Free-Form and CL) is to run a program that checks whether the SSH service is active. Depending on the status of the SSH job, the program should either inform the user that the SSH service is running or restart it.

## [MSG_CHECK.sqlrpgle](https://github.com/zouhair-oulli/Scripts-for-IBMi/blob/main/ssh_status/MSG_CHECK.sqlrpgle)
This RPG Free-Form program is using the table “QSYS2.MESSAGE_QUEUE_INFO” to check the existence of the error message “ERROR SSH SERVICE” in the message queue “QSYSOPR” of the library “QSYS”.

💡 Check the existence of the message X in message queue X of library X
`SELECT * FROM TABLE(QSYS2.MESSAGE_QUEUE_INFO(QUEUE_NAME => 'X', QUEUE_LIBRARY => 'X')) WHERE MESSAGE_TEXT LIKE '%X%'`

## [JOB_CHECK.sqlrpgle](https://github.com/zouhair-oulli/Scripts-for-IBMi/blob/main/ssh_status/JOB_CHECK.sqlrpgle)
This RPG Free-Form program is using the view “QSYS2.ACTIVE_JOB_INFO” to determine if a the job X in the subsystem X is active.

## [ENDTCPCNN.sqlrpgle](https://github.com/zouhair-oulli/Scripts-for-IBMi/blob/main/ssh_status/ENDTCPCNN.sqlrpgle)
This RPG Free-Form program is using the view “QSYS2.NETSTAT_INFO” to extract all local/remote connections (IP + port) and use ENDTCPCNN command on them.

💡 Check the number of remote connections at local port X
IBM i: `STRSQL à SELECT count(*) FROM QSYS2/NETSTAT_INFO WHERE LOCAL_PORT ='22' and REMOTE_PORT != '0'`
ACS: `SELECT count(*) FROM QSYS2.NETSTAT_INFO WHERE LOCAL_PORT ='22' and REMOTE_PORT != '0'`

💡 Check the port number and IP addresses of remote connections at local port X
`SELECT * FROM QSYS2.NETSTAT_INFO WHERE LOCAL_PORT ='22' and REMOTE_PORT != '0';`

## [SSH_RST.clp](https://github.com/zouhair-oulli/Scripts-for-IBMi/blob/main/ssh_status/SSH_RST.clp)
This CL program is using the RPG Free-Form program “ENDTCPCNN.sqlrpgle” to end all TCP connections and to restart the SSH service.

## [SSH_STATUS.clp (main program)](https://github.com/zouhair-oulli/Scripts-for-IBMi/blob/main/ssh_status/SSH_STATUS.clp)
This CL program is regrouping all CL and RPG Free-Form programs seen up this page (MSG_CHECK.sqlrpgle + JOB_CHECK.sqlrpgle + ENDTCPCNN.sqlrpgle + SSH_RST.clp).

## SSH_STATUS.cmd
We can create a customized command
`CRTSRCPF FILE(ZO/QCMDSRC) TEXT('Source PF - CMD')` → create CMD source physical file  
`CMD PROMPT('Check status of SSH')`

`CRTCMD CMD(QGPL/SSH_RST) PGM(ZO/SSH_RST) SRCFILE(ZO/QCMDSRC)` → Create Command  
`SSH_STATUS` → run the program
