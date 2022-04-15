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

`define     SLAVE_OFF_BITS   last_HADDR[7:0]

`define AHB_REG(name, size, offset, init)   \
        reg [size-1:0] name; \
        wire ``name``_sel = wr_enable & (`SLAVE_OFF_BITS == offset); \
        always @(posedge HCLK or negedge HRESETn) \
            if (~HRESETn) \
                ``name`` <= 'h``init``; \
            else if (``name``_sel) \
                ``name`` <= HWDATA[``size``-1:0];\

`define REG_FIELD(reg_name, fld_name, from, to)\
    wire [``to``-``from``:0] ``reg_name``_``fld_name`` = reg_name[to:from]; 

`define AHB_READ assign HRDATA = 

`define AHB_REG_READ(name, offset) (`SLAVE_OFF_BITS == offset) ? name : 

`define AHB_SLAVE_IFC   \
    input wire          HSEL,\
    input wire [31:0]   HADDR,\
    input wire [1:0]    HTRANS,\
    input wire          HWRITE,\
    input wire          HREADY,\
    input wire [31:0]   HWDATA,\
    input wire [2:0]    HSIZE,\
    output wire         HREADYOUT,\
    output wire [31:0]  HRDATA

`define AHB_SLAVE_RO_IFC   \
    input               HSEL,\
    input wire [31:0]   HADDR,\
    input wire [1:0]    HTRANS,\
    input wire          HWRITE,\
    input wire          HREADY,\
    input wire [2:0]    HSIZE,\
    output wire         HREADYOUT,\
    output wire [31:0]  HRDATA

`define AHB_SLAVE_BUS_IFC(prefix)   \
    output wire        ``prefix``_HSEL,\
    input wire         ``prefix``_HREADYOUT,\
    input wire [31:0]  ``prefix``_HRDATA

`define AHB_SLAVE_SIGNALS(prefix)\
    wire         ``prefix``_HSEL;\
    wire         ``prefix``_HREADYOUT;\
    wire [31:0]  ``prefix``_HRDATA;    

`define AHB_SLAVE_CONN(prefix)   \
        .``prefix``_HSEL(``prefix``_HSEL),\
        .``prefix``_HADDR(HADDR),\
        .``prefix``_HTRANS(HTRANS),\
        .``prefix``_HWRITE(HWRITE),\
        .``prefix``_HREADY(HREADY),\
        .``prefix``_HWDATA(HWDATA),\
        .``prefix``_HSIZE(HSIZE),\
        .``prefix``_HREADYOUT(``prefix``_HREADYOUT),\
        .``prefix``_HRDATA(``prefix``_HRDATA)

`define AHB_SLAVE_BUS_CONN(prefix)   \
        .``prefix``_HSEL(``prefix``_HSEL),\
        .``prefix``_HREADYOUT(``prefix``_HREADYOUT),\
        .``prefix``_HRDATA(``prefix``_HRDATA)

`define AHB_SLAVE_INST_CONN(prefix)   \
        .HSEL(``prefix``_HSEL),\
        .HADDR( HADDR),\
        .HTRANS(HTRANS),\
        .HWRITE(HWRITE),\
        .HREADY(HREADY),\
        .HWDATA(HWDATA),\
        .HSIZE( HSIZE),\
        .HREADYOUT(``prefix``_HREADYOUT),\
        .HRDATA(``prefix``_HRDATA)

`define AHB_SLAVE_INST_CONN_NP   \
        .HSEL(HSEL),\
        .HADDR( HADDR),\
        .HTRANS(HTRANS),\
        .HWRITE(HWRITE),\
        .HREADY(HREADY),\
        .HWDATA(HWDATA),\
        .HSIZE( HSIZE),\
        .HREADYOUT(HREADYOUT),\
        .HRDATA(HRDATA)

`define AHB_MASTER_IFC(prefix) \
    output wire [31:0]  HADDR,\
    output wire [1:0]   HTRANS,\
    output wire [2:0] 	HSIZE,\
    output wire         HWRITE,\
    output wire [31:0]  HWDATA,\
    input wire          HREADY,\
    input wire [31:0]   HRDATA 

`define AHB_MASTER_BUS_IFC(prefix) \
    input wire [31:0]   HADDR,\
    input wire [1:0]    HTRANS,\
    input wire [2:0]    HSIZE,\
    input wire          HWRITE,\
    input wire [31:0]   HWDATA,\
    output wire         HREADY,\
    output wire [31:0]  HRDATA 

`define AHB_MASTER_CONN \
        .HADDR( HADDR),\
        .HTRANS(HTRANS),\
        .HSIZE( HSIZE),\
        .HWRITE(HWRITE),\
        .HWDATA(HWDATA),\
        .HREADY(HREADY),\
        .HRDATA(HRDATA) 

`define AHB_MASTER_SIGNALS(prefix) \
    wire [31:0]  ``prefix``_HADDR;\
    wire [1:0]   ``prefix``_HTRANS;\
    wire [2:0] 	 ``prefix``_HSIZE;\
    wire         ``prefix``_HWRITE;\
    wire [31:0]  ``prefix``_HWDATA;\
    wire         ``prefix``_HREADY;\
    wire [31:0]  ``prefix``_HRDATA; 


`define AHB_SLAVE_EPILOGUE \
    reg             last_HSEL; \
    reg [31:0]      last_HADDR; \
    reg             last_HWRITE; \
    reg [1:0]       last_HTRANS; \
    \
    always@ (posedge HCLK) begin\
        if(HREADY) begin\
            last_HSEL       <= HSEL;   \
            last_HADDR      <= HADDR;  \
            last_HWRITE     <= HWRITE; \
            last_HTRANS     <= HTRANS; \
        end\
    end\
    \
    wire rd_enable = last_HSEL & (~last_HWRITE) & last_HTRANS[1]; \
    wire wr_enable = last_HSEL & (last_HWRITE) & last_HTRANS[1];


`define     SLAVE_SIGNAL(signal, indx)    S``indx``_``signal``
`define     AHB_SYS_EPILOGUE(DEC_BITS, DEC_BITS_CNT, NUM_SLAVES) \    
    wire [DEC_BITS_CNT-1:0]     PAGE = HADDR[DEC_BITS]; \
    reg  [DEC_BITS_CNT-1:0]     APAGE;\
    wire [NUM_SLAVES-1:0]       AHSEL;\
    always@ (posedge HCLK or negedge HRESETn) begin \
    if(!HRESETn)\
        APAGE <= DEC_BITS_CNT'h0;\
    else if(HREADY)\
        APAGE <= PAGE;\
    end

`define HSEL_GEN(SLAVE_ID)\
    assign ``SLAVE_ID``_HSEL    = (PAGE     == ``SLAVE_ID``_PAGE);\
    wire ``SLAVE_ID``_AHSEL   = (APAGE    == ``SLAVE_ID``_PAGE);

`define AHB_MUX\
    assign {HREADY, HRDATA} =

`define AHB_MUX_SLAVE(SLAVE_ID)\
    (``SLAVE_ID``_AHSEL) ? {``SLAVE_ID``_HREADYOUT, ``SLAVE_ID``_HRDATA} :

`define AHB_MUX_DEFAULT\
    {1'b1, 32'hFEADBEEF};\
