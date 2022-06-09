
module miner # (
	parameter CORES = 32'd1
 ) (
	input clk,
	input reset,
	input [639:0] block,
	input [31:0] nonce_start,
	output nonce_found,
	output [31:0] nonce_out
 );

	localparam OFFSET = 32'd733;

	wire [511:0] hash1;

	reg [511:0] midstate_d, midstate_q;
	reg [95:0] data_d, data_q;
	reg [31:0] target_d, target_q;
	reg [31:0] nonce_d, nonce_q;
	reg [31:0] nonce_out_d, nonce_out_q;
	reg nonce_found_d, nonce_found_q;
	reg reset_d, reset_q;

	reg [31:0] hash1_d, hash1_q;
	
	assign nonce_found = nonce_found_q;
	assign nonce_out = nonce_out_q;

	skein512 skein ( clk, midstate_q, data_q, nonce_q, hash1 );
	always @ (*) begin

		if ( reset_q ) begin

			nonce_d <= nonce_start;
			nonce_out_d <= nonce_start - (CORES * OFFSET);

			nonce_found_d <= 1'b0;

		end
		else begin

			nonce_d <= nonce_q + CORES;
			nonce_out_d <= nonce_out_q + CORES;

			if ( hash1_q <= target_q )
				nonce_found_d <= 1'b1;
			else
				nonce_found_d <= 1'b0;

		end

		midstate_d <= block[639:128];
		data_d <= block[127:32];
		target_d <= block[31:0];    
		hash1_d <= hash1[287:256];
		reset_d <= reset;

	end

	always @ (posedge clk) begin

		midstate_q <= midstate_d;
		data_q <= data_d;
		target_q <= target_d;

		nonce_q <= nonce_d;
		nonce_out_q <= nonce_out_d;

		hash1_q <= hash1_d;

		nonce_found_q <= nonce_found_d;

		reset_q <= reset_d;

		$display ("Nonce: %X, Hash: %X, Found: %d", nonce_out_d, hash2_q, nonce_found_d);
//		$display ("   H1: %x", hash1);
//		$display ("   H2: %x", hash2);
//		$display ("   H3: %x", hash3);
//		$display ("   H4: %x", hash4[511:256]);

	end

endmodule
