module sqrt(A, oper, clk, rem, reset, done, result); 
 input [15:0] A; 
 input clk, reset, oper; 
 output reg[7:0] result; 
 output reg done; 
 reg [15:0] cnt1; 
 reg [7:0] cnt2; 
 reg[15:0] rb; 
 reg [15:0] ra; 
 output reg [8:0] rem; //cmp 
   
 wire x1, x2, x3; 
 wire y1, y2, y3, y4, y5;                                     
 reg [2:0] st, nst;  
 parameter s0 = 3'd0, s1 = 3'd1, s2 = 3'd2, s3 = 3'd3, s4=3'd4,s5=3'd5;  
  
//fsm 
 always @(negedge clk or negedge reset) 
 if(!reset) st<=s0; 
 else st<=nst; 
    
//next_state 
       always @(*) 
       begin 
          case(st) 
               s0: nst = x1 ? s1: s0; 
               s1: nst=s2; 
               s2: nst=s3; 
               s3: nst = x2?s5:s4; 
               s4: nst = s3; 
               s5: nst = x1?s3:s0; 
               default: nst=s0;  
                   endcase 
                 end 
                   //output logic 
           assign y1 = (st == s1);//ra=A; cnt1=cnt2=1;  
           assign y2 = (st == s2);//rb=ra 
           assign y3 = (st == s3);//rb=rb-cnt1 
            assign y4 = (st == s4);cnt1=cnt1+2; cnt2=cnt2+1; 
            assign y5=(st==s5); 
        
//ra 
 always @(posedge clk) 
  if(y1) ra <= A; 
  else if(y2) ra <= ra-cnt1; 

//rb 
always@(posedge clk) 
if(y2)rb<=ra; 
else if(y3) rb<= rb-cnt1; 
 
//cnt1 
 always @(posedge clk) 
  if(y1) cnt1 <= 1; 
  else if(y4) cnt1<=cnt1+2; 
 
//cnt2 
 always @(posedge clk) 
  if(y1) cnt2 <= 1; 
  else if(y4) cnt2 <= cnt2 + 1; 

//done 
   always @(posedge clk) 
    if(y1) done <= 0; 
    else done <= y5; 
 
 //FSM inputs 
      assign x2=(rb<cnt1); 
      assign x1=oper; 
//results 
 always@(posedge clk) 
 if(y1) begin result<=0;rem<=0; end 
else if(y5) begin result<= cnt2; 
 rem<=rb[8:0]; 
 end 
endmodule 

module test_bench; 
 reg[15:0] A; 
 reg clk, reset, oper; 
 wire[7:0] result; 
 wire[8:0] rem; 
 wire done; 
 
  sqrt  Mart_Sero(A, oper, clk, rem, reset, done, result); 
  initial begin 
   clk = 0; reset = 0; oper = 0; 
   #11 reset = 1; A = 1000; 
   #5 oper = 1; 
   #10 wait(done); 
   #5 oper = 0; 
   #5 A = 100; 
   #10 oper = 1; 
   #10 wait(done); 
   #5 oper = 0;  
    #5 A = 121; 
     #10 oper = 1; 
     #10 wait(done); 
     #5 oper = 0;  
     #5 A = 10; 
     #10 oper = 1; 
     #10 wait(done); 
     #5 oper = 0;  
      #5 A = 1; 
           #10 oper = 1; 
           #10 wait(done); 
           #5 oper = 0;  #5 A = 1609; 
           #10 oper = 1; 
           #10 wait(done); 
           #5 oper = 0;  
 #30 $finish; 
  end 
  always #7 clk = ~clk; 
endmodule 