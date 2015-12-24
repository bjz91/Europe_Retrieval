function average_OMI_ECMWF_data_fine_resolution_height(ROI_index,start_jahr,end_jahr,start_month,end_month,wind_altitude,suffix,calm_speed,max_speed)
%resolution is number of subgrids
%if we want smaller size, only change the parameters here is not enough.
%Must change the definition of category below(line 135-138;165-168)
resolution=4;

%wind data has 21 layers, but satellite data are processed with wind data
%with 15 layers, thus remove the most 6 top wind data afterwards
path_input_files='input/';
load([path_input_files 'grid_definitions.mat']);
load([path_input_files 'ROI_definitions.mat']);

path_regional_files='output/';
DATA_dirname=[path_regional_files 'Region_OMI_ECMWF_data_' ROI(ROI_index).name];
%suffix in DATA_dirname
%suffix='200501_201312';

start_jahrstr=num2str(start_jahr);
end_jahrstr=num2str(end_jahr);
start_monatstr=num2str(start_month); if start_month<10 start_monatstr=['0' start_monatstr]; end;
end_monatstr=num2str(end_month); if end_month<10 end_monatstr=['0' end_monatstr]; end;

out_dirname=[path_regional_files 'Region_OMI_ECMWF_average_fine_resolution_' ROI(ROI_index).name];
if ~exist(out_dirname,'dir')
    system(['mkdir -p ' out_dirname]);
end;
filename=[out_dirname '/' 'Average_resolution' num2str(resolution) '_' ROI(ROI_index).name '_'  start_jahrstr start_monatstr '_' end_jahrstr end_monatstr ...
    '_altitude' num2str(wind_altitude) '_calmspeed' num2str(calm_speed) '_maxspeed' num2str(max_speed) '.mat'];

flag_altitude=0;
for height_jahr=start_jahr:end_jahr
    for height_monat= start_month:end_month
        height_jahrstr=num2str(height_jahr);
        height_monatstr=num2str(height_monat); if height_monat<10 height_monatstr=['0' height_monatstr]; end;
        heightname=[path_regional_files 'Region_ECMWF_height_' ROI(ROI_index).name '/' height_jahrstr '/' 'Regionalfile_mapping_ECMWF_height_' ROI(ROI_index).name '_' height_jahrstr height_monatstr '.mat'];
        load(heightname);
        altitudetmp=cellfun(@(x) mean(x,1),height,'UniformOutput',false);
        if flag_altitude==0
            altitudesum=altitudetmp;
            flag_altitude=1;
        else
            altitudesum=cellfun(@(x,y) x+y,altitudesum,altitudetmp,'UniformOutput',false);
            flag_altitude=flag_altitude+1;
        end;
    end;
end;

all_altitude=cellfun(@(x) (x-x(end))/flag_altitude,altitudesum,'UniformOutput',false);

map_TVCD=zeros(length(ROI(ROI_index).latvec)*resolution,length(ROI(ROI_index).lonvec)*resolution,6,9);
map_TAMF=zeros(length(ROI(ROI_index).latvec)*resolution,length(ROI(ROI_index).lonvec)*resolution,6,9);
map_CF=zeros(length(ROI(ROI_index).latvec)*resolution,length(ROI(ROI_index).lonvec)*resolution,6,9);
map_SZA=zeros(length(ROI(ROI_index).latvec)*resolution,length(ROI(ROI_index).lonvec)*resolution,6,9);
map_U   =zeros(length(ROI(ROI_index).latvec)*resolution,length(ROI(ROI_index).lonvec)*resolution,6,9);
map_V   =zeros(length(ROI(ROI_index).latvec)*resolution,length(ROI(ROI_index).lonvec)*resolution,6,9);
map_sample_num=zeros(length(ROI(ROI_index).latvec)*resolution,length(ROI(ROI_index).lonvec)*resolution,6,9);
for j=1:length(ROI(ROI_index).latvec)
    %for j=30:50 %Harbin
    %for j=30:50 %PRD
    ['lat' num2str(ROI(ROI_index).latvec(j))]
    %i is for complex number
    for ii=1:length(ROI(ROI_index).lonvec)
        %for ii=150:170 %Harbin
        %for ii=150:170 %PRD
        location_label=['lat' num2str(ROI(ROI_index).latvec(j)) '_lon' num2str(ROI(ROI_index).lonvec(ii))];
        load([DATA_dirname '/' 'Regionalfile_OMI_ECMWF_data_' ROI(ROI_index).name '_' location_label '_' suffix '.mat']);
        %subset of DATA corresponding to start_jahr,end_jahr,start_month,end_month
        time_string=cell2mat(CombineDATA.time);
        year_list=(str2num(time_string(:,1:4)));
        month_list=(str2num(time_string(:,6:7)));
        period_list=find(year_list>=start_jahr & year_list<=end_jahr & ...
            month_list>=start_month & month_list<=end_month);
        
        %filter satellite data
        %Cloud filter
        %CRF_list=find(CombineDATA.CRF<5000);
        CRF_list=find(CombineDATA.CF<300);
        
        SZA_list=find(CombineDATA.SZA<70);
        
        acrosstrack_list=find(cell2mat(CombineDATA.acrosstrack)<51 & cell2mat(CombineDATA.acrosstrack)>10);
        %acrosstrack_list=find(cell2mat(CombineDATA.acrosstrack)<61 & cell2mat(CombineDATA.acrosstrack)>0);
        %length(acrosstrack_list)
        %row anomaly
        anomaly_list=find(str2num([time_string(:,1:4) time_string(:,6:9)])>=20070625 & ...
            (cell2mat(CombineDATA.acrosstrack)==54 | cell2mat(CombineDATA.acrosstrack)==55));
        CombineDATA.TVCD(anomaly_list)=-999;
        anomaly_list=find(str2num([time_string(:,1:4) time_string(:,6:9)])>=20080511 & ...
            cell2mat(CombineDATA.acrosstrack)<=43 & cell2mat(CombineDATA.acrosstrack)>=38);
        CombineDATA.TVCD(anomaly_list)=-999;
        anomaly_list=find(str2num([time_string(:,1:4) time_string(:,6:9)])>=20081203 & ...
            cell2mat(CombineDATA.acrosstrack)==45);
        CombineDATA.TVCD(anomaly_list)=-999;
        anomaly_list=find(str2num([time_string(:,1:4) time_string(:,6:9)])>=20090124 & ...
            cell2mat(CombineDATA.acrosstrack)<=45 & cell2mat(CombineDATA.acrosstrack)>=28);
        CombineDATA.TVCD(anomaly_list)=-999;
        anomaly_list=find(str2num([time_string(:,1:4) time_string(:,6:9)])>=20110705 & ...
            cell2mat(CombineDATA.acrosstrack)<=43 & cell2mat(CombineDATA.acrosstrack)>=46);
        CombineDATA.TVCD(anomaly_list)=-999;
        %remove orbit 25(1-base)
        anomaly_list=find(str2num([time_string(:,1:4) time_string(:,6:9)])>=20110101 & ...
            cell2mat(CombineDATA.acrosstrack)==25);
        CombineDATA.TVCD(anomaly_list)=-999;
        
        TVCD_list=find(CombineDATA.TVCD>-10);
        %TVCD_list=find(CombineDATA.TVCD>-exp(1));
        
        %length(TVCD_list)
        %basic filter
        basic_list=intersect(period_list,intersect(TVCD_list,intersect(CRF_list,intersect(SZA_list,acrosstrack_list))));
        %basic_len=length(basic_list)
        %season=[winter, spring, summer, fall, ozone]
        winter_list=find(ismember( month_list,[12,1,2]));
        spring_list=find(ismember( month_list,[3,4,5]));
        summer_list=find(ismember( month_list,[6,7,8]));
        fall_list=find(ismember( month_list,[9,10,11]));
        ozone_list=find(ismember( month_list,[5,6,7,8,9]));
        non_ozone_list=find(ismember( month_list,[1,2,3,4,10,11,12]));
        season_list=cell(6);
        season_list={winter_list,spring_list,summer_list,fall_list,ozone_list,non_ozone_list};
        
        %location-dependent layer altitude
        %build look-up table of wind_altitude and dimention of wind_u, wind_v
        %table=[Level,Altitude (m)]
        altitude=all_altitude{j,ii}(1:15);
        %remove most 6 top layers
        Level=[1:1:15];
        table=zeros(15,2);
        table(:,1)=Level;
        table(:,2)=altitude;
        subset_wind=table(table(:,2)<=wind_altitude,1)';
        p=double(table(1:15,2))';
        dp(2:15)=-diff(p);
        dp(1)=p(1)-p(2);
        
        %average of wind data up to altitude
        clear DP_u;
        DP_u=repmat(dp,length(CombineDATA.wind_u),1);
        %DP_s=size(DP)
        %wind_s=size(CombineDATA.wind_u)
        u=squeeze(nansum(CombineDATA.wind_u(:,subset_wind).*DP_u(:,subset_wind),2)./nansum(DP_u(:,subset_wind),2));
        clear DP_v;
        DP_v=repmat(dp,length(CombineDATA.wind_v),1);
        v=squeeze(nansum(CombineDATA.wind_v(:,subset_wind).*DP_v(:,subset_wind),2)./nansum(DP_v(:,subset_wind),2));
        
        %calculate wind speed and direction
        wind_speed=sqrt(u.^2+v.^2);
        %wind_angle=angle(u+v*i);
        wind_angle=atan2(v,u);
        %wind_direction=[south-east,south,south-west,east,calm,west,north-east,north,north-west]
        theta=pi/8;
        southeast_list=find(wind_angle<7*theta & wind_angle>=5*theta & wind_speed>=calm_speed & wind_speed<=max_speed);
        south_list    =find(wind_angle<5*theta & wind_angle>=3*theta & wind_speed>=calm_speed & wind_speed<=max_speed);
        southwest_list=find(wind_angle<3*theta & wind_angle>=1*theta & wind_speed>=calm_speed & wind_speed<=max_speed);
        east_list     =find(abs(wind_angle)>7*theta & wind_speed>=calm_speed & wind_speed<=max_speed);
        calm_list     =find(wind_speed<calm_speed);
        west_list     =find(abs(wind_angle)<1*theta & wind_speed>=calm_speed & wind_speed<=max_speed);
        northeast_list=find(wind_angle<-5*theta & wind_angle>=-7*theta & wind_speed>=calm_speed & wind_speed<=max_speed);
        north_list    =find(wind_angle<-3*theta & wind_angle>=-5*theta & wind_speed>=calm_speed & wind_speed<=max_speed);
        northwest_list=find(wind_angle<-1*theta & wind_angle>=-3*theta & wind_speed>=calm_speed & wind_speed<=max_speed);
        direction_list=cell(9);
        direction_list={southeast_list,south_list,southwest_list,east_list,calm_list,west_list,northeast_list,north_list,northwest_list};
        %length(southeast_list)
        %length(northwest_list)
        %wind_len=length(southeast_list)+length(south_list)+length(southwest_list)+length(east_list)+length(calm_list)+length(west_list)+length(northeast_list)+length(north_list)+length(northwest_list)
        
        %average of TVCD by season and wind direction(sample number)
        %The new DATA contains the 4-dimensional matrix "map_TVCD" which contains wind-dependent seasonal mean NO2 maps.
        %The dimensions are 1. latitude index; 2. longitude index; 3.season; 4. wind direction index
        final_len=0;
        for s=1:6
            for w=1:9
                VCD_list=intersect(direction_list{w},intersect(season_list{s},basic_list));
                %VCD_len=length(VCD_list)
                %refine grid by satellite location
                Lat=CombineDATA.lat_satellite(VCD_list);
                Lon=CombineDATA.lon_satellite(VCD_list);
                
               % fine_TAMF=CombineDATA.TAMF(VCD_list);
                fine_CF=CombineDATA.CF(VCD_list);
                fine_SZA=CombineDATA.SZA(VCD_list);
                fine_VCD=CombineDATA.TVCD(VCD_list);
                fine_U=u(VCD_list);
                fine_V=v(VCD_list);
                list1=find(Lat>=ROI(ROI_index).latvec(j) & Lon<ROI(ROI_index).lonvec(ii));
                list2=find(Lat>=ROI(ROI_index).latvec(j) & Lon>=ROI(ROI_index).lonvec(ii));
                list3=find(Lat<ROI(ROI_index).latvec(j) & Lon<ROI(ROI_index).lonvec(ii));
                list4=find(Lat<ROI(ROI_index).latvec(j) & Lon>=ROI(ROI_index).lonvec(ii));
                
               % map_TAMF((j-1)*2+1,(ii-1)*2+1,s,w)=nanmean(fine_TAMF(list1));
               % map_TAMF((j-1)*2+1,(ii-1)*2+2,s,w)=nanmean(fine_TAMF(list2));
               % map_TAMF((j-1)*2+2,(ii-1)*2+1,s,w)=nanmean(fine_TAMF(list3));
               % map_TAMF((j-1)*2+2,(ii-1)*2+2,s,w)=nanmean(fine_TAMF(list4));
                
                map_CF((j-1)*2+1,(ii-1)*2+1,s,w)=nanmean(fine_CF(list1));
                map_CF((j-1)*2+1,(ii-1)*2+2,s,w)=nanmean(fine_CF(list2));
                map_CF((j-1)*2+2,(ii-1)*2+1,s,w)=nanmean(fine_CF(list3));
                map_CF((j-1)*2+2,(ii-1)*2+2,s,w)=nanmean(fine_CF(list4));
                
                map_SZA((j-1)*2+1,(ii-1)*2+1,s,w)=nanmean(fine_SZA(list1));
                map_SZA((j-1)*2+1,(ii-1)*2+2,s,w)=nanmean(fine_SZA(list2));
                map_SZA((j-1)*2+2,(ii-1)*2+1,s,w)=nanmean(fine_SZA(list3));
                map_SZA((j-1)*2+2,(ii-1)*2+2,s,w)=nanmean(fine_SZA(list4));
                
                map_TVCD((j-1)*2+1,(ii-1)*2+1,s,w)=nanmean(fine_VCD(list1));
                map_TVCD((j-1)*2+1,(ii-1)*2+2,s,w)=nanmean(fine_VCD(list2));
                map_TVCD((j-1)*2+2,(ii-1)*2+1,s,w)=nanmean(fine_VCD(list3));
                map_TVCD((j-1)*2+2,(ii-1)*2+2,s,w)=nanmean(fine_VCD(list4));
                
                map_U((j-1)*2+1,(ii-1)*2+1,s,w)=nanmean(fine_U);
                map_U((j-1)*2+1,(ii-1)*2+2,s,w)=nanmean(fine_U);
                map_U((j-1)*2+2,(ii-1)*2+1,s,w)=nanmean(fine_U);
                map_U((j-1)*2+2,(ii-1)*2+2,s,w)=nanmean(fine_U);
                
                map_V((j-1)*2+1,(ii-1)*2+1,s,w)=nanmean(fine_V);
                map_V((j-1)*2+1,(ii-1)*2+2,s,w)=nanmean(fine_V);
                map_V((j-1)*2+2,(ii-1)*2+1,s,w)=nanmean(fine_V);
                map_V((j-1)*2+2,(ii-1)*2+2,s,w)=nanmean(fine_V);
                
                map_sample_num((j-1)*2+1,(ii-1)*2+1,s,w)=length(list1);
                map_sample_num((j-1)*2+1,(ii-1)*2+2,s,w)=length(list2);
                map_sample_num((j-1)*2+2,(ii-1)*2+1,s,w)=length(list3);
                map_sample_num((j-1)*2+2,(ii-1)*2+2,s,w)=length(list4);
                %final_len=final_len+length(list1)+length(list2)+length(list3)+length(list4)
                %final_len=final_len+length(list1)
            end;
        end;
        clear CombineDATA;
    end;
end;

size_longs=(ROI(ROI_index).lonvec(2)-ROI(ROI_index).lonvec(1))/resolution;
% new_longs=(longs(1)-size_longs:2*size_longs:longs(length(longs))+size_longs);
size_lats=(ROI(ROI_index).latvec(1)-ROI(ROI_index).latvec(2))/resolution;
% new_lats=(lats(1)-size_lats:2*size_lats:lats(length(lats))+size_lats);

new_longs(1:2:(2*length(ROI(ROI_index).lonvec)-1))=ROI(ROI_index).lonvec-size_longs;
new_longs(2:2:(2*length(ROI(ROI_index).lonvec)))=ROI(ROI_index).lonvec+size_longs;
new_lats(1:2:(2*length(ROI(ROI_index).latvec)-1))=ROI(ROI_index).latvec+size_lats;
new_lats(2:2:(2*length(ROI(ROI_index).latvec)))=ROI(ROI_index).latvec-size_lats;

fine_DATA.lats=new_lats;
fine_DATA.longs=new_longs;
fine_DATA.size=0.36/resolution*2;
%fine_DATA.map_TAMF=map_TAMF;
fine_DATA.map_CF=map_CF;
fine_DATA.map_SZA=map_SZA;
fine_DATA.map_TVCD=map_TVCD;
fine_DATA.U=map_U;
fine_DATA.V=map_V;
fine_DATA.sample_num=map_sample_num;
fine_DATA.note='cloud fraction=30%; NO2>-exp(1); location-dependent layer height';
save(filename, 'fine_DATA');

