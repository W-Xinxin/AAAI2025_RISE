%% 参考CVPR2022-IMVC-CBG 生成不完整多视图数据，每个视图的样例存在情况索引，1表示存在，0表示缺损
%% 生成视图不完整数据 data( d*N，不完整的视图被置为Nan) 和  生成视图缺损索引矩阵， folds表示缺损情况示意矩阵： N*v ，1表示存在，0表示缺损
%% 缺损度计算方法：  至少1个视图是不完整的样本数量 /  总样本数量。  （这种计算方法与PIMVC是不一样的，该方法要求每个视图的缺少量相同） 

%% code by xinxin 10/01/2024
%% data: dv*n (NaN for missing column);   index: nv* n_view (index of exist instances for each view)


clc;
close all;
clear;
currentFolder = pwd;
addpath(genpath(currentFolder));
resultdir = '/home/viplab/Desktop/MyIncompleteData/';
datadir='/home/viplab/Desktop/MyIncompleteData/';
dataname = {'Caltech101-7','BDGP_fea','handwritten-5view','bbcsport4vbigRnSp','YoutubeFace_sel_fea','Animal','3Sources','NGs'};
n_dataset = length(dataname); % number of the datasets

for idata = 2
    % read dataset
    dataset_file = [datadir, cell2mat(dataname(idata)),'.mat'];
    load(dataset_file);
%    X = fea;
 %   Y = truth;     % for bbcsport4vbigRnSp
    V = length(X);  % the number of views
    oriData = cell(V,1);
    oriTruelabel = cell(V,1);

    for v = 1:V
        oriData{v} = X{v}';      % for Caltech7, Caltech20, BDGP, 
        %oriData{v} = X{v};      % for handwritten-5view;  bbcsport4vbigRnSp
        oriTruelabel{v} = Y;
    end

    clear X gt;
    N = size(oriData{1},2); % the number of instances
    n_view = length(oriData);
    perGrid = [0.1:0.1:0.9]; %  the percentage of paired instances  视图完整的样本数量的比例
    
    misingExampleVector = randperm(N);  %% 随机生成索引
    MissingStatus = zeros(N, n_view); % indicate the missing status of instance in each view (随机生成缺损情况，要求每个样本至少存在1个视图（不能全部缺损），但要保证视图是不完整的（不能是完整的）)
    for id = 1:N
        missingViewVector = randi([0, 1], n_view, 1, 'int8');
        while(0 == sum(missingViewVector) || n_view == sum(missingViewVector))
            % in case of all views mising
            missingViewVector = randi([0,1], n_view,1, 'int8');
        end
        MissingStatus(id, :) = missingViewVector;
    end
    
    for per_iter = 1:length(perGrid)   %% 遍历 视图缺损比例情况从0.1-0.9，随机生成索引
        per = perGrid(per_iter); % partial example ratio  视图完整的样本数量的比例
        miss_n = fix((per)*N); % the number of missing instances
        
        perMisingExampleVector = misingExampleVector(1: miss_n);
        data = oriData;
        full_index = cell(1,n_view);
        for v = 1:n_view
            full_index{v} = zeros(N,1); %% 初始化为全0
        end
        for id = 1: miss_n
            for j = 1 : n_view
                if 0 == MissingStatus(misingExampleVector(id), j)
                    data{j}(:,misingExampleVector(id)) = nan;    %% 将缺损的数据置为 Nan
                    full_index{j}(misingExampleVector(id)) = 1;  %%  random 将每个视图中缺损的样例置1
                end
            end
        end
        index = cell(1, n_view);
        for v = 1:n_view
            index{v} = find(full_index{v}==0);  %% 找到每个视图中存在的样例的 索引
        end
        truelabel = oriTruelabel; 
        
        folds= zeros(N,n_view); %% 保存每个视图中样例的状态，1表示存在，0表示缺损
        for v = 1: n_view
           folds(index{v},v) = 1;    %% 根据索引，将存在的样例置1
        end
        
        save([resultdir,char(dataname(idata)),'_Per',num2str(per),'.mat'],'data','truelabel','index','MissingStatus','folds');
        fprintf('%s finished_%f \n',cell2mat(dataname(idata)), per);
        clear data truelabel index;
    end
end
