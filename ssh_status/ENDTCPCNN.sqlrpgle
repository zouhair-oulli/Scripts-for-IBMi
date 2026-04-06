**free
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-pr qcmdexc extpgm('QCMDEXC');
   cmd char(500) const;
   cmdLen packed(15:5) const;
end-pr;

dcl-s localAddr     varchar(45);
dcl-s remoteAddr    varchar(45);
dcl-s localPort     int(10);
dcl-s remotePort    int(10);
dcl-s cmd           char(500);
dcl-s cmdLen        packed(15:5);

exec sql
    declare c1 cursor for
    select local_address, remote_address, local_port, remote_port
      from qsys2.netstat_info
     where local_port = 22 and remote_port != 0;

exec sql open c1;

dow sqlcode = 0;

    exec sql fetch c1 into :localAddr, :remoteAddr, :localPort, :remotePort;
    if sqlcode <> 0;
        leave;
    endif;

    // Build ENDTCPCNN command
    cmd = 'ENDTCPCNN PROTOCOL(*TCP) '
        + 'LCLINTNETA(''' + %trim(localAddr) + ''') '
        + 'LCLPORT(' + %char(localPort) + ') '
        + 'RMTINTNETA(''' + %trim(remoteAddr) + ''') '
        + 'RMTPORT(' + %char(remotePort) + ')';

    cmdLen = %len(%trimr(cmd));

    // Execute the command
    qcmdexc(cmd: cmdLen);

enddo;

exec sql close c1;
*inlr = *on;
