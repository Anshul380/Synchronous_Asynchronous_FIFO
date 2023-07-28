module tb_async;
reg  clk_wr , clk_rd, wrst ,rrst, wr_en, rd_en ;
reg[7:0] wr_data;
wire [7:0] rd_data;
wire full , empty ;
integer i ;


Async_fifo  af(rd_data,
						  full,
						  empty,
						  wr_data,
						  wr_en,clk_wr,wrst,
						   rd_en,clk_rd,rrst);

always begin

#10  clk_wr <= ~clk_wr ;

 
end

always begin

#35  clk_rd <= ~clk_rd ;
  

end


initial begin
clk_wr = 1'b0 ; wrst = 1'b1 ;
wr_en = 1'b0 ;
wr_data = 0 ;


repeat(10) @(posedge clk_wr);
   wrst = 1'b0 ;

   repeat(2) begin
    for(i=0 ; i<30 ; i=i+1) begin
	 @(posedge clk_wr )
	 wr_en = (i%2==0)?1'b1:1'b0;
	 if(wr_en)begin
	 wr_data = $random ;
	 
	 end
	 
	 end
	 #50 ;
	 
	 end

    end
	
initial begin
clk_rd = 1'b0 ; 
rd_en = 1'b0 ;
rrst = 1'b1;



repeat(10) @(posedge clk_wr);
     rrst = 1'b0 ;

   repeat(2) begin
    for(i=0 ; i<30 ; i=i+1) begin
	 @(posedge clk_rd )
	 rd_en = (i%2==0)?1'b1:1'b0;
	 
	 end
	 #50 ;
	 
	 end

    end	


endmodule 