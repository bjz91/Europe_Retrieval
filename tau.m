
str='/home/bijianzhao/git/Europe/output_old/2005_2014/Fit_tau_height_resolution4_Europe_altitude500_calmspeed2_maxspeed1000_calm_conv/';
load('/home/bijianzhao/git/Europe/input/Point.mat');

tau_final=cell(size(Point,2),2);

for i=1:size(Point,2)
    
    load([str,Point{i},'/Fitresults_',Point{i},'_300_bb300_new.mat']);
    
    tau=Results.tau(6,:);
    ci=Results.pre_ci(6,:);
    if size(ci,2)~=size(tau,2)
        for i=size(ci,2)+1:size(tau,2)
            ci(1,i)=0;
        end
    end
    ci(ci==0)=nan;
    inv_ci=1./ci;
    weight_sum=nansum(inv_ci);
    weight=inv_ci/weight_sum;
    tau_final{i,1}=Point{i};
    tau_final{i,2}=nansum(tau.*weight);
    
    clear Results
    
end

save([str,'tau.mat'],'tau_final');
