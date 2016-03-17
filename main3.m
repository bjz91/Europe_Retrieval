clear
clc

tic 

addpath('main');

for year=2005:2014
    create_OMI_ECMWF_data(3,year,year,1,12);
    clear;
end

toc
