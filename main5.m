clear
clc

parfor year=2005:2014
    for month=5:9
        create_ECMWF_height(3,year,month);
    end
end
