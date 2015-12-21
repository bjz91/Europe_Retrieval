clear
clc

for year=2011:2014
    create_OMI_ECMWF_data(3,year,year,5,9);
    clear;
end
