# Automatic clock gating on Yosys RTLIL level
An automatic clock gating utility that is generic for all SKY_130 RTL designs. The tool takes an RTL HDL design (typically Verilog) and applies clock gating using over-the-shelf commands provided by Yosys. The clock-gating problem is transformed into a graph problem with the help of Yosys RTLIL (register transfer level intermediate language), where the tool replaces all flipflops with enable inputs into clock-gated flipflops. 

# The American University In Cairo  
![the_american_university_in_cairo_0](https://user-images.githubusercontent.com/63082375/145812500-c4416b84-b1f0-4c99-b2f5-39622d864d2b.jpg)
# presentation slides
https://www.canva.com/design/DAE4K_5a9jc/peu76OEkvt6rcjPXY_-9Kg/view?utm_content=DAE4K_5a9jc&utm_campaign=designshare&utm_medium=link&utm_source=publishpresent
    


# Test cases overview 

<img width="660" alt="Screen Shot 2022-02-27 at 12 49 44 PM" src="https://user-images.githubusercontent.com/63082375/155879361-87a6d3b4-d7ff-4541-b379-1694e8468c69.png">
