function T=inversion_tau_nlinfit_prefit(X,parameters)
%zuerst wird NUR TAU gefittet; falls die Unsicherheit ausreichend klein (max-min<20h):
%alles andere auch!

t=parameters.XScale;
A=parameters.A;
B=parameters.B;
%sigma=parameters.sigma;
%t0=parameters.t0;
conv_XScale=parameters.conv_XScale;
conv_Tobs=parameters.conv_Tobs;

T=ExtendedModelFunction(t,X(1),A,B,conv_XScale,conv_Tobs);
