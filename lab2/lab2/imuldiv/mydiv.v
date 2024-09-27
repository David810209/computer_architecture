// //========================================================================
// // Lab 1 - Iterative Div Unit
// //========================================================================

// `ifndef RISCV_INT_DIV_ITERATIVE_V
// `define RISCV_INT_DIV_ITERATIVE_V

// `include "imuldiv-DivReqMsg.v"

// module imuldiv_IntDivIterative
// (

//   input         clk,
//   input         reset,

//   input         divreq_msg_fn,
//   input  [31:0] divreq_msg_a,
//   input  [31:0] divreq_msg_b,
//   input         divreq_val,
//   output        divreq_rdy,

//   output [63:0] divresp_msg_result,
//   output        divresp_val,
//   input         divresp_rdy
// );

//   imuldiv_IntDivIterativeDpath dpath
//   (
//     .clk                (clk),
//     .reset              (reset),
//     .divreq_msg_fn      (divreq_msg_fn),
//     .divreq_msg_a       (divreq_msg_a),
//     .divreq_msg_b       (divreq_msg_b),
//     .divreq_val         (divreq_val),
//     .divreq_rdy         (divreq_rdy),
//     .divresp_msg_result (divresp_msg_result),
//     .divresp_val        (divresp_val),
//     .divresp_rdy        (divresp_rdy)
//   );

//   imuldiv_IntDivIterativeCtrl ctrl
//   (
//   );

// endmodule

// //------------------------------------------------------------------------
// // Datapath
// //------------------------------------------------------------------------

// module imuldiv_IntDivIterativeDpath
// (
//   input         clk,
//   input         reset,

//   input         divreq_msg_fn,      // Function of MulDiv Unit
//   input  [31:0] divreq_msg_a,       // Operand A
//   input  [31:0] divreq_msg_b,       // Operand B
//   input         divreq_val,         // Request val Signal
//   output        divreq_rdy,         // Request rdy Signal

//   output [63:0] divresp_msg_result, // Result of operation
//   output        divresp_val,        // Response val Signal
//   input         divresp_rdy         // Response rdy Signal
// );

//   //----------------------------------------------------------------------
//   // Sequential Logic
//   //----------------------------------------------------------------------

//   reg         fn_reg;      // Register for storing function
//   reg  [31:0] a_reg;       // Register for storing operand A
//   reg  [31:0] b_reg;       // Register for storing operand B
//   reg         val_reg;     // Register for storing valid bit

//   always @( posedge clk ) begin

//     // Stall the pipeline if the response interface is not ready
//     if ( divresp_rdy ) begin
//       fn_reg  <= divreq_msg_fn;
//       a_reg   <= divreq_msg_a;
//       b_reg   <= divreq_msg_b;
//       val_reg <= divreq_val;
//     end

//   end

//   //----------------------------------------------------------------------
//   // Combinational Logic
//   //----------------------------------------------------------------------

//   // Extract sign bits

//   wire sign_bit_a = a_reg[31];
//   wire sign_bit_b = b_reg[31];

//   // Unsign operands if necessary

//   wire [31:0] unsigned_a = ( sign_bit_a ) ? (~a_reg + 1'b1) : a_reg;
//   wire [31:0] unsigned_b = ( sign_bit_b ) ? (~b_reg + 1'b1) : b_reg;

//   // Computation logic

//   wire [31:0] unsigned_quotient
//     = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED )   ? unsigned_a / unsigned_b
//     : ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? a_reg / b_reg
//     :                                                   32'bx;

//   wire [31:0] unsigned_remainder
//     = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED )   ? unsigned_a % unsigned_b
//     : ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? a_reg % b_reg
//     :                                                   32'bx;

//   // Determine whether or not result is signed. Usually the result is
//   // signed if one and only one of the input operands is signed. In other
//   // words, the result is signed if the xor of the sign bits of the input
//   // operands is true. Remainder opeartions are a bit trickier, and here
//   // we simply assume that the result is signed if the dividend for the
//   // rem operation is signed.

//   wire is_result_signed_div = sign_bit_a ^ sign_bit_b;
//   wire is_result_signed_rem = sign_bit_a;

//   // Sign the final results if necessary

//   wire [31:0] signed_quotient
//     = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED
//      && is_result_signed_div ) ? ~unsigned_quotient + 1'b1
//     :                            unsigned_quotient;

//   wire [31:0] signed_remainder
//     = ( fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED
//      && is_result_signed_rem )   ? ~unsigned_remainder + 1'b1
//    :                              unsigned_remainder;

//   assign divresp_msg_result = { signed_remainder, signed_quotient };

//   // Set the val/rdy signals. The request is ready when the response is
//   // ready, and the response is valid when there is valid data in the
//   // input registers.

//   assign divreq_rdy  = divresp_rdy;
//   assign divresp_val = val_reg;

// endmodule

// //------------------------------------------------------------------------
// // Control Logic
// //------------------------------------------------------------------------

// module imuldiv_IntDivIterativeCtrl
// (
// );

// endmodule

// `endif

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
    .counter            (counter)

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
    .sign_en            (sign_en)
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
  output [4:0]  counter
);

  //counter
  reg [4:0] counter_reg;
  always @(posedge clk) begin
    if (reset) begin
      counter_reg <= 5'd31;
    end else begin
      counter_reg <= (b_mux_sel) ? counter_reg - 1 : counter_reg ;
    end
  end
  assign counter = counter_reg;

  //sign
  reg        div_sign_reg;
  reg        rem_sign_reg;

  always @(posedge clk) begin
    if (reset) begin
      div_sign_reg <= 1'b0;
      rem_sign_reg <=  1'b0;
    end else begin
      div_sign_reg = (sign_en) ? divreq_msg_a[31] ^ divreq_msg_b[31] : div_sign_reg;
      rem_sign_reg = (sign_en) ? divreq_msg_a[31] : rem_sign_reg;
    end
  end

  reg [64:0] a_reg;
  reg [64:0] b_reg;
  reg fn_reg;
  
  reg [63:0]  divresp_msg_result;

  wire [64:0] unsigned_a = (divreq_msg_a[31] && divreq_msg_fn ==  `IMULDIV_DIVREQ_MSG_FUNC_SIGNED) ? ({33'b0, ~divreq_msg_a + 1'b1}) : {33'b0, divreq_msg_a};
  wire [64:0] unsigned_b = (divreq_msg_b[31] && divreq_msg_fn ==  `IMULDIV_DIVREQ_MSG_FUNC_SIGNED) ? ({1'b0, ~divreq_msg_b + 1'b1, 32'b0}) :  ({1'b0, divreq_msg_b, 32'b0});
  reg  [64:0] Diff  ;
  wire [64:0] diff_nxt = {Diff[64:1], 1'b1};

  always @(posedge clk)begin
    if(reset) begin
      a_reg <= 65'b0;
      fn_reg <= 1'b0;
    end else begin
      if(a_mux_sel)begin
        if(!Diff[64])a_reg <= (!counter) ? diff_nxt : diff_nxt << 1 ;
        else a_reg <= (!counter) ? a_reg  : a_reg << 1;
      end
      else begin
        a_reg <= unsigned_a << 1'b1;
        fn_reg <= divreq_msg_fn;
      end
    end
  end
  

  always @(posedge clk) begin
    if (reset) begin
      Diff <= 65'b0;
    end else begin
      if (a_mux_sel & counter != 0) begin
        Diff <= (!Diff[64]) ? ((diff_nxt << 1) ) - (b_reg) : (a_reg << 1'b1) - (b_reg);
      end 
      else begin
        Diff  <= (unsigned_a << 1'b1) - (unsigned_b);
      end
    end
  end


  always @(posedge clk) begin
    if (reset) begin
      b_reg <= 65'b0;
    end else begin
      b_reg = (b_mux_sel) ? b_reg : unsigned_b;
    end
  end

  //result
  wire [31:0] rem_result = (rem_sign_reg && fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED) ? ~a_reg[63:32] + 1'b1 : a_reg[63:32];
  wire [31:0] div_result = (div_sign_reg && fn_reg == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED) ? ~a_reg[31:0] + 1'b1 :  a_reg[31:0];
  always @(*) begin
    if (reset) begin 
      divresp_msg_result <= 64'b0;
    end 
    else begin
      divresp_msg_result <= {rem_result, div_result};
    end
  end
  

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
  output   sign_en

  
);

  reg [2:0] S;
  reg [2:0] S_next;
  localparam S_IDLE = 3'd0,
             S_CAL = 3'd1,
             S_DONE = 3'd2;

  always @(posedge clk) begin
    if (reset) begin
      S <=S_IDLE;
    end else begin
      S <= S_next;
    end
  end

  always @(*) begin
      S_next <= S;
      case (S)

        S_IDLE: 
          if (divreq_val) S_next <= S_CAL;
        
        S_CAL: 
          if (counter == 0) S_next <= S_DONE;
          else S_next <= S_CAL;
        S_DONE: 
          if(divresp_rdy)
            S_next <= S_IDLE;
      endcase
    // end
  end

  assign divreq_rdy = (S == S_IDLE);
  assign sign_en = (S == S_IDLE || S == S_DONE);
  assign a_mux_sel = (S == S_CAL);
  assign b_mux_sel = (S == S_CAL);
  assign divresp_val = (S == S_DONE);
  

endmodule

`endif