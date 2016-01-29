clear all
seasons=1:7
%seasons=6

intergrate_across_wind_para_path;
path_regional_files2=[path_regional_files start_jahrstr '_' end_jahrstr];
if ~exist(path_regional_files2,'dir')
    system(['mkdir -p ' path_regional_files2]);
end;
DATA_dirname=[path_regional_files2 '/LD_height_resolution' num2str(resolution) '_'  ROI(ROI_index).name '_altitude' num2str(wind_altitude) '_calmspeed' num2str(calm_speed) '_maxspeed' num2str(max_speed)];
out_dirname_main=[path_regional_files2 '/Fit_tau_height_resolution' num2str(resolution) '_' ROI(ROI_index).name '_altitude' num2str(wind_altitude) '_calmspeed' num2str(calm_speed) '_maxspeed' num2str(max_speed) '_calm_conv'];
if ~exist(out_dirname_main,'dir')
    system(['mkdir -p ' out_dirname_main]);
end;

fitoptions=optimset('lsqnonlin');
opt=statset('nlinfit');
%  opt.TolFun=1e-9;
%  opt.TolX=1e-9;
%  opt.DerivStep=1e-9;
%opt.Robust='on';

opt.TolFun=1e-10;
opt.TolX=1e-10;
opt.DerivStep=1e-10;

for k=1:size(raw,1)-1
    
    name=cell2mat(raw(k+1,1))
    name(name==' ')='_';
    name(name=='+')='_';
    aa=cell2mat(raw(k+1,6));
    bb=cell2mat(raw(k+1,7));
    aa_calm=cell2mat(raw(k+1,9));
    bb_calm=cell2mat(raw(k+1,10));
    %aa_calm=aa_calm+0;
    %aa=aa+50;
    %bb=bb-100;
    
    option=cell2mat(raw(k+1,14));
    
    if option==1
        
        clear Results;
        out_dirname=[out_dirname_main '/' name];
        if ~exist(out_dirname,'dir')
            system(['mkdir -p ' out_dirname]);
        end;
        fname=[DATA_dirname '/LineDensities_' name '_aa' num2str(aa) '_bb' num2str(bb) '.mat'];
        disp(fname);
        if exist(fname,'file')
            load(fname);%'LD'
            fname_calm=[DATA_dirname '/LineDensities_' name '_aa' num2str(aa_calm) '_bb' num2str(bb_calm) '_calm.mat'];
            load(fname_calm);%'LD_conv'
            Results.print=zeros(9,10);
            for indx_season=seasons
                for indx_winddir=[1:4 6:9]
                    %for indx_winddir=[8]
                    success=0;
                    Tobs=LD(indx_season,indx_winddir).Tobs;%in 1e23 molec/cm
                    %Terr=LD(indx_season,indx_winddir).Terr;
                    XScale=LD(indx_season,indx_winddir).XScale;%in km
                    projected_wind=LD(indx_season,indx_winddir).wind;%in m/s
                    N_=LD(indx_season,indx_winddir).N;
                    side_length_x=double(LD(indx_season,indx_winddir).side_length_x);%in km
                    
                    if sum(~isnan(Tobs))/length(XScale)>0.8 % 80% m?sen da sein!
                        %[indx_season,indx_winddir]
                        %Fit
                        windlabel=['v_{' winddirlabel(indx_winddir,':') '}'];
                        
                        %tau is x0 in this script!! in km
                        projected_wind=projected_wind*3.6;%in km/h
                        t=XScale; %x in km
                        Y=Tobs;%in 1e23 molec/cm
                        
                        %alle:tau,A,B,C,D,sigma,t0
                        %[conv_XScale,conv_Tobs]=convolution(k,indx_season,indx_winddir);
                        conv_Tobs=LD_conv(indx_season,indx_winddir).Tobs;%in 1e23 molec/cm
                        conv_XScale=LD_conv(indx_season,indx_winddir).XScale;%in km
                        if ~isnan(conv_Tobs)
                            ['Calm',indx_season,indx_winddir]
                            test_ExtendedModelFunctionFit;
                            Tcalc=Yfit;
                            
                            %nlinfit to get uncertainty ranges
                            %nans filled in by Tcalc from test_ExtendedModelFunctionFit (maximum 20% of all
                            %points!
                            
                            %if chi2_fit1<0.1 & r_fit>0.9
                            if r_fit>0.9
                                Y(isnan(Y))=Tcalc(isnan(Y));
                                parameters.XScale=t;
                                parameters.A=xfit(2);
                                parameters.B=xfit(3);
                                %parameters.sigma=xfit(4);
                                %parameters.t0=xfit(3);
                                %parameters.wind=projected_wind;
                                parameters.conv_XScale=conv_XScale;
                                parameters.conv_Tobs=conv_Tobs;
                                
                                %a) prefit
                                [X,r,J] = nlinfit(parameters,Y,@inversion_tau_nlinfit_prefit,xfit(1),opt);
                                Tcalc1=ExtendedModelFunction(t,X,xfit(2),xfit(3),conv_XScale,conv_Tobs);
                                %h=plot(t,Tcalc1,'c:','LineWidth',1.5);
                                taurange = nlparci(X,r,'jacobian',J);
                                if abs(diff(taurange))<20*projected_wind && xfit(1)<XMAX(1) && xfit(1)>XMIN(1)
                                    %b) fit all
                                    ci=taurange;
                                    [X_final,r,J,CovB,MSE] = nlinfit(parameters,Y,@inversion_tau_nlinfit,xfit,opt);
                                    %indx_winddir
                                    ci_final = nlparci(X_final,r,'jacobian',J);
                                    [Ypred,delta] = nlpredci(@inversion_tau_nlinfit,parameters,X_final,r,'Covar',CovB);
                                    pre_ci=nanmean(delta/Ypred);
                                    Results.pre_ci(indx_season,indx_winddir)=pre_ci;
                                    success=1;
                                    Tcalc2=ExtendedModelFunction(t,X_final(1),X_final(2),X_final(3),conv_XScale,conv_Tobs);
                                    %%%%%%%%%%%%%%%%%%%%%%%%plot_parameter(t,Tobs,projected_wind,windlabel,X(1),X(2),X(3),conv_XScale,conv_Tobs);
                                    %                                     plot_parameter_figure(t,Tobs,projected_wind,windlabel,xfit(1),xfit(2),xfit(3),conv_XScale,conv_Tobs,indx_winddir);
                                    %                                     %t_extended=conv_XScale(conv_XScale<120&conv_XScale>-120);
                                    %                                     %Y1=1*exp(-t_extended/(5*projected_wind));%Exponential function
                                    %                                     %Y1(Y1>1)=0;
                                    %                                     %Y2=conv2(conv_Tobs,Y1/sum(Y1),'same');
                                    %                                     %F=interp1(conv_XScale,Y2,t);
                                    %                                     %h=plot(t,F,'b:','LineWidth',2.5);
                                    %                                     %%%%%%%%%%%%%%%%%%%%%%%%dirstr=['dir' num2str(indx_winddir,1)];
                                    %                                     dirstr=winddirlabel(indx_winddir,':');
                                    %                                     location=nanmax(conv_Tobs)*1.2;
                                    %                                     h=text(0,location,dirstr);set(h,'FontS',24);set(h,'Color','k');
                                    %                                     %%%%%%%%%%%%%%%%%%%%%%%%h=plot(t,Tcalc,'r--','LineWidth',2.5);
                                    %                                     h=plot(t,Tcalc2,'r-','LineWidth',2.5);
                                    %                                     set(gca,'FontSize',16);
                                    %                                     axis square;
                                    %                                     xlabel('x [km]','fontname','Arial','FontSize',18);
                                    %                                     ylabel('NO_2 Line Density [10^{23} molec/cm]','fontname','Arial','FontSize',18);
                                    %
                                    %                                     xlim([-aa_calm aa_calm]);
                                    %                                     ylim([0 max(conv_Tobs)*1.4]);
                                    %                                     set(gca,'ytick',0:ceil(max(conv_Tobs)*1.4)/5:max(conv_Tobs)*1.4);
                                    %                                     set(gca,'position',[0.05,0.1,0.95,0.85]);
                                    %
                                    %                                     box on;
                                    % %
                                    %                                     figure_fname=[out_dirname '\Fit_' name '_season' num2str(indx_season) '_winddir' num2str(indx_winddir) '_aa' num2str(aa) '_bb' num2str(bb) '.png'];
                                    % %                                    figure_fname=[out_dirname '\Fit_' name '_interval' num2str(aa_calm) '_no_limit.png'];
                                    % %                                     print(gcf,'-dpng',figure_fname,'-r600');
                                    %                                     print(gcf,'-dpng',figure_fname);
                                    R=corrcoef(Tobs,Tcalc2,'rows','pairwise');
                                    
                                end;
                            end;
                        end;
                    end;
                    if success==1
                        Results.R(indx_season,indx_winddir)=R(2,1);
                        Results.tau_lsqnonlin(indx_season,indx_winddir)=xfit(1)/projected_wind;
                        Results.A_lsqnonlin(indx_season,indx_winddir)=xfit(2);
                        Results.background_lsqnonlin(indx_season,indx_winddir)=xfit(3);
                        Results.tau(indx_season,indx_winddir)=X_final(1)/projected_wind;
                        Results.tau_min(indx_season,indx_winddir)=ci_final(1,1)/projected_wind;
                        Results.tau_max(indx_season,indx_winddir)=ci_final(1,2)/projected_wind;
                        Results.A(indx_season,indx_winddir)=X_final(2);%convert molec to mole
                        Results.A_min(indx_season,indx_winddir)=ci_final(2,1);
                        Results.A_max(indx_season,indx_winddir)=ci_final(2,2);
                        Results.background(indx_season,indx_winddir)=X_final(3);
                        Results.background_min(indx_season,indx_winddir)=ci_final(3,1);
                        Results.background_max(indx_season,indx_winddir)=ci_final(3,2);
                        %Results.sigma(indx_season,indx_winddir)=X(4);
                        %Results.sigma_min(indx_season,indx_winddir)=ci(4,1);
                        %Results.sigma_max(indx_season,indx_winddir)=ci(4,2);
                        %Results.shift(indx_season,indx_winddir)=X(3);
                        %Results.shift_min(indx_season,indx_winddir)=ci(3,1);
                        %Results.shift_max(indx_season,indx_winddir)=ci(3,2);
                        Results.N(indx_season,indx_winddir)=N_;
                        Results.w(indx_season,indx_winddir)=projected_wind;
                        Results.chi2_fit1(indx_season,indx_winddir)=chi2_fit1;
                        %Results.chi2_fit2(indx_season,indx_winddir)=chi2_fit2;
                        %Results.chi2_fit3(indx_season,indx_winddir)=chi2_fit3;
                    else
                        Results.R(indx_season,indx_winddir)=nan;
                        Results.tau_lsqnonlin(indx_season,indx_winddir)=nan;
                        Results.A_lsqnonlin(indx_season,indx_winddir)=nan;
                        Results.background_lsqnonlin(indx_season,indx_winddir)=nan;
                        Results.tau(indx_season,indx_winddir)=nan;
                        Results.A(indx_season,indx_winddir)=nan;
                        Results.background(indx_season,indx_winddir)=nan;
                        %Results.sigma(indx_season,indx_winddir)=nan;
                        %Results.shift(indx_season,indx_winddir)=nan;
                        Results.N(indx_season,indx_winddir)=nan;
                        Results.w(indx_season,indx_winddir)=nan;
                        Results.chi2_fit1(indx_season,indx_winddir)=nan;
                        %Results.chi2_fit2(indx_season,indx_winddir)=nan;
                        %Results.chi2_fit3(indx_season,indx_winddir)=nan;
                        Results.tau_min(indx_season,indx_winddir)=nan;
                        Results.tau_max(indx_season,indx_winddir)=nan;
                        Results.A_min(indx_season,indx_winddir)=nan;
                        Results.A_max(indx_season,indx_winddir)=nan;
                        Results.background_min(indx_season,indx_winddir)=nan;
                        Results.background_max(indx_season,indx_winddir)=nan;
                        %Results.sigma_min(indx_season,indx_winddir)=nan;
                        %Results.sigma_max(indx_season,indx_winddir)=nan;
                        %Results.shift_min(indx_season,indx_winddir)=nan;
                        %Results.shift_max(indx_season,indx_winddir)=nan;
                    end;
                    if indx_season==6 && exist('X_final','var') && success==1
                        Results.print(indx_winddir,:)=[projected_wind/3.6 X_final(1)/projected_wind ci_final(1,1)/projected_wind ci_final(1,2)/projected_wind...
                            X_final(2) ci_final(2,1) ci_final(2,2) X_final(3) ci_final(3,1) ci_final(3,2)];
                    end;
                end;
            end;
            data_fname=[out_dirname '/Fitresults_' name '_' num2str(aa) '_bb' num2str(bb) '_new.mat'];
            save(data_fname,'Results');
        end;
    end
end;