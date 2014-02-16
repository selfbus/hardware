`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:20:26 02/26/2011 
// Design Name: 
// Module Name:    main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
// Copyright (c) 2011-2013 Arno Stock <arno.stock@yahoo.de>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License version 2 as
// published by the Free Software Foundation.
//
//////////////////////////////////////////////////////////////////////////////////
module main(
// Avr interface
	 input [15:8] AvrA,
    inout [7:0] AvrAD,
    input AvrALE,
    input AvrRD,
    input AvrWR,
// common signals
    output [7:0] A,
    inout [15:8] D,
// RAM interface
    output [18:13] RA,
    output RCE,
    output ROE,
    output RWE,
// Flash interface
    output [21:15] FA,
    output FCE,
    output FOE,
    output FWE,
// TFT interface
    output TRS,
    output TWR,
    output TRD,
    output TCS
);

// Address latch for A[7:0]
reg [7:0] address_latch;
always @ (negedge AvrALE)
	address_latch = AvrAD;

// complete 16 bit ATMEGA address
wire [15:0] AvrADDR;
assign AvrADDR = {AvrA, address_latch};

//************************************************
// Address decoder for ATMEGA address range
//************************************************
reg AvrFCS;	// Avr address range for Flash area
reg AvrRCS;	// Avr address range for RAM area
reg AvrRCSBANK;	// Avr address range for banked RAM area
reg AvrCCS;	// Avr address range for control register area
reg AvrTCS; // Avr address range for TFT
// Address range
// 0x0000 - 0x3FFF (16k): RAM non banked area (0x0000 - 0x10FF not accessible by Atmega)
// 0x4000 - 0x5FFF ( 8k): RAM banked area
parameter RAM_ADDR_MIN = 16'h0000;
parameter RAM_BANK_ADDR_MIN = 16'h4000;
parameter RAM_ADDR_MAX = 16'h5FFF;
// 0x6000 - 0x7FEF ( 8k): unused
// 0x7FF0 - 0x7FF1 ( 2b): TFT ports
parameter TFT_ADDR_MIN = 16'h7FF0;
parameter TFT_ADDR_MAX = 16'h7FF1;
// 0x7FF8 - 0x7FFF ( 8b): Control registers
parameter CTRL_ADDR_MIN = 16'h7FF8;
parameter CTRL_ADDR_MAX = 16'h7FFF;
// 0x8000 - 0xFFFF (32k): Flash area (banked)
parameter FLASH_ADDR_MIN = 16'h8000;
parameter FLASH_ADDR_MAX = 16'hFFFF;
always @ (AvrADDR) begin
	AvrRCS = ((AvrADDR >= RAM_ADDR_MIN) && (AvrADDR <= RAM_ADDR_MAX)) ? 1'b1 : 1'b0;
	AvrRCSBANK = ((AvrADDR >= RAM_BANK_ADDR_MIN) && (AvrADDR <= RAM_ADDR_MAX)) ? 1'b1 : 1'b0;
	AvrFCS = ((AvrADDR >= FLASH_ADDR_MIN) && (AvrADDR <= FLASH_ADDR_MAX)) ? 1'b1 : 1'b0;
	AvrCCS = ((AvrADDR >= CTRL_ADDR_MIN) && (AvrADDR <= CTRL_ADDR_MAX)) ? 1'b1 : 1'b0;
	AvrTCS = ((AvrADDR >= TFT_ADDR_MIN) && (AvrADDR <= TFT_ADDR_MAX)) ? 1'b1 : 1'b0;
end

//*********************************
// Control register structure
//*********************************
// 0x0 : Mode control register
parameter MODE_CTRL_ADDR = 3'h0;
// 0x1 : upper data byte register for write
parameter UPPER_DATA_WR_ADDR = 3'h1;
// 0x2 : upper data byte register for read
parameter UPPER_DATA_RD_ADDR = 3'h2;
// 0x3 : RAM bank address low byte
parameter RAM_BANK_ADDR = 3'h3;
// 0x4 : Flash bank address low byte
parameter FLASH_BANK_ADDR = 3'h4;

// Write mode control register
//----------------------------
wire tft_write_on_flash_read;
// d0: 1 = TFT write on Flash read
//     0 = no TFT write on Flash read
wire tft_write_on_ram_read;
// d1: 1 = TFT write on RAM read, upper data from CPLD latch
//     0 = no TFT write on RAM read
wire tft_write_on_ram_bank_read;
// d2: 1 = TFT write on RAM bank area read, upper data from CPLD latch
//     0 = no TFT write on RAM bank area read
wire ram_write_on_flash_read;
// d3: 1 = RAM write on Flash read (direct or bank area)
//     0 = no RAM write on Flash read
reg [3:0] mode_control_reg;
always @ (posedge AvrWR)
	if ((AvrCCS == 1) && (AvrADDR [2:0] == MODE_CTRL_ADDR))
		mode_control_reg[3:0]= AvrAD[3:0];
assign {ram_write_on_flash_read, tft_write_on_ram_bank_read, tft_write_on_ram_read, tft_write_on_flash_read} = mode_control_reg;

// Write upper data byte write register
//-------------------------------------
reg [7:0] upper_data_write_reg;
always @ (posedge AvrWR)
	if ((AvrCCS == 1) && (AvrADDR [2:0] == UPPER_DATA_WR_ADDR))
		upper_data_write_reg = AvrAD;
		
// Write upper data byte read register
//-------------------------------------
reg [7:0] upper_data_read_reg;
always @ (posedge AvrRD)
	if ((AvrFCS == 1) || (AvrTCS == 1))
		upper_data_read_reg = D;

// Write RAM bank select register
//-------------------------------------
reg [5:0] ram_bank_address;
always @ (posedge AvrWR)
	if ((AvrCCS == 1) && (AvrADDR [2:0] == RAM_BANK_ADDR))
		ram_bank_address[5:0] = AvrAD;

// Write Flash bank select register
//-------------------------------------
reg [6:0] flash_bank_address_reg;
always @ (posedge AvrWR)
	if ((AvrCCS == 1) && (AvrADDR [2:0] == FLASH_BANK_ADDR))
		flash_bank_address_reg [6:0] = AvrAD[6:0];

//********************************
// read back internal registers
//********************************
reg [7:0] avr_data_out;
always @ (AvrCCS or AvrRD or AvrADDR or ram_bank_address or flash_bank_address_reg or upper_data_write_reg or upper_data_read_reg or mode_control_reg) begin
	if ((AvrCCS == 1) && (AvrRD == 0)) begin
		if (AvrADDR [2:0] == RAM_BANK_ADDR)
			avr_data_out = { 2'b0, ram_bank_address[5:0]};
		else if (AvrADDR [2:0] == FLASH_BANK_ADDR)
			avr_data_out = { 1'b0, flash_bank_address_reg[6:0]};
		else if (AvrADDR [2:0] == UPPER_DATA_WR_ADDR)
			avr_data_out = upper_data_write_reg;
		else if (AvrADDR [2:0] == UPPER_DATA_RD_ADDR)
			avr_data_out = upper_data_read_reg;
		else if (AvrADDR [2:0] == MODE_CTRL_ADDR)
			avr_data_out = { 4'b0, mode_control_reg [3:0]};
		else avr_data_out = 8'b0;
	end
	else avr_data_out = 8'bz;
end
assign AvrAD = avr_data_out;


//***********************************
// Common output signals
//***********************************
// address latch output to RAM and Flash
assign A = address_latch;

// drive out upper data byte
//--------------------------
reg [7:0] upper_data_out;
always @ (AvrWR or AvrTCS or AvrFCS or upper_data_write_reg)
	upper_data_out = ((AvrWR ==0) && ((AvrTCS == 1) || (AvrFCS == 1))) ? upper_data_write_reg : 8'bz;
assign D = upper_data_out;


//***********************************
// Control of Flash
//***********************************
// write to Flash by Avr only
// read from Flash by Avr only
assign FA[21:15] = flash_bank_address_reg [6:0];
assign FCE = ~AvrFCS;
wire flash_read_internal_Z;
//assign flash_read_internal_Z = AvrRD | ~AvrFCS;
OR2 FRD_or0 (.in0(AvrRD), .in1(~AvrFCS), .out(flash_read_internal_Z));

assign FOE = flash_read_internal_Z;
wire flash_write_internal_Z;
//assign flash_write_internal_Z = AvrWR | ~AvrFCS;
OR2 FWR_or0 (.in0(AvrWR), .in1(~AvrFCS), .out(flash_write_internal_Z));

assign FWE = flash_write_internal_Z;

//***********************************
// Control of RAM
//***********************************
// write to RAM by Avr or Flash read, if ram_write_on_flash_read
wire ram_read_internal_Z;
//assign ram_read_internal_Z = AvrRD | ~AvrRCS;
OR2 RRD_or0 (.in0(AvrRD), .in1(~AvrRCS), .out(ram_read_internal_Z));

wire ram_write_internal_Z;
//assign ram_write_internal_Z = AvrWR | ~AvrRCS;
OR2 RWR_or0 (.in0(AvrWR), .in1(~AvrRCS), .out(ram_write_internal_Z));

assign RA[18:13] = AvrRCSBANK ? ram_bank_address [5:0] : { 5'b0, AvrADDR[13]};
assign RCE = ram_write_on_flash_read ?  ~(AvrFCS | AvrRCS) : ~AvrRCS;
assign ROE = ram_read_internal_Z;
assign RWE = ram_write_on_flash_read ?  (flash_read_internal_Z & ram_write_internal_Z) : ram_write_internal_Z;

//***********************************
// Control of TFT
//***********************************
// 0x0 : TFT register select register
parameter TFT_CTRL_ADDR = 1'h0;
// 0x1 : TFT register data register
parameter TFT_DATA_ADDR = 1'h1;

//wire tft_read_internal_Z;
//assign tft_read_internal_Z = AvrRD | ~AvrTCS;
//assign TRD = ~tft_read_internal_Z;
OR2 TRD_or0 (.in0(AvrRD), .in1(~AvrTCS), .out(TRD));

reg TRSinternal;
always @( AvrTCS or flash_read_internal_Z or ram_read_internal_Z or AvrADDR)
	TRSinternal = AvrTCS ? AvrADDR[0] : TFT_DATA_ADDR;
assign TRS = TRSinternal;

wire TWR_on_read;
assign TWR_on_read = (tft_write_on_flash_read & AvrFCS) | (tft_write_on_ram_read & AvrRCS & ~AvrRCSBANK) | (tft_write_on_ram_bank_read & AvrRCSBANK);
wire TWR_internal_Z;
wire AvrWR_TCS;
wire AvrRD_TWR_on_read;
OR2 TWR_or0 (.in0(AvrWR), .in1(~AvrTCS), .out(AvrWR_TCS));
OR2 TWR_or1 (.in0(AvrRD), .in1(~TWR_on_read), .out(AvrRD_TWR_on_read));
// assign TWR_internal_Z = (AvrWR | ~AvrTCS) & (AvrRD | ~TWR_on_read);
assign TWR_internal_Z = AvrWR_TCS & AvrRD_TWR_on_read;
assign TWR = TWR_internal_Z;

wire TCSinternal_Z;
assign TCSinternal_Z = ~(AvrTCS | TWR_on_read);
assign TCS = TCSinternal_Z;

endmodule
