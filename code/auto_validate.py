import os

dir_list = [   
            "chacha",      #passed 
   
            "regfile",      #passed 
            "AHB_SRAM",      #passed 


            "blake2s",      #passed 
            "blake2s_core",      #passed 
            "blake2s_G",      #passed 
            "blake2s_m_select",      #passed 
            ] 


for test in dir_list:
    print(test)
    #os.system('iverilog -o designs/'+test+'/'+test+'.vvp designs/'+test+'/'+test+'.v designs/'+test+'/'+test+'_tb.v')
    #os.system('vvp designs/'+test+'/'+test+'.vvp ')  
    #print("\n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n")
    #os.system('iverilog -o designs/'+test+'/before.vvp designs/'+test+'/before_gl.v designs/'+test+'/'+test+'_tb.v')
    #os.system('vvp designs/'+test+'/before.vvp')
    #print("\n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n")
    #os.system('iverilog -o designs/'+test+'/after.vvp designs/'+test+'/after_gl.v designs/'+test+'/'+test+'_tb.v')
    os.system('vvp designs/'+test+'/after.vvp')
    failed_grep= os.popen('vvp designs/'+test+'/after.vvp | grep -c FAILED' )
    failed_grep = failed_grep.read()
    print(failed_grep)
    assert  int(failed_grep) == 0


