parameter   FETCH1  =  4'b0001;
parameter   FETCH2  =  4'b0010;
parameter   FETCH3  =  4'b0011;
parameter   FETCH4  =  4'b0100;
parameter   DECODE  =  4'b0101;
parameter   MEMADR  =  4'b0110;
parameter   LBRD    =  4'b0111;
parameter   LBWR    =  4'b1000;
parameter   SBWR    =  4'b1001;
parameter   RTYPEEX =  4'b1010;
parameter   RTYPEWR =  4'b1011;
parameter   BEQEX   =  4'b1100;
parameter   JEX     =  4'b1101;
parameter   ADDIEX  =  4'b1110;
parameter   ADDIWR  =  4'b1111;

parameter   LB      =  6'b100000;
parameter   SB      =  6'b101000;
//Added by matutani
parameter   LW      =  6'b100011;
parameter   SW      =  6'b101011;
//
parameter   RTYPE   =  6'b0;
parameter   BEQ     =  6'b000100;
parameter   ADDI    =  6'b001000;
parameter   J       =  6'b000010;

parameter OP_WIDTH    = 6;
parameter INSTR_WIDTH = 32;
parameter EXMODE_WIDTH = 4;

