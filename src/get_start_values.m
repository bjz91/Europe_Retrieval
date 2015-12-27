function x0 = get_start_values(t,y)
%A
A=1;
B=0;
%t0
[maxi,i]=max(y);
if i == length(y)
    y(i)=y(i-1);
    [maxi,i]=max(y);
end;
if i == 1
    y(i)=y(i+1);
    [maxi,i]=max(y);
end;
%t0=t(i);
t0=0;
%B+C
a=nanmean(y(1:5));
b=nanmean(y(end-4:end));
C=(b-a)/(t(end)-t(1));
%B=a-C*(t(1)-t0);

%D
D=0;
%sigma:HWHM to the left
y_=y-B-C*(t-t0);
ii=i;
while y_(ii)>0.5*A && ii > 1
    ii=ii-1;
end;
sigma=t(i)-t(ii);
%tau:HWHM to the right
ii=i;
while y_(ii)>0.5*A && ii < length(y_)
        ii=ii+1;
end;
%tau=t(ii)-t(i)-sigma;
tau=t(ii)-t(i);
if tau<0
    tau=0;
end;

x0=[tau A B C D sigma t0];

