`default_nettype none
module serv_immdec
  (
   input wire 	     i_clk,
   //Input
   input wire 	     i_cnt_en,
   input wire 	     i_csr_imm_en,
   output wire 	     o_csr_imm,
   input wire [31:2] i_wb_rdt,
   input wire 	     i_wb_en,
   input wire 	     i_cnt_done,
   input wire [3:0]  i_immdec_en,
   input wire [3:0]  i_ctrl,
   //To RF
   output wire [4:0] o_rd_addr,
   output wire [4:0] o_rs1_addr,
   output wire [4:0] o_rs2_addr,
   output wire 	     o_imm);

   reg 	      signbit;

   reg [8:0]  imm19_12_20;
   reg 	      imm7;
   reg [5:0]  imm30_25;
   reg [4:0]  imm24_20;
   reg [4:0]  imm11_7;


   assign o_imm = i_cnt_done ? signbit : i_ctrl[0] ? imm11_7[0] : imm24_20[0];
   assign o_csr_imm = imm19_12_20[4];

   assign o_rs1_addr = imm19_12_20[8:4];
   assign o_rs2_addr = imm24_20;
   assign o_rd_addr  = imm11_7;

   always @(posedge i_clk) begin
      if (i_wb_en) begin
	 /* CSR immediates are always zero-extended, hence clear the signbit */
	 signbit     <= i_wb_rdt[31] & !i_csr_imm_en;
      end
      if (i_wb_en | (i_cnt_en & i_immdec_en[1]))
	imm19_12_20 <= i_wb_en ? {i_wb_rdt[19:12],i_wb_rdt[20]} : {i_ctrl[3] ? signbit : imm24_20[0], imm19_12_20[8:1]};
      if (i_wb_en | (i_cnt_en))
	imm7        <= i_wb_en ? i_wb_rdt[7]                    : signbit;

      if (i_wb_en | (i_cnt_en & i_immdec_en[3]))
	imm30_25    <= i_wb_en ? i_wb_rdt[30:25]                : {i_ctrl[2] ? imm7 : i_ctrl[1] ? signbit : imm19_12_20[0], imm30_25[5:1]};

      if (i_wb_en | (i_cnt_en & i_immdec_en[2]))
	imm24_20    <= i_wb_en ? i_wb_rdt[24:20]                : {imm30_25[0], imm24_20[4:1]};

      if (i_wb_en | (i_cnt_en & i_immdec_en[0]))
	imm11_7     <= i_wb_en ? i_wb_rdt[11:7]                 : {imm30_25[0], imm11_7[4:1]};
   end
endmodule
