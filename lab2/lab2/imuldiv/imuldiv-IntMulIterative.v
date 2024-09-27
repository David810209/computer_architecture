//========================================================================
// Lab 1 - Iterative Mul Unit
//========================================================================

`ifndef RISCV_INT_MUL_ITERATIVE_V
`define RISCV_INT_MUL_ITERATIVE_V

module imuldiv_IntMulIterative
#(
  parameter INPUT_SZ = 32
)(
  input                clk,
  input                reset,

  input  [INPUT_SZ-1:0] mulreq_msg_a,
  input  [INPUT_SZ-1:0] mulreq_msg_b,
  input         mulreq_val,
  output        mulreq_rdy,

  output [2*INPUT_SZ-1:0] mulresp_msg_result,
  output        mulresp_val,
  input         mulresp_rdy
);

  wire a_mux_sel, b_mux_sel, result_mux_sel, result_en, add_mux_sel, sign_mux_sel, sign_en;
  wire b_reg_0, sign;
  wire [$clog2(INPUT_SZ)-1:0] counter;

  imuldiv_IntMulIterativeDpath #(.INPUT_SZ(INPUT_SZ)) dpath
  (
    .clk                (clk),
    .reset              (reset),
    .mulreq_msg_a       (mulreq_msg_a),
    .mulreq_msg_b       (mulreq_msg_b),
    // .mulreq_val         (mulreq_val),
    // .mulreq_rdy         (mulreq_rdy),
    .mulresp_msg_result (mulresp_msg_result),
    // .mulresp_val        (mulresp_val),
    // .mulresp_rdy        (mulresp_rdy)
    
    .a_mux_sel(a_mux_sel),
    .b_mux_sel(b_mux_sel),
    .result_mux_sel(result_mux_sel),
    .result_en(result_en),
    .add_mux_sel(add_mux_sel),
    .sign_mux_sel(sign_mux_sel),
    .sign_en(sign_en),

    .b_reg_0(b_reg_0),
    .counter(counter),
    .sign(sign)
  );

  imuldiv_IntMulIterativeCtrl #(.INPUT_SZ(INPUT_SZ)) ctrl
  (
    .clk                (clk),
    .reset              (reset),
    .mulreq_val         (mulreq_val),
    .mulreq_rdy         (mulreq_rdy),
    .mulresp_val        (mulresp_val),
    .mulresp_rdy        (mulresp_rdy),

    .a_mux_sel(a_mux_sel),
    .b_mux_sel(b_mux_sel),
    .result_mux_sel(result_mux_sel),
    .result_en(result_en),
    .add_mux_sel(add_mux_sel),
    .sign_mux_sel(sign_mux_sel),
    .sign_en(sign_en),

    .b_reg_0(b_reg_0),
    .counter(counter),
    .sign(sign)
  );

endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module imuldiv_IntMulIterativeDpath
#(
  parameter INPUT_SZ = 32
)
(
  input         clk,
  input         reset,

  input  [INPUT_SZ-1:0] mulreq_msg_a,       // Operand A
  input  [INPUT_SZ-1:0] mulreq_msg_b,       // Operand B
  // input         mulreq_val,         // Request val Signal
  // output        mulreq_rdy,         // Request rdy Signal

  output [2*INPUT_SZ-1:0] mulresp_msg_result, // Result of operation
  // output        mulresp_val,        // Response val Signal
  // input         mulresp_rdy,        // Response rdy Signal

  input a_mux_sel,
  input b_mux_sel,
  input result_mux_sel,
  input result_en,
  input add_mux_sel,
  input sign_mux_sel,
  input sign_en,

  output b_reg_0,
  output [$clog2(INPUT_SZ)-1:0] counter,
  output sign
);

  // //----------------------------------------------------------------------
  // // Input Logic
  // //----------------------------------------------------------------------
  wire sign_bit_a = mulreq_msg_a[INPUT_SZ-1];
  wire sign_bit_b = mulreq_msg_b[INPUT_SZ-1];

  wire [2*INPUT_SZ-1:0] unsigned_a = { {INPUT_SZ{1'b0}}, ( sign_bit_a ) ? (~mulreq_msg_a + 1'b1) : mulreq_msg_a};
  wire [INPUT_SZ-1:0] unsigned_b = ( sign_bit_b ) ? (~mulreq_msg_b + 1'b1) : mulreq_msg_b;

  reg [2*INPUT_SZ-1:0] a_reg;
  reg [INPUT_SZ-1:0] b_reg;
  
  wire [2*INPUT_SZ-1:0] a_shift_out;
  wire [INPUT_SZ-1:0] b_shift_out;

  assign a_shift_out = a_reg << 1;
  assign b_shift_out = b_reg >> 1;

  always @( posedge clk ) begin
    // a_mux
    // 1 for unsigned_a, 0 for a_shift_out
    a_reg <= a_mux_sel ? unsigned_a : a_shift_out;

    // b_mux
    // 1 for unsigned_b, 0 for b_shift_out
    b_reg <= b_mux_sel ? unsigned_b : b_shift_out;
  end

  assign b_reg_0 = b_reg[0];

  // //----------------------------------------------------------------------
  // // Result Logic
  // //----------------------------------------------------------------------
  reg [2*INPUT_SZ-1:0] result_reg;
  wire [2*INPUT_SZ-1:0] result_mux, add_mux_out, temp_add;

  assign temp_add = a_reg + result_reg;

  // 0 for add out, 1 for result_reg
  assign add_mux_out = add_mux_sel ? result_reg : temp_add;

  // result_mux
  // 1 for 64'b0, 0 for add_mux_out
  assign result_mux = result_mux_sel ? 0 : add_mux_out;

  always @( posedge clk ) begin
    result_reg <= result_en ? result_mux : result_reg;
  end

  wire [2*INPUT_SZ-1:0] signed_result;
  assign signed_result = ~result_reg + 1'b1;

  // 0 for signed_result, 1 for original result
  assign mulresp_msg_result = sign_mux_sel ? result_reg : signed_result;

  // //----------------------------------------------------------------------
  // // Counter Logic
  // //----------------------------------------------------------------------
  reg [$clog2(INPUT_SZ)-1:0] counter_reg;

  always @(posedge clk) begin
    if (reset) begin
      counter_reg <= INPUT_SZ-1;
    end else if (b_mux_sel) begin
      counter_reg <= INPUT_SZ-1;
    end else if (counter_reg != 0) begin
      counter_reg <= counter_reg - 1;
    end
  end

  assign counter = counter_reg;

  // //----------------------------------------------------------------------
  // // Sign Logic
  // //----------------------------------------------------------------------
  reg sign_reg;

  always @( posedge clk ) begin
    sign_reg <= sign_en ? mulreq_msg_a[INPUT_SZ-1] ^ mulreq_msg_b[INPUT_SZ-1] : sign_reg;
  end

  assign sign = sign_reg;

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntMulIterativeCtrl
#(
  parameter INPUT_SZ = 32
)
(
  input         clk,
  input         reset,

  input         mulreq_val,         // Request val Signal
  output        mulreq_rdy,         // Request rdy Signal

  output        mulresp_val,        // Response val Signal
  input         mulresp_rdy,        // Response rdy Signal

  output a_mux_sel,
  output b_mux_sel,
  output result_mux_sel,
  output result_en,
  output add_mux_sel,
  output sign_mux_sel,
  output sign_en,

  input b_reg_0,
  input [$clog2(INPUT_SZ)-1:0] counter,
  input sign
);

  reg [1:0] state;
  localparam IDLE   = 2'd0;
  localparam RUN    = 2'd1;
  localparam FINISH = 2'd2;

  assign mulreq_rdy = (state == IDLE);
  assign mulresp_val = (state == FINISH);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          if (mulreq_val) begin
            state <= RUN;
          end
        end
        RUN: begin
          if (counter == 0) begin
            state <= FINISH;
          end
        end
        FINISH: begin
          if (mulresp_rdy) begin
            state <= IDLE;
          end
        end
      endcase
    end
  end

  // Control signal assignments
  assign a_mux_sel      = (state == IDLE);
  assign b_mux_sel      = (state == IDLE);
  assign result_mux_sel = (state == IDLE);
  assign result_en      = (state == RUN || state == IDLE);
  assign add_mux_sel    = ~b_reg_0;
  assign sign_mux_sel   = ~sign;
  assign sign_en        = (state == IDLE);

endmodule

`endif
