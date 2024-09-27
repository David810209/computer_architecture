// //========================================================================
// // Lab 1 - Iterative Mul Unit
// //========================================================================

// `ifndef RISCV_INT_MUL_ITERATIVE_V
// `define RISCV_INT_MUL_ITERATIVE_V

// module imuldiv_IntMulIterative
// (
//   input                clk,
//   input                reset,

//   input  [31:0] mulreq_msg_a,
//   input  [31:0] mulreq_msg_b,
//   input         mulreq_val,
//   output        mulreq_rdy,

//   output [63:0] mulresp_msg_result,
//   output        mulresp_val,
//   input         mulresp_rdy
// );

//   imuldiv_IntMulIterativeDpath dpath
//   (
//     .clk                (clk),
//     .reset              (reset),
//     .mulreq_msg_a       (mulreq_msg_a),
//     .mulreq_msg_b       (mulreq_msg_b),
//     .mulreq_val         (mulreq_val),
//     .mulreq_rdy         (mulreq_rdy),
//     .mulresp_msg_result (mulresp_msg_result),
//     .mulresp_val        (mulresp_val),
//     .mulresp_rdy        (mulresp_rdy)
//   );

//   imuldiv_IntMulIterativeCtrl ctrl
//   (
//   );

// endmodule

// //------------------------------------------------------------------------
// // Datapath
// //------------------------------------------------------------------------

// module imuldiv_IntMulIterativeDpath
// (
//   input         clk,
//   input         reset,

//   input  [31:0] mulreq_msg_a,       // Operand A
//   input  [31:0] mulreq_msg_b,       // Operand B
//   input         mulreq_val,         // Request val Signal
//   output        mulreq_rdy,         // Request rdy Signal

//   output [63:0] mulresp_msg_result, // Result of operation
//   output        mulresp_val,        // Response val Signal
//   input         mulresp_rdy         // Response rdy Signal
// );

//   //----------------------------------------------------------------------
//   // Sequential Logic
//   //----------------------------------------------------------------------

//   reg  [63:0] a_reg;       // Register for storing operand A
//   reg  [31:0] b_reg;       // Register for storing operand B
//   reg         val_reg;     // Register for storing valid bit

//   always @( posedge clk ) begin

//     // Stall the pipeline if the response interface is not ready
//     if ( mulresp_rdy ) begin
//       a_reg   <= mulreq_msg_a;
//       b_reg   <= mulreq_msg_b;
//       val_reg <= mulreq_val;
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

//   wire [63:0] unsigned_result = unsigned_a * unsigned_b;

//   // Determine whether or not result is signed. Usually the result is
//   // signed if one and only one of the input operands is signed. In other
//   // words, the result is signed if the xor of the sign bits of the input
//   // operands is true. Remainder opeartions are a bit trickier, and here
//   // we simply assume that the result is signed if the dividend for the
//   // rem operation is signed.

//   wire is_result_signed = sign_bit_a ^ sign_bit_b;

//   assign mulresp_msg_result
//     = ( is_result_signed ) ? (~unsigned_result + 1'b1) : unsigned_result;

//   // Set the val/rdy signals. The request is ready when the response is
//   // ready, and the response is valid when there is valid data in the
//   // input registers.

//   assign mulreq_rdy  = mulresp_rdy;
//   assign mulresp_val = val_reg;

// endmodule

// //------------------------------------------------------------------------
// // Control Logic
// //------------------------------------------------------------------------

// module imuldiv_IntMulIterativeCtrl
// (
// );

// endmodule

// `endif

//========================================================================
// Lab 1 - Iterative Mul Unit
//========================================================================

`ifndef RISCV_INT_MUL_ITERATIVE_V
`define RISCV_INT_MUL_ITERATIVE_V

module imuldiv_IntMulIterative (
  input         clk,
  input         reset,

  input  [31:0] mulreq_msg_a,        // Operand A
  input  [31:0] mulreq_msg_b,        // Operand B
  input         mulreq_val,          // Request valid signal
  output        mulreq_rdy,          // Request ready signal

  output [63:0] mulresp_msg_result,  // Result of operation
  output        mulresp_val,         // Response valid signal
  input         mulresp_rdy          // Response ready signal   
);

  wire a_mux_sel;
  wire b_mux_sel;
  wire result_mux_sel;
  wire add_mux_sel;
  wire result_en;
  wire [4:0] counter;
  wire sign_en;

  imuldiv_IntMulIterativeDpath dpath (
    //system signal
    .clk(clk),
    .reset(reset),

    //counter 
    .counter(counter),

    //sign
    .sign_en(sign_en),

    //a reg b reg
    .mulreq_msg_a(mulreq_msg_a),
    .mulreq_msg_b(mulreq_msg_b),
    .a_mux_sel(a_mux_sel),
    .b_mux_sel(b_mux_sel),

    //result reg
    .mulresp_msg_result(mulresp_msg_result),
    .result_mux_sel(result_mux_sel),
    .add_mux_sel(add_mux_sel),
    .result_en(result_en)
  );

  imuldiv_IntMulIterativeCtrl ctrl (
    //system signals
    .clk(clk),
    .reset(reset),

    //counter
    .counter(counter),

    //sign reg
    .sign_en(sign_en),

    //a reg
    .a_mux_sel(a_mux_sel),

    //b reg
    .b_mux_sel(b_mux_sel),
    
    //result reg
    .result_mux_sel(result_mux_sel),
    .add_mux_sel(add_mux_sel),
    .result_en(result_en),

    //val/rdy
    .mulreq_val(mulreq_val),
    .mulreq_rdy(mulreq_rdy),
    .mulresp_val(mulresp_val),
    .mulresp_rdy(mulresp_rdy)
  );

endmodule



// //------------------------------------------------------------------------
// // Datapath
// //------------------------------------------------------------------------

module imuldiv_IntMulIterativeDpath (
  //system signal
  input         clk,
  input         reset,

  //counter
   output     [4:0]  counter,

   //sign 
   input         sign_en,      // Enable signal for shifting B register

   //a reg b reg
  input  [31:0] mulreq_msg_a,        // Operand A
  input  [31:0] mulreq_msg_b,        // Operand B
  input         a_mux_sel,           // Mux selector for A
  input         b_mux_sel,           // Mux selector for B

  //result reg
  output [63:0] mulresp_msg_result,  // Result of operation
  input         result_mux_sel,      // Mux selector for Result
  input         add_mux_sel,         // Mux selector for Add
  input         result_en           // Enable signal for result register
  
 
);

  //counter
  reg [4:0] counter_reg;
  always @(posedge clk) begin
    if (reset) begin
      counter_reg <= 5'd31;
    end else begin
      counter_reg<= (b_mux_sel) ? counter_reg - 1 : counter_reg;
    end
  end
  assign counter = counter_reg;

  //sign
  reg sign_reg;

  always @(posedge clk) begin
    if (reset) begin
      sign_reg <= 0;
    end else begin
      sign_reg = (sign_en) ? mulreq_msg_a[31] ^ mulreq_msg_b[31] : sign_reg;
    end
  end

  //a reg b reg
  wire [63:0] unsigned_a = (mulreq_msg_a[31]) ? ({32'b0, ~mulreq_msg_a + 1'b1}) : {32'b0, mulreq_msg_a};
  wire [31:0] unsigned_b = (mulreq_msg_b[31]) ? (~mulreq_msg_b + 1'b1) : mulreq_msg_b;
  
  reg [63:0] a_reg;
  reg [31:0] b_reg;
  reg [63:0] result_reg;
  reg [63:0] mulresp_msg_result;

  always @(posedge clk) begin
    if (reset) begin
      a_reg <= 64'b0;
    end else begin
      a_reg <= (a_mux_sel) ? a_reg << 1 : unsigned_a;
    end
  end


  always @(posedge clk) begin
    if (reset) begin
      b_reg <= 64'b0;
    end else begin
      b_reg <= (b_mux_sel) ? b_reg >> 1 : unsigned_b;
    end
  end


  //result reg
  always @(posedge clk) begin
    if (reset) begin
      result_reg <= 64'b0;  
    end else begin
      result_reg = (result_mux_sel) ? (b_reg[0]) ? result_reg + a_reg : result_reg : 64'b0;
    end
  end

  always @(posedge clk) begin
    if (reset) begin 
      mulresp_msg_result <= 64'b0;
    end 
    else mulresp_msg_result <=  (result_en) ? (sign_reg) ? (~result_reg + 1'b1) : result_reg : 64'b0;
  

  end


endmodule



//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------
module imuldiv_IntMulIterativeCtrl (
  //system signals
  input         clk,
  input         reset,

  //counter
  input [4:0]   counter,

  //sign reg
  output   sign_en,
  
  //a reg
  output     a_mux_sel,

  //b reg
  output    b_mux_sel,

  //result reg
  output     result_mux_sel,
  output    add_mux_sel,
  output    result_en,

  //val/rdy 
  input         mulreq_val,  // The request val signal should be set high when new operands are available for the muldiv unit
  output    mulreq_rdy,  // request rdy signal should be high when the muldiv unit is ready to accept new operands
  output     mulresp_val, // the response val signal should go high when the result is valid and ready
  input         mulresp_rdy  // the response rdy signal should be high when the result is ready to be accepted by the next module
);

  reg [1:0] S;
  reg [1:0] S_next;
  localparam S_IDLE = 2'd0,
             S_CAL = 2'd1,
             S_DONE = 2'd2;

   always @(posedge clk) begin
      if (reset) begin
        S <= S_IDLE;
      end else begin
        S <= S_next;
      end
    end

  always @(*) begin
      S_next = S;
      case (S)
        S_IDLE: 
          if (mulreq_val) S_next <= S_CAL;
        S_CAL: 
          if (counter == 0) S_next <= S_DONE; 
          else S_next <= S_CAL;
        
        S_DONE: 
          if(mulresp_rdy)
            S_next <= S_IDLE;
      endcase
  end

  assign mulreq_rdy = (S == S_IDLE);
  assign sign_en = (S == S_IDLE || S == S_DONE);
  assign a_mux_sel = (S == S_CAL);
  assign b_mux_sel = (S == S_CAL);
  assign result_mux_sel = (S == S_CAL);
  assign add_mux_sel = (S == S_CAL);
  assign result_en = (S == S_CAL);
  assign mulresp_val = (S == S_DONE);
 
    
endmodule


`endif