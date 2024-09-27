//========================================================================
// Test for Mul/Div Unit
//========================================================================

`include "imuldiv-MulDivReqMsg.v"
`include "imuldiv-IntMulDivIterative.v"
`include "vc-TestSource.v"
`include "vc-TestSink.v"
`include "vc-Test.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module imuldiv_IntMulDivIterative_helper
(
  input       clk,
  input       reset,
  output      done
);

  wire [66:0] src_msg;
  wire  [2:0] src_msg_fn;
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

  vc_TestSource#(67,3) src
  (
    .clk   (clk),
    .reset (reset),
    .bits  (src_msg),
    .val   (src_val),
    .rdy   (src_rdy),
    .done  (src_done)
  );

  imuldiv_MulDivReqMsgFromBits msgfrombits
  (
    .bits (src_msg),
    .func (src_msg_fn),
    .a    (src_msg_a),
    .b    (src_msg_b)
  );

  imuldiv_IntMulDivIterative imuldiv
  (
    .clk                   (clk),
    .reset                 (reset),
    .muldivreq_msg_fn      (src_msg_fn),
    .muldivreq_msg_a       (src_msg_a),
    .muldivreq_msg_b       (src_msg_b),
    .muldivreq_val         (src_val),
    .muldivreq_rdy         (src_rdy),
    .muldivresp_msg_result (sink_msg),
    .muldivresp_val        (sink_val),
    .muldivresp_rdy        (sink_rdy)
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
    $dumpfile("imuldiv-IntMulDivIterative.vcd");
    $dumpvars;
  end

  `VC_TEST_SUITE_BEGIN( "imuldiv-IntMulDivIterative" )

  reg  t0_reset = 1'b1;
  wire t0_done;

  imuldiv_IntMulDivIterative_helper t0
  (
    .clk   (clk),
    .reset (t0_reset),
    .done  (t0_done)
  );

  `VC_TEST_CASE_BEGIN( 1, "mul" )
  `VC_TEST_CASE_INIT(67, 64)
  begin

    t0.src.m[0] = 67'h0_00000000_00000000; t0.sink.m[0] = 64'h00000000_00000000;
    t0.src.m[1] = 67'h0_00000001_00000001; t0.sink.m[1] = 64'h00000000_00000001;
    t0.src.m[2] = 67'h0_ffffffff_00000001; t0.sink.m[2] = 64'hffffffff_ffffffff;
    t0.src.m[3] = 67'h0_00000001_ffffffff; t0.sink.m[3] = 64'hffffffff_ffffffff;
    t0.src.m[4] = 67'h0_ffffffff_ffffffff; t0.sink.m[4] = 64'h00000000_00000001;
    t0.src.m[5] = 67'h0_00000008_00000003; t0.sink.m[5] = 64'h00000000_00000018;
    t0.src.m[6] = 67'h0_fffffff8_00000008; t0.sink.m[6] = 64'hffffffff_ffffffc0;
    t0.src.m[7] = 67'h0_fffffff8_fffffff8; t0.sink.m[7] = 64'h00000000_00000040;
    t0.src.m[8] = 67'h0_0deadbee_10000000; t0.sink.m[8] = 64'h00deadbe_e0000000;
    t0.src.m[9] = 67'h0_deadbeef_10000000; t0.sink.m[9] = 64'hfdeadbee_f0000000;
    t0.src.m[10] = 67'h0_00000000_00000000; t0.sink.m[10] = 64'h00000000_00000000;
    t0.src.m[11] = 67'h0_00000001_00000001; t0.sink.m[11] = 64'h00000000_00000001;
    t0.src.m[12] = 67'h0_ffffffff_00000001; t0.sink.m[12] = 64'hffffffff_ffffffff;
    t0.src.m[13] = 67'h0_00000001_ffffffff; t0.sink.m[13] = 64'hffffffff_ffffffff;
    t0.src.m[14] = 67'h0_ffffffff_ffffffff; t0.sink.m[14] = 64'h00000000_00000001;
    t0.src.m[15] = 67'h0_00000008_00000003; t0.sink.m[15] = 64'h00000000_00000018;
    t0.src.m[16] = 67'h0_fffffff8_00000008; t0.sink.m[16] = 64'hffffffff_ffffffc0;
    t0.src.m[17] = 67'h0_fffffff8_fffffff8; t0.sink.m[17] = 64'h00000000_00000040;
    t0.src.m[18] = 67'h0_0deadbee_10000000; t0.sink.m[18] = 64'h00deadbe_e0000000;
    t0.src.m[19] = 67'h0_deadbeef_10000000; t0.sink.m[19] = 64'hfdeadbee_f0000000;
    t0.src.m[20] = 67'h0_00000000_00000000; t0.sink.m[20] = 64'h00000000_00000000;
    t0.src.m[21] = 67'h0_00000001_00000001; t0.sink.m[21] = 64'h00000000_00000001;
    t0.src.m[22] = 67'h0_ffffffff_00000001; t0.sink.m[22] = 64'hffffffff_ffffffff;
    t0.src.m[23] = 67'h0_00000001_ffffffff; t0.sink.m[23] = 64'hffffffff_ffffffff;
    t0.src.m[24] = 67'h0_ffffffff_ffffffff; t0.sink.m[24] = 64'h00000000_00000001;
    t0.src.m[25] = 67'h0_00000008_00000003; t0.sink.m[25] = 64'h00000000_00000018;
    t0.src.m[26] = 67'h0_fffffff8_00000008; t0.sink.m[26] = 64'hffffffff_ffffffc0;
    t0.src.m[27] = 67'h0_fffffff8_fffffff8; t0.sink.m[27] = 64'h00000000_00000040;
    t0.src.m[28] = 67'h0_0deadbee_10000000; t0.sink.m[28] = 64'h00deadbe_e0000000;
    t0.src.m[29] = 67'h0_deadbeef_10000000; t0.sink.m[29] = 64'hfdeadbee_f0000000;
    t0.src.m[30] = 67'h0_00000000_00000000; t0.sink.m[30] = 64'h00000000_00000000;
    t0.src.m[31] = 67'h0_00000001_00000001; t0.sink.m[31] = 64'h00000000_00000001;
    t0.src.m[32] = 67'h0_ffffffff_00000001; t0.sink.m[32] = 64'hffffffff_ffffffff;
    t0.src.m[33] = 67'h0_00000001_ffffffff; t0.sink.m[33] = 64'hffffffff_ffffffff;
    t0.src.m[34] = 67'h0_ffffffff_ffffffff; t0.sink.m[34] = 64'h00000000_00000001;
    t0.src.m[35] = 67'h0_00000008_00000003; t0.sink.m[35] = 64'h00000000_00000018;
    t0.src.m[36] = 67'h0_fffffff8_00000008; t0.sink.m[36] = 64'hffffffff_ffffffc0;
    t0.src.m[37] = 67'h0_fffffff8_fffffff8; t0.sink.m[37] = 64'h00000000_00000040;
    t0.src.m[38] = 67'h0_0deadbee_10000000; t0.sink.m[38] = 64'h00deadbe_e0000000;
    t0.src.m[39] = 67'h0_deadbeef_10000000; t0.sink.m[39] = 64'hfdeadbee_f0000000;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #20000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN( 2, "div/rem" )
  `VC_TEST_CASE_INIT(67, 64)
  begin

    t0.src.m[ 0] = 67'h1_00000000_00000001; t0.sink.m[ 0] = 64'h00000000_00000000;
    t0.src.m[ 1] = 67'h1_00000001_00000001; t0.sink.m[ 1] = 64'h00000000_00000001;
    t0.src.m[ 2] = 67'h1_00000000_ffffffff; t0.sink.m[ 2] = 64'h00000000_00000000;
    t0.src.m[ 3] = 67'h1_ffffffff_ffffffff; t0.sink.m[ 3] = 64'h00000000_00000001;
    t0.src.m[ 4] = 67'h1_00000222_0000002a; t0.sink.m[ 4] = 64'h00000000_0000000d;
    t0.src.m[ 5] = 67'h1_0a01b044_ffffb146; t0.sink.m[ 5] = 64'h00000000_ffffdf76;
    t0.src.m[ 6] = 67'h1_00000032_00000222; t0.sink.m[ 6] = 64'h00000032_00000000;
    t0.src.m[ 7] = 67'h1_00000222_00000032; t0.sink.m[ 7] = 64'h0000002e_0000000a;
    t0.src.m[ 8] = 67'h1_0a01b044_ffffb14a; t0.sink.m[ 8] = 64'h00003372_ffffdf75;
    t0.src.m[ 9] = 67'h1_deadbeef_0000beef; t0.sink.m[ 9] = 64'hffffda72_ffffd353;
    t0.src.m[10] = 67'h1_f5fe4fbc_00004eb6; t0.sink.m[10] = 64'hffffcc8e_ffffdf75;
    t0.src.m[11] = 67'h1_f5fe4fbc_ffffb14a; t0.sink.m[11] = 64'hffffcc8e_0000208b;

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #100000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN( 3, "mixed" )
  `VC_TEST_CASE_INIT(67, 64)
  begin

    t0.src.m[ 0] = 67'h0_fffffff8_00000008; t0.sink.m[ 0] = 64'hffffffff_ffffffc0;
    t0.src.m[ 1] = 67'h0_fffffff8_fffffff8; t0.sink.m[ 1] = 64'h00000000_00000040;
    t0.src.m[ 2] = 67'h0_0deadbee_10000000; t0.sink.m[ 2] = 64'h00deadbe_e0000000;
    t0.src.m[ 3] = 67'h0_deadbeef_10000000; t0.sink.m[ 3] = 64'hfdeadbee_f0000000;
    t0.src.m[ 4] = 67'h1_0a01b044_ffffb14a; t0.sink.m[ 4] = 64'h00003372_ffffdf75;
    t0.src.m[ 5] = 67'h1_deadbeef_0000beef; t0.sink.m[ 5] = 64'hffffda72_ffffd353;
    t0.src.m[ 6] = 67'h1_f5fe4fbc_00004eb6; t0.sink.m[ 6] = 64'hffffcc8e_ffffdf75;
    t0.src.m[ 7] = 67'h1_f5fe4fbc_ffffb14a; t0.sink.m[ 7] = 64'hffffcc8e_0000208b;

    // Add entries for divu/remu here

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #100000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

   //---------------------------------------------------------------------
   // Add More Test Cases Here
   //---------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN( 4, "mixed2" )
  `VC_TEST_CASE_INIT(67, 64)
  begin

    t0.src.m[ 0] = 67'h2_7aa3e97d_5114e66a; t0.sink.m[ 0] = 64'h298f0313_00000001;
    t0.src.m[ 1] = 67'h2_3c2aab17_60e281d9; t0.sink.m[ 1] = 64'h3c2aab17_00000000;
    t0.src.m[ 2] = 67'h0_65c55a44_5f0fd8b9; t0.sink.m[ 2] = 64'h25ca893795c39b24;
    t0.src.m[ 3] = 67'h0_41f49ddc_0cd756dd; t0.sink.m[ 3] = 64'h034ef23800f82eec;

    // Add entries for divu/remu here

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #100000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END
  `VC_TEST_SUITE_END( 4 /* replace with number of test cases */ )

endmodule
