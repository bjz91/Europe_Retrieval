function T=Gaussian_nlinfit_linear_multiple1(X,scale)

A=X(1);
sigma=X(2);
shift=X(3);
B=    X(4);
slope=X(5);

T=A*normpdf(scale,shift,sigma)+B+slope*scale;
T(isnan(T))=0;