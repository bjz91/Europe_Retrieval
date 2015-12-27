%Season 5: overall mean
warning off;
%map_TAMF=fine_DATA.map_TAMF(:,:,1:4,:);
map_CF=fine_DATA.map_CF(:,:,1:4,:);
map_SZA=fine_DATA.map_SZA(:,:,1:4,:);
map_TVCD=fine_DATA.map_TVCD(:,:,1:4,:);
map_U=fine_DATA.U(:,:,1:4,:);
map_V=fine_DATA.V(:,:,1:4,:);
map_sample_num=fine_DATA.sample_num(:,:,1:4,:);

nanflag=isnan(map_U)|isnan(map_V)|isnan(map_TVCD)|isnan(map_CF)|isnan(map_SZA);%|isnan(map_TAMF);
map_U(nanflag)=0;
map_V(nanflag)=0;
map_TVCD(nanflag)=0;
%map_TAMF(nanflag)=0;
map_CF(nanflag)=0;
map_SZA(nanflag)=0;
%map_TVCDstd(nanflag)=0;
map_sample_num(nanflag)=0;

%optional!!!!
%remove data with too few sample number before average
%map_U(map_sample_num<=Samle_Num)=0;
%map_V(map_sample_num<=Samle_Num)=0;
%map_TVCD(map_sample_num<=Samle_Num)=0;
%map_TVCDstd(map_sample_num<=Samle_Num)=0;
%map_sample_num(map_sample_num<=Samle_Num)=0;

map_U_=sum(map_U.*map_sample_num,3)./sum(map_sample_num,3);
map_V_=sum(map_V.*map_sample_num,3)./sum(map_sample_num,3);
map_T_=sum(map_TVCD.*map_sample_num,3)./sum(map_sample_num,3);
%map_TAMF_=sum(map_TAMF.*map_sample_num,3)./sum(map_sample_num,3);
map_CF_=sum(map_CF.*map_sample_num,3)./sum(map_sample_num,3);
map_SZA_=sum(map_SZA.*map_sample_num,3)./sum(map_sample_num,3);
%map_Tstd_=sum(map_TVCDstd.*map_sample_num,3)./sum(map_sample_num,3);

map_U(:,:,5,:)=map_U_;
map_V(:,:,5,:)=map_V_;
map_TVCD(:,:,5,:)=map_T_;
%map_TAMF(:,:,5,:)=map_TAMF_;
map_CF(:,:,5,:)=map_CF_;
map_SZA(:,:,5,:)=map_SZA_;
%map_TVCDstd(:,:,5,:)=map_Tstd_;
map_sample_num(:,:,5,:)=sum(map_sample_num,3);

map_U(:,:,6:7,:)=fine_DATA.U(:,:,5:6,:);
map_V(:,:,6:7,:)=fine_DATA.V(:,:,5:6,:);
map_TVCD(:,:,6:7,:)=fine_DATA.map_TVCD(:,:,5:6,:);
%map_TAMF(:,:,6:7,:)=fine_DATA.map_TAMF(:,:,5:6,:);
map_CF(:,:,6:7,:)=fine_DATA.map_CF(:,:,5:6,:);
map_SZA(:,:,6:7,:)=fine_DATA.map_SZA(:,:,5:6,:);
map_sample_num(:,:,6:7,:)=fine_DATA.sample_num(:,:,5:6,:);

%remove data with too few sample number
map_TVCD(map_sample_num<=Samle_Num)=nan;
%map_TVCDstd(map_sample_num<=Samle_Num)=nan;
map_U(map_sample_num<=Samle_Num)=nan;
map_V(map_sample_num<=Samle_Num)=nan;
%map_TAMF(map_sample_num<=Samle_Num)=nan;
map_CF(map_sample_num<=Samle_Num)=nan;
map_SZA(map_sample_num<=Samle_Num)=nan;
map_sample_num(map_sample_num<=Samle_Num)=0;

clear map_U_ map_V_ map_T_ map_TAMF_ map_CF_ map_SZA_
%map_Tstd_;