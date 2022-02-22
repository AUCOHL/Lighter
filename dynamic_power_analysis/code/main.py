from liberty.parser import parse_liberty
import csv
from numpy import double  
import pyverilog.vparser.ast as vast
from pyverilog.vparser.parser import parse
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator
from sympy import false, true
from datetime import datetime
before_parsing_time = datetime.now()
# Read and parse a library.
library = parse_liberty(open("sky130_hd.lib").read())
after_parsing_time = datetime.now()
print("parsing time:", str(after_parsing_time-before_parsing_time))
f_clk= 1.0
voltage=1.5
alpha_normal=0.1
before_alpha_flip_flop=1.0
after_alpha_flip_flop=0.1

all_cells=[]
df_cells=[]
design_flip_flops=[]
design_normal_cells=[]
# Loop through all cells.

rtl = "/Users/youssef/Desktop/EDA/dynamic_power_analysis/code/test_outout_gatelevel.gl.v"
ast,_ = parse([rtl])
# get the root node of the tree (Description)
desc = ast.description
# get the ModuleDef node
definition = desc.definitions[0]
after_design_parsing_time = datetime.now()
print("design parsing time:", str(after_design_parsing_time-after_parsing_time))
#########################################################################################################################
def get_input_pin_cap(portname):
    input_pin_cap=0

    for itemDeclaration in definition.items:
        item_type = type(itemDeclaration).__name__
        if item_type == "InstanceList":
            instance = itemDeclaration.instances[0]
            name=instance.module
            for port in instance.portlist:
                if (port.argname==portname):
                    for cell_group in library.get_groups('cell'):
                            if name in str(cell_group.args[0]):
                                for pin_group in cell_group.get_groups('pin'):
                                    pin_direction= pin_group['direction']
                                    if pin_direction == "input":
                                        #print(portname, pin_group.args[0])
                                        if (port.portname in str(pin_group.args[0])):                                           
                                            pin_capacitance = pin_group['capacitance']
                                            input_pin_cap+= double(pin_capacitance)
    return input_pin_cap
#########################################################################################################################
def get_outpin_cap_and_names(design_cell_name):
    pins_names=[]
    #print(str(library.get_groups('cell')["sky130_fd_sc_hd__mux"]))

    for cell_group in library.get_groups('cell'):
        if design_cell_name in str(cell_group.args[0]):
            for pin_group in cell_group.get_groups('pin'):
               
                pin_direction= pin_group['direction']
                if pin_direction == "output":
                    pins_names.append( pin_group.args[0])

    return pins_names

################################################################
################################################################

def get_load(capac_port):


    load_cap=0.0

    for itemDeclaration in definition.items:
        item_type = type(itemDeclaration).__name__
        if item_type == "InstanceList": 
            instance = itemDeclaration.instances[0]
            for port in instance.portlist:
                #check input pin
                if port == capac_port:
                    load_cap+=get_input_pin_cap(port.argname)

      
    return load_cap

################################################################



#################################################################################################

def calculate_dynamic_power_estimate():
    dynamic_power=0.0
    total_ff_cap=0.0
    total_nor_cap=0.0
    for design_flip_flop in design_flip_flops:
        total_ff_cap+=design_flip_flop[1]
    


    for design_normal_cell in design_normal_cells:
        total_nor_cap+=design_normal_cell[1]

    x= total_nor_cap*voltage*voltage*f_clk*alpha_normal*1e-12
    y= total_ff_cap*voltage*voltage*f_clk*after_alpha_flip_flop*1e-12
    dynamic_power=x+y
    
    return dynamic_power
#################################################################################################


before_analysis = datetime.now()

for itemDeclaration in definition.items:
    item_type = type(itemDeclaration).__name__
    if item_type == "InstanceList":
        instance = itemDeclaration.instances[0]

        if("df" in instance.module):
            ff_name=instance.module
            load_capacitance=0
            total_output_capacitance=0
            output_pin_names= get_outpin_cap_and_names(ff_name)
            for port in instance.portlist:
                flag=false  
                for output_name in output_pin_names:
                    if port.portname == output_name:
                        flag=true
                if flag==true:
                    load_capacitance+= get_load(port)

       
            flip_flop=[ff_name, load_capacitance]
            design_flip_flops.append(flip_flop)
        else:
            normal_cell_name=instance.module
            load_capacitance=0
           
            output_pin_names= get_outpin_cap_and_names(normal_cell_name)
            for port in instance.portlist:
                flag=false  
                for output_name in output_pin_names:
                    if port.portname == output_name:
                        flag=true
                if flag==true:
                    load_capacitance+= get_load(port)

          
            normal_cell=[normal_cell_name,load_capacitance]
            design_normal_cells.append(normal_cell)


after_analysis = datetime.now()
print("DP analysis time:", str(after_analysis-before_analysis))
print("total dynamic power estimate: "+str(calculate_dynamic_power_estimate()))