function combine_OMI_ECMWF_data(ROI_index,start_jahr,end_jahr,start_month,end_month)
path_input_files='input/';
load([path_input_files 'grid_definitions.mat']);
load([path_input_files 'ROI_definitions.mat']);

path_regional_files='output/';

start_jahrstr=num2str(start_jahr);
end_jahrstr=num2str(end_jahr);
start_monatstr=num2str(start_month); if start_month<10 start_monatstr=['0' start_monatstr]; end;
end_monatstr=num2str(end_month); if end_month<10 end_monatstr=['0' end_monatstr]; end;

out_dirname=[path_regional_files 'Region_OMI_ECMWF_data_' ROI(ROI_index).name];
if ~exist(out_dirname,'dir')
    system(['mkdir -p ' out_dirname]);
end;
out_time_label= [start_jahrstr start_monatstr '_' end_jahrstr end_monatstr];


for j=1:length(ROI(ROI_index).latvec)
    ['lat' num2str(ROI(ROI_index).latvec(j))]
    for i=1:length(ROI(ROI_index).lonvec) 
        location_label=['lat' num2str(ROI(ROI_index).latvec(j)) '_lon' num2str(ROI(ROI_index).lonvec(i))];
        filename=[out_dirname '/' 'Regionalfile_OMI_ECMWF_data_' ROI(ROI_index).name '_' location_label '_' out_time_label '.mat'];
        CombineDATA.lat_center=ROI(ROI_index).latvec(j);
        CombineDATA.lon_center=ROI(ROI_index).lonvec(i);
        CombineDATA.size='0.36deg';
        flag=0;
        for jahr= start_jahr:end_jahr
            jahrstr=num2str(jahr);
            time_label= [jahrstr start_monatstr '_' jahrstr end_monatstr];
            DATA_dirname=[path_regional_files '/monthly/Region_OMI_ECMWF_data_' ROI(ROI_index).name '_' time_label];
            load([DATA_dirname '/' 'Regionalfile_OMI_ECMWF_data_' ROI(ROI_index).name '_' location_label '_' time_label '.mat']);
            
            if flag==0
                CombineDATA.time=DATA.time;
                CombineDATA.acrosstrack=DATA.acrosstrack;
                CombineDATA.alongtrack=DATA.alongtrack;
                CombineDATA.wind_u=DATA.wind_u;
                CombineDATA.wind_v=DATA.wind_v;
                %CombineDATA.TAMF=DATA.TAMF;
                CombineDATA.CF=DATA.CF;
                CombineDATA.CP=DATA.CP;
                CombineDATA.CRF=DATA.CRF;
                CombineDATA.TVCD=DATA.TVCD;
                CombineDATA.SZA=DATA.SZA;
                %CombineDATA.XQF=DATA.XQF;
                CombineDATA.lat_satellite=DATA.lat_satellite;
                CombineDATA.lon_satellite=DATA.lon_satellite;
                CombineDATA.lat_corner=DATA.lat_corner;
                CombineDATA.lon_corner=DATA.lon_corner;
                    
                flag=1;
            else
                CombineDATA.time=[CombineDATA.time;DATA.time];
                CombineDATA.acrosstrack=[CombineDATA.acrosstrack;DATA.acrosstrack];
                CombineDATA.alongtrack=[CombineDATA.alongtrack;DATA.alongtrack];
                CombineDATA.wind_u=[CombineDATA.wind_u;DATA.wind_u];
                CombineDATA.wind_v=[CombineDATA.wind_v;DATA.wind_v];
                %CombineDATA.TAMF=[CombineDATA.TAMF;DATA.TAMF];
                CombineDATA.CF=[CombineDATA.CF;DATA.CF];
                CombineDATA.CP=[CombineDATA.CP;DATA.CP];
                CombineDATA.CRF=[CombineDATA.CRF;DATA.CRF];
                CombineDATA.TVCD=[CombineDATA.TVCD;DATA.TVCD];
                CombineDATA.SZA=[CombineDATA.SZA;DATA.SZA];
                %CombineDATA.XQF=[CombineDATA.XQF;DATA.XQF];
                CombineDATA.lat_satellite=[CombineDATA.lat_satellite;DATA.lat_satellite];
                CombineDATA.lon_satellite=[CombineDATA.lon_satellite;DATA.lon_satellite];
                CombineDATA.lat_corner=[CombineDATA.lat_corner;DATA.lat_corner];
                CombineDATA.lon_corner=[CombineDATA.lon_corner;DATA.lon_corner];
            end;
            clear DATA;
           
        end;
        save(filename, 'CombineDATA'); 
        clear CombineDATA;
    end;
end;