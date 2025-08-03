%% 参考CVPR2022-IMVC-CBG 生成不完整多视图数据，每个视图的样例存在情况索引，1表示样本存在，0表示样本不存在
%% 生成视图完整性索引矩阵， folds{i}表示第i种缺损情况， folds{i}= n*v,  
%% 视图不完整度计算方法：  至少1个视图是不完整的样本数量 /  总样本数量。  （这种计算方法与PIMVC是不一样的，该方法要求每个视图的缺少量相同） 
%% code by xinxin 09/01/2024
clc;
close all;
clear;
currentFolder = pwd;
addpath(genpath(currentFolder));
resultdir = '/home/viplab/Desktop/MyIncompleteData/';
datadir='/home/viplab/Desktop/MyIncompleteData/';
% dataname={'MSRCV1', 'ORL', '20newsgroups','COIL20-3v', 'handwritten', ...
%     '100leaves', 'yale_mtv_2', 'Wikipedia'};
% dataname={'MSRCV1_3v', 'handwritten_3v', 'Wiki', 'scene-15'};
%%dataname={'AwA_fea', 'Caltech101-7','Caltech101-20','Caltech101-all_fea','CCV','Mfeat','MNIST_fea','MNIST_fea_sort','NUSWIDEOBJ','ORL_mtv','SUNRGBD_fea','Wiki_fea','YoutubeFace_sel_fea'};
%%dataname={'100Leaves','NGs','prokaryotic','proteinFold','synthetic3d','uci-digit','WebKB'};
% dataname = {'ALOI-100','BBC','BBCSport','handwritten','Handwritten_numerals','Hdigit','uci-digit'};
dataname = {'Caltech101-20','Caltech101-7','BDGP-fea'};
n_dataset = length(dataname); % number of the datasets
% for idata = 1:n_dataset-(n_dataset-1)
for idata = 1:3
    % read dataset
    dataset_file = [datadir, cell2mat(dataname(idata)),'.mat'];
    load(dataset_file); %% n *d
%     X = fea;
%     Y = truth;
    V = length(X); % the number of views
    oriData = cell(V,1);
    oriTruelabel = cell(V,1);
    for v = 1:V
        oriData{v} = X{v}';
        oriTruelabel{v} = Y;
    end
    clear X gt;
    N = size(oriData{1},2); % the number of instances
    n_view = length(oriData);
    perGrid = [0.1:0.1:0.9]; %  the percentage of paired instances   视图的样本missing 比例
    
    for per_iter = 1:length(perGrid)  %% 遍历 视图缺损比例情况从0.1-0.9，随机生成索引
        per = perGrid(per_iter); % partial example ratio    视图缺损的样本数量的比例
        miss_n = fix((per)*N); % the number of missing instances   
        folds = cell(1,30);
        
        for ii = 1: 30
            misingExampleVector = randperm(N); %% 随机生成索引
            MissingStatus = zeros(N, n_view); % indicate the missing status of instance in each view (至少存在1个视图，且保证视图是不完整的，)
            for id = 1:N
                missingViewVector = randi([0, 1], n_view, 1, 'int8');
                while(0 == sum(missingViewVector) || n_view == sum(missingViewVector))
                    % in case of all views mising
                    missingViewVector = randi([0,1], n_view,1, 'int8');
                end
                MissingStatus(id, :) = missingViewVector;
            end
            
            Temp = ones(N,n_view); %% 初始化为全1
            for id = 1: miss_n
                for j = 1 : n_view
                    if 0 == MissingStatus(misingExampleVector(id), j)
                        Temp(misingExampleVector(id),j) = 0;  %% 将每个视图中缺损的样例置0
                    end
                end
            end
             folds{ii} = Temp;  %% n*v, 对于每个视图，1表示样例存在，0 表示缺损
        end       
        
        save([resultdir,char(dataname(idata)),'_PercentDel',num2str(per),'.mat'],'folds');
        fprintf('%s finished_ %f \n',cell2mat(dataname(idata)),per);
    end
end

