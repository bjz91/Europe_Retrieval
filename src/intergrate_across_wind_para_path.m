
ROI_index=3;

start_jahr=2005;
end_jahr=2014;
start_month=1;
end_month=12;

wind_altitude=500;
calm_speed=2;
max_speed=1000;

resolution=4;

start_jahrstr=num2str(start_jahr);
end_jahrstr=num2str(end_jahr);
start_monatstr=num2str(start_month); if start_month<10 start_monatstr=['0' start_monatstr]; end;
end_monatstr=num2str(end_month); if end_month<10 end_monatstr=['0' end_monatstr]; end;

winddirlabel=['SE'; 'S '; 'SW'; 'E '; '0 '; 'W '; 'NE'; 'N '; 'NW'];

path_input_files='input/';
load([path_input_files 'grid_definitions.mat']);
load([path_input_files 'ROI_definitions.mat']);

path_regional_files='output/';
DATA_dirname=[path_regional_files 'Region_OMI_ECMWF_average_fine_resolution_' ROI(ROI_index).name];
load([DATA_dirname '/' 'Average_resolution' num2str(resolution) '_' ROI(ROI_index).name '_'  start_jahrstr start_monatstr '_' end_jahrstr end_monatstr ...
    '_altitude' num2str(wind_altitude) '_calmspeed' num2str(calm_speed) '_maxspeed' num2str(max_speed) '.mat']);

if ROI_index==2
    address=[path_input_files 'Location_USA.xls'];
elseif ROI_index==3
    address=[path_input_files 'Location_Europe.xls'];
else
    address=[path_input_files 'Location_China.xls'];
end;
[number,txt,raw]=xlsread(address);
clear number txt

