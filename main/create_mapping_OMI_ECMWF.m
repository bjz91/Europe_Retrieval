function create_mapping_OMI_ECMWF(ROI_index,jahr,monat,overwrite)

path_input_files='input/';
%load([path_input_files 'grid_definitions.mat']);
load([path_input_files 'ROI_definitions.mat']);

%grid_definitions.mat is worldwide: lat:90?-90? lon:0?180?-180?~0?
%keep_region(1:length(localgrid.lat_ECMWFindex),1:length(localgrid.lon_ECMWFindex))=0;
%keep_region(ROI(ROI_index).jvec,ROI(ROI_index).ivec)=1;

path_OMI='/public/satellite/OMI/no2/DOMINO_S_v2/';
path_regional_files='output/';

%built the path of input file
dirname=[path_regional_files 'Region_mapping_OMI_ECMWF_' ROI(ROI_index).name];
if ~exist(dirname,'dir')
    system(['mkdir -p ' dirname]);
end;

jahrstr=num2str(jahr);
monatstr=num2str(monat); if monat<10 monatstr=['0' monatstr]; end;
clear valid;
filename=[dirname '/' 'Regionalfile_mapping_OMI_ECMWF_' ROI(ROI_index).name '_' jahrstr monatstr '.mat'];
if ~exist(filename,'file') || overwrite==1
    valid=1;
else
    disp(['Skip ' filename]);
    valid=0;
end;

if valid==1
    time_acrosstrack_alongtrack=cell(length(ROI(ROI_index).jvec),length(ROI(ROI_index).ivec));%area should be continuous
    %time_acrosstrack_alongtrack=cell(length(localgrid.lat_ECMWFindex),length(localgrid.lon_ECMWFindex));
    flag2=0;
    for tag=1:eomday(jahr,monat)
        
        %for tag=1:1
        tagstr=num2str(tag); if tag<10 tagstr=['0' tagstr]; end;
        disp([jahrstr monatstr tagstr]);
        path=[path_OMI jahrstr '/' monatstr '/'];
        disp(path);
        flist=dir([path 'OMI-Aura_L2-OMDOMINO_' jahrstr 'm' monatstr tagstr '*' ]);
        
        for ii=1:length(flist)
            
            fname=[path flist(ii).name];
            disp(fname);
            if not(strcmp(fname,'/public/satellite/OMI/no2/DOMINO_S_v2/2013/10/OMI-Aura_L2-OMDOMINO_2013m1002t1854-o49025_v003-2013m1006t001124.he5'))
                if not(strcmp(fname,'/public/satellite/OMI/no2/DOMINO_S_v2/2013/10/OMI-Aura_L2-OMDOMINO_2013m1009t0548-o49119_v003-2013m1013t000457.he5'))
                    if not(strcmp(fname,'/public/satellite/OMI/no2/DOMINO_S_v2/2013/12/OMI-Aura_L2-OMDOMINO_2013m1201t1555-o49897_v003-2013m1205t001125.he5'))
                        
                        lat_center = hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Geolocation Fields/Latitude');
                        lon_center = hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Geolocation Fields/Longitude');
                        LatCenter=double(lat_center);
                        LonCenter=double(lon_center);
                        
                        for j=1:length(ROI(ROI_index).jvec)
                            %for j=1:5
                            for i=1:length(ROI(ROI_index).ivec)
                                %for i=1:5
                                latmid=ROI(ROI_index).latvec(j);
                                latmin=latmid-0.18;
                                latmax=latmid+0.18;
                                lonmid=ROI(ROI_index).lonvec(i);
                                lonmin=lonmid-0.18;
                                lonmax=lonmid+0.18;
                                
                                flag=0;
                                keep=LatCenter<latmax & LatCenter>latmin & LonCenter<lonmax & LonCenter>lonmin;
                                [across,along]=find(keep);
                                col=length(across);
                                if col>0
                                    for h=1:col
                                        %filename across_track along_track
                                        data=[{flist(ii).name(22:35)},across(h),along(h)];
                                        if flag==0
                                            result=data;
                                            flag=1;
                                        else
                                            result=[result;data];
                                        end
                                    end;
                                end;
                                
                                if flag==1
                                    if flag2==0
                                        time_acrosstrack_alongtrack{j,i}= result;
                                        flag2=1;
                                    else
                                        time_acrosstrack_alongtrack{j,i}=[time_acrosstrack_alongtrack{j,i};result];
                                    end;
                                end;
                                clear result;
                                
                            end;
                        end;
                    end
                end
            end;
            %end;
            
        end;
    end;
    
    save(filename, 'time_acrosstrack_alongtrack');
end;





