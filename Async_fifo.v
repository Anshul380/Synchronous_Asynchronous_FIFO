// top level

module Async_fifo #(parameter data_width = 8,
                    parameter address_width = 4)
						  (output [data_width-1:0] rdata,
						  output  wfull,
						  output rempty,
						  input[data_width-1:0] wdata,
						  input  winc,wclk,wrst,
						  input  rinc,rclk,rrst);
						  
						  
wire[address_width-1:0] waddr,raddr;
wire[address_width:0]  wptr,rptr,wq2_rptr,rq2_wptr;



sync_r2w sr2w( wq2_rptr, wclk, wrst, rptr);
sync_w2r sw2r( rq2_wptr, rclk, rrst, wptr);


fifmem fifo(rdata, wdata, waddr,raddr, wclk,winc,wfull);


rptr_empty r_empty(rempty,raddr, rptr, rq2_wptr, rinc,rclk,rrst) ;


 wptr_full wfull_r(wfull, waddr, wptr, wq2_rptr,winc, wclk , wrst); 



endmodule


//-------------------------------------------------------//
// Memory implementation

module fifmem #(parameter data_width = 8,
parameter address_width = 4)
(output [data_width-1:0] rdata,
input[data_width-1:0] wdata,
input[address_width-1:0] waddr,raddr,
input wclk,wclken,wfull);

localparam depth = 1<<address_width;
reg[data_width-1:0] mem[0:depth-1] ;

assign rdata= mem[raddr];

always @(posedge wclk)
if(wclken && !wfull)
  begin
  mem[waddr] <= wdata; 
  end
  
endmodule
//----------------------------------------------------------------//
// synchronize read and write

module sync_r2w #(parameter addr_width=4)
  (output reg [addr_width:0] wq2_rptr,
  input wclk, wrst,
input [addr_width:0] rptr);

reg[addr_width:0] wq1_rptr;
always @(posedge wclk or posedge wrst )
   if(wrst)
	{wq2_rptr,wq1_rptr} <=0;
	else
	{wq2_rptr,wq1_rptr}  <= {wq1_rptr,rptr};


endmodule




module sync_w2r #(parameter addr_width=4)
  (output reg [addr_width:0] rq2_wptr,
  input rclk, rrst,
input [addr_width:0] wptr);

reg[addr_width:0] rq1_wptr;
always @(posedge rclk or posedge rrst )
   if(rrst)
	{rq2_wptr,rq1_wptr} <=0;
	else
	{rq2_wptr,rq1_wptr}  <= {rq1_wptr,wptr};


endmodule


//-------------------------------
//empty


module rptr_empty #(parameter address_width = 4)
(output reg rempty,
output[address_width-1:0] raddr,
output reg [address_width:0] rptr,
input  [address_width :0] rq2_wptr,
input rinc,rclk,rrst) ;

reg [address_width:0] rbin;
wire [address_width:0] rgray_next,rbin_next ;


always @(posedge rclk or posedge rrst)
    if(rrst) {rbin,rptr} <= 0 ;
	 else {rbin,rptr} <= {rbin_next, rgray_next};






assign raddr = rbin[address_width-1:0];


assign rbin_next = rbin + (rinc& ~rempty);

assign rgray_next = (rbin_next>>1)^rbin_next;


always @(posedge rclk or posedge rrst) begin
  if(rrst) rempty <= 1'b1;
  else rempty <= {rgray_next==rq2_wptr};

end
endmodule

//-------------------------------------------------
//full

module wptr_full #(parameter address_width = 4)
(output reg wfull,
output[address_width-1:0] waddr,
output reg [address_width:0] wptr,
input[address_width :0] wq2_rptr,
input   winc, wclk , wrst); 

reg [address_width:0] wbin;
wire [address_width:0] wgray_next,wbin_next;
wire wfull_value ;

always @(posedge wclk, posedge wrst)
   if(wrst)
	  {wbin, wptr} <= 0 ;
	 else
	 {wbin,wptr} <= {wbin_next,wgray_next};
	 
assign waddr = wbin[address_width-1:0];

assign wbin_next = wbin +(winc & ~wfull);

assign wgray_next = (wbin_next>>1)^wbin_next ;


assign  wfull_value =(wgray_next[address_width] !=wq2_rptr[address_width])  &&
                      (wgray_next[address_width-1] !=wq2_rptr[address_width-1]) &&
							 (wgray_next[address_width-2:0] ==wq2_rptr[address_width-2:0]);
							 
always @(posedge wclk  or posedge wrst)
   if(wrst)
	   wfull <= 1'b0 ;
	else 
	 wfull <= wfull_value ;
 
endmodule
