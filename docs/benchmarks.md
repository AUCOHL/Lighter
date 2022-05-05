# Dynamic Power Analysis

To evaluate the performance of this tool, the OpenSTA API was used to calculate the dynamic power of the designs before and after clock gating, and produce a power reduction summary. 

To understand how OpenSTA calculates the power, we experimented with the power reports using an inverter-driven flipflop, and we got the following results:

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


These results show that the... (WIP)



Since that OpenSTA calculates the activity factors by propagation over the cells, and does not assign a 100% activity factor for flipflops nor recognizes clock gates activity factor contribution, we applied the following formula to get reasonable and accurate power reports:

    Total power before clk_gating = (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(1.0))

    Total power after clk_gating =  (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(0.05)) - (Clock-gates power at alpha(0.1)) + (Clock-gates power at alpha(1.0))

    Where alpha is the activity factor.



# Benchmarks
|Design          |# Cells before|# Cells after|# Clock Gates          |# Flipflops           |# Clock-gated Flipflops|Total power before (W)|Total power after (W)|Total power difference (W)|Power reduction %|Cells reduction %|
|----------------|--------------|-------------|-----------------------|----------------------|-----------------------|----------------------|---------------------|--------------------------|-----------------|-----------------|
|AHB_SRAM        |245           |182          |7                      |49                    |47                     |3.90E-04              |3.08E-04             |8.11E-05                  |20.83%           |25.71%           |
|blake2s         |14225         |14253        |16                     |1875                  |512                    |8.94E-03              |8.06E-03             |8.86E-04                  |9.91%            |-0.20%           |
|chacha          |12857         |12882        |26                     |1938                  |832                    |6.92E-03              |5.88E-03             |1.03E-03                  |14.93%           |-0.19%           |
|genericfir      |143703        |145111       |128                    |11624                 |1536                   |8.43E-02              |8.09E-02             |3.38E-03                  |4.01%            |-0.98%           |
|i2c_master      |759           |680          |21                     |145                   |106                    |5.79E-04              |5.05E-04             |7.34E-05                  |12.68%           |10.41%           |
|jpeg_encoder    |63757         |56216        |388                    |4638                  |4637                   |3.41E-02              |2.38E-02             |1.03E-02                  |30.26%           |11.83%           |
|ldpcenc         |19947         |18712        |28                     |1372                  |1273                   |1.90E-02              |1.04E-02             |8.55E-03                  |45.05%           |6.19%            |
|NfiVe32_RF      |3362          |2334         |32                     |1024                  |1024                   |7.84E-03              |5.45E-03             |2.39E-03                  |30.46%           |30.58%           |
|picorv32a       |14348         |12624        |85                     |1618                  |1011                   |6.45E-03              |5.10E-03             |1.35E-03                  |20.90%           |12.02%           |
|PPU             |10156         |6850         |405                    |2845                  |2824                   |6.26E-02              |5.01E-02             |1.25E-02                  |19.96%           |32.55%           |
|prv32_cpu       |2186          |1662         |10                     |211                   |207                    |1.03E-03              |7.36E-04             |2.93E-04                  |28.45%           |23.97%           |
|rf_64x64        |13461         |9158         |64                     |4096                  |4096                   |3.14E-02              |2.14E-02             |1.01E-02                  |32.02%           |31.97%           |
|sha512          |20240         |17645        |74                     |3673                  |3669                   |7.70E-03              |5.37E-03             |2.33E-03                  |30.21%           |12.82%           |
|spi_master      |179           |145          |8                      |53                    |43                     |1.92E-04              |1.71E-04             |2.04E-05                  |10.64%           |18.99%           |
|y_quantizer     |8281          |8122         |16                     |2820                  |176                    |2.27E-01              |2.23E-01             |3.86E-03                  |1.70%            |1.92%            |
|zigzag          |3807          |1591         |65                     |769                   |769                    |8.14E-02              |5.54E-02             |2.60E-02                  |31.95%           |58.21%           |

