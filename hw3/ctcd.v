
`timescale 1ps/1fs

module ctdc (
    input wire In_PW_in,
    input wire EN_n_in,
    output wire pos_lead_neg_out,
    output wire R_pos_out,
    output wire R_neg_out
);

    wire mrk_pos;
    wire mrk_neg;
    wire R_pos;
    wire R_neg;
    wire pos_lead_neg;

    
    pulse2marker_pair pulse2marker_pair1(.pulse_in(In_PW_in), .marker1_out(mrk_pos), .marker2_out(mrk_neg), .en_in(EN_n_in));

    loop_pos loop_pos1(.pulse_in(mrk_pos), .pulse_out(R_pos), .en_in(EN_n_in));
    loop_neg loop_neg1(.pulse_in(mrk_neg), .pulse_out(R_neg), .en_in(EN_n_in));

    
    bbpd bbpd1(.pulse1_in(R_pos), .pulse2_in(R_neg), .S_out(pos_lead_neg), .R_out(), .en_in(EN_n_in));
    
    CLKBUFX2 BUF1( .A(R_pos), .Y(R_pos_out) );
    CLKBUFX2 BUF2( .A(pos_lead_neg), .Y(pos_lead_neg_out) );
    
endmodule




module loop_pos (
    input wire pulse_in,
    output wire pulse_out,
    input wire en_in
);

    wire OA_output;
    wire pwstd_output;
    wire dl_output;

    AO22X1 AO1( .A0(pulse_in), .A1(en_in), .B0(en_in), .B1(pulse_out), .Y(OA_output) );
    pwstd pwstd1(.pulse_in(OA_output), .pulse_out(pwstd_output));

    dl_x2 dl1(.pulse_in(pwstd_output), .pulse_out(dl_output));

    dl_large dl_large1(.pulse_in(dl_output), .pulse_out(pulse_out));
    
endmodule


module loop_neg (
    input wire pulse_in,
    output wire pulse_out,
    input wire en_in
);

    wire OA_output;
    wire pwstd_output;
    wire dl_output;

    AO22X1 AO1( .A0(pulse_in), .A1(en_in), .B0(en_in), .B1(pulse_out), .Y(OA_output) );
    pwstd pwstd1(.pulse_in(OA_output), .pulse_out(pwstd_output));

    dl_x1 dl1(.pulse_in(pwstd_output), .pulse_out(dl_output));

    dl_large dl_large1(.pulse_in(dl_output), .pulse_out(pulse_out));
    
endmodule



/* ####### bbpd ############################################################################# */


module bbpd(
        input wire pulse1_in,        
        input wire pulse2_in,        
        output wire S_out,        
        output wire R_out,        
        input wire en_in        
);

wire dff1_out;
wire dff2_out;
wire rst_n;
wire n1, n2;

DFFRQX2  DFF1( .D(1'b1), .CK(pulse1_in), .RN(rst_n), .Q(dff1_out) );
DFFRQX2  DFF2( .D(1'b1), .CK(pulse2_in), .RN(rst_n), .Q(dff2_out) );

CLKNAND2X2 U5 ( .A(dff1_out), .B(dff2_out), .Y(n1) );
CLKNAND2X2 U6 ( .A(n1), .B(en_in), .Y(n2) );
INVX2 I1(.A(n2), .Y(rst_n));

wire S_out_racing;
wire R_out_racing;

CLKNAND2X2 U1 ( .A(dff1_out), .B(R_out_racing), .Y(S_out_racing) );
CLKNAND2X2 U2 ( .A(dff2_out), .B(S_out_racing), .Y(R_out_racing) );

CLKNAND2X2 U3 ( .A(S_out_racing), .B(R_out), .Y(S_out) );
CLKNAND2X2 U4 ( .A(R_out_racing), .B(S_out), .Y(R_out) );

endmodule



/* ####### pwstd ############################################################################# */

module pwstd(
        input wire pulse_in,         
        output wire pulse_out             
);

    parameter n = 13;
    wire idl_output;
    wire [n:0] net;

    assign net[0] = pulse_in;
    generate
        genvar i;
            for (i=0; i<n; i=i+1) begin : gen_db_large
                INVX2 I_i(.A(net[i]), .Y(net[i+1]));
            end
    endgenerate 
    assign idl_output = net[n];

    NOR2X1 NOR21( .A(idl_output), .B(pulse_in), .Y(pulse_out));

endmodule


module idl_pwstd(input wire pulse_in, output wire pulse_out);


    parameter n = 7;
    wire [n:0] net;

    assign net[0] = pulse_in;
    generate
        genvar i;
            for (i=0; i<n; i=i+1) begin : gen_db_large
                INVX2 I_i(.A(net[i]), .Y(net[i+1]));
            end
    endgenerate 
    assign pulse_out = net[n];


endmodule


/* ####### dl_large ############################################################################# */

module dl_large(
        output wire pulse_out,
        input wire pulse_in
);

    parameter n = 80;
    wire [n:0] net;

    assign net[0] = pulse_in;
    generate
        genvar i;
            for (i=0; i<n; i=i+1) begin : gen_db_large
                db_large db_large_i(.pulse_in(net[i]), .pulse_out(net[i+1])); 
            end
    endgenerate 
    assign pulse_out = net[n];


endmodule

module db_large (output wire pulse_out, input wire pulse_in);

    wire n1;
    INVX2 I1(.A(pulse_in), .Y(n1));
    INVX2 I2(.A(n1), .Y(pulse_out));

endmodule

/* ####### dl_x1, dl_x2 ############################################################################# */



module dl_x1 (input wire pulse_in, output wire pulse_out );

    parameter n = 1;

    wire [n:0] net;

    assign net[0] = pulse_in;
    generate
        genvar i;
            for (i=0; i<n; i=i+1) begin : gen_delay_block
                db_x1 db_x1_i(.pulse_in(net[i]), .pulse_out(net[i+1]));
            end
    endgenerate
    assign pulse_out = net[n];
endmodule

module db_x1 (output wire pulse_out, input wire pulse_in);

    wire n1;
    INVX2 I1(.A(pulse_in), .Y(n1));
    INVX2 I2(.A(n1), .Y(pulse_out));

endmodule




module dl_x2 (input wire pulse_in, output wire pulse_out );

    parameter n = 1;

    wire [n:0] net;

    assign net[0] = pulse_in;
    generate
        genvar i;
            for (i=0; i<n; i=i+1) begin : gen_delay_block
                db_x2 db_x2_i(.pulse_in(net[i]), .pulse_out(net[i+1]));
            end
    endgenerate
    assign pulse_out = net[n];
endmodule

module db_x2 (output wire pulse_out, input wire pulse_in);

    wire n1;
    INVX3 I1(.A(pulse_in), .Y(n1));
    INVX3 I2(.A(n1), .Y(pulse_out));

endmodule





/* ####### pulse2marker_pair ############################################################################# */


`timescale 1ps/1fs

module pulse2marker_pair(
        input wire pulse_in,
        output wire marker1_out,
        output wire marker2_out,
        input wire en_in
);


    posedge_marker posedge_marker1(
        .pulse_in(pulse_in),
        .marker_out(marker1_out)
    );


    negedge_marker negedge_marker1(
        .pulse_in(pulse_in),
        .marker_out(marker2_out)
    );

endmodule




module posedge_marker( input wire pulse_in, output wire marker_out );

    wire n11;
    wire n12;
    wire n13;

    idl idl1(pulse_in, n11);
    CLKNAND2X2 NAND11( .A(n11), .B(pulse_in), .Y(n12) );
    INVX2 I16(.A(n12), .Y(n13));
    pel pel1(.pulse_in(n13), .pulse_out(marker_out));


endmodule



module negedge_marker( input wire pulse_in, output wire marker_out );

    wire n11;
    wire n12;
    wire n13;

    idl idl1(pulse_in, n11);
    NOR2X1 NOR21( .A(n11), .B(pulse_in), .Y(n13));
    pel pel1(.pulse_in(n13), .pulse_out(marker_out));


endmodule




module idl(input wire pulse_in, output wire pulse_out);

    wire [3:0] net1;
    INVX2 I11(.A(pulse_in), .Y(net1[0]));
    INVX2 I12(.A(net1[0]), .Y(net1[1]));
    INVX2 I13(.A(net1[1]), .Y(net1[2]));
    INVX2 I14(.A(net1[2]), .Y(net1[3]));
    INVX2 I15(.A(net1[3]), .Y(pulse_out));

endmodule



module pel(input wire pulse_in, output wire pulse_out);

    parameter n = 3;
    wire [n:0] net;

    assign net[0] = pulse_in;
    generate
        genvar i;
            for (i=0; i<n; i=i+1) begin : pulse_expansion_block
                peb peb_i(.pulse_in(net[i]), .pulse_out(net[i+1]));
            end
    endgenerate
    assign pulse_out = net[n];

endmodule


module peb(input wire pulse_in, output wire pulse_out);


    wire [2:0] net;
    INVX2 I1(.A(pulse_in), .Y(net[0]));
    INVX2 I2(.A(net[0]), .Y(net[1]));    
    NOR2X1 NOR( .A(net[1]), .B(pulse_in), .Y(net[2]));
    INVX2 I3(.A(net[2]), .Y(pulse_out));  


endmodule



