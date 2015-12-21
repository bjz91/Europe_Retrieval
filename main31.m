clear
clc

for year=2005:2007
    create_OMI_ECMWF_data(3,year,year,5,9);
    clear;
end
