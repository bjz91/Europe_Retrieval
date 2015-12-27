function F=inversion_EMF_v20140130(xfit,xparam,fitflag,X,Y,conv_XScale,conv_Tobs)

t=X;

%xfit beinhaltet die zu fittenden Variablen;
%xparam die anderen;
%in der festgelegten Reihenfolge!
%Hier müssen die Variablen zusammengesucht werden
xfitindex=1;
xparamindex=1;
if fitflag(1)==1
    tau=xfit(xfitindex);xfitindex=xfitindex+1;
else
    tau=xparam(xparamindex);xparamindex=xparamindex+1;
end;
if fitflag(2)==1
    A=xfit(xfitindex);xfitindex=xfitindex+1;
else
    A=xparam(xparamindex);xparamindex=xparamindex+1;
end;
if fitflag(3)==1
    B=xfit(xfitindex);xfitindex=xfitindex+1;
else
    B=xparam(xparamindex);xparamindex=xparamindex+1;
end;
if fitflag(4)==1
    C=xfit(xfitindex);xfitindex=xfitindex+1;
else
    C=xparam(xparamindex);xparamindex=xparamindex+1;
end;
if fitflag(5)==1
    D=xfit(xfitindex);xfitindex=xfitindex+1;
else
    D=xparam(xparamindex);xparamindex=xparamindex+1;
end;
if fitflag(6)==1
    sigma=xfit(xfitindex);xfitindex=xfitindex+1;
else
    sigma=xparam(xparamindex);xparamindex=xparamindex+1;
end;
if fitflag(7)==1
    t0=xfit(xfitindex);xfitindex=xfitindex+1;
else
    t0=xparam(xparamindex);xparamindex=xparamindex+1;
end;

Ycalc=ExtendedModelFunction(t,tau,A,B,conv_XScale,conv_Tobs);
F=Ycalc-Y;
F(isnan(F))=0;




