# Automatic clock gating on Yosys RTLIL level
An automatic clock gating utility that is generic for all SKY_130 RTL designs. The tool takes an RTL HDL design (typically Verilog) and applies synthesis and clock gating using over-the-shelf commands provided by Yosys.The clock-gating problem is transformed into a graph problem with the help of Yosys RTLIL (register transfer level intermediate language), where the tool replaces all flipflops with enable inputs into clock-gated flipflops. The tool produces a clock-gated gatelevel netlist. 

# The American University In Cairo  
![the_american_university_in_cairo_0](https://user-images.githubusercontent.com/63082375/145812500-c4416b84-b1f0-4c99-b2f5-39622d864d2b.jpg)
# presentation slides
https://www.canva.com/design/DAE4K_5a9jc/peu76OEkvt6rcjPXY_-9Kg/view?utm_content=DAE4K_5a9jc&utm_campaign=designshare&utm_medium=link&utm_source=publishpresent
    


# Test cases overview 

To evaluate the performance of this tool, the OpenSta API was used to claculate the dynamic power of the input design before and after clock gating, and produce power reduction summary. 

| module               | Internal before | Switching before | Leakage before | Total before | Internal after | Switching after | Leakage after | Total after | total power difference | percentage reduction |
|----------------------|-----------------|------------------|----------------|--------------|----------------|-----------------|---------------|-------------|------------------------|----------------------|
| blabla               | 2.53E-03        | 8.68E-04         | 4.49E-08       | 3.39E-03     | 1.34E-03       | 3.53E-04        | 4.59E-08      | 1.69E-03    | 1.70E-03               | 50.22%               |
| chacha               | 6.43E-03        | 2.29E-03         | 4.35E-08       | 8.72E-03     | 3.96E-03       | 8.40E-04        | 4.26E-08      | 4.81E-03    | 3.92E-03               | 44.91%               |
| ldpc_decoder_802_3an | 1.53E-02        | 1.13E-02         | 1.23E-07       | 2.67E-02     | 1.23E-02       | 7.74E-03        | 1.33E-07      | 2.00E-02    | 6.68E-03               | 25.08%               |
| ldpcenc              | 1.93E-02        | 2.29E-02         | 7.46E-08       | 4.20E-02     | 1.03E-02       | 3.53E-03        | 6.91E-08      | 1.39E-02    | 2.81E-02               | 67.01%               |
| sp_mul               | 1.79E-02        | 1.63E-02         | 1.18E-08       | 3.41E-02     | 8.15E-03       | 4.77E-03        | 1.12E-08      | 1.29E-02    | 2.12E-02               | 62.12%               |
| PPU                  | 5.92E-02        | 1.27E-02         | 4.38E-08       | 7.20E-02     | 3.92E-02       | 3.03E-03        | 4.28E-08      | 4.23E-02    | 2.97E-02               | 41.27%               |
| ula                  | 2.76E-03        | 1.35E-03         | 1.16E-09       | 4.11E-03     | 2.40E-04       | 8.87E-05        | 1.17E-09      | 3.28E-04    | 3.78E-03               | 92.03%               |
| vm80a                | 6.87E-03        | 2.67E-03         | 4.55E-09       | 9.54E-03     | 5.23E-03       | 6.71E-04        | 4.44E-09      | 5.90E-03    | 3.64E-03               | 38.19%               |
| xtea                 | 9.19E-04        | 7.55E-04         | 6.01E-09       | 1.67E-03     | 7.61E-04       | 4.25E-04        | 5.70E-09      | 1.19E-03    | 4.87E-04               | 29.10%               |
| y_huff               | 1.25E-02        | 2.87E-03         | 3.76E-08       | 1.53E-02     | 9.32E-03       | 1.27E-03        | 3.64E-08      | 1.06E-02    | 4.71E-03               | 30.72%               |
| y_quantizer          | 2.01E-01        | 3.86E-02         | 4.53E-08       | 2.41E-01     | 1.35E-01       | 1.78E-02        | 3.12E-08      | 1.53E-01    | 8.78E-02               | 36.47%               |
| zigzag               | 8.53E-02        | 2.38E-02         | 1.25E-08       | 1.09E-01     | 4.89E-02       | 6.73E-03        | 9.96E-09      | 5.58E-02    | 5.33E-02               | 48.86%               |
| zipdiv               | 5.56E-04        | 2.31E-04         | 2.62E-09       | 7.87E-04     | 3.62E-04       | 6.90E-05        | 2.56E-09      | 4.32E-04    | 3.56E-04               | 45.17%               |
| y_dct                | 3.43E-02        | 2.29E-02         | 2.70E-07       | 5.73E-02     | 2.44E-02       | 1.28E-02        | 2.68E-07      | 3.72E-02    | 2.01E-02               | 35.07%               |
| jpeg_encoder         | 5.17E-02        | 3.27E-02         | 2.10E-07       | 8.31E-02     | 5.60E-02       | 3.25E-02        | 2.02E-07      | 8.84E-02    | -5.24E-03              | -6.30%               |
| aes_cipher           | 4.87E-03        | 3.86E-03         | 2.65E-08       | 8.73E-03     | 3.34E-03       | 1.48E-03        | 2.60E-08      | 4.82E-03    | 3.91E-03               | 44.76%               |
| sha512               | 1.26E-02        | 8.42E-03         | 7.47E-08       | 2.10E-02     | 7.18E-03       | 3.84E-03        | 6.48E-08      | 1.10E-02    | 9.96E-03               | 47.48%               |
| picorv32a            | 1.16E-02        | 5.11E-03         | 4.24E-08       | 1.67E-02     | 4.41E-03       | 1.42E-03        | 4.14E-08      | 5.83E-03    | 1.09E-02               | 65.18%               |
| riscv_top_151        | 1.18E-03        | 7.65E-04         | 3.00E-08       | 1.94E-03     | 9.12E-04       | 2.48E-04        | 2.86E-08      | 1.16E-03    | 7.80E-04               | 40.17%               |
| NfiVe32_RF           | 1.45E-03        | 2.29E-04         | 1.76E-08       | 1.68E-03     | 9.71E-04       | 3.35E-05        | 1.76E-08      | 1.00E-03    | 6.77E-04               | 40.26%               |
|                      |                 |                  |                |              |                |                 |               |             |                        | avg percentage       |
|                      |                 |                  |                |              |                |                 |               |             |                        | 43.89%               |
