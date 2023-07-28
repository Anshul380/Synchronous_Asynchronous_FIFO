module Synchronous_fifo #(parameter data_width = 10 , address_width = 4)

(input clk , input reset ,input w_enable, input read_enable,
 input[9:0] wr_data, output [9:0] r_data , output full , output empty  );
 

wire [address_width:0] wptr,rptr ;

wfull  full_logic( rptr, wptr,clk,reset, w_enable, full);
fifo_mem fifo(wr_data, r_data, wptr[address_width-1:0],rptr[address_width-1:0],clk ,full,w_enable,read_enable);
rempty empty_logic(clk , reset , read_enable, wptr, rptr, empty );



endmodule
//------------------------------------Memory implementation 

module fifo_mem #(parameter data_size =10,
parameter address_width = 4)

(input [data_size-1:0] wdata,output[data_size-1:0] rdata,
input[address_width-1:0] wptr,rptr,
input clk , wfull,winc,rinc);



localparam depth = 1<<address_width ;


reg [data_size-1:0] mem [0:depth-1] ;


always @(posedge clk )
    begin
	 if(!wfull && winc)
	 mem[wptr] <= wdata ;
	 
	 end
assign rdata = (rinc)? mem[rptr]:'bz;


endmodule


//-------------------------------------wfull


module wfull #(parameter address_size=4)
(input [address_size:0] rptr,
output reg [address_size:0]  wptr,
input   clk,reset, winc,
output reg wfull);

wire [address_size:0] wnext;
wire  wfull_value ;

always @(posedge clk or posedge reset)
   begin
	
	if(reset) begin
	wptr <= 0 ;

	
	end
	else
	wptr <= wnext[address_size:0] ; 
	
	end
	
assign wfull_value = ( {~wnext[address_size] , wnext[address_size-1:0]}) == (rptr) && !reset;
	
assign wnext = wptr + (~wfull & winc) ;

always @(posedge clk or posedge reset )
    begin
	 if(reset)
	    wfull<= 0 ;
	else 
	    wfull <=  wfull_value ;
	 
	 
	 
	 end





endmodule


//------------------------Empty


module rempty #(parameter address_size = 4)
(input clk , reset , rinc,
input[address_size:0] wptr,
output reg[address_size:0] rptr,
output reg rempty );

wire[address_size:0] rnext;
wire rempty_value ;

always @(posedge clk or posedge reset)
   if(reset)
	rptr <= 0 ;
	
	else
	rptr <= rnext[address_size:0] ;
	
assign rnext = rptr + (~rempty && rinc); 

assign rempty_value = (wptr == rptr)  ;


always @(posedge clk or posedge reset )
   begin
	if(reset)
	   
	rempty <= 1'b1 ;
	else 
   rempty <= rempty_value ; 
	
	
	end

endmodule

