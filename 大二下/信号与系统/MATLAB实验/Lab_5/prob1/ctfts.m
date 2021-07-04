function [X,w] = ctfts(x,T)
%CTFTS calculates the continuous-time Fourier transform (CTFT) 
% of a periodic signal x(t) which is reconstructed from the samples in
% the vector x using ideal bandlimited interpolation.  The vector x
% contains samples of x(t) over an integer number of periods, and T
% is the sampling period.
%
% Usage: [X,w] = ctfts(x,T)
% 
% The vector X contains the area of the impulses at the frequency
% values stored in the vector w.
% 
% This function makes make use of the relationship between the CTFT
% of x(t) and the DTFT of its samples x[n], as well as the
% relationship between the DTFT and the DTFS of x[n].

%---------------------------------------------------------------
% copyright 1996, by John Buck, Michael Daniel, and Andrew Singer.
% For use with the textbook "Computer Explorations in Signals and
% Systems using MATLAB", Prentice Hall, 1997.
%---------------------------------------------------------------

N = length(x);
X = fftshift(fft(x,N))*(2*pi/N);
w = linspace(-1,1-1/N,N)/(2*T);

