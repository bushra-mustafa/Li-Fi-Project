function [theorBER ,simuBER ] = OOK(SNRdb,Rb,SNR_e,R_rx,T_noise)
%OOK Summary of this function goes here
nSignal=1000;
Tbit=1/Rb;
randombinary = rand (1,nSignal)> 0.5; % Random Binary Signal 
randombinary = randombinary *1; %transform logical input in double 
for i=1:length(SNRdb) %SNR_db cycle 
Pavg(i) = sqrt((T_noise*Rb*SNR_e(i))/(2*R_rx^2)); %Luminous power 
Ipeak(i) = 2*R_rx*Pavg(i); %Photodiode Current 
Epeak(i) = Ipeak(i)^2 * Tbit; %Peak current energy 
sigma(i)=sqrt(T_noise*Epeak(i)/2); %standard deviation after receiver 
threshold=0.5*Epeak(i); %threshold level 
for j=1 : nSignal; 
receivedSignal(j) = randombinary(j)*Epeak(i)+ normrnd(0,sigma(i)); %matched filter output 
% bitsignal * Energy for one bit + normal distribuited noise 
end 
% same of above cycle 
Rx = zeros(1,nSignal); %received signal inizialization 
Rx(find(receivedSignal>threshold)) = 1; %threshold detection 
[No_of_Error(i) simuBER(i)]=biterr(randombinary,Rx); %matlab function 
end 
theorBER = qfunc(sqrt(SNR_e)); %theorical formula of OOK BER 



end

