module tb ();
reg clk, reset,w_enable,read_enable ;
reg [9:0] wr_data ;
wire[9:0] r_data ;
wire full , empty ;
integer i ;

Synchronous_fifo sf( clk ,  reset , w_enable,  read_enable,
  wr_data,  r_data ,   full , empty  );
  
 
always 
begin
  #5 clk = !clk  ;
end
initial begin
clk = 0 ;
reset = 1;
w_enable = 0 ;
read_enable = 0 ;
wr_data = 0 ;
 

repeat(10) @ (posedge clk) begin

    reset = 1'b0 ;  end
	 
	 repeat(2)begin
	 
	 for (i = 0 ; i<30 ; i=i+1)begin
	    @(posedge clk);
		 w_enable = (i%2 == 0)? 1'b1: 1'b0 ;
		 if(w_enable & !full) begin
		    wr_data = $random;
		 end
		 end
		 #50 ;
		 end
	 
	 
	 
	 
	 
	 
	 repeat(10) @ (posedge clk)

    reset = 1'b0 ;
	 
	 repeat(2)begin
	 
	 for ( i = 0 ; i<30 ; i=i+1)begin
	    @(posedge clk);
		 read_enable = (i%2 == 0)? 1'b1: 1'b0 ;
		
		 end
		 #50 ;
		 end
	 
	 end
	 
	 
	
	      
endmodule 