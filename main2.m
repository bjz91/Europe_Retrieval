clear
clc

parfor month=1:12
    for year=2005:2014
        create_mapping_OMI_ECMWF_time(3,year,month);
    end
end
