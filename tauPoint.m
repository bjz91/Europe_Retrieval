
str='output/2005_2014/Fit_tau_height_resolution4_Europe_altitude500_calmspeed2_maxspeed1000_calm_conv/';
strLD='output/2005_2014/LD_height_resolution4_Europe_altitude500_calmspeed2_maxspeed1000/';
load('input/Points.mat');

tau_final=cell(size(Points,2),6);

season=6; %Ozone season

for i=1:size(Points,2)
    
    disp(Points{i});
    
    %% 读取数据
    load([str,Points{i},'/Fitresults_',Points{i},'_300_bb300_new.mat']);
    load([strLD,'LineDensities_',Points{i},'_aa300_bb300.mat']);
    
    
    % Tau of all seasons and wind directions
    tau_all=Results.tau;
    %tau_all=Results.tau_lsqnonlin; %!!!!!!!!!用lsqnonlin的结果看起来更好
    tau_all(tau_all==0)=NaN;
    if sum(~isnan(tau_all))==0
        tau_final{i,1}=Points{i};
        tau_final{i,2}=nan;
        tau_final{i,3}=nan;
        tau_final{i,4}=nan;
        tau_final{i,5}=nan;
        tau_final{i,6}=nan;
        disp('Nonexist!');
        continue;
    end
    
    % Wind speed in 7*9
    windspeed_all=zeros(7,9);
    for ws_i=1:7
        for ws_j=1:9
            windspeed_all(ws_i,ws_j)=LD(ws_i,ws_j).wind;
        end
    end
    
    ci_all=Results.tau_max-Results.tau_min;
    R_all=Results.R;
    chi2_all=Results.chi2_fit1;
    N_all=Results.N;
    
    %% 预处理
    
    % Ozone season
    tau=tau_all(season,:);
    ci=ci_all(season,:);
    R=R_all(season,:);
    tau_low=Results.tau_min(season,:);
    chi2=chi2_all(season,:);
    windspeed=windspeed_all(season,:);
    N=N_all(season,:);
    
    
    %% 数据过滤
    
    %R>0.9
    tau(R<0.9)=NaN;
    %CI下边界>0
    tau(tau_low<0)=NaN;
    %CI宽度<10h
    tau(ci>10)=NaN;
    %CI,chi2和windspeed重计算
    ci(isnan(tau))=NaN;
    chi2(isnan(tau))=NaN;
    windspeed(isnan(tau))=NaN;
    N(isnan(tau))=NaN;
    R(isnan(tau))=NaN;
    
    
    %% 计算tau
    
    %Inverse weight of ci
    inv_ci=1./ci;
    weight_sum_ci=nansum(inv_ci);
    weight_ci=inv_ci/weight_sum_ci;
    %Inverse weight of chi2
    inv_chi2=1./chi2;
    weight_sum_chi2=nansum(inv_chi2);
    weight_chi2=inv_chi2/weight_sum_chi2;
    %Final weight
    weight=weight_ci+weight_chi2;
    weight=weight/nansum(weight);
    
    %Calculate the weighted tau and wind speed
    tau_final{i,1}=Points{i};
    tau_final{i,2}=nansum(tau.*weight);
    tau_final{i,3}=nansum(windspeed.*weight);
    tau_final{i,4}=nansum(ci.*weight);
    tau_final{i,5}=nansum(N.*weight);
    tau_final{i,6}=nansum(R.*weight);
    if tau_final{i,2}==0
        tau_final{i,2}=nan;
    end
    if tau_final{i,3}==0
        tau_final{i,3}=nan;
    end
    if tau_final{i,4}==0
        tau_final{i,4}=nan;
    end
    if tau_final{i,5}==0
        tau_final{i,5}=nan;
    end
    if tau_final{i,6}==0
        tau_final{i,6}=nan;
    end
    
    disp(['Tau = ',num2str(tau_final{i,2})]);
    disp(['Wind Speed = ',num2str(tau_final{i,3})]);
    disp(['CI = ',num2str(tau_final{i,4})]);
    disp(['N = ',num2str(tau_final{i,5})]);
    disp(['R = ',num2str(tau_final{i,6})]);
    
    clear Results
    
end

save(['res/','tau.mat'],'tau_final');
