function F=Gaussian_fit_function_linear_multiple4(xfit,matrix1,matrix2,matrix3,matrix4)
A=xfit(1);
sigma=[xfit(2) xfit(6) xfit(10) xfit(14)];
shift=[xfit(3) xfit(7) xfit(11) xfit(15)];
B=    [xfit(4) xfit(8) xfit(12) xfit(16)];
slope=[xfit(5) xfit(9) xfit(13) xfit(17)];

Ycalc1=A*normpdf(matrix1(1,:),shift(1),sigma(1))+B(1)+slope(1)*matrix1(1,:);
Ycalc2=A*normpdf(matrix2(1,:),shift(2),sigma(2))+B(2)+slope(2)*matrix2(1,:);
Ycalc3=A*normpdf(matrix3(1,:),shift(3),sigma(3))+B(3)+slope(3)*matrix3(1,:);
Ycalc4=A*normpdf(matrix4(1,:),shift(4),sigma(4))+B(4)+slope(4)*matrix4(1,:);

F=[Ycalc1-matrix1(2,:) Ycalc2-matrix2(2,:) Ycalc3-matrix3(2,:) Ycalc4-matrix4(2,:)];
F(isnan(F))=0;