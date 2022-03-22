import os
import csv
import sys
from tokenize import Double

import numpy as np


def check_if_valid(vvd_file):

    return


dir_list = [ 
            #"aes256",
            "blabla", 
            "chacha", 
            "ldpc_decoder_802_3an",
            "ldpcenc", 
            #"sp_mul", 
            "PPU",
            #"des", 
            #"sbox", 
            #"ula", 
            #"vm80a", 
            #"xtea",
            "y_huff", 
            "y_quantizer", 
            #"zigzag", 
            #"zipdiv", 
            "y_dct", 
            "jpeg_encoder",
            #"aes_cipher",
            "sha512", 
            "picorv32a", 
            "riscv_top_151", 
            "genericfir",
            "NfiVe32_RF", 
            "rf_64x64"
            ] 

for test in dir_list:
    print(test)
    create_vvp= os.popen('iverilog -o out.vvp '+test+'.v '+test+'_tb.v' )
    vvp_out= os.popen('vvp out.vvp' )
    vvp_out_terminal = vvp_out.read()
    check_if_valid(vvp_out_terminal)