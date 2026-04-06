**free
ctl-opt Main(Main) option(*srcstmt) dftactgrp(*no);

dcl-pr Main extpgm('MSG_CHECK');
  *n char(1);   // found = Y, not found = N
end-pr;

dcl-proc Main;
  dcl-pi *n;
    MsgFound char(1);
  end-pi;

  exec sql WHENEVER NOT FOUND CONTINUE;

  MsgFound = 'N';

  exec sql
    SELECT 'Y' INTO :MsgFound
      FROM TABLE(
        QSYS2.MESSAGE_QUEUE_INFO(QUEUE_NAME => 'QSYSOPR', QUEUE_LIBRARY => 'QSYS')
      ) A
      WHERE MESSAGE_TEXT LIKE '%ERROR SSH SERVICE%'
      FETCH FIRST ROW ONLY;

end-proc;
