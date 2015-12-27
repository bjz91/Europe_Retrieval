fitoptions=optimset('lsqnonlin');

%X0=[A sigma shift B slope]
Initial_A=mean(Initialx0(find(Con==1),1));
xmin=[5   -20 -0.1 -1];
xmax=[50  20  3    1];

matrix1=[Initialx{1};Initialy{1}];
matrix2=[Initialx{2};Initialy{2}];
matrix3=[Initialx{3};Initialy{3}];
matrix4=[Initialx{4};Initialy{4}];
matrix={matrix1;matrix2;matrix3;matrix4};
use_id=find(Con==1);

XMIN=[0   repmat(xmin,1,length(use_id))];
XMAX=[1e4 repmat(xmax,1,length(use_id))];
xfit=zeros(1,17);
%F=Gaussian_fit_function(A,sigma,B,X,Y)
%x = lsqnonlin(fun,x0,lb,ub,options,P1,P2,...) passes the problem-dependent parameters P1, P2, etc., directly to the function fun. Pass an empty matrix for options to use the default values for options.
if length(use_id)==1
    X0=[Initial_A Initialx0(use_id,2:5)];
    [xfit_tmp,fval,exitflag,output]=lsqnonlin(@Gaussian_fit_function_linear_multiple1,X0,XMIN,XMAX,fitoptions,matrix{use_id});
    xfit([1 4*use_id-2 4*use_id-1 4*use_id 4*use_id+1])=xfit_tmp;
elseif length(use_id)==2
    X0=[Initial_A Initialx0(use_id(1),2:5) Initialx0(use_id(2),2:5)];
    [xfit_tmp,fval,exitflag,output]=lsqnonlin(@Gaussian_fit_function_linear_multiple2,X0,XMIN,XMAX,fitoptions,matrix{use_id(1)},matrix{use_id(2)});
    xfit([1 4*use_id(1)-2 4*use_id(1)-1 4*use_id(1) 4*use_id(1)+1 4*use_id(2)-2 4*use_id(2)-1 4*use_id(2) 4*use_id(2)+1])=xfit_tmp;
elseif length(use_id)==3
    X0=[Initial_A Initialx0(use_id(1),2:5) Initialx0(use_id(2),2:5) Initialx0(use_id(3),2:5)];
    [xfit_tmp,fval,exitflag,output]=lsqnonlin(@Gaussian_fit_function_linear_multiple3,X0,XMIN,XMAX,fitoptions,matrix{use_id(1)},matrix{use_id(2)},matrix{use_id(3)});
    xfit([1 4*use_id(1)-2 4*use_id(1)-1 4*use_id(1) 4*use_id(1)+1 4*use_id(2)-2 4*use_id(2)-1 4*use_id(2) 4*use_id(2)+1 4*use_id(3)-2 4*use_id(3)-1 4*use_id(3) 4*use_id(3)+1])=xfit_tmp;
else
    X0=[Initial_A Initialx0(1,2:5) Initialx0(2,2:5) Initialx0(3,2:5) Initialx0(4,2:5)];
    [xfit_tmp,fval,exitflag,output]=lsqnonlin(@Gaussian_fit_function_linear_multiple4,X0,XMIN,XMAX,fitoptions,matrix1,matrix2,matrix3,matrix4);
    xfit=xfit_tmp;
end;
  
A=xfit(1);
sigma=[xfit(2) xfit(6) xfit(10) xfit(14)];
shift=[xfit(3) xfit(7) xfit(11) xfit(15)];
B=    [xfit(4) xfit(8) xfit(12) xfit(16)];
slope=[xfit(5) xfit(9) xfit(13) xfit(17)];
Ycalc1=A*normpdf(matrix1(1,:),shift(1),sigma(1))+B(1)+slope(1)*matrix1(1,:);
Ycalc2=A*normpdf(matrix2(1,:),shift(2),sigma(2))+B(2)+slope(2)*matrix2(1,:);
Ycalc3=A*normpdf(matrix3(1,:),shift(3),sigma(3))+B(3)+slope(3)*matrix3(1,:);
Ycalc4=A*normpdf(matrix4(1,:),shift(4),sigma(4))+B(4)+slope(4)*matrix4(1,:);

Yfit=[Ycalc1 Ycalc2 Ycalc3 Ycalc4];
Yfit_plot=cell(1,4);
Yfit_plot{1}=Ycalc1;Yfit_plot{2}=Ycalc2;Yfit_plot{3}=Ycalc3;Yfit_plot{4}=Ycalc4;

Yfit(isnan(Yfit))=[];
y=   [matrix1(2,:) matrix2(2,:) matrix3(2,:) matrix4(2,:)];
y(isnan(y))=[];
Tdiff=Yfit-y;
chi2_fit=nanmean(Tdiff.^2);

r_fit1=corrcoef(Yfit,y,'rows','pairwise');
r_fit=r_fit1(1,2);