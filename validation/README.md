yosys-config --build cg_plugin.so clock_gating_plugin.cc
python synth_test.py
python validate.py
