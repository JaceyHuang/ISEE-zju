% deffeqn.m
function y=diffeqn(a,x,yn1)

N=length(x);
y(1)=yn1;
for n=0:N-1
    y(n+2)=a*y(n+1)+x(n+1); % Eq.(1.6)
end