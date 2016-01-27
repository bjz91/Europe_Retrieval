clear
clc

addpath('main');
parfor month=1:12
    for year=2013:2013
        create_mapping_OMI_ECMWF_time(3,year,month);
    end
end
