function F=Gaussian_fit_function_linear_multiple2(xfit,matrix1,matrix2)
A=xfit(1);
sigma=[xfit(2) xfit(6)];
shift=[xfit(3) xfit(7)];
B=    [xfit(4) xfit(8)];
slope=[xfit(5) xfit(9)];

Ycalc1=A*normpdf(matrix1(1,:),shift(1),sigma(1))+B(1)+slope(1)*matrix1(1,:);
Ycalc2=A*normpdf(matrix2(1,:),shift(2),sigma(2))+B(2)+slope(2)*matrix2(1,:);

F=[Ycalc1-matrix1(2,:) Ycalc2-matrix2(2,:)];
F(isnan(F))=0;