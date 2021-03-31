function [T_noise] = Noise( Dr  , q , R_rx , Iamf , Prx_los , Ba)
%% Calculate Noise in System
I2=0.562 ;                            %noise bandwdith factor  
%% Noise Bandwidth 
Bn= I2 *Dr ;
P_amb = Iamf / R_rx ; 
P_total= Prx_los * P_amb ; 
%% shot noise 
shot_n = 2*q * R_rx * P_total * Bn ;
%% Amplifier noise variance 
Amp_n = Iamf^2 * Ba ;
%% Total noise 
T_noise = Amp_n + shot_n; 
end

