# Dynamic Power Analysis

To evaluate the performance of this tool, the OpenSta API was used to calculate the dynamic power of the designs before and after clock gating, and produce a power reduction summary. 

To understand how OpenSta calculates the power, we experimented with the power reports using an inverter-driven flipflop, and we got the following results:

### Flipflop power at activity factor 1.0:

|Internal|Switching|Leakage |Total   |
|--------|---------|--------|--------|
|Power   |Power    |Power   |Power   |
|7.50e-06|3.87e-07 |8.78e-12|7.89e-06|



### Flipflop power at activity factor 0.1:

|Internal|Switching|Leakage |Total   |
|--------|---------|--------|--------|
|Power   |Power    |Power   |Power   |
|4.17e-06|3.87e-08 |8.78e-12|4.21e-06|


### Flipflop power at activity factor 0.05:

|Internal|Switching|Leakage |Total   |
|--------|---------|--------|--------|
|Power   |Power    |Power   |Power   |
|3.99e-06|1.94e-08 |8.78e-12|4.01e-06|


These results show that the...



Since that OpenSta calculates the activity factors by propagation over the cells, and does not assign a 100% activity factor for flipflops nor recognizes clock gates activity factor contribution, we applied the following formula to get reasonable and accurate power reports:

    Total power before clk_gating = (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(1.0))

    Total power after clk_gating =  (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(0.05))

    Where alpha is the activity factor.



# Benchmarks
|Design  |Clock Gates|Flipflops|Clock-gated Flipflops|Total power before (W)|Total power after (W)|Total power difference (W)|Percentage power reduction %|Percentage # Cells reduction %|
|--------|-----------|---------|---------------------|----------------------|---------------------|--------------------------|----------------------------|------------------------------|
|AHB_SRAM|7          |49       |47                   |3.90E-04              |2.97E-04             |9.22E-05                  |23.67%                      |25.71%                        |
|blabla  |24         |1098     |1098                 |1.57E-03              |1.12E-03             |4.48E-04                  |28.54%                      |4.30%                         |
|blake2s |63         |1875     |1872                 |8.94E-03              |5.86E-03             |3.08E-03                  |34.43%                      |11.75%                        |
|blake2s_core|46         |1353     |1353                 |7.06E-03              |4.50E-03             |2.56E-03                  |36.28%                      |13.07%                        |
|blake2s_m_select|16         |512      |512                  |2.64E-03              |1.50E-03             |1.14E-03                  |43.36%                      |22.47%                        |
|chacha  |52         |1938     |1936                 |6.92E-03              |4.67E-03             |2.24E-03                  |32.44%                      |5.23%                         |
|genericfir|638        |11624    |11624                |8.43E-02              |5.60E-02             |2.83E-02                  |33.55%                      |6.22%                         |
|i2c_master|21         |145      |106                  |5.79E-04              |4.89E-04             |8.96E-05                  |15.48%                      |10.41%                        |
|jpeg_encoder|388        |4638     |4637                 |3.41E-02              |2.34E-02             |1.07E-02                  |31.38%                      |11.83%                        |
|ldpcenc |28         |1372     |1273                 |1.90E-02              |1.04E-02             |8.58E-03                  |45.23%                      |6.19%                         |
|NfiVe32_RF|32         |1024     |1024                 |7.84E-03              |5.39E-03             |2.45E-03                  |31.26%                      |30.58%                        |
|picorv32a|127        |1619     |1244                 |6.45E-03              |4.80E-03             |1.65E-03                  |25.52%                      |12.91%                        |
|PPU     |410        |2845     |2845                 |6.26E-02              |4.82E-02             |1.43E-02                  |22.91%                      |32.62%                        |
|prv32_cpu|10         |211      |207                  |1.03E-03              |7.28E-04             |3.00E-04                  |29.21%                      |23.97%                        |
|rf_64x64|64         |4096     |4096                 |3.14E-02              |2.12E-02             |1.02E-02                  |32.40%                      |27.35%                        |
|sha512  |74         |3673     |3669                 |7.70E-03              |5.35E-03             |2.36E-03                  |30.59%                      |12.82%                        |
|spi_master|8          |53       |43                   |1.92E-04              |1.65E-04             |2.66E-05                  |13.85%                      |18.99%                        |
|y_dct   |247        |5362     |4928                 |3.38E-02              |2.33E-02             |1.05E-02                  |30.98%                      |5.95%                         |
|y_huff  |450        |2368     |2345                 |1.36E-02              |1.06E-02             |3.00E-03                  |22.07%                      |21.59%                        |
|y_quantizer|256        |2820     |2816                 |2.27E-01              |1.53E-01             |7.45E-02                  |32.78%                      |30.90%                        |
|zigzag  |65         |769      |769                  |8.14E-02              |5.42E-02             |2.73E-02                  |33.46%                      |58.21%                        |

