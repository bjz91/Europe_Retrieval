function F=interference_Gaussian(Trot,starti,direction,dis_lim,type)
F=1;

%dis_lim_i=ceil(dis_lim/18);
dis_lim_i=floor(dis_lim/18);
% switch type
%     case 'S'
%         dis_lim_j=2;
%     case 'M'
%         dis_lim_j=3;
%     otherwise
%         dis_lim_j=4;
% end;

switch type
    case 'S'
        dis_lim_j=2;
    case 'M'
        dis_lim_j=3;
    otherwise
        dis_lim_j=3;
end;

half_le=ceil(size(Trot,1)/2);
if strcmp(direction,'right')
    for i_index=starti:starti+dis_lim_i
        for j_index=[1:(half_le-dis_lim_j) (half_le+dis_lim_j):size(Trot,1)]
            if Trot(j_index,i_index)> 0.9*mean(mean(Trot(half_le-(dis_lim_j-1):half_le+(dis_lim_j-1),starti:starti+(dis_lim_j-1))))
%                 Trot(j_index,i_index)
%                 j_index,i_index
                 F=0;
            end;
        end;
    end;
else
    for i_index=starti-dis_lim_i:starti
        for j_index=[1:(half_le-dis_lim_j) (half_le+dis_lim_j):size(Trot,1)]
            if  Trot(j_index,i_index)> 0.9*mean(mean(Trot(half_le-(dis_lim_j-1):half_le+(dis_lim_j-1),starti-(dis_lim_j-1):starti)))
%                 Trot(j_index,i_index)
%                 j_index,i_index
                F=0;
            end;
        end;
    end;
end;
                
       