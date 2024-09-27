//========================================================================
// Test for Div Unit
//========================================================================

`include "imuldiv-DivReqMsg.v"
`include "imuldiv-IntDivIterative.v"
`include "vc-TestSource.v"
`include "vc-TestSink.v"
`include "vc-Test.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module imuldiv_IntDivIterative_helper
(
  input       clk,
  input       reset,
  output      done
);

  wire [64:0] src_msg;
  wire        src_msg_fn;
  wire [31:0] src_msg_a;
  wire [31:0] src_msg_b;
  wire        src_val;
  wire        src_rdy;
  wire        src_done;

  wire [63:0] sink_msg;
  wire        sink_val;
  wire        sink_rdy;
  wire        sink_done;

  assign done = src_done && sink_done;

  vc_TestSource#(65,3) src
  (
    .clk   (clk),
    .reset (reset),
    .bits  (src_msg),
    .val   (src_val),
    .rdy   (src_rdy),
    .done  (src_done)
  );

  imuldiv_DivReqMsgFromBits msgfrombits
  (
    .bits (src_msg),
    .func (src_msg_fn),
    .a    (src_msg_a),
    .b    (src_msg_b)
  );

  imuldiv_IntDivIterative idiv
  (
    .clk                 (clk),
    .reset               (reset),
    .divreq_msg_fn       (src_msg_fn),
    .divreq_msg_a        (src_msg_a),
    .divreq_msg_b        (src_msg_b),
    .divreq_val          (src_val),
    .divreq_rdy          (src_rdy),
    .divresp_msg_result  (sink_msg),
    .divresp_val         (sink_val),
    .divresp_rdy         (sink_rdy)
  );

  vc_TestSink#(64,3) sink
  (
    .clk   (clk),
    .reset (reset),
    .bits  (sink_msg),
    .val   (sink_val),
    .rdy   (sink_rdy),
    .done  (sink_done)
  );

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module tester;

  // VCD Dump
  initial begin
    $dumpfile("imuldiv-IntDivIterative.vcd");
    $dumpvars;
  end

  `VC_TEST_SUITE_BEGIN( "imuldiv-IntDivIterative" )

  reg  t0_reset = 1'b1;
  wire t0_done;

  imuldiv_IntDivIterative_helper t0
  (
    .clk   (clk),
    .reset (t0_reset),
    .done  (t0_done)
  );

  `VC_TEST_CASE_BEGIN( 1, "div/rem" )
  begin

    t0.src.m[ 0] = 65'h1_00000000_00000001; t0.sink.m[ 0] = 64'h00000000_00000000;
    t0.src.m[ 1] = 65'h1_00000001_00000001; t0.sink.m[ 1] = 64'h00000000_00000001;
    t0.src.m[ 2] = 65'h1_00000000_ffffffff; t0.sink.m[ 2] = 64'h00000000_00000000;
    t0.src.m[ 3] = 65'h1_ffffffff_ffffffff; t0.sink.m[ 3] = 64'h00000000_00000001;
    t0.src.m[ 4] = 65'h1_00000222_0000002a; t0.sink.m[ 4] = 64'h00000000_0000000d;
    t0.src.m[ 5] = 65'h1_0a01b044_ffffb146; t0.sink.m[ 5] = 64'h00000000_ffffdf76;
    t0.src.m[ 6] = 65'h1_00000032_00000222; t0.sink.m[ 6] = 64'h00000032_00000000;
    t0.src.m[ 7] = 65'h1_00000222_00000032; t0.sink.m[ 7] = 64'h0000002e_0000000a;
    t0.src.m[ 8] = 65'h1_0a01b044_ffffb14a; t0.sink.m[ 8] = 64'h00003372_ffffdf75;
    t0.src.m[ 9] = 65'h1_deadbeef_0000beef; t0.sink.m[ 9] = 64'hffffda72_ffffd353;
    t0.src.m[10] = 65'h1_f5fe4fbc_00004eb6; t0.sink.m[10] = 64'hffffcc8e_ffffdf75;
    t0.src.m[11] = 65'h1_f5fe4fbc_ffffb14a; t0.sink.m[11] = 64'hffffcc8e_0000208b;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #10000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Add Unsigned Test Case Here
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "divu/remu" )
  begin
    t0.src.m[0] = 65'h0_7aa3e97d_5114e66a; t0.sink.m[0] = 64'h298f0313_00000001;
    t0.src.m[1] = 65'h0_3c2aab17_60e281d9; t0.sink.m[1] = 64'h3c2aab17_00000000;
    t0.src.m[2] = 65'h0_511b53f_4c81d230; t0.sink.m[2] = 64'h0511b53f_00000000;
    t0.src.m[3] = 65'h0_70cac66c_08b53657; t0.sink.m[3] = 64'h084c3a58_0000000c;
    t0.src.m[4] = 65'h0_45bd7f4b_405014ba; t0.sink.m[4] = 64'h056d6a91_00000001;
    t0.src.m[5] = 65'h0_327444f7_1572c425; t0.sink.m[5] = 64'h078ebcad_00000002;
    t0.src.m[6] = 65'h0_6c153adc_3c40e923; t0.sink.m[6] = 64'h2fd451b9_00000001;
    t0.src.m[7] = 65'h0_38ec4d36_6dcd7518; t0.sink.m[7] = 64'h38ec4d36_00000000;
    t0.src.m[8] = 65'h0_607457b3_09e3d841; t0.sink.m[8] = 64'h0771bd6a_00000009;
    t0.src.m[9] = 65'h0_4e901b77_547adde5; t0.sink.m[9] = 64'h4e901b77_00000000;
    t0.src.m[10] = 65'h0_7aa3e97d_5114e66a; t0.sink.m[10] = 64'h298f0313_00000001;
    t0.src.m[11] = 65'h0_3c2aab17_60e281d9; t0.sink.m[11] = 64'h3c2aab17_00000000;
    t0.src.m[12] = 65'h0_511b53f_4c81d230; t0.sink.m[12] = 64'h0511b53f_00000000;
    t0.src.m[13] = 65'h0_70cac66c_08b53657; t0.sink.m[13] = 64'h084c3a58_0000000c;
    t0.src.m[14] = 65'h0_45bd7f4b_405014ba; t0.sink.m[14] = 64'h056d6a91_00000001;
    t0.src.m[15] = 65'h0_327444f7_1572c425; t0.sink.m[15] = 64'h078ebcad_00000002;
    t0.src.m[16] = 65'h0_6c153adc_3c40e923; t0.sink.m[16] = 64'h2fd451b9_00000001;
    t0.src.m[17] = 65'h0_38ec4d36_6dcd7518; t0.sink.m[17] = 64'h38ec4d36_00000000;
    t0.src.m[18] = 65'h0_607457b3_09e3d841; t0.sink.m[18] = 64'h0771bd6a_00000009;
    t0.src.m[19] = 65'h0_4e901b77_547adde5; t0.sink.m[19] = 64'h4e901b77_00000000;
    t0.src.m[20] = 65'h0_7aa3e97d_5114e66a; t0.sink.m[20] = 64'h298f0313_00000001;
    t0.src.m[21] = 65'h0_3c2aab17_60e281d9; t0.sink.m[21] = 64'h3c2aab17_00000000;
    t0.src.m[22] = 65'h0_511b53f_4c81d230; t0.sink.m[22] = 64'h0511b53f_00000000;
    t0.src.m[23] = 65'h0_70cac66c_08b53657; t0.sink.m[23] = 64'h084c3a58_0000000c;
    t0.src.m[24] = 65'h0_45bd7f4b_405014ba; t0.sink.m[24] = 64'h056d6a91_00000001;
    t0.src.m[25] = 65'h0_327444f7_1572c425; t0.sink.m[25] = 64'h078ebcad_00000002;
    t0.src.m[26] = 65'h0_6c153adc_3c40e923; t0.sink.m[26] = 64'h2fd451b9_00000001;
    t0.src.m[27] = 65'h0_38ec4d36_6dcd7518; t0.sink.m[27] = 64'h38ec4d36_00000000;
    t0.src.m[28] = 65'h0_607457b3_09e3d841; t0.sink.m[28] = 64'h0771bd6a_00000009;
    t0.src.m[29] = 65'h0_4e901b77_547adde5; t0.sink.m[29] = 64'h4e901b77_00000000;
    t0.src.m[30] = 65'h0_7aa3e97d_5114e66a; t0.sink.m[30] = 64'h298f0313_00000001;
    t0.src.m[31] = 65'h0_3c2aab17_60e281d9; t0.sink.m[31] = 64'h3c2aab17_00000000;
    t0.src.m[32] = 65'h0_511b53f_4c81d230; t0.sink.m[32] = 64'h0511b53f_00000000;
    t0.src.m[33] = 65'h0_70cac66c_08b53657; t0.sink.m[33] = 64'h084c3a58_0000000c;
    t0.src.m[34] = 65'h0_45bd7f4b_405014ba; t0.sink.m[34] = 64'h056d6a91_00000001;
    t0.src.m[35] = 65'h0_327444f7_1572c425; t0.sink.m[35] = 64'h078ebcad_00000002;
    t0.src.m[36] = 65'h0_6c153adc_3c40e923; t0.sink.m[36] = 64'h2fd451b9_00000001;
    t0.src.m[37] = 65'h0_38ec4d36_6dcd7518; t0.sink.m[37] = 64'h38ec4d36_00000000;
    t0.src.m[38] = 65'h0_607457b3_09e3d841; t0.sink.m[38] = 64'h0771bd6a_00000009;
    t0.src.m[39] = 65'h0_4e901b77_547adde5; t0.sink.m[39] = 64'h4e901b77_00000000;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #20000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 2/* replace with number of tests cases */ )

endmodule
