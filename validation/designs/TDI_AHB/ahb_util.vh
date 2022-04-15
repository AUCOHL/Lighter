/*
	Copyright 2020 Mohamed Shalan
	
	Licensed under the Apache License, Version 2.0 (the "License"); 
	you may not use this file except in compliance with the License. 
	You may obtain a copy of the License at:

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.
*/
/*
    This file contains a set of helper macros for constructing AHB bus
    components.
*/

// AHB Register 
`define AHB_REG(name, size, offset, init, prefix)   \
        reg [size-1:0] name; \
        wire ``name``_sel = wr_enable & (last_HADDR[7:0] == offset); \
        always @(posedge HCLK or negedge HRESETn) \
            if (~HRESETn) \
                ``name`` <= 'h``init``; \
            else if (``name``_sel) \
                ``name`` <= ``prefix``HWDATA[``size``-1:0];\

// Breaking down AHB register into its fields
`define REG_FIELD(reg_name, fld_name, from, to)\
    wire [``to``-``from``:0] ``reg_name``_``fld_name`` = reg_name[to:from]; 

`define AHB_READ assign HRDATA = 

// AHB Register Read
`define AHB_REG_READ(name, offset) (last_HADDR[7:0] == offset) ? name : 


// AHB Slave RW Bus Interface 
`define AHB_SLAVE_IFC(prefix)   \
        input               ``prefix``HSEL,\
        input wire [31:0]   ``prefix``HADDR,\
        input wire [1:0]    ``prefix``HTRANS,\
        input wire          ``prefix``HWRITE,\
        input wire          ``prefix``HREADY,\
        input wire [31:0]   ``prefix``HWDATA,\
        input wire [2:0]    ``prefix``HSIZE,\
        output wire         ``prefix``HREADYOUT,\
        output wire [31:0]  ``prefix``HRDATA
        

// AHB Slave RO Bus Interface 
`define AHB_SLAVE_RO_IFC(prefix)   \
        input               ``prefix``HSEL,\
        input wire [31:0]   ``prefix``HADDR,\
        input wire [1:0]    ``prefix``HTRANS,\
        input wire          ``prefix``HWRITE,\
        input wire          ``prefix``HREADY,\
        output wire         ``prefix``HREADYOUT,\
        output wire [31:0]  ``prefix``HRDATA

// AHB Master Bus Interface
`define AHB_MASTER_IFC(prefix) \
        output wire [31:0]  ``prefix``HADDR,\
        output wire [1:0]   ``prefix``HTRANS,\
        output wire [2:0] 	 ``prefix``HSIZE,\
        output wire         ``prefix``HWRITE,\
        output wire [31:0]  ``prefix``HWDATA,\
        input wire          ``prefix``HREADY,\
        input wire [31:0]   ``prefix``HRDATA 
        

// AHB Slave essential logic
`define AHB_SLAVE_EPILOGUE(prefix) \
    reg             last_HSEL; \
    reg [31:0]      last_HADDR; \
    reg             last_HWRITE; \
    reg [1:0]       last_HTRANS; \
    \
    always@ (posedge HCLK) begin\
        if(``prefix``HREADY) begin\
            last_HSEL       <= ``prefix``HSEL;   \
            last_HADDR      <= ``prefix``HADDR;  \
            last_HWRITE     <= ``prefix``HWRITE; \
            last_HTRANS     <= ``prefix``HTRANS; \
        end\
    end\
    \
    wire rd_enable = last_HSEL & (~last_HWRITE) & last_HTRANS[1]; \
    wire wr_enable = last_HSEL & (last_HWRITE) & last_HTRANS[1]; 



