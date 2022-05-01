"""
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
"""


import os

dir_list = [
    "chacha",  # passed
    "regfile",  # passed
    "AHB_SRAM",  # passed
    "blake2s",  # passed
    "blake2s_core",  # passed
    "blake2s_G",  # passed
    "blake2s_m_select",  # passed
]


for test in dir_list:
    print(test)
    # os.system('iverilog -o designs/'+test+'/'+test+'.vvp designs/'+test+'/'+test+'.v designs/'+test+'/'+test+'_tb.v')
    # os.system('vvp designs/'+test+'/'+test+'.vvp ')
    # print("\n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n")
    # os.system('iverilog -o designs/'+test+'/before.vvp designs/'+test+'/before_gl.v designs/'+test+'/'+test+'_tb.v')
    # os.system('vvp designs/'+test+'/before.vvp')
    # print("\n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n")
    os.system('iverilog -o designs/'+test+'/after.vvp designs/'+test+'/after_gl.v designs/'+test+'/'+test+'_tb.v')
    os.system("vvp designs/" + test + "/after.vvp")
    failed_grep = os.popen("vvp designs/" + test + "/after.vvp | grep -c FAILED")
    failed_grep = failed_grep.read()
    print(failed_grep)
    assert int(failed_grep) == 0
