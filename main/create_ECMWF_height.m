function create_ECMWF_height(ROI_index,jahr,monat)
%when we have global ECMWF data, we should verify
%v_wind=v_wind(ROI(ROI_index).ivec,ROI(ROI_index).jvec,:);
load 'input/ROI_definitions.mat';

path_regional_files='output/';
dirname=[path_regional_files 'Region_mapping_OMI_ECMWF_' ROI(ROI_index).name];
jahrstr=num2str(jahr);
monatstr=num2str(monat); if monat<10 monatstr=['0' monatstr]; end;
load([dirname '/' 'Regionalfile_mapping_OMI_ECMWF_' ROI(ROI_index).name '_' jahrstr monatstr '.mat']);

out_dirname=[path_regional_files 'Region_ECMWF_height_' ROI(ROI_index).name '/' jahrstr];
if ~exist(out_dirname,'dir')
    system(['mkdir -p ' out_dirname]);
end;

path_ECMWF='/home/bijianzhao/bjz_tmp/Europe/Europe036Hourly/';

flag_result=zeros(size(time_acrosstrack_alongtrack,1),size(time_acrosstrack_alongtrack,2));
height=cell(size(time_acrosstrack_alongtrack,1),size(time_acrosstrack_alongtrack,2));
for tag=1:eomday(jahr,monat)
    %for tag=31:31
    tagstr=num2str(tag); if tag<10 tagstr=['0' tagstr]; end;
    [jahrstr monatstr tagstr]
    path=[path_ECMWF jahrstr '/' monatstr '/' tagstr '/netcdf_complete/'];
    flist=dir([path '*.nc']);
    
    flag=0;
    %the sequence of row/column of wind data is contrary to
    %'time_acrosstrack_alongtrack'
    for ii=1:length(flist)
        fname=[path flist(ii).name];
        ncid = netcdf.open(fname,'NOWRITE');
        timeid=netcdf.inqVarID(ncid,'time_utc');
        time_utc=netcdf.getVar(ncid,timeid);
        zid=netcdf.inqVarID(ncid,'height');
        zvalue=netcdf.getVar(ncid,zid);
        z_wind=zvalue(ROI(ROI_index).ivec,ROI(ROI_index).jvec,:);
        %grid_definitions.mat is worldwide: lat:90?-90?lon:0?180?-180?~0?
        if flag==0
            x_ECMWF = ones(length(time_utc));
            z = ones(size(z_wind, 1), size(z_wind, 2),size(z_wind, 3),length(flist)+1);
            flag=1;
        end;
        x_ECMWF(ii)=time_utc/10000*60;
        z(:,:,:,ii)=z_wind;
        netcdf.close(ncid);
    end;
    
    %lack data for 01/01/2014
    %{
    if jahr== 2013 && monat==12 && tag==31
        tom_jahrstr=num2str(jahr);
        tom_monatstr='12';
        tom_tagstr='31';
    else
    %}
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
    % end;
    path=[path_ECMWF tom_jahrstr '/' tom_monatstr '/' tom_tagstr '/netcdf_complete/'];
    tom_flist=dir([path '*_00_complete.nc']);
    fname=[path tom_flist(1).name];
    ncid = netcdf.open(fname,'NOWRITE');
    timeid=netcdf.inqVarID(ncid,'time_utc');
    time_utc=netcdf.getVar(ncid,timeid);
    zid=netcdf.inqVarID(ncid,'height');
    zvalue=netcdf.getVar(ncid,zid);
    z_wind=zvalue(ROI(ROI_index).ivec,ROI(ROI_index).jvec,:);
    
    x_ECMWF(ii+1)=24*60;
    z(:,:,:,ii+1)=z_wind;
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
                
                z_ECMWF=squeeze(z(i,j,:,:))';
                z_OMI=interp1(x_ECMWF,z_ECMWF,x_OMI);
                
                if flag_result(j,i)==0
                    height{j,i}=z_OMI;
                    flag_result(j,i)=1;
                else
                    height{j,i}=[height{j,i};z_OMI];
                end;
            end;
            
        end;
    end;
    
end;

filename=[out_dirname '/' 'Regionalfile_mapping_ECMWF_height_' ROI(ROI_index).name '_' jahrstr monatstr '.mat'];
save(filename, 'height');


