clear
clc

tic

parpool(12);

addpath('main');

parfor month=1:12
    for year=2005:2014
        create_ECMWF_height(3,year,month);
    end
end

toc
