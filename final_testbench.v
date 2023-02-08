`include "timescale.v"

module test;
reg		clk;
reg		rd_clk, wr_clk;
reg		rst;
integer		n,x1,x,rwd1,rwd;
reg		we2, re2;
reg	[7:0]	din2;
wire	[7:0]	dout2;
wire		full2, empty2;
wire		full_r2, empty_r2;
wire		full_n2, empty_n2;
wire		full_n_r, empty_n_r;
wire	[1:0]	level2;

reg		we1, re1;
reg	[7:0]	din1;
reg		clr;
wire	[7:0]	dout1;
wire		full1, empty1;
wire		full_n1, empty_n1;
wire	[1:0]	level1;


reg	[7:0]	buffer[0:1024000];
integer		wrp,rdp,wrp1,rdp1;
real		rcp,rcp1;
initial begin
	$dumpfile("dump.vcd");
	$dumpvars;
end
initial
   begin
	$timeformat (-9, 1, " ns", 12);

`ifdef WAVES
  	$shm_open("waves");
	$shm_probe("AS",test,"AS");
	$display("INFO: Signal dump enabled ...\n\n");
`endif
	rcp=5;
	rcp1=5;
   	clk = 0;
   	rd_clk = 0;
   	wr_clk = 0;
   	rst = 1;

	we2 = 0;
	re2 = 0;
	clr = 0;

	we1 = 0;
	re1 = 0;
	rwd=0;
	rwd1=0;
	wrp=0;
	rdp=0;
	rwd1=0;wrp1=0;rdp1=0;

   	repeat(10)	@(posedge clk);
   	rst = 0;
   	repeat(10)	@(posedge clk);
   	rst = 1;
   	repeat(10)	@(posedge clk);


	if(1)
	   begin
		test_sc_fifo;
		test_dc_fifo;
	   end
	else
	   begin

		rwd1=4;
		wr_dc(100);
		rd_dc(100);
		wr_dc(100);
		rd_dc(100);

	   end


   	repeat(200)	@(posedge clk);

$display("rdp1=%0d, wrp1=%0d delta1=%0d", rdp1, wrp1, wrp1-rdp1);

   	$finish;
   end





task test_dc_fifo;
begin


$display("\n\n");
$display("*****************************************************");
$display("*** DC FIFO Sanity Test                           ***");
$display("*****************************************************\n");

for(rwd1=0;rwd1<5;rwd1=rwd1+1)	// read write delay
for(rcp1=10;rcp1<50;rcp1=rcp1+10.0)
   begin
	$display("rwd1=%0d, rcp1=%0f",rwd1, rcp1);

	$display("pass 0 ...");
	for(x1=0;x1<10;x1=x1+1)
	   begin
		rd_wr_dc;
		wr_dc(1);
	   end
	$display("pass 1 ...");
	for(x1=0;x<10;x1=x1+1)
	   begin
		rd_wr_dc;
		rd_dc(1);
	   end
	$display("pass 2 ...");
	for(x1=0;x1<10;x1=x1+1)
	   begin
		rd_wr_dc;
		wr_dc(1);
	   end
	$display("pass 3 ...");
	for(x1=0;x1<10;x1=x1+1)
	   begin
		rd_wr_dc;
		rd_dc(1);
	   end
   end

$display("");
$display("*****************************************************");
$display("*** DC FIFO Sanity Test DONE                      ***");
$display("*****************************************************\n");
end
endtask


task test_sc_fifo;
begin

$display("\n\n");
$display("*****************************************************");
$display("*** SC FIFO Sanity Test                           ***");
$display("*****************************************************\n");

for(rwd1=0;rwd1<5;rwd1=rwd1+1)	// read write delay
   begin
	$display("rwd=%0d",rwd1);
	$display("pass 0 ...");
	for(x=0;x<10;x=x+1)
	   begin
		rd_wr_sc;
		wr_sc(1);
	   end
	$display("pass 1 ...");
	for(x=0;x<10;x=x+1)
	   begin
		rd_wr_sc;
		rd_sc(1);
	   end
	$display("pass 2 ...");
	for(x=0;x<10;x=x+1)
	   begin
		rd_wr_sc;
		wr_sc(1);
	   end
	$display("pass 3 ...");
	for(x=0;x<10;x=x+1)
	   begin
		rd_wr_sc;
		rd_sc(1);
	   end
   end

$display("");
$display("*****************************************************");
$display("*** SC FIFO Sanity Test DONE                      ***");
$display("*****************************************************\n");

end
endtask

///////////////////////////////////////////////////////////////////
//
// Data tracker
//

/*always @(posedge clk)
	if(we2 & !full2)
	   begin
		buffer[wrp] = din2;
		wrp=wrp+1;
	   end

always @(posedge clk)
	if(re2 & !empty2)
	   begin
		#3;
		if(dout2 != buffer[rdp])
			$display("ERROR: Data (%0d) mismatch, expected %h got %h (%t)",
			 rdp, buffer[rdp], dout2, $time);
		rdp=rdp+1;
	   end

always @(posedge wr_clk)
	if(we1 & !full1)
	   begin
		buffer[wrp1] = din1;
		wrp1=wrp+1;
	   end

always @(posedge rd_clk)
	if(re1 & !empty1)
	   begin
		#3;
		if(dout1 != buffer[rdp1] | ( ^dout1 )===1'bx)
			$display("ERROR: Data (%0d) mismatch, expected %h got %h (%t)",
			 rdp1, buffer[rdp1], dout1, $time);
		rdp1=rdp1+1;
	   end
*/
///////////////////////////////////////////////////////////////////
//
// Clock generation
//

always #5 clk = ~clk;
always #(rcp1) rd_clk = ~rd_clk;
always #50 wr_clk = ~wr_clk;

///////////////////////////////////////////////////////////////////
//
// Module Instantiations
//


generic_fifo_dc #(8,8,9) u1(
		.rd_clk(	rd_clk		),
		.wr_clk(	wr_clk		),
		.rst(		rst		),
		.clr(		clr		),
		.din(		din1		),
		.we(		(we1 & !full1)	),
		.dout(		dout1		),
		.re(		(re1 & !empty1)	),
		.full(		full1		),
		.empty(		empty1		),
		.full_n(	full_n1		),
		.empty_n(	empty_n1	),
		.level(		level1		)
		);

generic_fifo_sc_a #(8,8,9) u0(
		.clk(		clk		),
		.rst(		rst		),
		.clr(		clr		),
		.din(		din2		),
		.we(		(we2 & !full2)	),
		.dout(		dout1		),
		.re(		(re2 & !empty2)	),
		.full(		full2		),
		.empty(		empty2		),
		.full_r(	full_r2		),
		.empty_r(	empty_r2		),
		.full_n(	full_n2		),
		.empty_n(	empty_n2		),
		.full_n_r(	full_n_r	),
		.empty_n_r(	empty_n_r	),
		.level(		level2		)
		);
task wr_dc;
input	cnt;
integer	n, cnt;
begin
@(posedge wr_clk);
for(n=0;n<cnt;n=n+1)
   begin
	#1;
	we1 = 1;
	din1 = $random;
	@(posedge wr_clk);
	#1;
	we1 = 0;
	din1 = 8'hxx;
	repeat(rwd1)	@(posedge wr_clk);
   end
end
endtask


task rd_dc;
input	cnt;
integer	n, cnt;
begin
@(posedge rd_clk);
for(n=0;n<cnt;n=n+1)
   begin
	#1;
	re1 = 1;
	@(posedge rd_clk);
	#1;
	re1 = 0;
	repeat(rwd1)	@(posedge rd_clk);
   end
end
endtask


task rd_wr_dc;

integer		n;
begin
   		repeat(10)	@(posedge wr_clk);
		// RD/WR 1
		for(n=0;n<5;n=n+1)
		   fork

			begin
				wr_dc(1);
			end

			begin
				@(posedge wr_clk);
				@(posedge wr_clk);
				rd_dc(1);
			end

		   join

   		repeat(50)	@(posedge wr_clk);

		// RD/WR 2
		for(n=0;n<5;n=n+1)
		   fork

			begin
				wr_dc(2);
			end

			begin
				@(posedge wr_clk);
				@(posedge wr_clk);
				@(posedge wr_clk);
				rd_dc(2);
			end

		   join



		// RD/WR 3
		for(n=0;n<5;n=n+1)
		   fork

			begin
				wr_dc(3);
			end

			begin
				@(posedge wr_clk);
				@(posedge wr_clk);
				@(posedge wr_clk);
				@(posedge wr_clk);
				rd_dc(3);
			end

		   join

   		repeat(50)	@(posedge wr_clk);


		// RD/WR 4
		for(n=0;n<5;n=n+1)
		   fork

			begin
				wr_dc(4);
			end

			begin
				@(posedge wr_clk);
				@(posedge wr_clk);
				@(posedge wr_clk);
				@(posedge wr_clk);
				@(posedge wr_clk);
				rd_dc(4);
			end

		   join
   		repeat(50)	@(posedge wr_clk);
end
endtask




task wr_sc;
input	cnt;
integer	cnt;

begin
@(posedge clk);
	for(n=0;n<cnt;n=n+1)
	   begin
		//@(posedge clk);
		#1;
		we2 = 1;
		din2 = $random;
		@(posedge clk);
		#1;
		we2 = 0;
		din2 = 8'hxx;
		repeat(rwd)	@(posedge clk);
	   end
end
endtask


task rd_sc;
input	cnt;
integer	cnt;

begin
@(posedge clk);
	for(n=0;n<cnt;n=n+1)
	   begin
		//@(posedge clk);
		#1;
		re2 = 1;
		@(posedge clk);
		#1;
		re2 = 0;
		repeat(rwd)	@(posedge clk);
	   end
end
endtask


task rd_wr_sc;

begin
   		repeat(10)	@(posedge clk);
		// RD/WR 1
		for(n=0;n<5;n=n+1)
		   begin
			@(posedge clk);
			#1;
			re2= 0;
			we2 = 1;
			din2 = $random;
			@(posedge clk);
			#1;
			we2 = 0;
			din2 = 8'hxx;
			re2 = 1;
		   end
		@(posedge clk);
		#1;
		re2 = 0;

   		repeat(10)	@(posedge clk);

		// RD/WR 2
		for(n=0;n<5;n=n+1)
		   begin
			@(posedge clk);
			#1;
			we2 = 1;
			din2 = $random;
			@(posedge clk);
			#1;
			din2 = $random;
			@(posedge clk);
			#1;
			we2 = 0;
			din2 = 8'hxx;
			re2 = 1;
			@(posedge clk);
			@(posedge clk);
			#1;
			re2 = 0;
		   end

		// RD/WR 3
		for(n=0;n<5;n=n+1)
		   begin
			@(posedge clk);
			#1;
			we2 = 1;
			din2 = $random;
			@(posedge clk);
			#1;
			din2 = $random;
			@(posedge clk);
			#1;
			din2 = $random;
			@(posedge clk);
			#1;
			we2 = 0;
			din2 = 8'hxx;
			re2 = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			#1;
			re2 = 0;
		   end


		// RD/WR 4
		for(n=0;n<5;n=n+1)
		   begin
			@(posedge clk);
			#1;
			we2 = 1;
			din2 = $random;
			@(posedge clk);
			#1;
			din2 = $random;
			@(posedge clk);
			#1;
			din2 = $random;
			@(posedge clk);
			#1;
			din2 = $random;
			@(posedge clk);
			#1;
			we2 = 0;
			din2 = 8'hxx;
			re2 = 1;
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			@(posedge clk);
			#1;
			re2 = 0;
		   end
end
endtask



endmodule


