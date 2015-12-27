function Fit_prepare=get_start_values_gaussian_linear_multiple(t,y,Trot,type,dis_lim,bb)
%   t=conv_XScale;
%   y=conv_Tobs;
%   Trot=Trot_return;
[mini,starti]=min(abs(t));
[tmp,tmpi]= max([y(starti-1),y(starti),y(starti+1)]);
 starti=starti+tmpi-2;
 

%interference in y-direction: valid:1
if bb>=50
Fr=interference_Gaussian(Trot,starti,'right',dis_lim,type);
Fl=interference_Gaussian(Trot,starti,'left',dis_lim,type);
else
% Fr=interference_Gaussian_narrow(Trot,starti,'right',dis_lim,type);
% Fl=interference_Gaussian_narrow(Trot,starti,'left',dis_lim,type);
Fr=1;
Fl=1;
end

Y=y;
T=t;
if Fr==1 & Fl==0
    Fit_prepare.quality=1;
elseif Fr==0 & Fl==1
    Fit_prepare.quality=2;
elseif Fr==1 & Fl==1
    Fit_prepare.quality=3;
else
    Fit_prepare.quality=nan;
    Y=nan;
    T=nan;
end;

if Fit_prepare.quality>0
    [maxi,i]=max(Y);
    B=min(Y);
    A=Y(starti);
    slope=0;
    %sigma:HWHM to the right
    y_=Y-B;
    ii=i;
    while ii<length(y_) & y_(ii)>0.5*A  
        ii=ii+1;
    end;
    sigma=T(ii)-T(i);
    shift=t(starti);
    Fit_prepare.X0=[A sigma shift B slope];
else
    Fit_prepare.X0=[0 0 0 0 0];
end;
Fit_prepare.y=Y;
Fit_prepare.t=T;
