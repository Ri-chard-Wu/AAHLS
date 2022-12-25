

`timescale 1ps/1fs

`include "ctdc.v"
`include "counter.v"

module top(
        output wire R_out,
        input wire In_PW,
        input wire EN_n,
        output wire [31:0] Out_code,
        input wire Reset,
        output wire [7:0] computed_pulse_width,
        output reg [31:0] n_lead_pulses
        
);

wire pos_lead_neg;
wire R_pos;
parameter psm = 7;


ctdc ctdc1(.In_PW_in(In_PW), .EN_n_in(EN_n), .pos_lead_neg_out(pos_lead_neg), .R_pos_out(R_pos), .R_neg_out());

counter counter1( .Out_code(Out_code), .clk(R_pos), .Reset(Reset));

always @(negedge pos_lead_neg)begin

    n_lead_pulses <= Out_code;

end

assign computed_pulse_width = psm * (n_lead_pulses + 1);

endmodule
