clear
clc

tic

addpath('main');

average_OMI_ECMWF_data_fine_resolution_height(3,2005,2014,1,12,500,'200501_201412',2,1000);

toc
