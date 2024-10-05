// //========================================================================
// // Lab 1 - Iterative Div Unit
// //========================================================================

// `ifndef RISCV_INT_DIV_ITERATIVE_V
// `define RISCV_INT_DIV_ITERATIVE_V

// `include "imuldiv-DivReqMsg.v"

// module imuldiv_IntDivIterative
// #(
//   parameter INPUT_SZ = 32
// )
// (

//   input         clk,
//   input         reset,

//   input         divreq_msg_fn,
//   input  [INPUT_SZ-1:0] divreq_msg_a,
//   input  [INPUT_SZ-1:0] divreq_msg_b,
//   input         divreq_val,
//   output        divreq_rdy,

//   output [2*INPUT_SZ-1:0] divresp_msg_result,
//   output        divresp_val,
//   input         divresp_rdy
// );

//   wire a_mux_sel;
//   wire a_en;
//   wire b_en;
//   wire sub_mux_sel;
//   wire div_sign_mux_sel;
//   wire rem_sign_mux_sel;
//   wire b_mux_sel;
//   wire sign_en;

//   wire div_sign;
//   wire rem_sign;
//   wire sub_out_64;
//   wire [$clog2(INPUT_SZ)-1:0] counter;

//   imuldiv_IntDivIterativeDpath #(.INPUT_SZ(INPUT_SZ)) dpath
//   (
//     .clk                (clk),
//     .reset              (reset),
//     .divreq_msg_fn      (divreq_msg_fn),
//     .divreq_msg_a       (divreq_msg_a),
//     .divreq_msg_b       (divreq_msg_b),
//     // .divreq_val         (divreq_val),
//     // .divreq_rdy         (divreq_rdy),
//     .divresp_msg_result (divresp_msg_result),
//     // .divresp_val        (divresp_val),
//     // .divresp_rdy        (divresp_rdy)

//     .a_mux_sel(a_mux_sel),
//     .a_en(a_en),
//     .b_en(b_en),
//     .sub_mux_sel(sub_mux_sel),
//     .div_sign_mux_sel(div_sign_mux_sel),
//     .rem_sign_mux_sel(rem_sign_mux_sel),
//     .b_mux_sel(b_mux_sel),
//     .sign_en(sign_en),

//     .div_sign(div_sign),
//     .rem_sign(rem_sign),
//     .sub_out_64(sub_out_64),
//     .counter(counter)    
//   );

//   imuldiv_IntDivIterativeCtrl #(.INPUT_SZ(INPUT_SZ)) ctrl
//   (
//     .clk                (clk),
//     .reset              (reset),  
    
//     .divreq_val         (divreq_val),
//     .divreq_rdy         (divreq_rdy),  
//     .divresp_val        (divresp_val),
//     .divresp_rdy        (divresp_rdy),

//     .a_mux_sel(a_mux_sel),
//     .a_en(a_en),
//     .b_en(b_en),
//     .sub_mux_sel(sub_mux_sel),
//     .div_sign_mux_sel(div_sign_mux_sel),
//     .rem_sign_mux_sel(rem_sign_mux_sel),
//     .b_mux_sel(b_mux_sel),
//     .sign_en(sign_en),

//     .div_sign(div_sign),
//     .rem_sign(rem_sign),
//     .sub_out_64(sub_out_64),
//     .counter(counter)   
//   );

// endmodule

// //------------------------------------------------------------------------
// // Datapath
// //------------------------------------------------------------------------

// module imuldiv_IntDivIterativeDpath
// #(
//   parameter INPUT_SZ = 32
// )
// (
//   input         clk,
//   input         reset,

//   input         divreq_msg_fn,      // Function of MulDiv Unit
//   input  [INPUT_SZ-1:0] divreq_msg_a,       // Operand A
//   input  [INPUT_SZ-1:0] divreq_msg_b,       // Operand B
//   // input         divreq_val,         // Request val Signal
//   // output        divreq_rdy,         // Request rdy Signal

//   output [2*INPUT_SZ-1:0] divresp_msg_result, // Result of operation
//   // output        divresp_val,        // Response val Signal
//   // input         divresp_rdy,        // Response rdy Signal

//   input a_mux_sel,
//   input a_en,
//   input b_en,
//   input sub_mux_sel,
//   input div_sign_mux_sel,
//   input rem_sign_mux_sel,
//   input b_mux_sel,
//   input sign_en,

//   output div_sign,
//   output rem_sign,
//   output sub_out_64,
//   output [$clog2(INPUT_SZ)-1:0] counter
// );
//   // //----------------------------------------------------------------------
//   // // Main Logic
//   // //----------------------------------------------------------------------
//   wire sign_bit_a 
//     = ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED ) ? divreq_msg_a[INPUT_SZ-1]
//     : ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? 0
//     : 1'bx;

//   wire sign_bit_b
//     = ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_SIGNED ) ? divreq_msg_b[INPUT_SZ-1]
//     : ( divreq_msg_fn == `IMULDIV_DIVREQ_MSG_FUNC_UNSIGNED ) ? 0
//     : 1'bx;

//   wire [INPUT_SZ-1:0] unsigned_a, unsigned_b;
//   assign unsigned_a = ( sign_bit_a ) ? (~divreq_msg_a + 1'b1) : divreq_msg_a;
//   assign unsigned_b = ( sign_bit_b ) ? (~divreq_msg_b + 1'b1) : divreq_msg_b;

//   wire [2*INPUT_SZ:0] extended_a, extended_b;
//   // assign extended_a = {33'b0, unsigned_a};
//   assign extended_a = {{(INPUT_SZ+1){1'b0}}, unsigned_a};
//   assign extended_b = {1'b0, unsigned_b, {INPUT_SZ{1'b0}}};

//   wire [2*INPUT_SZ:0] a_mux = a_mux_sel ? extended_a : sub_mx_out;

//   reg [2*INPUT_SZ:0] a_reg, b_reg;
//   always @(posedge clk) begin
//     a_reg <= a_en ? a_mux : a_reg;
//     b_reg <= b_en ? extended_b : b_reg;
//   end

//   wire [2*INPUT_SZ:0] a_shift_out = a_reg << 1;
//   wire [2*INPUT_SZ:0] sub_out = a_shift_out - b_reg;

//   assign sub_out_64 = sub_out[2*INPUT_SZ];

//   wire [2*INPUT_SZ:0] sub_mx_out = sub_mux_sel ? {sub_out[2*INPUT_SZ:1], 1'b1} : a_shift_out;

//   wire [2*INPUT_SZ-1:0] signed_rem = ~a_reg[2*INPUT_SZ-1:INPUT_SZ] + 1'b1;
//   wire [INPUT_SZ-1:0] signed_div = ~a_reg[INPUT_SZ-1: 0] + 1'b1;

//   wire [INPUT_SZ-1:0] signed_rem_mux_out = rem_sign_mux_sel ? signed_rem : a_reg[2*INPUT_SZ-1:INPUT_SZ];
//   wire [INPUT_SZ-1:0] signed_div_mux_out = div_sign_mux_sel ? signed_div : a_reg[INPUT_SZ-1: 0];

//   assign divresp_msg_result = {signed_rem_mux_out, signed_div_mux_out};

//   // //----------------------------------------------------------------------
//   // // Sign Logic
//   // //----------------------------------------------------------------------
//   reg div_sign_reg, rem_sign_reg;
//   always @(posedge clk) begin
//     div_sign_reg <= sign_en ? sign_bit_a ^ sign_bit_b : div_sign_reg;
//     rem_sign_reg <= sign_en ? sign_bit_a : rem_sign_reg;
//   end

//   assign div_sign = div_sign_reg;
//   assign rem_sign = rem_sign_reg;

//   // //----------------------------------------------------------------------
//   // // Counter Logic
//   // //----------------------------------------------------------------------  
//   reg [$clog2(INPUT_SZ)-1:0] counter_reg;

//   always @(posedge clk) begin
//     if (reset) begin
//       counter_reg <= INPUT_SZ-1;
//     end else if (b_mux_sel) begin
//       counter_reg <= INPUT_SZ-1;
//     end else if (counter_reg != 0) begin
//       counter_reg <= counter_reg - 1;
//     end
//   end

//   assign counter = counter_reg;

// endmodule

// //------------------------------------------------------------------------
// // Control Logic
// //------------------------------------------------------------------------

// module imuldiv_IntDivIterativeCtrl
// #(
//   parameter INPUT_SZ = 32
// )
// (
//   input         clk,
//   input         reset,

//   input         divreq_val,         // Request val Signal
//   output        divreq_rdy,         // Request rdy Signal

//   output        divresp_val,        // Response val Signal
//   input         divresp_rdy,        // Response rdy Signal

//   output a_mux_sel,
//   output a_en,
//   output b_en,
//   output sub_mux_sel,
//   output div_sign_mux_sel,
//   output rem_sign_mux_sel,
//   output b_mux_sel,
//   output sign_en,

//   input div_sign,
//   input rem_sign,
//   input sub_out_64,
//   input [$clog2(INPUT_SZ)-1:0] counter
// );

//   reg [1:0] state;
//   localparam IDLE   = 2'd0;
//   localparam RUN    = 2'd1;
//   localparam FINISH = 2'd2;

//   assign divreq_rdy = (state == IDLE);
//   assign divresp_val = (state == FINISH);

//   always @(posedge clk or posedge reset) begin
//     if (reset) begin
//       state <= IDLE;
//     end else begin
//       case (state)
//         IDLE: begin
//           if (divreq_val) begin
//             state <= RUN;
//           end
//         end
//         RUN: begin
//           if (counter == 5'd0) begin
//             state <= FINISH;
//           end
//         end
//         FINISH: begin
//           if (divresp_rdy) begin
//             state <= IDLE;
//           end
//         end
//       endcase
//     end
//   end

//   // Control signal assignments
//   assign a_mux_sel        = (state == IDLE);
//   assign b_mux_sel        = (state == IDLE);
//   assign a_en             = (state == IDLE || state == RUN);
//   assign b_en             = (state == IDLE);
//   assign sub_mux_sel      = ~sub_out_64;
//   assign div_sign_mux_sel = div_sign;
//   assign rem_sign_mux_sel = rem_sign;
//   assign sign_en          = (state == IDLE);

// endmodule

// `endif