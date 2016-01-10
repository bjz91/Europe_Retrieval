function T=Gaussian_nlinfit_linear_multiple2(X,scale)

A=X(1);
sigma=[X(2) X(6)];
shift=[X(3) X(7)];
B=    [X(4) X(8)];
slope=[X(5) X(9)];
num1=scale(1,end);
num2=scale(2,end);

T1=A*normpdf(scale(1,1:num1),shift(1),sigma(1))+B(1)+slope(1)*scale(1,1:num1);
T2=A*normpdf(scale(2,1:num2),shift(2),sigma(2))+B(2)+slope(2)*scale(2,1:num2);

T=[T1 T2];
T(isnan(T))=0;