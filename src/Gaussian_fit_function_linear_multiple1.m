function F=Gaussian_fit_function_linear_multiple1(xfit,matrix1)
A=xfit(1);
sigma=[xfit(2)];
shift=[xfit(3)];
B=    [xfit(4)];
slope=[xfit(5)];

Ycalc1=A*normpdf(matrix1(1,:),shift(1),sigma(1))+B(1)+slope(1)*matrix1(1,:);

F=[Ycalc1-matrix1(2,:)];
F(isnan(F))=0;