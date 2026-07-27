`timescale 1ns / 1ps

module neural_processor(
    input  wire                  clk_processing,
    input  wire                  rst,

    input  wire signed [3:0]     x0,
    input  wire signed [3:0]     x1,
    input  wire signed [3:0]     x2,

    output reg  [6:0]            total_spikes,

    output reg                   output_neuron_0,
    output reg                   output_neuron_1
);

    //==========================================================
    // Parameters
    //==========================================================

    localparam STATE_INIT      = 2'b00;
    localparam STATE_CALC      = 2'b01;
    localparam STATE_DONE      = 2'b10;

    // Reduced threshold to allow visible spike-count variation
    localparam signed [13:0] THRESHOLD = 14'sd10;

    //==========================================================
    // Internal Registers
    //==========================================================

    reg [1:0] current_state;

    reg [6:0] neuron_index;
    reg [6:0] spike_accumulator;

    reg signed [7:0] W0_rom [0:99];
    reg signed [7:0] W1_rom [0:99];
    reg signed [7:0] W2_rom [0:99];
    reg signed [7:0] B_rom  [0:99];

    reg signed [13:0] neuron_sum;

    integer i;

    //==========================================================
    // Weight Initialization
    //==========================================================

    initial begin
        for(i = 0; i < 100; i = i + 1) begin

            W0_rom[i] = (i % 3 == 0) ? 8'sd15 :
                        (i % 3 == 1) ? -8'sd10 :
                                       8'sd5;

            W1_rom[i] = (i % 2 == 0) ? -8'sd20 :
                                        8'sd12;

            W2_rom[i] = (i % 5 == 0) ? 8'sd25 :
                                       -8'sd8;

            B_rom[i]  = (i % 4 == 0) ? -8'sd15 :
                                        8'sd2;
        end
    end

    //==========================================================
    // Main Processing FSM
    //==========================================================

    always @(posedge clk_processing or posedge rst) begin

        if(rst) begin

            current_state     <= STATE_INIT;

            neuron_index      <= 7'd0;
            spike_accumulator <= 7'd0;

            total_spikes      <= 7'd0;

            output_neuron_0   <= 1'b0;
            output_neuron_1   <= 1'b0;

            neuron_sum        <= 14'sd0;

        end
        else begin

            case(current_state)

                //--------------------------------------------------
                // Reset processing for new evaluation
                //--------------------------------------------------
                STATE_INIT: begin

                    neuron_index      <= 7'd0;
                    spike_accumulator <= 7'd0;

                    current_state     <= STATE_CALC;

                end

                //--------------------------------------------------
                // Process 100 neurons
                //--------------------------------------------------
                STATE_CALC: begin

                    neuron_sum <=
                        (x0 * W0_rom[neuron_index]) +
                        (x1 * W1_rom[neuron_index]) +
                        (x2 * W2_rom[neuron_index]) +
                         B_rom[neuron_index];

                    if(
                        ((x0 * W0_rom[neuron_index]) +
                         (x1 * W1_rom[neuron_index]) +
                         (x2 * W2_rom[neuron_index]) +
                          B_rom[neuron_index]) > THRESHOLD
                    )
                    begin
                        spike_accumulator <= spike_accumulator + 1'b1;
                    end

                    if(neuron_index == 7'd99)
                        current_state <= STATE_DONE;
                    else
                        neuron_index <= neuron_index + 1'b1;

                end

                //--------------------------------------------------
                // Generate outputs
                //--------------------------------------------------
                STATE_DONE: begin

                    total_spikes <= spike_accumulator;

                    // Output neuron #0
                    output_neuron_0 <= (spike_accumulator >= 7'd30);

                    // Output neuron #1
                    output_neuron_1 <= (spike_accumulator >= 7'd60);

                    current_state <= STATE_INIT;

                end

                default:
                    current_state <= STATE_INIT;

            endcase

        end
    end

endmodule
