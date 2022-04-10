import os
import csv
from re import S
import sys
#from tokenize import Double

#import numpy as np


#def check_if_valid(vvd_file):

#    return


dir_list = [ 
            ##"aes256",
            #"blabla", 
            #"chacha", 
            #"ldpc_decoder_802_3an",
            #"ldpcenc", 
            ##"sp_mul", 
            #"PPU",
            ##"des", 
            ##"sbox", 
            ##"ula", 
            ##"vm80a", 
            ##"xtea",
            #"y_huff", 
            #"y_quantizer", 
            ##"zigzag", 
            ##"zipdiv", 
            #"y_dct", 
            #"jpeg_encoder",
            ##"aes_cipher",
            #"sha512", 
            #"picorv32a", 
            #"riscv_top_151", 
            #"genericfir",
            #"NfiVe32_RF", 
            #"rf_64x64",
            #"AHB_FLASH_CTRL",
            #"AHB_SRAM",
            #"regfile",
            #"AHB_UART_MASTER",



            #"blake2s",
            "blake2s_core",
            #"blake2s_G",
            #"blake2s_m_select",

            #"chacha"
            ] 

for test in dir_list:
    print(test)
    #os.system('iverilog -o designs/'+test+'/'+test+'.vvp designs/'+test+'/'+test+'.v designs/'+test+'/'+test+'_tb.v')
    #os.system('vvp designs/'+test+'/'+test+'.vvp ')  
    print("\n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n")
    os.system('iverilog -o designs/'+test+'/before.vvp designs/'+test+'/before_gl.v designs/'+test+'/'+test+'_tb.v')
    os.system('vvp designs/'+test+'/before.vvp')
    print("\n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n /////////////////////////////////////////////////// \n")
    os.system('iverilog -o designs/'+test+'/after.vvp designs/'+test+'/after_gl.v designs/'+test+'/'+test+'_tb.v')
    os.system('vvp designs/'+test+'/after.vvp')


