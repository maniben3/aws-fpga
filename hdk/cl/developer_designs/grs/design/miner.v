
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

	wire [511:0]block1,block2,block3;
	wire [255:0] hash,out,constant,s2hash;
	reg [31:0] nonce;
	assign constant = 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
	assign block1 = block[511:0];
	assign block2 = {64'h240,319'b0,1'b1,nonce,block[607:512]};
	assign block3 = {64'h100,191'b0,1'b1,s2hash};
	sha256_transform s1(constant,block1,out);
	sha256_transform s2(out,block2,s2hash);
	sha256_transform s3(constant,block3,hash);
    reg[31:0] target_d,nonce_out_d;
    reg nonce_found_d;
    assign nonce_found=nonce_found_d;
    assign nonce_out=nonce;
	always @ ( posedge clk ) begin

		if ( reset ) begin
			target_d = block[31:0];
			nonce = nonce_start;
			nonce_found_d = 1'b0;
			nonce_out_d = 32'd0;

		end
		else begin
			nonce = nonce + CORES;
			if ( hash[255:224] <= target_d )
				nonce_found_d = 1'b1;
			else
				nonce_found_d = 1'b0;
		
		end
	end 
	endmodule
