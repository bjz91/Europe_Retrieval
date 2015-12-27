%Clipping NO2
%aa und bb m?sen gesetzt sein

deltaloi=fine_DATA.size;

clear longs;longs=fine_DATA.longs;
clear lats; lats=fine_DATA.lats;

smallest_side_length=median(abs(diff(lats)))*111*cos(point_latitude/180*pi);
adist_upper_bound=ceil(aa/smallest_side_length);
bdist_upper_bound=ceil(bb/2/smallest_side_length);
range=ceil(sqrt(adist_upper_bound^2+bdist_upper_bound^2));

%[LOI(LOI_index).jj,LOI(LOI_index).ii]=convert_latlon2jjii(LOI(LOI_index).lat,LOI(LOI_index).lon,localgrid);
delta=abs(longs-point_longitude);[mini,iii]=min(delta);
delta=abs(lats-point_latitude);  [mini,jjj]=min(delta);
clear mini
%iii,jjj: relative Koordinaten von LOI
%now: quadratic subset of length 2*range+1 with LOI in center
keepjjj=jjj+(-range:range);
keepiii=iii+(-range:range);

if min(keepjjj)>0 && min(keepiii)>0 && max(keepjjj)<length(lats) && max(keepiii)<length(longs)

    OK=1;
    longs=longs(keepiii);lats=lats(keepjjj);

    jjj=range+1;%overwrite
    iii=range+1;
    Scale=lats*111;Scale=Scale-Scale(jjj);Scale=-Scale;
    %km-Skala relativ zu LOI; verk?zung des lon-Abstandes als Funktion der
    %Breite wird sp?er korrigiert!

    map_sample_num_=map_sample_num(keepjjj,keepiii,:,:);
    map_U_=map_U(keepjjj,keepiii,:,:);
    map_V_=map_V(keepjjj,keepiii,:,:);
    map_TVCD_=map_TVCD(keepjjj,keepiii,:,:);
    %map_TAMF_=map_TAMF(keepjjj,keepiii,:,:);
    map_CF_=map_CF(keepjjj,keepiii,:,:);
    map_SZA_=map_SZA(keepjjj,keepiii,:,:);
    %map_TVCDstd_=map_TVCDstd(keepjjj,keepiii,:,:);
    map_U_filled_=map_U_filled(keepjjj,keepiii,:,:);
    map_V_filled_=map_V_filled(keepjjj,keepiii,:,:);
    map_TVCD_filled_=map_TVCD_filled(keepjjj,keepiii,:,:);
    %map_TAMF_filled_=map_TAMF_filled(keepjjj,keepiii,:,:);
    map_CF_filled_=map_CF_filled(keepjjj,keepiii,:,:);
    map_SZA_filled_=map_SZA_filled(keepjjj,keepiii,:,:);
    %map_TVCDstd_filled_=map_TVCDstd_filled(keepjjj,keepiii,:,:);
    
else
    OK=0;
end;

