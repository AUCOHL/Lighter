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
    Testbench creation helper Macros
*/
`define TB_CLK_GEN(clk, period)\
    initial clk = 1'b0;\
    always #(period/2) clk = ~ clk;


`define TB_RESET_SYNC(clk, rst, level, rst_time)\
    initial begin\
        rst = 1'bx;\
        #33;\
        rst = level;\
        #rst_time;\
        @(posedge clk);\
        rst = ~level;\
    end\

`define TB_RESET_ASYNC(rst, level, rst_time)\
    initial begin\
        rst = 1'bx;\
        #33;\
        rst = level;\
        #rst_time;\
        rst = ~level;\
    end\


`define TB_INIT(top, vcd_file, dump_level, sim_duration)\
    initial begin\
        $dumpfile(vcd_file);\
        $dumpvars(dump_level, top);\
        #sim_duration;\
        $finish;\
    end\


