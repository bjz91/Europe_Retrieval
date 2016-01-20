clear all
seasons=1:7

dx=[-1 0 1 -1 0 1 -1 0 1];
dy=[1 1 1 0 0 0 -1 -1 -1];

intergrate_across_wind_para_path;
path_regional_files2=[path_regional_files start_jahrstr '_' end_jahrstr];
if ~exist(path_regional_files2,'dir')
    system(['mkdir -p ' path_regional_files2]);
end;
out_dirname=[path_regional_files2 '/LD_height_resolution' num2str(resolution) '_' ROI(ROI_index).name '_altitude' num2str(wind_altitude) '_calmspeed' num2str(calm_speed) '_maxspeed' num2str(max_speed)];
if ~exist(out_dirname,'dir')
    system(['mkdir -p ' out_dirname]);
end;


%raw is the info of hotspots
for k=1:size(raw,1)-1
    %for k=[1:42 44:108 110:size(raw,1)-1]
    %for k=110:110
    name=cell2mat(raw(k+1,1))
    name(name==' ')='_';
    name(name=='+')='_';
    point_latitude=cell2mat(raw(k+1,2));
    point_longitude=cell2mat(raw(k+1,3));
    aa=cell2mat(raw(k+1,9));
    bb=cell2mat(raw(k+1,10));
    %aa=aa+200;
    %bb=bb+100;
    Samle_Num=cell2mat(raw(k+1,8));
    
    option=cell2mat(raw(k+1,14));
    
    if option==1
        
        %season=[winter, spring, summer, fall, all]
        %wind_direction=[south-east,south,south-west,east,calm,west,north-east,north,north-west]
        %The map_TVCD is the 4-dimensional matrix which contains wind-dependent seasonal mean NO2 maps.
        %The dimensions are 1. latitude index; 2. longitude index; 3.season; 4.wind direction index
        add_season_5;%remove data with too few sample number
        fill_gaps;
        
        clear LD_conv;
        clipping_intergrate_across_wind;
        
        %Skalierung lat/lon->y/x
        dlat=dy;
        dlon=dx./cos(point_latitude/180*pi);
        rotangle=atan2(dlat,dlon)/pi*180;
        windangle=atan2(dy,dx)/pi*180;
        
        
        for indx_season=seasons
            for indx_winddir=1:9
                T=squeeze(map_TVCD_filled_(:,:,indx_season,5));
                T_Orin=squeeze(map_TVCD_(:,:,indx_season,5));
                %Tstd=squeeze(map_TVCDstd_filled_(:,:,indx_season,5));
                U=squeeze(map_U_filled_(:,:,indx_season,5));
                V=squeeze(map_V_filled_(:,:,indx_season,5));
                N=squeeze(sum(sum(map_sample_num_(:,:,indx_season,5))));
                n=squeeze(map_sample_num_(:,:,indx_season,5));
                
                Trot=imrotate(T,-rotangle(indx_winddir),'bicubic','crop');
                Trot_Orin=imrotate(T_Orin,-rotangle(indx_winddir),'bicubic','crop');
                %Tstdrot=imrotate(Tstd,-rotangle(indx_winddir),'bicubic','crop');
                Urot=imrotate(U,-rotangle(indx_winddir),'bicubic','crop');
                Vrot=imrotate(V,-rotangle(indx_winddir),'bicubic','crop');
                nrot=imrotate(n,-rotangle(indx_winddir),'bicubic','crop');
                
                [XScaleRot,YScaleRot]=corrected_scales(Scale,-rotangle(indx_winddir),point_latitude);
                side_length_x=median(abs(diff(XScaleRot)));
                side_length_y=median(abs(diff(YScaleRot)));
                adist=ceil(aa/side_length_x);
                bdist=ceil(bb/2/side_length_y);
                arange=-adist:adist;
                brange=-bdist:bdist;
                
                %Check: Interferenz mit anderen Quellen in y-Richtung? einfacher Test ?er Momente!
                integrationrange=jjj+brange;
                fitrange=iii+arange;
                
                %interferenz=abs(Moment1)>3;%In Pixeln! Kann man Moment2 noch sinnvol nutzen? %
                Trot_=Trot(integrationrange,fitrange);
                Trot_Orin_=Trot_Orin(integrationrange,fitrange);
                %nan is not allowed in the array of calm (input of fit), so use different
                %interference function here
                TLD=interference_calm(Trot_,Trot_Orin_,side_length_y);
                
                %Interferenzen raus
                %TLD(interferenz)=nan;
                
                TLD=TLD/1e8; %Reskalierung auf 1e23 molec/cm
                %rel_err=sqrt(sum(Tstdrot(integrationrange,:).^2))./sum(Trot_(:,:));
                %TLD_err=TLD.*rel_err./sqrt(length(integrationrange)); %Fehler des Mittelwertes
                N_=mean(mean(nrot(integrationrange,fitrange)));
                mean_U=nanmean(nanmean(Urot(integrationrange,fitrange)));
                mean_V=nanmean(nanmean(Vrot(integrationrange,fitrange)));
                direction=[cos(windangle(indx_winddir)/180*pi) sin(windangle(indx_winddir)/180*pi)];
                wind=[mean_U mean_V];
                projected_wind=wind*direction';
                XScale=XScaleRot(fitrange);
                %Tobs=TLD(fitrange);
                Tobs=TLD;
                %Terr=TLD_err(fitrange);
                LD_conv(indx_season,indx_winddir).Tobs=double(Tobs);
                %LD.Terr=Terr;
                LD_conv(indx_season,indx_winddir).wind=projected_wind;
                LD_conv(indx_season,indx_winddir).N=N_;
                LD_conv(indx_season,indx_winddir).U=mean_U;
                LD_conv(indx_season,indx_winddir).V=mean_V;
                LD_conv(indx_season,indx_winddir).XScale=double(XScale);
                LD_conv(indx_season,indx_winddir).side_length_x=side_length_x;
            end;
        end;
        data_fname=[out_dirname '/LineDensities_' name '_aa' num2str(aa) '_bb' num2str(bb) '_calm.mat'];
        save(data_fname,'LD_conv');
        
    end
end;