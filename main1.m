clear
clc

tic

parpool(12);

addpath('main');

parfor month=1:12
    for year=2013:2013
        create_mapping_OMI_ECMWF(3,year,month,1);
    end
end

toc
