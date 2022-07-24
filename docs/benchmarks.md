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
|Design          |# Cells before|# Cells after|# Clock Gates|# Flipflops|# Clock-gated Flipflops|Total power before (W)|Total power after (W)|Total power difference (W)|Power reduction %|Cells reduction %|
|----------------|--------------|-------------|-------------|-----------|-----------------------|----------------------|---------------------|--------------------------|-----------------|-----------------|
|AHB_SRAM        |245           |182          |7            |182        |47                     |3.896E-04             |3.222E-04            |6.737E-05                 |17.29%           |25.71%           |
|blake2s         |14225         |14253        |16           |14253      |512                    |8.943E-03             |8.437E-03            |5.056E-04                 |5.65%            |-0.20%           |
|chacha          |12857         |12882        |26           |12882      |832                    |6.915E-03             |5.982E-03            |9.330E-04                 |13.49%           |-0.19%           |
|genericfir      |143703        |145111       |128          |145111     |1536                   |8.430E-02             |7.792E-02            |6.379E-03                 |7.57%            |-0.98%           |
|i2c_master      |759           |680          |21           |680        |106                    |5.789E-04             |5.038E-04            |7.510E-05                 |12.97%           |10.41%           |
|jpeg_encoder    |63757         |56216        |388          |56216      |4637                   |3.413E-02             |2.380E-02            |1.033E-02                 |30.26%           |11.83%           |
|ldpcenc         |19947         |18712        |28           |18712      |1273                   |1.897E-02             |1.562E-02            |3.348E-03                 |17.65%           |6.19%            |
|NfiVe32_RF      |3362          |2334         |32           |2334       |1024                   |7.843E-03             |5.454E-03            |2.389E-03                 |30.46%           |30.58%           |
|picorv32a       |14348         |12624        |85           |12624      |1011                   |6.449E-03             |5.011E-03            |1.439E-03                 |22.31%           |12.02%           |
|PPU             |10156         |6850         |405          |6850       |2824                   |6.257E-02             |5.029E-02            |1.228E-02                 |19.62%           |32.55%           |
|prv32_cpu       |2186          |1662         |10           |1662       |207                    |1.029E-03             |7.342E-04            |2.945E-04                 |28.63%           |23.97%           |
|rf_64x64        |13461         |9158         |64           |9158       |4096                   |3.141E-02             |2.135E-02            |1.006E-02                 |32.02%           |31.97%           |
|sha512          |20240         |17645        |74           |17645      |3669                   |7.702E-03             |5.374E-03            |2.328E-03                 |30.22%           |12.82%           |
|spi_master      |179           |145          |8            |145        |43                     |1.919E-04             |1.757E-04            |1.622E-05                 |8.45%            |18.99%           |
|y_quantizer     |8281          |8122         |16           |8122       |176                    |2.272E-01             |2.248E-01            |2.409E-03                 |1.06%            |1.92%            |
|zigzag          |3807          |1591         |65           |1591       |769                    |8.143E-02             |5.542E-02            |2.602E-02                 |31.95%           |58.21%           |

