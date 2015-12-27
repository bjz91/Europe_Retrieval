function [conv_XScale,conv_Tobs,Trot_]=convolution_Gaussian(k,indx_season,indx_winddir,aa,bb)
%k=5
%indx_season=4
%indx_winddir=3

intergrate_across_wind_para_path;

dx=[-1 0 1 -1 0 1 -1 0 1];
dy=[1 1 1 0 0 0 -1 -1 -1];

%raw is the info of hotspots       
point_latitude=cell2mat(raw(k+1,2));
point_longitude=cell2mat(raw(k+1,3));
Samle_Num=cell2mat(raw(k+1,8));
    
%season=[winter, spring, summer, fall, all]
%wind_direction=[south-east,south,south-west,east,calm,west,north-east,north,north-west]
%The map_TVCD is the 4-dimensional matrix which contains wind-dependent seasonal mean NO2 maps.
%The dimensions are 1. latitude index; 2. longitude index; 3.season; 4.wind direction index
add_season_5;%remove data with too few sample number
fill_gaps;
    
clear LD_conv;   
clipping_intergrate_across_wind_Gaussian;

%Skalierung lat/lon->y/x
dlat=dy;
dlon=dx./cos(point_latitude/180*pi);
rotangle=atan2(dlat,dlon)/pi*180;
windangle=atan2(dy,dx)/pi*180;

%T=squeeze(map_TVCD_filled_(:,:,indx_season,indx_winddir));
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

%figure;imagesc(Trot,[0,10]);
%axis xy;
%axis equal;
%Berechnung der Skalierung für gedrehte Bilder samt
%Korrektur für Breitenabhängigkeit
[XScaleRot,YScaleRot]=corrected_scales(Scale,-rotangle(indx_winddir),point_latitude);
side_length_x=median(abs(diff(XScaleRot)));
side_length_y=median(abs(diff(YScaleRot)));
adist=ceil(aa/side_length_x);
bdist=ceil(bb/side_length_y);
%the extended distance is for check the declining trend of line density,
%not used for fitting columns
if adist<=3
    adist=4;
end;
arange=-adist:adist;
brange=-bdist:bdist;
%Check: Interferenz mit anderen Quellen in y-Richtung? einfacher Test über Momente!
integrationrange=jjj+brange;
fitrange=iii+arange;

%figure;imagesc(Trot_,[0,10]);
%axis xy;
%axis equal;
%for i_index=1:size(Trot,2)
    %Trot_(:,i_index)=Trot_(:,i_index)-min(Trot_(:,i_index));
    %Moment1(i_index)=     sum(Trot_(:,i_index)'.*(integrationrange-jjj)   )/sum(Trot_(:,i_index));
    %Moment2(i_index)=sqrt(sum(Trot_(:,i_index)'.*(integrationrange-jjj).^2)/sum(Trot_(:,i_index)));
%end;
%interferenz=abs(Moment1)>3;%In Pixeln! Kann man Moment2 noch sinnvol nutzen? %
Trot_=Trot(integrationrange,fitrange);
Trot_Orin_=Trot_Orin(integrationrange,fitrange);
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
%Terr=TLD_err(fitrange);
Tobs=TLD;
LD_conv.Tobs=double(Tobs);
%LD.Terr=Terr;
LD_conv.wind=projected_wind;
LD_conv.N=N_;
LD_conv.U=mean_U;
LD_conv.V=mean_V;
LD_conv.XScale=double(XScale);
LD_conv.side_length_x=side_length_x;

conv_Tobs=LD_conv.Tobs;
conv_XScale=LD_conv.XScale;

%plot(LD_conv.XScale,LD_conv.Tobs,'r--','LineWidth',2.5);
        