PGM                                                    
/* End all TCP remote connections on local port 22 */  
             CALL       PGM(ZO/ENDTCPCNN)              
                                                       
/* End SSH */                                          
             ENDTCPSVR  SERVER(*SSHD)                  
                                                                                                          
/* Delay for 30 seconds between end and start of SSH */
             DLYJOB     DLY(30)                        
                                                       
/* Start SSH */                                        
             STRTCPSVR  SERVER(*SSHD)                                                                         
ENDPGM
