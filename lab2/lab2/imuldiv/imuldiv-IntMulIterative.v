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
  input         result_en           // Enable signal for result register
  
 
);

  //counter
  reg [4:0] counter_reg;
  always @(posedge clk) begin
    if (reset) begin
      counter_reg <= 5'd31;
    end else if (b_mux_sel) begin
      counter_reg <= 5'd31;
    end else if (counter_reg != 0) begin
      counter_reg <= counter_reg - 1;
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
  

  always @(posedge clk) begin
    if (reset) begin
      a_reg <= 64'b0;
      b_reg <= 64'b0;
    end else begin
      a_reg <= (a_mux_sel) ? unsigned_a : a_reg << 1;
      b_reg <= (b_mux_sel) ? unsigned_b : b_reg >> 1;
    end
  end


  //result reg
  reg [63:0] result_reg;
  wire [63:0] result_mux;
  assign result_mux = result_mux_sel ? 0 : (~b_reg[0] ? result_reg : a_reg + result_reg);

  always @( posedge clk ) begin
    result_reg <= result_en ? result_mux : result_reg;
  end


  assign mulresp_msg_result = ~sign_reg ? result_reg : ~result_reg + 1'b1;



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
  output    result_en,

  //val/rdy 
  input         mulreq_val,  // The request val signal should be set high when new operands are available for the muldiv unit
  output    mulreq_rdy,  // request rdy signal should be high when the muldiv unit is ready to accept new operands
  output     mulresp_val, // the response val signal should go high when the result is valid and ready
  input         mulresp_rdy  // the response rdy signal should be high when the result is ready to be accepted by the next module
);

  reg [1:0] S;
  localparam S_IDLE = 2'd0,
             S_CAL = 2'd1,
             S_DONE = 2'd2;


  always @(posedge clk or posedge reset) begin
      if (reset) begin
        S <= S_IDLE;
      end
      else begin
        case (S)
          S_IDLE: 
            if (mulreq_val) S <= S_CAL;
          S_CAL: 
            if (counter == 0) S <= S_DONE; 
          S_DONE: 
            if(mulresp_rdy) S <= S_IDLE;
        endcase
      end
  end

  assign mulreq_rdy = (S == S_IDLE);
   assign sign_en = (S == S_IDLE);
  assign a_mux_sel = (S == S_IDLE);
  assign b_mux_sel = (S == S_IDLE);
  assign result_mux_sel = (S == S_IDLE);
  assign result_en = (S == S_CAL || S == S_IDLE);
 assign mulresp_val = (S == S_DONE);
    
endmodule


`endif
