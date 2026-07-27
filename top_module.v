`timescale 1ns / 1ps

module top(
    input  wire        clk,          // Basys 3 100 MHz clock (W5)
    input  wire        rst,          // Reset button
    input  wire [11:0] sw,           // 12 switches

    output wire [2:0]  led,          // LEDs
    output wire [3:0]  anode,        // Seven-segment anodes
    output wire [6:0]  cathode       // Seven-segment cathodes
);

    //==========================================================
    // Internal Signals
    //==========================================================

    wire clk_1MHz;
    wire clk_1kHz;

    wire [6:0] final_spikes;

    wire signed [3:0] x0;
    wire signed [3:0] x1;
    wire signed [3:0] x2;

    wire output_neuron_0;
    wire output_neuron_1;

    //==========================================================
    // Input Mapping
    //==========================================================

    assign x0 = sw[3:0];
    assign x1 = sw[7:4];
    assign x2 = sw[11:8];

    //==========================================================
    // Clock Divider
    //==========================================================

    clk_divider clk_unit (
        .clk_100MHz(clk),
        .rst(rst),
        .clk_1MHz(clk_1MHz),
        .clk_1kHz(clk_1kHz)
    );

    //==========================================================
    // Neural Processor
    //==========================================================

    neural_processor processor_unit (
        .clk_processing(clk_1MHz),
        .rst(rst),

        .x0(x0),
        .x1(x1),
        .x2(x2),

        .total_spikes(final_spikes),

        .output_neuron_0(output_neuron_0),
        .output_neuron_1(output_neuron_1)
    );

    //==========================================================
    // LED Outputs
    //==========================================================

    assign led[0] = output_neuron_0;
    assign led[1] = output_neuron_1;
    assign led[2] = 1'b0;

    //==========================================================
    // Seven Segment Display
    //==========================================================

    seven_seg_driver display_unit (
        .clk_display(clk_1kHz),
        .rst(rst),

        .binary_value(final_spikes),

        .anode(anode),
        .cathode(cathode)
    );

endmodule
