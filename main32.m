clear
clc

for year=2008:2010
    create_OMI_ECMWF_data(3,year,year,5,9);
    clear;
end
