PGM
/* &MSGFOUND is status of error message in QSYSOPR */
/* &ACTIVE is status of job QP0ZSPWP, 'Y' for YES, 'N' for NO */
             DCL        VAR(&MSGFOUND) TYPE(*CHAR) LEN(1)
             DCL        VAR(&ACTIVE) TYPE(*CHAR) LEN(1)

/* Call RPG program that is checking msgq QSYSOPR of library QSYS */
             CALL       PGM(ZO/MSG_CHECK) PARM(&MSGFOUND)

/* First condition : is there error "ERROR SSH SERVICE" in msgq QSYSOPR */
/* if error was found, SSH will restart and program will end */
             IF         COND(&MSGFOUND = 'Y') THEN(DO)
             CALL       PGM(ZO/SSH_RST)
             DLYJOB     DLY(5)
             WRKACTJOB  SBS(QUSRWRK) JOB(QP0ZSPWP)
             SNDPGMMSG  MSG('SSH service is restarted!')
             GOTO       CMDLBL(EXIT)
             ENDDO

/* Call RPG program that is checking the status of job QP0ZSPWP sbs QUSRWRK */
             CALL       PGM(ZO/JOB_STATUS) PARM('QUSRWRK' 'QP0ZSPWP' +
                          &ACTIVE)

/* Second condition : is the job QP0ZSPWP active */
/* if job is active, nothing to do / if job not found, restart SSH service */
             IF         COND(&ACTIVE = 'Y') THEN(DO)
             SNDPGMMSG  MSG('SSH service is active! No errors in +
                          QSYSOPR')
             WRKACTJOB  SBS(QUSRWRK) JOB(QP0ZSPWP)
             ENDDO
             ELSE       CMD(DO)
             CALL       PGM(ZO/SSH_RST)
             DLYJOB     DLY(5)
             SNDPGMMSG  MSG('SSH service is restarted!')
             WRKACTJOB  SBS(QUSRWRK) JOB(QP0ZSPWP)
             ENDDO
EXIT:
ENDPGM
