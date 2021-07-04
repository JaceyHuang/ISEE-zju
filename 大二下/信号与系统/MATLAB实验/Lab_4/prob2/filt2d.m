% filt2d.m

function y=filt2d(b,a,d,x)
    z=zeros(32,32); % preset memory
    y=zeros(32,32);
    for i=1:32
        xi=x(:,i); % each column        
        z1=filter(b,a,[xi;zeros(d,1)]); % filter response
        z(:,i)=z1(d+1:end); % store the result
    end
    for i=1:32
        zi=z(i,:); % each row
        y1=filter(b,a,[zi zeros(1,d)]); % filter response
        y(i,:)=y1(d+1:end); % store the result
    end