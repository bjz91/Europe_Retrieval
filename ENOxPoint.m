str='/home/bijianzhao/git/Europe/output/2005_2014/Intergrate_column_height_resolution4_Europe_altitude500_calmspeed2_maxspeed1000/';
load('/home/bijianzhao/git/Europe/res/Point.mat');
load('/home/bijianzhao/git/Europe/res/tau.mat');

ENOx_final=cell(size(Point,2),2);

for i=1:size(Point,2)
    
    if Point{i}==tau_final{i,1}
        
       load([str,Point{i},'/Intergrate_calm_',Point{i},'_200_bb40_linear_multiple.mat']);
        
        tau=tau_final{i,2};
        A=Intergrate.A(6); %Ozone season
        A=A*1e28;
        mol=A/(6.022*1e23);
        ENO2=mol/(tau*3600);
        ENOx=ENO2*1.32;
        ENOx_final{i,1}=Point{i};
        ENOx_final{i,2}=ENOx;
    else
        disp('Point names from tau and emission did not match.');
    end
    
    disp(ENOx);
    
    clear Intergrate
    
end

save(['/home/bijianzhao/git/Europe/res/','Emission.mat'],'ENOx_final');
