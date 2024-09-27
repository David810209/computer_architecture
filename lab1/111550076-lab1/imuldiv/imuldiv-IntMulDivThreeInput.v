//========================================================================
// Lab 1 - Three Input Iterative Mul/Div Unit
//========================================================================

`ifndef RISCV_INT_MULDIV_THREEINPUT_V
`define RISCV_INT_MULDIV_THREEINPUT_V

`include "imuldiv-ThreeMulDivReqMsg.v"
`include "imuldiv-IntMulIterative.v"
`include "imuldiv-DivReqMsg.v"

module imuldiv_IntMulDivThreeInput
(
  input         clk,
  input         reset,

  input   [2:0] muldivreq_msg_fn,
  input  [31:0] muldivreq_msg_a,
  input  [31:0] muldivreq_msg_b,
  input  [31:0] muldivreq_msg_c,
  input         muldivreq_val,
  output        muldivreq_rdy,

  output [95:0] muldivresp_msg_result,
  output        muldivresp_val,
  input         muldivresp_rdy
);
  

  wire [63:0] mulresp_msg_bc_result;
  wire [95:0] mulresp_msg_result;
  wire [95:0] divresp_msg_result;
  wire        mulreq_val_32;
  wire       mulreq_rdy_32;
  wire       mulresp_val_32;
  wire       mulresp_rdy_32;

  wire       mulreq_val_64;
  wire       mulreq_rdy_64;
  wire       mulresp_val_64;
  wire       mulresp_rdy_64;

  wire       divreq_val_64;
  wire       divreq_rdy_64;
  wire       divresp_rdy_64;
  wire       divresp_val_64;

  assign mulreq_val_32 =  muldivreq_val;
  // assign mulresp_rdy_32 = mulreq_rdy_64 ;
  assign mulresp_rdy_32 = fn_reg == `IMULDIV_THREE_MULDIVREQ_MSG_FUNC_MUL ? mulreq_rdy_64 : divreq_rdy_64;
  assign mulreq_val_64 = mulresp_val_32 && fn_reg == `IMULDIV_THREE_MULDIVREQ_MSG_FUNC_MUL;
  // assign mulreq_val_64 = mulresp_val_32;
  assign divreq_val_64 = mulresp_val_32 && fn_reg != `IMULDIV_THREE_MULDIVREQ_MSG_FUNC_MUL;
  assign mulresp_rdy_64 = muldivresp_rdy;
  assign divresp_rdy_64 = muldivresp_rdy;

  reg  [31:0] a_reg;
  reg [2:0] fn_reg;
  reg start;
  always @(posedge clk)begin
    if(reset) begin
      a_reg <= muldivreq_msg_a;
      fn_reg = muldivreq_msg_fn;
    end

    else begin
      if(muldivreq_val)begin
        a_reg <= muldivreq_msg_a;
        fn_reg = muldivreq_msg_fn;
      end
    end
  end

  reg [31:0] a_reg_2;
  
  always @(posedge clk)begin
    if(reset) begin
      a_reg_2 <= 32'b0;
      start <= 0;
    end

    else begin
      if(!start)
      begin
        if(muldivreq_val) start = 1;
        a_reg_2 = muldivreq_msg_a;
      end
      else if(mulresp_val_32)begin
        a_reg_2 <= a_reg;
      end
    end
  end

  reg [63:0] result_32_reg;
  
  always @(posedge clk)begin
    if(reset) begin
      result_32_reg <= 64'b0;
    end

    else begin
      if(mulresp_val_32)begin
        result_32_reg <= mulresp_msg_bc_result;
      end
    end
  end


 // TODO
   imuldiv_IntMulIterative imul_32
  (
    .clk                (clk),
    .reset              (reset),
    .mulreq_msg_a       (muldivreq_msg_b),
    .mulreq_msg_b       (muldivreq_msg_c),
    .mulreq_val         (mulreq_val_32),
    .mulreq_rdy         (mulreq_rdy_32),
    .mulresp_msg_result (mulresp_msg_bc_result),
    .mulresp_val        (mulresp_val_32),
    .mulresp_rdy        (mulresp_rdy_32)
  );

  imuldiv_IntMulIterative_64 imul_64(
    .clk                (clk),
    .reset              (reset),
    // .mulreq_msg_a       (result_32_reg),
    .mulreq_msg_b       (a_reg_2),
    .mulreq_msg_a       (mulresp_msg_bc_result),
    // .mulreq_msg_b       (muldivreq_msg_a),
    .mulreq_val         (mulreq_val_64),
    .mulreq_rdy         (mulreq_rdy_64),
    .mulresp_msg_result (mulresp_msg_result),
    .mulresp_val        (mulresp_val_64),
    .mulresp_rdy        (mulresp_rdy_64)

  );

  imuldiv_IntDivIterative_64 idiv_64
  (
    .clk                (clk),
    .reset              (reset),
    .divreq_msg_fn      (fn_reg == `IMULDIV_THREE_MULDIVREQ_MSG_FUNC_DIVU || fn_reg == `IMULDIV_THREE_MULDIVREQ_MSG_FUNC_REMU),
    .divreq_msg_a       (a_reg_2),
    .divreq_msg_b       (mulresp_msg_bc_result[31:0]),
    .divreq_val         (divreq_val_64),
    .divreq_rdy         (divreq_rdy_64),
    .divresp_msg_result (divresp_msg_result),
    .divresp_val        (divresp_val_64),
    .divresp_rdy        (divresp_rdy_64)
  );




  assign muldivreq_rdy = mulreq_rdy_32 ;
  assign muldivresp_val = fn_reg == `IMULDIV_THREE_MULDIVREQ_MSG_FUNC_MUL ? mulresp_val_64 : divresp_val_64;
  // assign muldivresp_val =  mulresp_val_64 ;
  assign muldivresp_msg_result = (fn_reg == `IMULDIV_THREE_MULDIVREQ_MSG_FUNC_MUL)? mulresp_msg_result : divresp_msg_result;
  // assign muldivresp_msg_result = mulresp_msg_result;

endmodule 

// mul 64
module imuldiv_IntMulIterative_64 (
  input         clk,
  input         reset,

  input  [63:0] mulreq_msg_a,        // Operand A
  input  [31:0] mulreq_msg_b,        // Operand B
  input         mulreq_val,          // Request valid signal
  output        mulreq_rdy,          // Request ready signal

  output [95:0] mulresp_msg_result,  // Result of operation
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

  imuldiv_IntMulIterativeDpath_64 dpath_64 (
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

  imuldiv_IntMulIterativeCtrl_64 ctrl_64 (
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

module imuldiv_IntMulIterativeDpath_64 (
  //system signal
  input         clk,
  input         reset,

  //counter
   output     [4:0]  counter,

   //sign 
   input         sign_en,      // Enable signal for shifting B register

   //a reg b reg
  input  [63:0] mulreq_msg_a,        // Operand A
  input  [31:0] mulreq_msg_b,        // Operand B
  input         a_mux_sel,           // Mux selector for A
  input         b_mux_sel,           // Mux selector for B

  //result reg
  output [95:0] mulresp_msg_result,  // Result of operation
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
      sign_reg = (sign_en) ? mulreq_msg_a[63] ^ mulreq_msg_b[31] : sign_reg;
    end
  end

  //a reg b reg
  wire [63:0] unsigned_a = (mulreq_msg_a[63]) ? (~mulreq_msg_a + 1'b1) : mulreq_msg_a;
  wire [31:0] unsigned_b = (mulreq_msg_b[31]) ? (~mulreq_msg_b + 1'b1) : mulreq_msg_b;
  
  reg [63:0] a_reg;
  reg [31:0] b_reg;
  reg [95:0] result_reg;
  reg [95:0] mulresp_msg_result;

  always @(posedge clk) begin
    if (reset) begin
      a_reg <= 64'b0;
    end else begin
      a_reg <= (a_mux_sel) ? a_reg << 1 : unsigned_a;
    end
  end


  always @(posedge clk) begin
    if (reset) begin
      b_reg <= 32'b0;
    end else begin
      b_reg <= (b_mux_sel) ? b_reg >> 1 : unsigned_b;
    end
  end


  //result reg
  always @(posedge clk) begin
    if (reset) begin
      result_reg <= 96'b0;  
    end else begin
      result_reg = (result_mux_sel) ? (b_reg[0]) ? result_reg + a_reg : result_reg : 96'b0;
    end
  end

  always @(posedge clk) begin
    if (reset) begin 
      mulresp_msg_result <= 96'b0;
    end 
    else mulresp_msg_result <=  (result_en) ? (sign_reg) ? (~result_reg + 1'b1) : result_reg : 96'b0;
  

  end


endmodule



//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------
module imuldiv_IntMulIterativeCtrl_64 (
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
          if (counter == 0 && mulresp_rdy) S_next <= S_DONE; 
          else S_next <= S_CAL;
        
        S_DONE: 
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


//--------------div 64---------------------------------



module imuldiv_IntDivIterative_64
(

  input         clk,
  input         reset,

  input         divreq_msg_fn,
  input  [31:0] divreq_msg_a,
  input  [31:0] divreq_msg_b,
  input         divreq_val,
  output        divreq_rdy,

  output [95:0] divresp_msg_result,
  output        divresp_val,
  input         divresp_rdy
);

  wire        a_mux_sel;             
  wire        b_mux_sel;                 
  wire        sign_en;              
  wire [4:0]  counter;   


  imuldiv_IntDivIterativeDpath_64 dpath
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

  imuldiv_IntDivIterativeCtrl_64 ctrl(
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

module imuldiv_IntDivIterativeDpath_64
(
  //system signal
  input         clk,
  input         reset,

  input         divreq_msg_fn,      // Function of MulDiv Unit
  input  [31:0] divreq_msg_a,       // Operand A
  input  [31:0] divreq_msg_b,       // Operand B

  output [95:0] divresp_msg_result, // Result of operation

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
  
  reg [95:0]  divresp_msg_result;

  wire [64:0] unsigned_a = (divreq_msg_a[31] && divreq_msg_fn ==  `IMULDIV_DIVREQ_MSG_FUNC_SIGNED) ? ({33'b0, ~divreq_msg_a + 1'b1}) : {33'b0, divreq_msg_a};
  wire [64:0] unsigned_b = (divreq_msg_b[31] && divreq_msg_fn ==  `IMULDIV_DIVREQ_MSG_FUNC_SIGNED) ? ({1'b0, ~divreq_msg_b + 1'b1, 32'b0}) :  ({1'b0, divreq_msg_b, 32'b0});
  reg  [64:0] Diff  ;
  wire [64:0] diff_nxt = {Diff[64:1], 1'b1};

  always @(posedge clk) begin
    if (reset) begin
      a_reg <= 65'b0;
      Diff <= 65'b0;
      fn_reg <= 1'b0;
    end else begin
      if (a_mux_sel) begin
        if(!Diff[64])begin
          if(!counter) begin
            a_reg <= diff_nxt ;
          end
          else begin
            a_reg <= diff_nxt  << 1;
            Diff  <= ((diff_nxt << 1) ) - (b_reg);
          end
        end
        else begin
          if(!counter)begin
            a_reg <= a_reg;
          end
          else begin
            a_reg <= a_reg << 1;
            Diff  <= (a_reg << 1'b1) - (b_reg);
          end 
        end
      end 
      else begin
        a_reg <=  unsigned_a << 1'b1;
        Diff  <= (unsigned_a << 1'b1) - (unsigned_b);
        fn_reg <= divreq_msg_fn;
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
      divresp_msg_result <= 96'b0;
    end 
    else begin
      divresp_msg_result <= {16'b0, rem_result,16'b0,  div_result};
    end
  end
  

endmodule

//------------------------------------------------------------------------
// Control Logic
//------------------------------------------------------------------------

module imuldiv_IntDivIterativeCtrl_64(
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
          if (counter == 0 && divresp_rdy) S_next <= S_DONE;
        
        S_DONE: 
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
