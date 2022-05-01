/*
 	Copyright 2022 AUC Open Source Hardware Lab
	
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

#include "kernel/yosys.h" 

USING_YOSYS_NAMESPACE

struct CLK_Gating_Pass : public Pass {

    CLK_Gating_Pass() : Pass("reg_clock_gating", "perform flipflop clock gating") { }

    void help() override
        {
            //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
            log("\n");
            log("     reg_clock_gating mapfile.v\n");
            log("\n");
            log("This pass calls the following passes to perform technology mapping \n");
            log("of enabled flip_flops to clock-gated flipflops.\n");
            log("\n");
            log("    procs\n");
            log("    opt;;\n");
            log("    memory_collect\n");
            log("    memory_map\n");
            log("    opt;; \n");
            log("    techmap -map\n");
            log("    opt;;\n");
            log("\n");
        }

    virtual void execute(std::vector<std::string> args, RTLIL::Design *design) 
    {


        if (args.size() < 2) {
            log_error("Incorrect number of arguments");
            log_error("Clock gating map file is required");         
        }
        else {

            log_header(design, "Executing Clock gating pass.\n");
            log_push();
            Pass::call(design, "proc");
            Pass::call(design, "opt;;");
            Pass::call(design, "memory_collect");
            Pass::call(design, "memory_map;;");
            Pass::call(design, "opt;;");
        
            Pass::call(design, "techmap -map " + args[1]);
            Pass::call(design, "opt;;");

            design->optimize();
            design->sort();
            design->check();

            log_header(design, "Finished Clock gating pass.\n");
            log_pop();
        }
    }
} CLK_Gating_Pass;
