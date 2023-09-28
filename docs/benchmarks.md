# Dynamic Power Consumption Analysis for Clock Gating Optimization

This documentation presents the power consumption analysis for a design that underwent clock gating optimization using Lighter. The objective of the analysis is to determine the dynamic power reduction achieved through clock gating. It is important to note that OpenSTA was used for power calculations, and it only provides static power values based on a given activity factor. Therefore, an alternative approach was employed to estimate the dynamic power reduction after clock gating.

To gain insights into the power calculation criteria used by OpenSTA, we conducted experiments on an inverter-driven flip-flop, and we obtained a series of intriguing results, which are outlined below:

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


These results reveal a limitation of the OpenSTA tool, as it does not consider the real activity factor for the flip-flops. The observed values in the table indicate that the internal and switching power significantly change when the activity factor is changed. This discrepancy raises concerns because, in theory, the flip-flop remains connected to the main clock source, which maintains full activity. This contradicts the expected result of having the values unchanged, which implies that OpenSTA will not provide realistic values for the power reduction done after clock gating by Lighter. Thus we introduced the following criteria to estimate the reduction.

## Methodology

1. Measurement of Total Power Consumption Before Clock Gating:
   - The total power consumption of the entire design was measured at an activity factor of 0.1, representing the assumption that all cells except flip-flops are active 10% of the time.

   - The power consumption of the flip-flops is calculated at an activity factor of 1.0, since they are connected directly to the clock source that has full activity.

   - Using the obtained measurements, the total power consumption before clock gating was calculated using the following equation:

            Total power before clk_gating = (power of all cells at alpha(0.1)) - (flipflops power at alpha(0.1)) + (flipflops power at alpha(1.0))


2. Calculation of Total Power Consumption After Clock Gating:
   - The total power consumption of the entire design excluding the added clock gates was measured at an activity factor of 0.1, representing the assumption that all cells except flip-flops are active 10% of the time.

   - The power consumption of the clock gated flip-flops is now measured at a reduced activity factor of 0.05, reflecting the industry-standard assumption that flip-flops are active only 5% of the time after clock gating.

   - The power consumption of the not clock gated flip-flops and the clock gate cells is measured at a high activity factor of 1.0, since they are directly connected to the clock.

   - Using the obtained measurements, the total power consumption after clock gating was calculated using the following equation: 

            Let the following:
            normal      = activity factor of 0.1
            high        = activity factor of 1.0
            low         = activity factor of 0.05
            Power after = Power after clock gating
            all         = power of all cells
            cg_ff       = power of clock gated flip flops
            n_cg_ff     = power of not clock gated flip flops
            cg          = power of clock gates

            Power after = all_normal - cg_ff_normal + cg_ff_low - cg_normal + cg_high - n_cg_ff_normal + n_cg_ff_high

# Benchmarks

The benchmarking results presented below demonstrate the remarkable energy savings and enhanced power efficiency achieved through the implementation of this optimization technique. These findings highlight the crucial role of incorporating automatic clock gating, such Lighter, within building HW designs. By leveraging Lighter, substantial power reductions can be realized, enabling designers to effectively meet power-related design constraints and elevate overall efficiency levels.

|Design          |# Cells before|# Cells after|# Clock Gates|# Flipflops|# Clock-gated Flipflops|Total power before (W)|Total power after (W)|Total power difference (W)|Power reduction %|# Cells reduction %|
|----------------|--------------|-------------|-------------|-----------|-----------------------|----------------------|---------------------|--------------------------|-----------------|-------------------|
|AHB_SRAM        |245           |182          |7            |182        |47                     |3.90E-04              |3.22E-04             |6.74E-05                  |17.29%           |25.71%             |
|blabla          |10589         |10195        |24           |10195      |1098                   |1.57E-03              |1.12E-03             |4.52E-04                  |28.80%           |3.72%              |
|blake2s         |14207         |12637        |63           |12637      |1872                   |8.96E-03              |5.94E-03             |3.02E-03                  |33.70%           |11.05%             |
|blake2s_core    |12971         |11346        |46           |11346      |1353                   |7.09E-03              |4.53E-03             |2.56E-03                  |36.05%           |12.53%             |
|blake2s_m_select|4518          |3511         |16           |3511       |512                    |2.65E-03              |1.51E-03             |1.14E-03                  |43.00%           |22.29%             |
|chacha          |12857         |12307        |52           |12307      |1936                   |6.92E-03              |4.74E-03             |2.18E-03                  |31.49%           |4.28%              |
|genericfir      |143575        |135662       |638          |135662     |11624                  |8.42E-02              |5.67E-02             |2.75E-02                  |32.62%           |5.51%              |
|i2c_master      |758           |658          |21           |658        |106                    |5.79E-04              |5.02E-04             |7.70E-05                  |13.29%           |13.19%             |
|jpeg_encoder    |62472         |55114        |388          |55114      |4637                   |3.38E-02              |2.36E-02             |1.02E-02                  |30.23%           |11.78%             |
|ldpcenc         |20134         |18898        |28           |18898      |1273                   |1.91E-02              |1.56E-02             |3.44E-03                  |18.04%           |6.14%              |
|NfiVe32_RF      |3362          |2334         |32           |2334       |1024                   |7.84E-03              |5.45E-03             |2.39E-03                  |30.46%           |30.58%             |
|picorv32a       |14271         |12490        |128          |12490      |1244                   |6.42E-03              |4.79E-03             |1.63E-03                  |25.42%           |12.48%             |
|PPU             |10248         |6719         |410          |6719       |2845                   |6.25E-02              |5.01E-02             |1.23E-02                  |19.74%           |34.44%             |
|prv32_cpu       |2241          |1715         |10           |1715       |207                    |1.03E-03              |7.34E-04             |2.94E-04                  |28.57%           |23.47%             |
|rf_64x64        |13475         |9153         |64           |9153       |4096                   |3.14E-02              |2.14E-02             |1.01E-02                  |32.01%           |32.07%             |
|sha512          |20187         |17592        |74           |17592      |3669                   |7.73E-03              |5.37E-03             |2.36E-03                  |30.53%           |12.85%             |
|spi_master      |175           |145          |8            |145        |43                     |1.93E-04              |1.76E-04             |1.77E-05                  |9.16%            |17.14%             |
|y_huff          |11004         |8657         |450          |8657       |2345                   |1.37E-02              |1.10E-02             |2.68E-03                  |19.55%           |21.33%             |
|y_quantizer     |8281          |5726         |256          |5726       |2816                   |2.27E-01              |1.57E-01             |7.04E-02                  |30.96%           |30.85%             |
|zigzag          |3807          |1591         |65           |1591       |769                    |8.14E-02              |5.54E-02             |2.60E-02                  |31.95%           |58.21%             |


## Further Stats:

| Avarage Power Reduction % | Avarage cell Reduction % |
| ------------------------- | ------------------------ |
| 27.14%                    | 19.48%                   |

| Max Power Reduction % | Min Power Reduction % |
| --------------------- | --------------------- |
| 43.00%                | 9.16%                |

| Max cell Reduction % | Min cell Reduction % |
| -------------------- | -------------------- |
| 58.21%               | 3.72%                |


<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/power_reduction_summary.png" alt="power_summary" width="750"/>

<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/area_reduction_summary.png" alt="cells_summary" width="750"/>