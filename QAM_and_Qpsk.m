function [im_qpsk,im_16qam,im_64qam, in] = QAM_and_Qpsk(SNRdb)
SNRdb=max(max(SNRdb));
%%% Modulator and Demodulator Objects %%%
h_qpsk=modem.pskmod('M',16,'phaseoffset',pi/16,'inputtype','bit');
g_qpsk=modem.pskdemod('M',16,'phaseoffset',pi/16,'outputtype','bit');
h_16qam=modem.qammod('M',16,'inputtype','bit');
g_16qam=modem.qamdemod('M',16,'outputtype','bit');
h_64qam=modem.qammod('M',64,'inputtype','bit');
g_64qam=modem.qamdemod('M',64,'outputtype','bit');
%%%%% TRANSMITTER  
in=imread('4.2.03.tiff');    % image to be transmitted and matlab code should be in same directory
N=numel(in);
in2=reshape(in,N,1);
bin=de2bi(in2,'left-msb');
input=reshape(bin',numel(bin),1);
len=length(input);
%%%%% padding zeroes to input %%%
z=len;
while(rem(z,2) || rem(z,4)|| rem(z,6))
    z=z+1;
    input(z,1)=0;
end
input=double(input);
y_qpsk=modulate(h_qpsk,input);
y_16qam=modulate(h_16qam,input);
y_64qam=modulate(h_64qam,input);
ifft_out_qpsk=ifft(y_qpsk);
ifft_out_16qam=ifft(y_16qam);
ifft_out_64qam=ifft(y_64qam);


tx_qpsk=awgn(ifft_out_qpsk,SNRdb,'measured');
tx_16qam=awgn(ifft_out_16qam,SNRdb,'measured');
tx_64qam=awgn(ifft_out_64qam,SNRdb,'measured');

%%%%    RECEIVER  
k_qpsk=fft(tx_qpsk);
k_16qam=fft(tx_16qam);
k_64qam=fft(tx_64qam);
l_qpsk=demodulate(g_qpsk,k_qpsk);
l_16qam=demodulate(g_16qam,k_16qam);
l_64qam=demodulate(g_64qam,k_64qam);
output_qpsk=uint8(l_qpsk);
output_16qam=uint8(l_16qam);
output_64qam=uint8(l_64qam);
output_qpsk=output_qpsk(1:len);
output_16qam=output_16qam(1:len);
output_64qam=output_64qam(1:len);
b1=reshape(output_qpsk,8,N)';
b2=reshape(output_16qam,8,N)';
b3=reshape(output_64qam,8,N)';
dec_qpsk=bi2de(b1,'left-msb');
dec_16qam=bi2de(b2,'left-msb');
dec_64qam=bi2de(b3,'left-msb');


%% calculat BER 
BER_qpsk=biterr(input,l_qpsk)/len
BER_16qam=biterr(input,l_16qam)/len
BER_64qam=biterr(input,l_64qam)/len


%% Received image data 
im_qpsk=reshape(dec_qpsk(1:N),size(in,1),size(in,2),size(in,3));
im_16qam=reshape(dec_16qam(1:N),size(in,1),size(in,2),size(in,3));
im_64qam=reshape(dec_64qam(1:N),size(in,1),size(in,2),size(in,3));

end

