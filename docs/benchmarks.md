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

| Design       | \# Cells before | \# Cells after | \# Clock Gates | \# Flipflops | \# Clock-gated Flipflops | Total power before (W) | Total power after (W) | Total power difference (W) | Power reduction % | \# Cells reduction % |
| ------------ | --------------- | -------------- | -------------- | ------------ | ------------------------ | ---------------------- | --------------------- | -------------------------- | ----------------- | -------------------- |
| AHB_SRAM     | 245             | 182            | 7              | 182          | 47                       | 3.90E-04               | 3.22E-04              | 6.74E-05                   | 17.29%            | 25.71%               |
| blake2s      | 14225           | 14302          | 16             | 14302        | 512                      | 8.94E-03               | 8.46E-03              | 4.83E-04                   | 5.40%             | \-0.54%              |
| chacha       | 12857           | 12892          | 26             | 12892        | 832                      | 6.92E-03               | 6.03E-03              | 8.90E-04                   | 12.87%            | \-0.27%              |
| genericfir   | 143703          | 145111         | 128            | 145111       | 1536                     | 8.43E-02               | 7.79E-02              | 6.38E-03                   | 7.57%             | \-0.98%              |
| i2c_master   | 759             | 680            | 21             | 680          | 106                      | 5.79E-04               | 5.04E-04              | 7.51E-05                   | 12.97%            | 10.41%               |
| jpeg_encoder | 63757           | 55113          | 388            | 55113        | 4637                     | 3.41E-02               | 2.36E-02              | 1.05E-02                   | 30.85%            | 13.56%               |
| ldpcenc      | 19947           | 18880          | 28             | 18880        | 1273                     | 1.90E-02               | 1.56E-02              | 3.35E-03                   | 17.66%            | 5.35%                |
| NfiVe32_RF   | 3362            | 2334           | 32             | 2334         | 1024                     | 7.84E-03               | 5.45E-03              | 2.39E-03                   | 30.46%            | 30.58%               |
| picorv32a    | 14348           | 12624          | 85             | 12624        | 1011                     | 6.45E-03               | 5.01E-03              | 1.44E-03                   | 22.38%            | 12.02%               |
| PPU          | 10156           | 6921           | 405            | 6921         | 2824                     | 6.26E-02               | 5.03E-02              | 1.23E-02                   | 19.61%            | 31.85%               |
| prv32_cpu    | 2186            | 1662           | 10             | 1662         | 207                      | 1.03E-03               | 7.34E-04              | 2.95E-04                   | 28.63%            | 23.97%               |
| rf_64x64     | 13461           | 9572           | 64             | 9572         | 4096                     | 3.14E-02               | 2.14E-02              | 1.01E-02                   | 32.02%            | 28.89%               |
| sha512       | 20240           | 17592          | 74             | 17592        | 3669                     | 7.70E-03               | 5.37E-03              | 2.33E-03                   | 30.24%            | 13.08%               |
| spi_master   | 179             | 145            | 8              | 145          | 43                       | 1.92E-04               | 1.76E-04              | 1.62E-05                   | 8.45%             | 18.99%               |
| y_quantizer  | 8281            | 8122           | 16             | 8122         | 176                      | 2.27E-01               | 2.25E-01              | 2.41E-03                   | 1.06%             | 1.92%                |
| zigzag       | 3807            | 1591           | 65             | 1591         | 769                      | 8.14E-02               | 5.54E-02              | 2.60E-02                   | 31.95%            | 58.21%               |



## Further Stats:

| Avarage Power Reduction % | Avarage cell Reduction % |
| ------------------------- | ------------------------ |
| 19.34%                    | 17.05%                   |

| Max Power Reduction % | Min Power Reduction % |
| --------------------- | --------------------- |
| 32.02%                | 1.06%                 |

| Max cell Reduction % | Min cell Reduction % |
| -------------------- | -------------------- |
| 58.21%               | \-0.98%              |



<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/power_reduction_summary.png" alt="power_summary" width="750"/>

<img src="https://github.com/AUCOHL/Lighter/blob/main/docs/diagrams/area_reduction_summary.png" alt="cells_summary" width="750"/>