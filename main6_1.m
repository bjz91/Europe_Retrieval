clear
clc

tic

addpath('main');

average_OMI_ECMWF_data_fine_resolution_height(3,2010,2014,5,9,500,'201005_201409',2,1000);

toc
