`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:17:18 12/19/2012 
// Design Name: 
// Module Name:    OR2 
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
module OR2(
    input in0,
    input in1,
    output out
    );

assign out = in0 | in1;

endmodule
