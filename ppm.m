function PPM=ppm (Bo,nsym)
% function to PPM 
% 'Bo' bit order 
% 'nsym': number of PPM symbol to generate 
PPM=[];                                            %PPM array empty inizialization 
for i= 1:nsym                                    %cycle from 1 to number of symbol,every cycle generate one symbol 
bitSig= rand (1,Bo)> 0.5;                 % random binary number 
dec_value=bi2de(bitSig,'left-msb'); %converting bit to decimal value 
tempPPM=zeros(1,2^Bo);                %zero sequence of length 2^M 
tempPPM(dec_value+1)=1;              %placing a pulse accoring to decimal value, 
%matlab index start from 1 and not from 0, so need to add 1; 
PPM=[PPM tempPPM];                    %put tempPPM in array queue 
end                                                    %close for cycle 
end

