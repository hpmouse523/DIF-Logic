
 add_fsm_encoding \
       {SlaveFifoRead.presentstate} \
       { }  \
       {{000 000} {001 001} {010 010} {011 100} {100 011} {101 101} }

 add_fsm_encoding \
       {SlaveFifoWrite.presentstate} \
       { }  \
       {{000 000} {001 001} {010 011} {011 100} {100 101} {101 010} }
