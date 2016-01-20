clear all
seasons=1:7
%aa=200
%bb=120
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
    name=cell2mat(raw(k+1,1))
    name(name==' ')='_';
    name(name=='+')='_';
    point_latitude=cell2mat(raw(k+1,2));
    point_longitude=cell2mat(raw(k+1,3));
    aa=cell2mat(raw(k+1,6));
    bb=cell2mat(raw(k+1,7));
    %aa=aa+50;
    %bb=bb-100;
    Samle_Num=cell2mat(raw(k+1,8));
    
    option=cell2mat(raw(k+1,14));
    
    if option==1
        
        %season=[winter, spring, summer, fall, all]
        %wind_direction=[south-east,south,south-west,east,calm,west,north-east,north,north-west]
        %The map_TVCD is the 4-dimensional matrix which contains wind-dependent seasonal mean NO2 maps.
        %The dimensions are 1. latitude index; 2. longitude index; 3.season; 4.wind direction index
        add_season_5;%remove data with too few sample number
        fill_gaps;
        
        clear LD;
        clipping_intergrate_across_wind;
        
        %Skalierung lat/lon->y/x
        dlat=dy;
        dlon=dx./cos(point_latitude/180*pi);
        rotangle=atan2(dlat,dlon)/pi*180;
        windangle=atan2(dy,dx)/pi*180;
        
        if OK==1
            for indx_season=seasons
                %for indx_winddir=[1:4 6:9]
                for indx_winddir=1:9
                    T=squeeze(map_TVCD_filled_(:,:,indx_season,indx_winddir));
                    %TAMF=squeeze(map_TAMF_filled_(:,:,indx_season,indx_winddir));
                    CF=squeeze(map_CF_filled_(:,:,indx_season,indx_winddir));
                    SZA=squeeze(map_SZA_filled_(:,:,indx_season,indx_winddir));
                    T_Orin=squeeze(map_TVCD_(:,:,indx_season,indx_winddir));
                    %Tstd=squeeze(map_TVCDstd_filled_(:,:,indx_season,indx_winddir));
                    U=squeeze(map_U_filled_(:,:,indx_season,indx_winddir));
                    V=squeeze(map_V_filled_(:,:,indx_season,indx_winddir));
                    N=squeeze(sum(sum(map_sample_num_(:,:,indx_season,indx_winddir))));
                    n=squeeze(map_sample_num_(:,:,indx_season,indx_winddir));
                    
                    Trot=imrotate(T,-rotangle(indx_winddir),'bicubic','crop');
                    %TAMFrot=imrotate(TAMF,-rotangle(indx_winddir),'bicubic','crop');
                    CFrot=imrotate(CF,-rotangle(indx_winddir),'bicubic','crop');
                    SZArot=imrotate(SZA,-rotangle(indx_winddir),'bicubic','crop');
                    Trot_Orin=imrotate(T_Orin,-rotangle(indx_winddir),'bicubic','crop');
                    %Tstdrot=imrotate(Tstd,-rotangle(indx_winddir),'bicubic','crop');
                    Urot=imrotate(U,-rotangle(indx_winddir),'bicubic','crop');
                    Vrot=imrotate(V,-rotangle(indx_winddir),'bicubic','crop');
                    nrot=imrotate(n,-rotangle(indx_winddir),'bicubic','crop');
                    
                    %Berechnung der Skalierung f?r gedrehte Bilder samt
                    %Korrektur f?r Breitenabh?ngigkeit
                    [XScaleRot,YScaleRot]=corrected_scales(Scale,-rotangle(indx_winddir),point_latitude);
                    side_length_x=median(abs(diff(XScaleRot)));
                    side_length_y=median(abs(diff(YScaleRot)));
                    adist=ceil(aa/side_length_x);
                    bdist=ceil(bb/2/side_length_y);
                    %arange=round(-adist/2):adist;
                    arange=-adist:adist;
                    brange=-bdist:bdist;
                    %Check: Interferenz mit anderen Quellen in y-Richtung? einfacher Test ?ber Momente!
                    integrationrange=jjj+brange;
                    fitrange=iii+arange;
                    %Trot_=Trot(integrationrange,:);
                    %for i_index=1:size(Trot,2)
                    %    Trot_(:,i_index)=Trot_(:,i_index)-min(Trot_(:,i_index));
                    %    Moment1(i_index)=     sum(Trot_(:,i_index)'.*(integrationrange-jjj)   )/sum(Trot_(:,i_index));
                    %    Moment2(i_index)=sqrt(sum(Trot_(:,i_index)'.*(integrationrange-jjj).^2)/sum(Trot_(:,i_index)));
                    %end;
                    %interferenz=abs(Moment1)>3;%In Pixeln! Kann man Moment2 noch sinnvol nutzen? %
                    Trot_=Trot(integrationrange,fitrange);
                    Trot_Orin_=Trot_Orin(integrationrange,fitrange);
                    Trot_filter=interference(Trot_,Trot_Orin_);
                    TLD=nansum(Trot_filter*side_length_y*1e5); %Line Densities
                    %Interferenzen raus
                    %TLD(interferenz)=nan;
                    TLD=TLD/1e8; %Reskalierung auf 1e23 molec/cm
                    %rel_err=sqrt(sum(Tstdrot(integrationrange,:).^2))./sum(Trot_(:,:));
                    %TLD_err=TLD.*rel_err./sqrt(length(integrationrange)); %Fehler des Mittelwertes
                    N_=mean(mean(nrot(integrationrange,fitrange)));
                    mean_U=nanmean(nanmean(Urot(integrationrange,fitrange)));
                    mean_V=nanmean(nanmean(Vrot(integrationrange,fitrange)));
                    %mean_TAMF=nanmean(nanmean(TAMFrot(integrationrange,fitrange)));
                    mean_CF=nanmean(nanmean(CFrot(integrationrange,fitrange)));
                    mean_SZA=nanmean(nanmean(SZArot(integrationrange,fitrange)));
                    direction=[cos(windangle(indx_winddir)/180*pi) sin(windangle(indx_winddir)/180*pi)];
                    wind=[mean_U mean_V];
                    projected_wind=wind*direction';
                    XScale=XScaleRot(fitrange);
                    %Tobs=TLD(fitrange);
                    Tobs=TLD;
                    Tobs(Tobs==0)=nan;
                    %Terr=TLD_err(fitrange);
                    LD(indx_season,indx_winddir).Tobs=double(Tobs);
                    %LD(indx_season,indx_winddir).Terr=Terr;
                    LD(indx_season,indx_winddir).wind=projected_wind;
                    LD(indx_season,indx_winddir).N=N_;
                    LD(indx_season,indx_winddir).U=mean_U;
                    LD(indx_season,indx_winddir).V=mean_V;
                    %LD(indx_season,indx_winddir).TAMF=mean_TAMF;
                    LD(indx_season,indx_winddir).CF=mean_CF;
                    LD(indx_season,indx_winddir).SZA=mean_SZA;
                    LD(indx_season,indx_winddir).XScale=double(XScale);
                    LD(indx_season,indx_winddir).side_length_x=side_length_x;
                    data_fname=[out_dirname '/LineDensities_' name '_aa' num2str(aa) '_bb' num2str(bb) '.mat'];
                    save(data_fname,'LD');
                end;
            end;
        end;
        
    end
    
end;