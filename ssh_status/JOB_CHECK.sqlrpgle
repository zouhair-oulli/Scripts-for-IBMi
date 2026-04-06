**free
ctl-opt Main(Main) option(*srcstmt) dftactgrp(*no);

dcl-pr Main extpgm('JOB_STATUS');
  *n char(10);  // subsystem name
  *n char(10);  // job name
  *n char(1);   // active = Y, inactive = N
end-pr;

dcl-proc Main;
  dcl-pi *n;
    SbsName char(10);
    SbsJob char(10);
    JobActive char(1);
  end-pi;

  exec sql WHENEVER NOT FOUND CONTINUE;

  JobActive = 'N';

  exec sql
    SELECT 'Y' INTO :JobActive
      FROM TABLE(QSYS2.ACTIVE_JOB_INFO(SUBSYSTEM_LIST_FILTER => :SbsName)) A
      WHERE JOB_NAME LIKE CONCAT('%', RTRIM(:SbsJob))
      FETCH FIRST ROW ONLY;

end-proc;
