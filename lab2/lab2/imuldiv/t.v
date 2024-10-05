//========================================================================
// Lab 1 - Iterative Div Unit
//========================================================================

`ifndef RISCV_INT_DIV_ITERATIVE_V
`define RISCV_INT_DIV_ITERATIVE_V

`include "imuldiv-DivReqMsg.v"

module imuldiv_IntDivIterative
(

  input         clk,
  input         reset,

  input         divreq_msg_fn,
  input  [31:0] divreq_msg_a,
  input  [31:0] divreq_msg_b,
  input         divreq_val,
  output        divreq_rdy,

  output [63:0] divresp_msg_result,
  output        divresp_val,
  input         divresp_rdy
);

  wire        a_mux_sel;             
  wire        b_mux_sel;                 
  wire        sign_en;              
  wire [4:0]  counter;   
  wire a_en;
  wire b_en;


  imuldiv_IntDivIterativeDpath dpath
  (
    //system signal
    .clk                (clk),
    .reset              (reset),

    //a b sign result reg
    .divreq_msg_fn      (divreq_msg_fn),
    .divreq_msg_a       (divreq_msg_a),
    .divreq_msg_b       (divreq_msg_b),
    .divresp_msg_result (divresp_msg_result),
    .a_mux_sel          (a_mux_sel),        
    .b_mux_sel          (b_mux_sel),
    .sign_en            (sign_en),
    .counter            (counter),
    .a_en               (a_en),
    .b_en               (b_en)

  );

  imuldiv_IntDivIterativeCtrl ctrl(
    //system signal
    .clk                (clk),
    .reset              (reset),

    //val/ rdy
    .divreq_val         (divreq_val),
    .divreq_rdy         (divreq_rdy),
    .divresp_val        (divresp_val),
    .divresp_rdy        (divresp_rdy),

    //a b sign counter reg
    .counter            (counter),
    .a_mux_sel          (a_mux_sel),      
    .b_mux_sel          (b_mux_sel),
    .sign_en            (sign_en),
    .a_en               (a_en),
    .b_en               (b_en)
  );
endmodule

//------------------------------------------------------------------------
// Datapath
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeDpath
(
  //system signal
  input         clk,
  input         reset,

  input         divreq_msg_fn,      // Function of MulDiv Unit
  input  [31:0] divreq_msg_a,       // Operand A
  input  [31:0] divreq_msg_b,       // Operand B

  output [63:0] divresp_msg_result, // Result of operation

  input         a_mux_sel,
  input         b_mux_sel,
  input         sign_en,
  output [4:0]  counter,
  input         a_en,
  input         b_en

);

  //counter
  reg [4:0] counter_reg;

  always @(posedge clk) begin
    if (reset) begin
      counter_reg <= 31;
    end else if (b_mux_sel) begin
      counter_reg <= 31;
    end else if (counter_reg != 0) begin
      counter_reg <= counter_reg - 1;
    end
  end

  assign counter = counter_reg;
  //sign
  reg div_sign_reg, rem_sign_reg;
  always @(posedge clk) begin
    div_sign_reg <= sign_en ? sign_bit_a ^ sign_bit_b : div_sign_reg;
    rem_sign_reg <= sign_en ? sign_bit_a : rem_sign_reg;
  end
  //a reg  b reg
  wire sign_bit_a 
    = ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED ) ? divreq_msg_a[31]
    : ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? 0
    : 1'bx;

  wire sign_bit_b
    = ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED ) ? divreq_msg_b[31]
    : ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? 0
    : 1'bx;

  wire [64:0] unsigned_a = ( sign_bit_a) ? ({33'b0, ~divreq_msg_a + 1'b1}) : {33'b0, divreq_msg_a};
  wire [64:0] unsigned_b = (sign_bit_b) ? ({1'b0, ~divreq_msg_b + 1'b1, 32'b0}) :  ({1'b0, divreq_msg_b, 32'b0});




  reg [64:0] a_reg, b_reg;
  always @(posedge clk) begin
    a_reg <= a_en ? (a_mux_sel ? unsigned_a: sub_mx_out) : a_reg;
    b_reg <= b_en ? unsigned_b : b_reg;
  end
  wire [64:0] a_shift_out = a_reg << 1;
  wire [64:0] sub_out = a_shift_out - b_reg;

  wire [64:0] sub_mx_out = ~sub_out[64] ? {sub_out[64:1], 1'b1} : a_shift_out


  //result
  wire [63:0] signed_rem_mux_out = rem_sign_reg ? ~a_reg[63:32] + 1'b1 : a_reg[63:32];
  wire [31:0] signed_div_mux_out = div_sign_reg ? ~a_reg[31: 0] + 1'b1 : a_reg[31: 0];

  assign divresp_msg_result = {signed_rem_mux_out, signed_div_mux_out};
  
endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeCtrl(
  //system signals
  input         clk,
  input         reset,

  //val/rdy
  input         divreq_val,         // Request val Signal
  output    divreq_rdy,         // Request rdy Signal
  output    divresp_val,        // Response val Signal
  input         divresp_rdy,        // Response rdy Signal

  //a b sign counter reg
  input [4:0]  counter,
  output    a_mux_sel,
  output   b_mux_sel,
  output   sign_en,
  output  a_en,
  output  b_en

  
);

  reg [1:0] S;
  localparam S_IDLE = 2'd0,
             S_CAL = 2'd1,
             S_DONE = 2'd2;


  always @(posedge clk or posedge reset) begin
      if (reset) begin
      S <=S_IDLE;
      end else begin
        case (S)
          S_IDLE: 
            if (divreq_val) S <= S_CAL;
          S_CAL: 
            if (counter == 5'd0) S <= S_DONE;
          S_DONE: 
            if(divresp_rdy) S <= S_IDLE;
        endcase
      end
  end

  assign divreq_rdy = (S == S_IDLE);
  assign sign_en = (S == S_IDLE);
  assign a_mux_sel = (S == S_IDLE);
  assign b_mux_sel = (S == S_IDLE);
  assign a_en      = (S == S_IDLE || S == S_CAL);
  assign b_en      = S == S_IDLE;
  assign divresp_val = (S == S_DONE);
  

endmodule

`endif
