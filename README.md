# Matlab
Matlab Codes

The code contains the simulation of Turbo encoder - Symmetric and Asymmetric encoder.
1. To obtain the turbo encoder output ,
    all the files of Turbo encoder folder has to be opened in MATLAB and should be in the path of Matlab.exe execution file.
    The final_lte_encoder.m function has to be executed.
 
2. To obtain the turbo decoder output,
    1>component_decoder1.m
    2>component_decoder2.m
    3>jac.m
    4>measure_mutual_information_averaging.m
    5>constituent_encoder.m
    6>constituent_encoder2.m
    7>LTE_Turbo_interleaver.m
   8>total_decoder.m
All  the above mentioned files must be opened in MATLAB and the function total_decoder.m has to be executed.

3. To obtain the BER v/s SNR plot,
    replace the function total_decoder.m in point 2 by main_ber.m and execute the later.
