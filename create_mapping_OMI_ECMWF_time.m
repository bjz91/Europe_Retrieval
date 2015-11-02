function create_mapping_OMI_ECMWF_time(ROI_index,jahr,monat)
%when we have global ECMWF data, we should verify
%v_wind=v_wind(ROI(ROI_index).ivec,ROI(ROI_index).jvec,:);
load 'input/ROI_definitions.mat';

path_regional_files='output/';
dirname=[path_regional_files 'Region_mapping_OMI_ECMWF_' ROI(ROI_index).name];
jahrstr=num2str(jahr);
monatstr=num2str(monat); if monat<10 monatstr=['0' monatstr]; end;
load([dirname '/' 'Regionalfile_mapping_OMI_ECMWF_' ROI(ROI_index).name '_' jahrstr monatstr '.mat']);

out_dirname=[path_regional_files 'Region_mapping_OMI_ECMWF_time_' ROI(ROI_index).name '/' jahrstr];
if ~exist(out_dirname,'dir')
    system(['mkdir -p ' out_dirname]);
end;

path_ECMWF='/public/temp/BJZ/ERA-Interim/Europe036Hourly/';

flag_result=zeros(size(time_acrosstrack_alongtrack,1),size(time_acrosstrack_alongtrack,2));
U15_V15=cell(size(time_acrosstrack_alongtrack,1),size(time_acrosstrack_alongtrack,2));
for tag=1:eomday(jahr,monat)
    %for tag=31:31
    
    tagstr=num2str(tag); if tag<10 tagstr=['0' tagstr]; end;
    disp([jahrstr monatstr tagstr]);
    path=[path_ECMWF jahrstr '/' monatstr '/' tagstr '/netcdf_complete/'];
    flist=dir([path '*.nc']); %这里是要得到文件夹下的四个nc吗？？？？
    
    flag=0;
    %the sequence of row/column of wind data is contrary to
    %'time_acrosstrack_alongtrack'
    for ii=1:length(flist)
        fname=[path flist(ii).name];
        ncid = netcdf.open(fname,'NOWRITE');
        timeid=netcdf.inqVarID(ncid,'time_utc');
        time_utc=netcdf.getVar(ncid,timeid);
        uid=netcdf.inqVarID(ncid,'u_wind');
        u_wind=netcdf.getVar(ncid,uid);
        %grid_definitions.mat is worldwide: lat:90?-90?lon:0?180?-180?~0?
        %u_wind=u_wind(ROI(ROI_index).ivec,ROI(ROI_index).jvec,:);
        vid=netcdf.inqVarID(ncid,'v_wind');
        v_wind=netcdf.getVar(ncid,vid);
        %v_wind=v_wind(ROI(ROI_index).ivec,ROI(ROI_index).jvec,:);
        if flag==0
            x_ECMWF = ones(length(time_utc));
            u = ones(size(u_wind, 1), size(u_wind, 2),size(u_wind, 3),length(flist)+1);
            v = ones(size(v_wind, 1), size(v_wind, 2),size(v_wind, 3),length(flist)+1);
            flag=1;
        end;
        x_ECMWF(ii)=time_utc/10000*60;
        u(:,:,:,ii)=u_wind;
        v(:,:,:,ii)=v_wind;
        netcdf.close(ncid);
    end;
    
    %load the 'tomorrow' data for interpolate
    if monat==12 && tag==31
        tom_jahrstr=num2str(jahr+1);
        tom_monatstr='01';
        tom_tagstr='01';
    elseif monat<12 && tag==eomday(jahr,monat)
        tom_jahrstr=num2str(jahr);
        tom_monatstr=num2str(monat+1); if monat+1<10 tom_monatstr=['0' tom_monatstr]; end;
        tom_tagstr='01';
    else
        tom_jahrstr=num2str(jahr);
        tom_monatstr=num2str(monat); if monat<10 tom_monatstr=['0' tom_monatstr]; end;
        tom_tagstr=num2str(tag+1); if tag+1<10 tom_tagstr=['0' tom_tagstr]; end;
    end;
    path=[path_ECMWF tom_jahrstr '/' tom_monatstr '/' tom_tagstr '/netcdf_complete/'];
    tom_flist=dir([path '*_U_V_ml_00.nc']);
    fname=[path tom_flist(1).name];
    ncid = netcdf.open(fname,'NOWRITE');
    timeid=netcdf.inqVarID(ncid,'time_utc');
    time_utc=netcdf.getVar(ncid,timeid);
    uid=netcdf.inqVarID(ncid,'u_wind');
    u_wind=netcdf.getVar(ncid,uid);
    %u_wind=u_wind(ROI(ROI_index).ivec,ROI(ROI_index).jvec,:);
    vid=netcdf.inqVarID(ncid,'v_wind');
    v_wind=netcdf.getVar(ncid,vid);
    %v_wind=v_wind(ROI(ROI_index).ivec,ROI(ROI_index).jvec,:);
    
    x_ECMWF(ii+1)=24*60;
    u(:,:,:,ii+1)=u_wind;
    v(:,:,:,ii+1)=v_wind;
    netcdf.close(ncid);
    
    for j=1:size(time_acrosstrack_alongtrack,1)
        for i=1:size(time_acrosstrack_alongtrack,2)
            %for j=1:2
            %    for i=1:2
            list=squeeze(time_acrosstrack_alongtrack{j,i}(:,1));
            sublist=list(strmatch([jahrstr 'm' monatstr tagstr],list));
            time=cell2mat(sublist);
            
            if size(time,1) > 0
                hour=str2num(time(:,11:12));
                minute=str2num(time(:,13:14));
                x_OMI=(hour*60+minute)';
                
                u_ECMWF=squeeze(u(i,j,:,:))';
                v_ECMWF=squeeze(v(i,j,:,:))';
                
                %得到OMI时刻的风场数据
                u_OMI=interp1(x_ECMWF,u_ECMWF,x_OMI);
                v_OMI=interp1(x_ECMWF,v_ECMWF,x_OMI);
                
                data= ones(size(u_OMI, 1), size(u_OMI, 2),2);
                data(:,:,1)=u_OMI;
                data(:,:,2)=v_OMI;
                
                if flag_result(j,i)==0
                    U15_V15{j,i}=data;
                    flag_result(j,i)=1;
                else
                    U15_V15{j,i}=[U15_V15{j,i};data];
                end;
            end;
            
        end;
    end;
    
end;

filename=[out_dirname '/' 'Regionalfile_mapping_OMI_ECMWF_time_' ROI(ROI_index).name '_' jahrstr monatstr '.mat'];
save(filename, 'U15_V15');


