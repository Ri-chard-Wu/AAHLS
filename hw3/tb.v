

`timescale 1ps/1fs

module testbench;

parameter t_sep = 250000;

parameter w1 = 100;
parameter w2 = 125;
parameter w3 = 150;
parameter w4 = 175;
parameter w5 = 200;



reg pulse_in;
reg en_in;
reg Reset;
wire [7:0] computed_pulse_width;

top top1(
    .R_out(),
    .In_PW(pulse_in),
    .EN_n(en_in),
    .Out_code(),
    .Reset(Reset),
    .computed_pulse_width(computed_pulse_width)

);

initial begin
        $sdf_annotate("./top_syn.sdf", top1);
        $fsdbDumpfile("./top_syn.fsdb");
        $fsdbDumpvars;
end

initial begin

    en_in = 0;
    Reset = 1;
    pulse_in = 0; #5000;

    Reset = 0;
    en_in = 1; #10000;

    pulse_in = 1; #(w1);
    pulse_in = 0; #(t_sep);

    Reset = 1; en_in = 0; #5000;
    Reset = 0; en_in = 1; #5000;

    pulse_in = 1; #(w2);
    pulse_in = 0; #(t_sep);



    Reset = 1; en_in = 0; #5000;
    Reset = 0; en_in = 1; #5000;

    pulse_in = 1; #(w3);
    pulse_in = 0; #(t_sep);



    Reset = 1; en_in = 0; #5000;
    Reset = 0; en_in = 1; #5000;
    
    pulse_in = 1; #(w4);
    pulse_in = 0; #(t_sep);



    Reset = 1; en_in = 0; #5000;
    Reset = 0; en_in = 1; #5000;
    
    pulse_in = 1; #(w5);
    pulse_in = 0; #(t_sep);

    #20000 $finish;

end


endmodule

