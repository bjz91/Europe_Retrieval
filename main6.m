clear
clc

tic

addpath('main');

average_OMI_ECMWF_data_fine_resolution_height(3,2005,2009,5,9,500,'200505_200909',2,1000);

toc
