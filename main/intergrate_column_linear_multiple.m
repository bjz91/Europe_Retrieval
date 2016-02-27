clear all
seasons=1:7
%seasons=6

intergrate_across_wind_para_path;
path_regional_files2=[path_regional_files start_jahrstr '_' end_jahrstr];
if ~exist(path_regional_files2,'dir')
    system(['mkdir -p ' path_regional_files2]);
    %mkdir(path_regional_files2);
end;
out_dirname_main=[path_regional_files2 '/Intergrate_column_height_resolution' num2str(resolution) '_' ROI(ROI_index).name '_altitude' num2str(wind_altitude) '_calmspeed' num2str(calm_speed) '_maxspeed' num2str(max_speed)];
if ~exist(out_dirname_main,'dir')
    system(['mkdir -p ' out_dirname_main]);
    %mkdir(out_dirname_main);
end;

fitoptions=optimset('lsqnonlin');
%for k=40
for k=1:size(raw,1)-1
    
    %for k=[1:7 9:16 19:22 24:94 96:99 101:106 108:size(raw,1)-1]%China
    %China from 76 aa*1.5 not until
    %k=[8 17 18 23 95 100 107]%skip China
    %for k=[2:4 6:18 20:25 27:28 30:35 37:41 44 46:47 49:75 77:97 100:size(raw,1)-1]%USA
    %k=[1 5 19 26 29 36 42 43 48 76 98 99]%skip USA
    intergrate_across_wind_para_path;
    
    name=cell2mat(raw(k+1,1))
    name(name==' ')='_';
    name(name=='+')='_';
    type=cell2mat(raw(k+1,13));
    
    %aa_LD=cell2mat(raw(k+1,6));
    %bb_LD=cell2mat(raw(k+1,7));
    
    option=cell2mat(raw(k+1,14));
    
    if option==1
        %aa, bb are single-side
        %         switch type
        %             case 'S'
        %                 aa=50;
        %                 bb=50;
        %             case 'M'
        %                 aa=100;
        %                 bb=100;
        %             otherwise
        %                 aa=100;
        %                 bb=100;
        %         end;
        
        switch type
            case 'S'
                %BJZ edit
                aa=100; %h=200km
                bb=20;  %v=40km
                %aa=250;
                %bb=250;
            case 'M'
                aa=100;
                bb=20;
            otherwise
                aa=100;
                bb=20;
        end;
        if strcmp(name, 'PRD')
            aa=150;
            bb=60;
        end;
 
        
        %BJZ edit why 1.5?
        % aa=aa*1.5;
         %bb=bb*1.5;
        
        clear Intergrate;
        out_dirname=[out_dirname_main '/' name];
        if ~exist(out_dirname,'dir')
            system(['mkdir -p ' out_dirname]);
            %mkdir(out_dirname);
        end;
        
        for indx_season=seasons
            Initialx=cell(4,1);
            Initialx{1,1}=nan;Initialx{2,1}=nan;Initialx{3,1}=nan;Initialx{4,1}=nan;
            Initialy=cell(4,1);
            Initialy{1,1}=nan;Initialy{2,1}=nan;Initialy{3,1}=nan;Initialy{4,1}=nan;
            Initialx0=zeros(4,5);
            Con=zeros(4,1);
            for indx_winddir=[1:4]
                [conv_XScale,conv_Tobs,Trot_return]=convolution_Gaussian(k,indx_season,indx_winddir,aa,bb);
                if ~isnan(conv_Tobs)
                    %[indx_season indx_winddir]
                    %dis_lim defines the minimum length of a good decay in function get_start_values_gaussian (data quality)
                    %dis_lim_j in function interference_Gaussian determines the area of direct source
                    switch type
                        case 'S'
                            dis_lim=50;
                            delta=22;% to ensure at least 4 grids used
                        case 'M'
                            dis_lim=100;
                            delta=0;
                        otherwise
                            dis_lim=100;
                            delta=0;
                    end;
                    %delta=aa-dis_lim;
                    %delta=22;%extend to 4 grid 18*4
                    Fit_prepare=get_start_values_gaussian_linear_multiple(conv_XScale,conv_Tobs,Trot_return,type,dis_lim,bb);
                    Initialx0(indx_winddir,:)=Fit_prepare.X0;
                    Initialx{indx_winddir}=Fit_prepare.t;
                    Initialy{indx_winddir}=Fit_prepare.y;
                    Intergrate.LD_quality(indx_season,indx_winddir)=Fit_prepare.quality;
                    %use Coni to label the direction which can be used for the fit
                    if ~isnan(Fit_prepare.quality)
                        Con(indx_winddir)=1;
                    end;
                    Intergrate.LD_max(indx_season,indx_winddir)=max(Fit_prepare.y);
                else
                    Intergrate.LD_max(indx_season,indx_winddir)=nan;
                end
            end;
            
            casenum=sum(Con);
            if casenum>0
                Gaussian_calm_fit_linear_multiple;
                %Yfit
                %if chi2_fit<0.1 & r_fit>0.8
                Intergrate.r_fit(indx_season,1)=r_fit;
                Intergrate.A(indx_season,1)=xfit(1);
                Intergrate.B(indx_season,:)=[xfit(4) xfit(8) xfit(12) xfit(16)];
                Intergrate.slope(indx_season,:)=[xfit(5) xfit(9) xfit(13) xfit(17)];
                Intergrate.sigma(indx_season,:)=[xfit(2) xfit(6) xfit(10) xfit(14)];
                Intergrate.shift(indx_season,:)=[xfit(3) xfit(7) xfit(11) xfit(15)];
                %unify the size of array
                %unify the size of array
                pointnum=max([length(matrix1(1,:)) length(matrix2(1,:)) length(matrix3(1,:)) length(matrix4(1,:))]);
                if length(matrix1)<pointnum
                    matrix1_new=[matrix1(1,:) zeros(1,pointnum-length(matrix1(1,:))) length(matrix1(1,:))];
                else
                    matrix1_new=[matrix1(1,:) length(matrix1(1,:))];
                end;
                if length(matrix2)<pointnum
                    matrix2_new=[matrix2(1,:) zeros(1,pointnum-length(matrix2(1,:))) length(matrix2(1,:))];
                else
                    matrix2_new=[matrix2(1,:) length(matrix2(1,:))];
                end;
                if length(matrix3)<pointnum
                    matrix3_new=[matrix3(1,:) zeros(1,pointnum-length(matrix3(1,:))) length(matrix3(1,:))];
                else
                    matrix3_new=[matrix3(1,:) length(matrix3(1,:))];
                end;
                if length(matrix4)<pointnum
                    matrix4_new=[matrix4(1,:) zeros(1,pointnum-length(matrix4(1,:))) length(matrix4(1,:))];
                else
                    matrix4_new=[matrix4(1,:) length(matrix4(1,:))];
                end;
                matrix_new=[matrix1_new; matrix2_new; matrix3_new; matrix4_new];
                
                X=zeros(1,17);
                ci=zeros(17,2);
                if length(use_id)==1
                    scale=matrix{use_id}(1,:);
                    y    =matrix{use_id}(2,:);
                    [X_tmp,r,J] = nlinfit(scale,y,@Gaussian_nlinfit_linear_multiple1,xfit_tmp);
                    ci_tmp = nlparci(X_tmp,r,'jacobian',J);
                    X([1 4*use_id-2 4*use_id-1 4*use_id 4*use_id+1])=X_tmp;
                    ci([1 4*use_id-2 4*use_id-1 4*use_id 4*use_id+1],:)=ci_tmp;
                elseif length(use_id)==2
                    scale=[matrix_new(use_id(1),:); matrix_new(use_id(2),:)];
                    y    =[matrix{use_id(1)}(2,:) matrix{use_id(2)}(2,:)];
                    [X_tmp,r,J] = nlinfit(scale,y,@Gaussian_nlinfit_linear_multiple2,xfit_tmp);
                    ci_tmp = nlparci(X_tmp,r,'jacobian',J);
                    X([1 4*use_id(1)-2 4*use_id(1)-1 4*use_id(1) 4*use_id(1)+1 4*use_id(2)-2 4*use_id(2)-1 4*use_id(2) 4*use_id(2)+1])=X_tmp;
                    ci([1 4*use_id(1)-2 4*use_id(1)-1 4*use_id(1) 4*use_id(1)+1 4*use_id(2)-2 4*use_id(2)-1 4*use_id(2) 4*use_id(2)+1],:)=ci_tmp;
                elseif length(use_id)==3
                    scale=[matrix_new(use_id(1),:); matrix_new(use_id(2),:); matrix_new(use_id(3),:)];
                    y    =[matrix{use_id(1)}(2,:) matrix{use_id(2)}(2,:) matrix{use_id(3)}(2,:)];
                    [X_tmp,r,J] = nlinfit(scale,y,@Gaussian_nlinfit_linear_multiple3,xfit_tmp);
                    ci_tmp = nlparci(X_tmp,r,'jacobian',J);
                    X([1 4*use_id(1)-2 4*use_id(1)-1 4*use_id(1) 4*use_id(1)+1 4*use_id(2)-2 4*use_id(2)-1 4*use_id(2) 4*use_id(2)+1 4*use_id(3)-2 4*use_id(3)-1 4*use_id(3) 4*use_id(3)+1])=X_tmp;
                    ci([1 4*use_id(1)-2 4*use_id(1)-1 4*use_id(1) 4*use_id(1)+1 4*use_id(2)-2 4*use_id(2)-1 4*use_id(2) 4*use_id(2)+1 4*use_id(3)-2 4*use_id(3)-1 4*use_id(3) 4*use_id(3)+1],:)=ci_tmp;
                else
                    scale=matrix_new;
                    y    =[matrix{use_id(1)}(2,:) matrix{use_id(2)}(2,:) matrix{use_id(3)}(2,:) matrix{use_id(4)}(2,:)];
                    [X_tmp,r,J] = nlinfit(scale,y,@Gaussian_nlinfit_linear_multiple4,xfit_tmp);
                    ci_tmp = nlparci(X_tmp,r,'jacobian',J);
                    X=X_tmp;
                    ci=ci_tmp;
                end;
                
                A=X(1);
                sigma=[X(2) X(6) X(10) X(14)];
                shift=[X(3) X(7) X(11) X(15)];
                B=    [X(4) X(8) X(12) X(16)];
                slope=[X(5) X(9) X(13) X(17)];
                Ycalc1=A*normpdf(matrix1(1,:),shift(1),sigma(1))+B(1)+slope(1)*matrix1(1,:);
                Ycalc2=A*normpdf(matrix2(1,:),shift(2),sigma(2))+B(2)+slope(2)*matrix2(1,:);
                Ycalc3=A*normpdf(matrix3(1,:),shift(3),sigma(3))+B(3)+slope(3)*matrix3(1,:);
                Ycalc4=A*normpdf(matrix4(1,:),shift(4),sigma(4))+B(4)+slope(4)*matrix4(1,:);
                Yfit2=[Ycalc1 Ycalc2 Ycalc3 Ycalc4];
                Yfit2(isnan(Yfit2))=[];
                R=corrcoef(y,Yfit2,'rows','pairwise');
                
                %                                Slope_line=cell(4,1);
                %                                plot_parameter_Gaussian_linear_multiple;
                %                                 out_dirname_figure1=[out_dirname_main '/figure'];
                %                                 if ~exist(out_dirname_figure1,'dir')
                %                                     %system(['md ' out_dirname_figure1]);
                %                                     mkdir(out_dirname_figure1);
                %                                 end;
                %                                 out_dirname_figure=[out_dirname_figure1 '/' name '_multiple'];
                %                                 if ~exist(out_dirname_figure,'dir')
                %                                     %system(['mkdir ' out_dirname_figure]);
                %                                     mkdir(out_dirname_figure);
                %                                 end;
                %                                 figure_fname=[out_dirname_figure '/Intergrate_calm_' name '_season' num2str(indx_season) '_winddir' num2str(indx_winddir) '_aa' num2str(aa) '_bb' num2str(bb) '.png'];
                %                                 %print(gcf,'-dpng',figure_fname,'-r600');
                %                                 print(gcf,'-dpng',figure_fname);
                
                Intergrate.R(indx_season,1)=R(2,1);
                Intergrate.A_lsqnonlin(indx_season,1)=X(1);
                Intergrate.A_min(indx_season,1)=ci(1,1);
                Intergrate.A_max(indx_season,1)=ci(1,2);
                Intergrate.B_lsqnonlin(indx_season,:)=[X(4) X(8) X(12) X(16)];
                Intergrate.B_min(indx_season,:)=[ci(4,1) ci(8,1) ci(12,1) ci(16,1)];
                Intergrate.B_max(indx_season,:)=[ci(4,2) ci(8,2) ci(12,2) ci(16,2)];
                Intergrate.slope_lsqnonlin(indx_season,:)=[X(5) X(9) X(13) X(17)];
                Intergrate.slope_min(indx_season,:)=[ci(5,1) ci(9,1) ci(13,1) ci(17,1)];
                Intergrate.slope_max(indx_season,:)=[ci(5,2) ci(9,2) ci(13,2) ci(17,2)];
                Intergrate.sigma_lsqnonlin(indx_season,:)=[X(2) X(6) X(10) X(14)];
                Intergrate.sigma_min(indx_season,:)=[ci(2,1) ci(6,1) ci(10,1) ci(14,1)];
                Intergrate.sigma_max(indx_season,:)=[ci(2,2) ci(6,2) ci(10,2) ci(14,2)];
                Intergrate.shift_lsqnonlin(indx_season,:)=[X(3) X(7) X(11) X(15)];
                Intergrate.shift_min(indx_season,:)=[ci(3,1) ci(7,1) ci(11,1) ci(15,1)];
                Intergrate.shift_max(indx_season,:)=[ci(3,2) ci(7,2) ci(11,2) ci(15,2)];
                Intergrate.chi2_fit(indx_season,1)=chi2_fit;
            else
                Intergrate.r_fit(indx_season,1)=nan;
                Intergrate.R(indx_season,1)=nan;
                Intergrate.A(indx_season,1)=nan;
                Intergrate.B(indx_season,1:4)=[nan nan nan nan];
                Intergrate.slope(indx_season,1:4)=[nan nan nan nan];
                Intergrate.sigma(indx_season,1:4)=[nan nan nan nan];
                Intergrate.shift(indx_season,1:4)=[nan nan nan nan];
                Intergrate.A_lsqnonlin(indx_season,1)=nan;
                Intergrate.A_min(indx_season,1)=nan;
                Intergrate.A_max(indx_season,1)=nan;
                Intergrate.B_lsqnonlin(indx_season,1:4)=[nan nan nan nan];
                Intergrate.B_min(indx_season,1:4)=[nan nan nan nan];
                Intergrate.B_max(indx_season,1:4)=[nan nan nan nan];
                Intergrate.slope_lsqnonlin(indx_season,1:4)=[nan nan nan nan];
                Intergrate.slope_min(indx_season,1:4)=[nan nan nan nan];
                Intergrate.slope_max(indx_season,1:4)=[nan nan nan nan];
                Intergrate.sigma_lsqnonlin(indx_season,1:4)=[nan nan nan nan];
                Intergrate.sigma_min(indx_season,1:4)=[nan nan nan nan];
                Intergrate.sigma_max(indx_season,1:4)=[nan nan nan nan];
                Intergrate.shift_lsqnonlin(indx_season,1:4)=[nan nan nan nan];
                Intergrate.shift_min(indx_season,1:4)=[nan nan nan nan];
                Intergrate.shift_max(indx_season,1:4)=[nan nan nan nan];
                Intergrate.chi2_fit(indx_season,1)=nan;
            end;
        end;
        data_fname=[out_dirname '/Intergrate_calm_' name '_' num2str(aa) '_bb' num2str(bb) '_linear_multiple.mat'];
        save(data_fname,'Intergrate');
    end;
end;



