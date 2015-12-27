function T=inversion_tau_nlinfit(X,parameters)

t=parameters.XScale;
A=X(2);
B=X(3);
%sigma=X(4);if sigma<5 sigma=5; end;
%t0=X(3);
conv_XScale=parameters.conv_XScale;
conv_Tobs=parameters.conv_Tobs;

T=ExtendedModelFunction(t,X(1),A,B,conv_XScale,conv_Tobs);