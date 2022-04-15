/*
	Copyright 2022 Mohamed Shalan
	
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

task AHB_READ_WORD(input [31:0] ADDR, output [31:0] data);
    begin : task_body
        wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b0;
        HADDR <= ADDR;
        HSIZE <= 3'd2;
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b00;
        wait (HREADY == 1'b1);
        @(posedge HCLK) data = HRDATA;
    end
endtask

task AHB_WRITE_WORD(input [31:0] ADDR, input [31:0] data);
    begin : task_body
        //wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b1;
        HADDR <= ADDR;
        HSIZE <= 3'd2;
        @(posedge HCLK);
        HTRANS <= 0;
        HWDATA <= data;
    end
endtask


task AHB_READ_HALF(input [31:0] ADDR, output [15:0] data);
    begin : task_body
        wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b0;
        HADDR <= ADDR;
        HSIZE <= 3'd1;
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b00;
        wait (HREADY == 1'b1);
        @(posedge HCLK) data = HRDATA;
    end
endtask

task AHB_WRITE_HALF(input [31:0] ADDR, input [15:0] data);
    begin : task_body
        //wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b1;
        HADDR <= ADDR;
        HSIZE <= 3'd1;
        @(posedge HCLK);
        HTRANS <= 0;
        HWDATA <= data;
    end
endtask


task AHB_READ_BYTE(input [31:0] ADDR, output [7:0] data);
    begin : task_body
        wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b0;
        HADDR <= ADDR;
        HSIZE <= 3'd0;
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b00;
        wait (HREADY == 1'b1);
        @(posedge HCLK) data = HRDATA;
    end
endtask

task AHB_WRITE_BYTE(input [31:0] ADDR, input [7:0] data);
    begin : task_body
        //wait (HREADY == 1'b1);
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b1;
        HADDR <= ADDR;
        HSIZE <= 3'd0;
        @(posedge HCLK);
        HTRANS <= 0;
        HWDATA <= data;
    end
endtask

task AHB_WRITE_READ_WORD(input [31:0] WADDR, input [31:0] RADDR, input [31:0] WDATA, output [31:0] RDATA);
    begin : task_body
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b1;
        HADDR <= WADDR;
        HSIZE <= 3'd2;
        @(posedge HCLK);
        #1;
        HTRANS <= 2'b10;
        HWRITE <= 1'b0;
        HADDR <= RADDR;
        HSIZE <= 3'd2;
        HWDATA <= WDATA;
        @(posedge HCLK);
        HTRANS <= 2'b00;
        @(posedge HCLK);
        RDATA = HRDATA;
    end
endtask