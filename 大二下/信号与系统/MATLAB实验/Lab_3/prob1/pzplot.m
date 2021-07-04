function [poles,zeros]=pzplot(b,a,ROC)
%PZPLOT plots the poles and zeros of a continuous-time LTI system.
%
% Usage:  [poles,zeros] = pzplot(b,a,ROC)
%
% The vectors 'a' and 'b' contain the coefficients of the denominator
% and numerator polynomials of the LTI system function. The optional
% argument ROC defines one point in the region of convergence. The
% locations of the poles and zeros are returned in 'poles' and
% 'zeros'.

%---------------------------------------------------------------
% copyright 1996, by John Buck, Michael Daniel, and Andrew Singer.
% For use with the textbook "Computer Explorations in Signals and
% Systems using MATLAB", Prentice Hall, 1997.
%---------------------------------------------------------------

poles=roots(a); % determine poles
zeros=roots(b); % determine zeros
poles=poles(:); % make into column vector
zeros=zeros(:); % make into column vector

MaxI=max(abs(imag([poles; zeros;j]))); % Determine size of diagram
MaxR=max(abs(real([poles; zeros;1]))); % 
plot(1.5*[-MaxR MaxR],[0 0],'w')     % Plot the real axis
hold on
text(1.5*MaxR,0,' Re')
plot([0 0],1.5*[-MaxI MaxI],'w')     % Plot the imag axis
text(0,1.5*MaxI,' Im')
plot(real(zeros),imag(zeros),'bo')   % Plot zeros
plot(real(poles),imag(poles),'gx')   % Plot poles

if nargin>2,                         % ROC optional
  if(any(real(poles)<ROC))           % Any poles to the left?
    lpole=max(real(poles(real(poles)<ROC)));
    plot([lpole lpole],1.5*[-MaxI MaxI],'r--')
  end
  if(any(real(poles)>ROC))           % Any poles to the right?
    rpole=min(real(poles(real(poles)>ROC)));
    plot([rpole rpole],1.5*[-MaxI MaxI],'r--')
  end
  text(ROC,-1.25*MaxI,'ROC')          % Label the ROC
end

axis('square');                      % Make square aspect ratio
grid
hold off


