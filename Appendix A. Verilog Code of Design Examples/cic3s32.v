//*********************************************************
// IEEE STD 1364-2001 Verilog file: cic3s32.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************

module cic3s32  //----> Interface
( input  clk,  // System clock
  input  reset,  // Asynchronous reset
  input signed [7:0] x_in, // System input
  output signed [9:0] y_out,// System output
  output reg clk2);  // Clock divider

// --------------------------------------------------------
parameter hold=0, sample=1;
reg [1:0] state;
reg [4:0] count;
reg signed [7:0] x;  // Registered input
reg signed [25:0] i0;  // I section 0
reg signed [20:0] i1;  // I section 1
reg signed [15:0] i2;  // I section 2
reg signed [13:0] i2d1, i2d2, c1, c0;  // I+C0
reg signed [12:0] c1d1, c1d2, c2;  // COMB 1
reg signed [11:0] c2d1, c2d2, c3;  // COMB 2

always @(posedge clk or posedge reset) begin : FSM
    if (reset) begin  // Asynchronous reset
        count <= 0;
        state <= hold;
        clk2 <= 0;
    end else begin
        if (count == 31) begin
            count <= 0;
            state <= sample;
            clk2 <= 1;
        end else begin
            count <= count + 1;
            state <= hold;
            clk2 <= 0;
        end
    end
end

always @(posedge clk or posedge reset) begin : Int  // 3 stage integrator sections
    if (reset) begin // Asynchronous clear
        x <= 0; 
        i0 <= 0; 
        i1 <= 0; 
        i2 <= 0;
    end else begin
        x  <= x_in;
        i0 <= i0 + x;
        i1 <= i1 + i0[25:5];
        i2 <= i2 + i1[20:5];
    end
end

always @(posedge clk or posedge reset) begin : Comb  // 3 stage comb sections
    if (reset) begin // Asynchronous clear
        c0 <= 0; 
        c1 <= 0; 
        c2 <= 0; 
        c3 <= 0;
        i2d1 <= 0; 
        i2d2 <= 0; 
        c1d1 <= 0; 
        c1d2 <= 0;
        c2d1 <= 0; 
        c2d2 <= 0;
    end else if (state == sample) begin
        c0  <= i2[15:2];
        i2d1 <= c0;
        i2d2 <= i2d1;
        c1  <= c0 - i2d2;
        c1d1 <= c1[13:1];
        c1d2 <= c1d1;
        c2  <= c1[13:1] - c1d2;
        c2d1 <= c2[12:1];
        c2d2 <= c2d1;
        c3  <= c2[12:1] - c2d2;
    end
end

assign y_out = c3[11:2];

endmodule