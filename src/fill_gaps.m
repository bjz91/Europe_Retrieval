%fill in little gaps and little smoothing

clear CONVKERN;
CONVKERN(1:5,1:5)=1e-6; %very little smoothing!
CONVKERN(2:4,2:4)=1e-3;
CONVKERN(3,3)=1;
CONVKERN=CONVKERN/sum(sum(CONVKERN));

map_U_filled=map_U;
map_V_filled=map_V;
map_TVCD_filled=map_TVCD;
%map_TAMF_filled=map_TAMF;
map_CF_filled=map_CF;
map_SZA_filled=map_SZA;
%map_TVCDstd_filled=map_TVCDstd;

for fill_gaps_seasonindex=1:7
    for fill_gaps_winddirindex=1:9       
                map=squeeze(map_U(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex));
                mask=~isnan(map);            map(mask==0)=0;
                convmask=convn(mask,CONVKERN,'same');            convmap=convn(map,CONVKERN,'same');
                map=convmap./convmask;       map(map==0)=nan;
                map_U_filled(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex)=map;

                map=squeeze(map_V(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex));
                mask=~isnan(map);            map(mask==0)=0;
                convmask=convn(mask,CONVKERN,'same');            convmap=convn(map,CONVKERN,'same');
                map=convmap./convmask;       map(map==0)=nan;
                map_V_filled(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex)=map;
                
                map=squeeze(map_TVCD(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex));
                mask=~isnan(map);            map(mask==0)=0;
                convmask=convn(mask,CONVKERN,'same');            convmap=convn(map,CONVKERN,'same');
                map=convmap./convmask;       map(map==0)=nan;
                map_TVCD_filled(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex)=map;

                %map=squeeze(map_TVCDstd(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex));
                %mask=~isnan(map);            map(mask==0)=0;
                %convmask=convn(mask,CONVKERN,'same');            convmap=convn(map,CONVKERN,'same');
                %map=convmap./convmask;       map(map==0)=nan;
                %map_TVCDstd_filled(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex)=map;
                
                %{
                map=squeeze(map_TAMF(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex));
                mask=~isnan(map);            map(mask==0)=0;
                convmask=convn(mask,CONVKERN,'same');            convmap=convn(map,CONVKERN,'same');
                map=convmap./convmask;       map(map==0)=nan;
                map_TAMF_filled(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex)=map;
                %}
                
                map=squeeze(map_CF(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex));
                mask=~isnan(map);            map(mask==0)=0;
                convmask=convn(mask,CONVKERN,'same');            convmap=convn(map,CONVKERN,'same');
                map=convmap./convmask;       map(map==0)=nan;
                map_CF_filled(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex)=map;
                
                map=squeeze(map_SZA(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex));
                mask=~isnan(map);            map(mask==0)=0;
                convmask=convn(mask,CONVKERN,'same');            convmap=convn(map,CONVKERN,'same');
                map=convmap./convmask;       map(map==0)=nan;
                map_SZA_filled(:,:,fill_gaps_seasonindex,fill_gaps_winddirindex)=map;
    end;
end;
    

clear CONVKERN convmask convmap map mask fill_gaps_*;