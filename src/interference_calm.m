function TLD=interference_calm(Trot,Trot_Orin,side_length_y)
TLD=nansum(Trot*side_length_y*1e5); 
%label records whether the Trot_Orin is valid: 1: valid
label=ones(1,size(Trot_Orin,2));
for j_index=1:size(Trot_Orin,2)
    if sum(~isnan(Trot_Orin(:,j_index)))/length(Trot_Orin(:,j_index))<0.9
        label(j_index)=0;
    end;
end;

if sum(label)/size(Trot_Orin,2)<0.8
    TLD=nan;
else
    valid=find(label==1);
    LD=nansum(Trot_Orin,1);
    for j_index=1:size(Trot_Orin,2)
        if label(j_index)==0
            temp=abs(valid-j_index);
            [x,index]=sort(temp);
            if LD(j_index)<LD(index(1)) & LD(j_index)<LD(index(2))
                TLD(j_index)=min(TLD(index(1)),TLD(index(2)));
            end;
        end;
    end;
end;