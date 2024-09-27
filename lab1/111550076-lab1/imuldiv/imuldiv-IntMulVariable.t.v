//========================================================================
// Test for Variable Mul Unit
//========================================================================

`include "imuldiv-MulDivReqMsg.v"
`include "imuldiv-IntMulVariable.v"
`include "vc-TestSource.v"
`include "vc-TestSink.v"
`include "vc-Test.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module imuldiv_IntMulVariable_helper
(
  input       clk,
  input       reset,
  output      done
);

  wire [66:0] src_msg;
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
    .func (),
    .a    (src_msg_a),
    .b    (src_msg_b)
  );

  imuldiv_IntMulVariable imul
  (
    .clk                (clk),
    .reset              (reset),
    .mulreq_msg_a       (src_msg_a),
    .mulreq_msg_b       (src_msg_b),
    .mulreq_val         (src_val),
    .mulreq_rdy         (src_rdy),
    .mulresp_msg_result (sink_msg),
    .mulresp_val        (sink_val),
    .mulresp_rdy        (sink_rdy)
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
    $dumpfile("imuldiv-IntMulVariable.vcd");
    $dumpvars;
  end

  `VC_TEST_SUITE_BEGIN( "imuldiv-IntMulVariable" )

  reg  t0_reset = 1'b1;
  wire t0_done;

  imuldiv_IntMulVariable_helper t0
  (
    .clk   (clk),
    .reset (t0_reset),
    .done  (t0_done)
  );

  `VC_TEST_CASE_BEGIN( 1, "mul" )
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

    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #10000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN( 2, "mul2" )
  begin

   t0.src.m[0] = 67'h0_65c55a44_5f0fd8b9; t0.sink.m[0] = 64'h25ca893795c39b24;
    t0.src.m[1] = 67'h0_3b4fbb63_363a9f2e; t0.sink.m[1] = 64'h0c906678842428ca;
    t0.src.m[2] = 67'h0_297032b6_32cf55a3; t0.sink.m[2] = 64'h0839797d3070b7e2;
    t0.src.m[3] = 67'h0_41f49ddc_0cd756dd; t0.sink.m[3] = 64'h034ef23800f82eec;
    t0.src.m[4] = 67'h0_71805ff7_05e506f7; t0.sink.m[4] = 64'h029d0ccc300f6151;
    t0.src.m[5] = 67'h0_386541af_52be554a; t0.sink.m[5] = 64'h123a5cfab9f61796;
    t0.src.m[6] = 67'h0_471dabfb_16b154d8; t0.sink.m[6] = 64'h064dcfdd380277c8;
    t0.src.m[7] = 67'h0_1d41144b_65e69840; t0.sink.m[7] = 64'h0ba506dfc6b39ac0;
    t0.src.m[8] = 67'h0_321877a9_3aecf164; t0.sink.m[8] = 64'h0b87e8e73400d704;
    t0.src.m[9] = 67'h0_5d9ecc93_24d5ceae; t0.sink.m[9] = 64'h0d78857a4cdc55ea;


    #5;   t0_reset = 1'b1;
    #20;  t0_reset = 1'b0;
    #10000; `VC_TEST_CHECK( "Is sink finished?", t0_done )

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 2 )

endmodule
