#include "kernel/yosys.h" 

USING_YOSYS_NAMESPACE

struct CLK_Gating_Pass : public Pass {

    CLK_Gating_Pass() : Pass("clock_gating", "perform flipflop clock gating") { }

    void help() override
        {
            //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
            log("\n");
            log("    clock_gating mapfile.v\n");
            log("\n");
            log("This pass calls the following passes to perform technology mapping \n");
            log("of enabled flip_flops to clock-gated flipflops.\n");
            log("\n");
            log("    proc\n");
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

//proc;
//opt;; 
//memory_collect
//memory_map
//opt;; 
//techmap -map lib/map_file.v;;
//opt;; 

//yosys-config --build plugin.so plugin.cc
//yosys -m plugin.so -p clock_gating

//yosys -m ./plugin.so -p clock_gating