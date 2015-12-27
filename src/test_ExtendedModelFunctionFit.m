
fitoptions=optimset('lsqnonlin');

X0=get_start_values(t,Y);
X0(1)=4*projected_wind;
%XMIN=[0.1*projected_wind 0 -0.1 -Inf -Inf 5 min(t)];
%XMAX=[50*projected_wind 1e4 1 Inf Inf 200 max(t)];
XMIN=[0.1*projected_wind 0 -0.2 -Inf -Inf 5 -30];
XMAX=[48*projected_wind 2 0.2 Inf Inf 200 30];

%alle:tau,A,B,C,D,sigma,t0
fitflag=[1 1 1 0 0 0 0];
%davon zu fitten: tau,A,B
x0=X0(fitflag==1);
xmin=XMIN(fitflag==1);
xmax=XMAX(fitflag==1);
%die anderen: C,D,sigma,t0
xparam=[0 0 0 0];
%F=inversion_EMF_v20140130(xfit,xparam,fitflag,X,Y,conv_XScale,conv_Tobs)
%x = lsqnonlin(fun,x0,lb,ub,options,P1,P2,...) passes the problem-dependent parameters P1, P2, etc., directly to the function fun. Pass an empty matrix for options to use the default values for options.
[xfit,resnorm,residual,exitflag,output,lambda,jacobian]=lsqnonlin(@inversion_EMF_v20140130,x0,xmin,xmax,fitoptions,xparam,fitflag,t,Y,conv_XScale,conv_Tobs);
%jacobian
%test = nlparci(xfit,residual,'jacobian',jacobian)

Yfit=ExtendedModelFunction(t,xfit(1),xfit(2),xfit(3),conv_XScale,conv_Tobs);
Tdiff=Yfit-Tobs; chi2_fit1=nanmean(Tdiff.^2);

r_fit1=corrcoef(Yfit,Tobs,'rows','pairwise');
r_fit=r_fit1(1,2);
%figure; hold on;
%plot(t,Y,'k-');
%plot(t,Yfit,'r-');
%xfit


%alle:tau,A,B,C,D,sigma,t0
%fitflag=[1 1 1 1 1 1 1];
%x0=X0(fitflag==1);
%xmin=XMIN(fitflag==1);
%xmax=XMAX(fitflag==1);
%xparam=[];
%[xfit,fval,exitflag,output]=lsqnonlin(@inversion_EMF_v20140130,x0,xmin,xmax,fitoptions,xparam,fitflag,t,Y,conv_XScale,conv_Tobs);
%Yfit=ExtendedModelFunction(t,xfit(1),xfit(2),xfit(3),xfit(4),xfit(5),xfit(6),xfit(7),conv_XScale,conv_Tobs);
%Tdiff=Yfit-Tobs; chi_fit3=nanmean(Tdiff.^2);

%figure; hold on;
%plot(t,Y,'k-');
%plot(t,Yfit,'r-');
%xfit
