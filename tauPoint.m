
str='/home/bijianzhao/git/Europe/output/2005_2014/Fit_tau_height_resolution4_Europe_altitude500_calmspeed2_maxspeed1000_calm_conv/';
load('/home/bijianzhao/git/Europe/res/Point.mat');

tau_final=cell(size(Point,2),2);

for i=1:size(Point,2)
    
    disp(Point{i});
    
    %% ��ȡ����
    load([str,Point{i},'/Fitresults_',Point{i},'_300_bb300_new.mat']);
    
    %tau_all=Results.tau;
    tau_all=Results.tau_lsqnonlin; %!!!!!!!!!��lsqnonlin�Ľ������������
    tau_all(tau_all==0)=NaN;
    if sum(~isnan(tau_all))==0
        tau_final{i,1}=Point{i};
        tau_final{i,2}=nan;
        disp(tau_final{i,2});
        disp('Nonexist!');
        continue;
    end
    ci_tmp=Results.pre_ci;
    R_all=Results.R;
    
    %% Ԥ����
    
    % ��ȫci����
    ci_all=tau_all;
    ci_all(1:size(ci_tmp,1),1:size(ci_tmp,2))=ci_tmp;
    
    % Ozone season
    tau=tau_all(6,:);
    ci=ci_all(6,:);
    R=R_all(6,:);
    tau_low=tau-ci;
    
    
    %% ���ݹ���
    
    %R>0.9
    tau(R<0.9)=NaN;
    %CI�±߽�>0
    tau(tau_low<0)=NaN;
    %CI���<10h
    tau(ci>10)=NaN;
    %CI�ؼ���
    ci(isnan(tau))=NaN;
    
    
    %% ����tau
    
    inv_ci=1./ci;
    weight_sum=nansum(inv_ci);
    weight=inv_ci/weight_sum;
    tau_final{i,1}=Point{i};
    tau_final{i,2}=nansum(tau.*weight);
    if tau_final{i,2}==0
        tau_final{i,2}=nan;
    end
    
    disp(tau_final{i,2});
    
    clear Results
    
end

save(['/home/bijianzhao/git/Europe/res/','tau.mat'],'tau_final');
