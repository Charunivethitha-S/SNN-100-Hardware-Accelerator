`timescale 1ns / 1ps

module clk_divider (
    input  wire clk_100MHz,   // Basys-3 onboard clock (100 MHz)
    input  wire rst,          // Active-high reset

    output reg  clk_1MHz,     // Processing clock
    output reg  clk_1kHz      // Display refresh clock
);

    // ==========================================================
    // Counter declarations
    // ==========================================================

    reg [6:0]  count_1MHz;    // Counts 0 to 49
    reg [16:0] count_1kHz;    // Counts 0 to 49999

    // ==========================================================
    // 100 MHz -> 1 MHz
    //
    // Toggle every 50 cycles:
    // 100 MHz / (2 × 50) = 1 MHz
    // ==========================================================

    always @(posedge clk_100MHz or posedge rst) begin
        if (rst) begin
            count_1MHz <= 7'd0;
            clk_1MHz   <= 1'b0;
        end
        else begin
            if (count_1MHz == 7'd49) begin
                count_1MHz <= 7'd0;
                clk_1MHz   <= ~clk_1MHz;
            end
            else begin
                count_1MHz <= count_1MHz + 7'd1;
            end
        end
    end

    // ==========================================================
    // 100 MHz -> 1 kHz
    //
    // Toggle every 50000 cycles:
    // 100 MHz / (2 × 50000) = 1 kHz
    // ==========================================================

    always @(posedge clk_100MHz or posedge rst) begin
        if (rst) begin
            count_1kHz <= 17'd0;
            clk_1kHz   <= 1'b0;
        end
        else begin
            if (count_1kHz == 17'd49999) begin
                count_1kHz <= 17'd0;
                clk_1kHz   <= ~clk_1kHz;
            end
            else begin
                count_1kHz <= count_1kHz + 17'd1;
            end
        end
    end

endmodule
