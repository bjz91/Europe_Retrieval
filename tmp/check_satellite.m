%% Check whether satellite files has missing data fields.
% Jianzhao Bi
% 2016-01-24

clear

sYear='/public/satellite/OMI/no2/DOMINO_S_v2/2013';
sMonth={'01','02','03','04','05','06','07','08','09','10','11','12'};

for nMonth=1:12
    sFolder=[sYear,'/',sMonth{nMonth}];
    disp(sFolder);
    files=dir(fullfile(sFolder,'*.he5'));
    for i=1:size(files,1)
        fname=[sFolder,'/',files(i).name];
        %disp(fname);
        if strcmp(fname,'/public/satellite/OMI/no2/DOMINO_S_v2/2013/12/OMI-Aura_L2-OMDOMINO_2013m1201t1555-o49897_v003-2013m1205t001125.he5')
            continue
        else
            CF_list=double(hdf5read(fname,'/HDFEOS/SWATHS/DominoNO2/Data Fields/CloudFraction'));
            if size(CF_list,1)==0 && size(CF_list,2)==0
                disp(fname);
            end
        end
    end
end

