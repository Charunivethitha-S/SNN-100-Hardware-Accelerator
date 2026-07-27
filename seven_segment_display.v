`timescale 1ns / 1ps

module seven_seg_driver(
    input  wire       clk_display,      // 1 kHz refresh clock
    input  wire       rst,
    input  wire [6:0] binary_value,     // Spike count (0-99)

    output reg  [3:0] anode,
    output reg  [6:0] cathode
);

    reg refresh_counter;

    reg [3:0] digit;

    // Limit displayed value to 99
    wire [6:0] display_value;

    assign display_value = (binary_value > 7'd99) ? 7'd99 : binary_value;

    wire [3:0] tens;
    wire [3:0] ones;

    assign tens = display_value / 10;
    assign ones = display_value % 10;

    // Refresh between two digits
    always @(posedge clk_display or posedge rst) begin
        if (rst)
            refresh_counter <= 1'b0;
        else
            refresh_counter <= ~refresh_counter;
    end

    // Digit selection
    always @(*) begin
        case(refresh_counter)

            1'b0: begin
                anode = 4'b1110;   // Rightmost digit
                digit = ones;
            end

            1'b1: begin
                anode = 4'b1101;   // Second digit from right
                digit = tens;
            end

            default: begin
                anode = 4'b1111;
                digit = 4'd0;
            end

        endcase
    end

    // Seven-segment decoder (Common Anode - Basys 3)
    always @(*) begin
        case(digit)

            4'd0: cathode = 7'b1000000;
            4'd1: cathode = 7'b1111001;
            4'd2: cathode = 7'b0100100;
            4'd3: cathode = 7'b0110000;
            4'd4: cathode = 7'b0011001;
            4'd5: cathode = 7'b0010010;
            4'd6: cathode = 7'b0000010;
            4'd7: cathode = 7'b1111000;
            4'd8: cathode = 7'b0000000;
            4'd9: cathode = 7'b0010000;

            default: cathode = 7'b1111111; // blank

        endcase
    end

endmodule
