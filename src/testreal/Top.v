`timescale 1ns / 1ps
`include "src/include/InstSpec.v"

module Top(
    input RSTN,
    input [3:0] BTN_y,
    input [15:0] SW,
    input clk_100mhz,
    output CR,
    output seg_clk,
    output seg_sout,
    output SEG_PEN,
    output seg_clrn,
    output led_clk,
    output led_sout,
    output LED_PEN,
    output led_clrn,
    output RDY,
    output readn,
    output [4:0] BTN_x
);

wire AntiJitter_rst;

wire clk_div_Clk_CPU;
wire [31:0] clk_div_clkdiv;
clk_div u_clk_div(
    .clk     (clk_100mhz),
    .rst     (AntiJitter_rst),
    .SW2     (AntiJitter_SW_OK[2]),
    .clkdiv  (clk_div_clkdiv),
    .Clk_CPU (clk_div_Clk_CPU)
);

wire [3:0] AntiJitter_pulse_out, AntiJitter_BTN_OK;
wire [4:0] AntiJitter_Key_out;
wire [15:0] AntiJitter_SW_OK;
SAnti_jitter u_SAnti_jitter(
    .clk       (clk_100mhz),
    .RSTN      (RSTN),
    .readn     (readn),
    .Key_y     (BTN_y),
    .Key_x     (BTN_x),
    .SW        (SW),
    .Key_out   (AntiJitter_Key_out),
    .Key_ready (RDY),
    .pulse_out (AntiJitter_pulse_out),
    .BTN_OK    (AntiJitter_BTN_OK),
    .SW_OK     (AntiJitter_SW_OK),
    .CR        (CR),
    .rst       (AntiJitter_rst)
);

wire [31:0] SEnter_Ai, SEnter_Bi;
SEnter_2_32 u_SEnter_2_32(
    .clk     (clk_100mhz),
    .BTN     (AntiJitter_BTN_OK[2:0]),
    .Ctrl    ({AntiJitter_SW_OK[7:5], AntiJitter_SW_OK[15], AntiJitter_SW_OK[0]}),
    .D_ready (RDY),
    .Din     (AntiJitter_Key_out),
    .readn   (readn),
    .Ai      (SEnter_Ai),
    .Bi      (SEnter_Bi),
    .blink   ()
);

wire [31:0] Multi8CH32_Disp_num;
wire [7:0] Multi8CH32_point_out;
wire [7:0] Multi8CH32_LE_out;
SSeg7_Dev u_SSeg7_Dev(
    .clk      (clk_100mhz),
    .rst      (AntiJitter_rst),
    .Start    (clk_div_clkdiv[20]),
    .SW0      (AntiJitter_SW_OK[0]),
    .flash    (clk_div_clkdiv[25]),
    .Hexs     (Multi8CH32_Disp_num),
    .point    (Multi8CH32_point_out),
    .LES      (Multi8CH32_LE_out),
    .seg_clk  (seg_clk),
    .seg_sout (seg_sout),
    .SEG_PEN  (SEG_PEN),
    .seg_clrn (seg_clrn)
);

wire [1:0] SPIO_counter_set;
wire MIO_counter_we;
wire [31:0] MIO_Peripheral_in;
wire Counter_counter0_OUT, Counter_counter1_OUT, Counter_counter2_OUT;
wire [31:0] Counter_counter_out;
Counter_x u_Counter_x(
    .clk          (~clk_div_Clk_CPU),
    .rst          (AntiJitter_rst),
    .clk0         (clk_div_clkdiv[6]),
    .clk1         (clk_div_clkdiv[9]),
    .clk2         (clk_div_clkdiv[11]),
    .counter_we   (MIO_counter_we),
    .counter_val  (MIO_Peripheral_in),
    .counter_ch   (SPIO_counter_set),
    .counter0_OUT (Counter_counter0_OUT),
    .counter1_OUT (Counter_counter1_OUT),
    .counter2_OUT (Counter_counter2_OUT),
    .counter_out  (Counter_counter_out)
);

wire [31:0] SCPU_Data_out, SCPU_Addr_out;
wire [31:0] RAM_douta;
wire [15:0] SPIO_LED_out;
wire [31:0] MIO_Cpu_data4bus;
wire [9:0] MIO_ram_addr;
wire [31:0] MIO_ram_data_in;
wire MIO_data_ram_we;
wire MIO_GPIOf0000000_we, MIO_GPIOe0000000_we;
wire CPU_data_mem_write_en;
reg [31:0] data_in;
MIO_BUS u_MIO_BUS(
    .clk             (clk_100mhz),
    .rst             (AntiJitter_rst),
    .BTN             (AntiJitter_BTN_OK),
    .SW              (AntiJitter_SW_OK),
    .mem_w           (CPU_data_mem_write_en),
    .Cpu_data2bus    (data_in),
    .addr_bus        (SCPU_Addr_out),
    .ram_data_out    (RAM_douta),
    .led_out         (SPIO_LED_out),
    .counter_out     (Counter_counter_out),
    .counter0_out    (Counter_counter0_OUT),
    .counter1_out    (Counter_counter1_OUT),
    .counter2_out    (Counter_counter2_OUT),
    .Cpu_data4bus    (MIO_Cpu_data4bus),
    .ram_data_in     (MIO_ram_data_in),
    .ram_addr        (MIO_ram_addr),
    .data_ram_we     (MIO_data_ram_we),
    .GPIOf0000000_we (MIO_GPIOf0000000_we),
    .GPIOe0000000_we (MIO_GPIOe0000000_we),
    .counter_we      (MIO_counter_we),
    .Peripheral_in   (MIO_Peripheral_in)
);

reg [3:0] wea;
RAM u_RAM(
    .clka  (~clk_100mhz),
    .wea   (wea),
    .addra (MIO_ram_addr),
    .dina  (MIO_ram_data_in),
    .douta (RAM_douta)
);

wire [31:0] ROM_spo;
wire [31:0] SCPU_PC_out;
ROM u_ROM(
    .a   (SCPU_PC_out[11:2]),
    .spo (ROM_spo)
);

wire [`MEMWRWIDTH_BUS] CPU_data_mem_write_width;
wire [31:0] SCPU_x25;
CPU u_CPU(
    .clk                  (clk_div_Clk_CPU),
    .rst                  (AntiJitter_rst),
    .int                  (1'b0),
    .inst_mem_in          (ROM_spo),
    .data_mem_in          (MIO_Cpu_data4bus),
    .data_mem_write_en    (CPU_data_mem_write_en),
    .inst_mem_addr        (SCPU_PC_out),
    .data_mem_addr        (SCPU_Addr_out),
    .data_mem_out         (SCPU_Data_out),
    .data_mem_write_width (CPU_data_mem_write_width),
    .x25                  (SCPU_x25)
);
wire [1:0] inblock_addr = SCPU_Addr_out[1:0];
always @(*) begin
    wea <= 4'b0000;
    data_in <= SCPU_Data_out;
    if (MIO_data_ram_we == 1'b1) begin
        case (CPU_data_mem_write_width)
            `MEMWRWIDTH_WORD: begin
                if (inblock_addr == 2'b00) begin
                    wea <= 4'b1111;
                    data_in <= SCPU_Data_out;
                end
            end
            `MEMWRWIDTH_HWORD: begin
                if (inblock_addr == 2'b00) begin
                    wea <= 4'b0011;
                    data_in <= SCPU_Data_out;
                end else if (inblock_addr == 2'b01) begin
                    wea <= 4'b0110;
                    data_in <= {SCPU_Data_out[23:0], 8'b0};
                end else if (inblock_addr == 2'b10) begin
                    wea <= 4'b1100;
                    data_in <= {SCPU_Data_out[15:0], 16'b0};
                end
            end
            `MEMWRWIDTH_BYTE: begin
                if (inblock_addr == 2'b00) begin
                    wea <= 4'b0001;
                    data_in <= SCPU_Data_out;
                end else if (inblock_addr == 2'b01) begin
                    wea <= 4'b0010;
                    data_in <= {SCPU_Data_out[23:0], 8'b0};
                end else if (inblock_addr == 2'b10) begin
                    wea <= 4'b0100;
                    data_in <= {SCPU_Data_out[15:0], 16'b0};
                end else if (inblock_addr == 2'b11) begin
                    wea <= 4'b1000;
                    data_in <= {SCPU_Data_out[7:0], 24'b0};
                end
            end
        endcase
    end
end

Multi_8CH32 u_Multi_8CH32(
    .clk       (~clk_div_Clk_CPU),
    .rst       (AntiJitter_rst),
    .EN        (MIO_GPIOe0000000_we),
    .Test      (AntiJitter_SW_OK[7:5]),
    .point_in  ({clk_div_clkdiv[31:0], clk_div_clkdiv[31:0]}),
    .LES       (64'b0),
    .Data0     (MIO_Peripheral_in),
    .data1     ({SCPU_PC_out[31:2], 2'b0}),
    .data2     (ROM_spo),
    .data3     (Counter_counter_out),
    .data4     (SCPU_Addr_out),
    .data5     (SCPU_Data_out),
    .data6     (MIO_Cpu_data4bus),
    .data7     (SCPU_x25),
    .point_out (Multi8CH32_point_out),
    .LE_out    (Multi8CH32_LE_out),
    .Disp_num  (Multi8CH32_Disp_num)
);

SPIO u_SPIO(
    .clk         (~clk_div_Clk_CPU),
    .rst         (AntiJitter_rst),
    .Start       (clk_div_clkdiv[20]),
    .EN          (MIO_GPIOf0000000_we),
    .P_Data      (MIO_Peripheral_in),
    .counter_set (SPIO_counter_set),
    .LED_out     (SPIO_LED_out),
    .led_clk     (led_clk),
    .led_sout    (led_sout),
    .led_clrn    (led_clrn),
    .LED_PEN     (LED_PEN),
    .GPIOf0      ()
);

endmodule
