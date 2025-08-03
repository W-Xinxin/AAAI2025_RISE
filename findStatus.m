%%% Coded by xinxinwang 23/01/2024   , refer to code of CVPR2022 -IMVC-CBG


function[X1, ind] = findStatus(data,index);
%% data:  dv * n   , with NaN for missing column
%% index: nv* v_view,   the exist index for each view
[numofview,~] = size(data);
[~,numofsample] = size(data{1});

X1 = cell(numofview,1);
ind = zeros(numofsample,numofview);
for i = 1: numofview
    [d,~] = size(data{i});
    ind(index{i},i) = 1;
    origin = data{i};
    origin(isnan(origin)) = [] ;
end

end