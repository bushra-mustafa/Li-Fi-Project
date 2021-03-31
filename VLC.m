%%%%%%%%%%%%%%%%%%%% References %%%%%%%%%%%%%%%%%%%
% [1] Xiao Long (University of Cambridge) and LC Png (Nanyang Technological University)
% [2]Z. Ghassemlooy, W. Popoola, and S. Rajbhandari.
%    Optical Wireless Communications:System and Channel Modelling with MATLAB.
%    CRC Press, Inc., USA, 1st edition, 2012.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc
%%  paremetars %%
Illuminance
phi =30;       %FOV
P_led = 10 ;    %power by led (M-Watt)
theta = 60 ;    %Transmitter Semi-angle, angle of irradiance in half (Radian)
ar = 7.8E-7 ;   % Detector area, ARX (or photodiode active area) (Meter^2)
n=1.5 ;         % Photodetect Concentrator refractive index
Dr= 115200;      %Data rate
Iamb = 7E-8;    % Ambient light power (Ampere) %
q = 1.60E-19;   % Electron charge (C)
Ba = 4.5E6;     % Amplifier bandwidth (Hz)%
Iamf = 5e-12 ;  % Amplifier noise density (Ampere/Hz^0.5)%
R_rx = 0.6;     %responsivity of receiver
%%
%% room
L=5 ; W=5 ; H=3 ;
D=1.48 ;                           %distance between Tx & Rx

%% Line of sight (los )
M=-log(2)/log(cos(theta)) ;                  % Order of Lambertian emission
Ro= ((M+1)/(2*pi)) * cos(theta)^M ;          % Lambertian radiant intensity
H_Los = (ar./D.^2).*cos(phi)*Ro ;            %Channel transfer function
Prx_los = P_led * H_Los   ;                  % Rx power of los

%% call function Noise
[T_noise ] = Noise (  Dr  , q , R_rx , Iamf , Prx_los , Ba );

%% Signal to noise ratio (SNR)
SNR = (R_rx *Prx_los).^2 / T_noise ;
SNR_db = 10* log10 (SNR);

%% puls pustion modulation parametar
Bo=3 ;                %Bit order
Lsy=2^Bo;             %symbol length
nsym=200;             %number of PPM symbols
Lsig=nsym*Lsy;        %total length of PPM slots
Rsymb=1e6;            %slot rate symbol rate
Rb=(Rsymb*Bo);        %Bit rate
Tb =1/Rb ;
%%
SNRdb= 0:0.5:SNR_db;       %Energy per bit db
EsN0=SNRdb+10*log10(Bo);    %Energy per symbol db
EbN0= 10.^(SNRdb./10);     %Energy per bit Eb/N0

%% Call Function PPM Modulation
PPM=ppm(Bo,nsym);      %function to generate PPM signal 0
PPM = PPM*1;           %Matlab logic signal in double
for i=1:length(SNRdb)
    Pavg(i) =(1/Lsy)*sqrt((((2*Bo)*T_noise*Rsymb*EbN0(i))/(2*R_rx^2))); %Luminous power factor (2M/L)
    Ipeak(i) = Lsy*R_rx*Pavg(i);       %Photodiode Current
    Epeak(i) = Lsy*Bo*Ipeak(i)^2 * Tb; %Peak current energy
    sigma(i)=sqrt(T_noise*Epeak(i)/(2));%standard deviation after receiver
    threshold=0.5*Epeak(i);             %threshold level
    for j=1 : Lsig
        MF_out(j) = PPM(j)*Epeak(i)+ normrnd(0,sigma(i));   %matched filter output
    end
    received_PPM=zeros(1,Lsig);                             %generating empty PPM vector
    received_PPM(find(MF_out> threshold))=1;                %generating the received signal
    [No_of_Error(i) ser_hdd(i)]= biterr(received_PPM,PPM);  %Matlab function to caluclate the SER
end



%%
%% theoretical calculation
figure(1)
semilogy(SNRdb ,ser_hdd,'magenta');     %simulation BER graph
ylabel('SLER'); xlabel('SNR (dB)');
title([num2str(Lsy),'-PPM Slot Error Rate']);
grid on
grid minor
hold on;

Pse_ppm_theor=qfunc(sqrt(Bo*EbN0)); %transform SLER to SER

semilogy(SNRdb ,Pse_ppm_theor,'red','linewidth',0.5); %theoretical BER

%% Call function to OOK Modulation
[theorBER,simuBER] = OOK(SNRdb,Rb,EbN0,R_rx,T_noise);
figure(2)
semilogy(SNRdb,theorBER,'red');  %theoretical BER graph
grid on
ylabel('BER');
xlabel('SNR (dB)');
title('Bit Error Rate for Binary (OOK) ');
hold on                          %graph definition
%% theoretical BER amd Eb/N0 graph
figure(4)
semilogy(EbN0,theorBER,'blue');
grid on
ylabel('BER');
xlabel('EbN0');
title('Bit Error probability curve for Binary (OOK) ');
hold on
%% Call Function Qam & QPSK Modulation

[im_qpsk,im_16qam,im_64qam ,in] = QAM_and_Qpsk(SNRdb);
figure(6);
imshow(im_qpsk);
title('QPSK');
figure(7);
imshow(im_16qam);
title('16QAM');
figure(8);
imshow(im_64qam);title('64-QAM');
%% MSE  Mean-squared error

s=immse(im_qpsk,in);
s16=immse(im_16qam,in);
s64=immse(im_64qam,in)'

y=[s s16 s64];
x=1:3 ;
figure;
bar(x,y,'blue');
title(" Mean squared error");
set(gca,'xTicklabel',{"16-QPSK " ,"16-QAM" , "64-QAM"})