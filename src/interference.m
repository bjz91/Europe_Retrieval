function Trot_filter=interference(Trot,Trot_Orin)
for j_index=1:size(Trot,2)
    if sum(~isnan(Trot_Orin(:,j_index)))/length(Trot_Orin(:,j_index))<0.9
        Trot(:,j_index)=nan;
    end;
end;
Trot_filter=Trot;