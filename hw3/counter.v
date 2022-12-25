`timescale 1ps/1fs

module counter(
        output wire [31:0] Out_code,
        input wire clk,
        input wire Reset
);
    reg [31:0] count;

    always @(posedge clk or posedge Reset) begin
        if(Reset)begin
            count <= 0;
        end
        else begin
            count <= count + 32'b1;
        end
    end

    assign Out_code = count;


endmodule
