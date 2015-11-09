function [ps, f] = PowerSpect(sig, Fs)
% [PS, F] = POWERSPECT(SIG, FS) generates power spectrum from given signal
% using Fourier transform

% Calc and plot power spectrum
N = length(sig);
f = (0:1:N-1)*Fs/N;
xf = 2*abs(fft(sig))/N; xf(1) = xf(1)/2;
ps = xf.^2;                 % Compute Power spectrum (without Hamming window)

f = f(1:floor((N-1)/2));
ps = ps(1:floor((N-1)/2));
ps(1) = 0; % discard DC-component