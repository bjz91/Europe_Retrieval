str='output/2005_2014/Intergrate_column_height_resolution4_Europe_altitude500_calmspeed2_maxspeed1000/';
load('input/Points.mat');
load('res/tau.mat');

ENOx_final=cell(size(Points,2),2);

season=6; %Ozone season

for i=1:size(Points,2)
    
    disp(Points{i});
    
    %% Load data
    load([str,Points{i},'/Intergrate_calm_',Points{i},'_100_bb20_linear_multiple.mat']);
    
    %Load lifetime
    tau=tau_final{i,2};
    %Load mass
    A=Intergrate.A(season);
    %A=Intergrate.A_lsqnonlin(season);  %!!!!!!!!!
    
    if ~isnan(A)
        
        %% Filter Data
        R=Intergrate.R(season);
        CI=Intergrate.A_max(season)-Intergrate.A_min(season);
        CI_low=Intergrate.A_min(season);
        
        %R>0.9
        if R<0.9
            A=NaN;
        end
        %Low boundary of CI is greater than 0
        if CI_low<0
            A=NaN;
        end
        %CI is less than 0.8*A
        if CI>0.8*A
            A=NaN;
        end
        
        %% Integral factor BJZ edit 2016/3/4
        sigma=Intergrate.sigma(season,:);
        q=zeros(1,4); % Factors for A
        for sigma_i=1:4
            sigma_tmp=sigma(sigma_i);
            fun=@(x) 1./(sqrt(2*pi).*sigma_tmp).*exp(-x.^2./(2.*sigma_tmp.^2));
            q1=integral(fun,-20,20);
            q2=integral(fun,-Inf,Inf);
            q(sigma_i)=q1/q2;
        end
        A=A/mean(q);
        
        %% Calculate emission
        A=A*1e28;
        mol=A/(6.022*1e23);
        ENO2=mol/(tau*3600);
        ENOx=ENO2*1.32;
        ENOx_final{i,1}=Points{i};
        ENOx_final{i,2}=ENOx;
        ENOx_final{i,3}=A;
        
    else
        
        ENOx_final{i,1}=Points{i};
        ENOx_final{i,2}=NaN;
        ENOx_final{i,3}=NaN;
        
    end
    
    disp(ENOx_final{i,2});
    
    clear Intergrate
    
end

save(['res/','Emission.mat'],'ENOx_final');
