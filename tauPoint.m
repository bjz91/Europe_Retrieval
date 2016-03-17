
str='output/2005_2014/Fit_tau_height_resolution4_Europe_altitude500_calmspeed2_maxspeed1000_calm_conv/';
load('input/Points.mat');

tau_final=cell(size(Points,2),2);

season=6; %Ozone season

for i=1:size(Points,2)
    
    disp(Points{i});
    
    %% 读取数据
    load([str,Points{i},'/Fitresults_',Points{i},'_300_bb300_new.mat']);
    
    tau_all=Results.tau;
    %tau_all=Results.tau_lsqnonlin; %!!!!!!!!!用lsqnonlin的结果看起来更好
    tau_all(tau_all==0)=NaN;
    if sum(~isnan(tau_all))==0
        tau_final{i,1}=Points{i};
        tau_final{i,2}=nan;
        disp(tau_final{i,2});
        disp('Nonexist!');
        continue;
    end
    ci_all=Results.tau_max-Results.tau_min;
    R_all=Results.R;
    chi2_all=Results.chi2_fit1;
    
    %% 预处理
    
    % Ozone season
    tau=tau_all(season,:);
    ci=ci_all(season,:);
    R=R_all(season,:);
    tau_low=Results.tau_min(season,:);
    chi2=chi2_all(season,:);
    
    
    %% 数据过滤
    
    %R>0.9
    tau(R<0.9)=NaN;
    %CI下边界>0
    tau(tau_low<0)=NaN;
    %CI宽度<10h
    tau(ci>10)=NaN;
    %CI和chi2重计算
    ci(isnan(tau))=NaN;
    chi2(isnan(tau))=NaN;
    
    
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
    
    %Calculate the weighted tau
    tau_final{i,1}=Points{i};
    tau_final{i,2}=nansum(tau.*weight);
    if tau_final{i,2}==0
        tau_final{i,2}=nan;
    end
    
    disp(tau_final{i,2});
    
    clear Results
    
end

save(['res/','tau.mat'],'tau_final');
