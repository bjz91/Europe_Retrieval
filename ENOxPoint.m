str='/home/bijianzhao/git/Europe/output/2005_2014/Intergrate_column_height_resolution4_Europe_altitude500_calmspeed2_maxspeed1000/';
load('/home/bijianzhao/git/Europe/res/Point.mat');
load('/home/bijianzhao/git/Europe/res/tau.mat');

ENOx_final=cell(size(Point,2),2);

season=6; %Ozone season

for i=1:size(Point,2)
    
    disp(Point{i});
    
    %% Load data
    load([str,Point{i},'/Intergrate_calm_',Point{i},'_100_bb20_linear_multiple.mat']);
    
    %Load lifetime
    tau=tau_final{i,2};
    %Load mass
    A=Intergrate.A(season);
    %A=Intergrate.A_lsqnonlin(season);  %!!!!!!!!!
    
    if ~isnan(A)
        
        %% Filter Data
        R=Intergrate.R(season);
        LD_quality=Intergrate.LD_quality(season,:);
        
        %R>0.9
        if R<0.9
            A=NaN;
        end
        %LD_quality %!!!!!!!!这个过滤标准没有经过证实
        if sum(LD_quality~=3)>0
            A=NaN;
        end
        
        
        %% Calculate emission
        A=A*1e28;
        mol=A/(6.022*1e23);
        ENO2=mol/(tau*3600);
        ENOx=ENO2*1.32;
        ENOx_final{i,1}=Point{i};
        ENOx_final{i,2}=ENOx;
        
    else
        
        ENOx_final{i,1}=Point{i};
        ENOx_final{i,2}=NaN;
        
    end
    
    disp(ENOx);
    
    clear Intergrate
    
end

save(['/home/bijianzhao/git/Europe/res/','Emission.mat'],'ENOx_final');
