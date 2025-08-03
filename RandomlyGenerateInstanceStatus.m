%% �ο�CVPR2022-IMVC-CBG ���ɲ���������ͼ���ݣ�ÿ����ͼ�������������������1��ʾ�������ڣ�0��ʾ����������
%% ������ͼ�������������� folds{i}��ʾ��i��ȱ������� folds{i}= n*v,  
%% ��ͼ�������ȼ��㷽����  ����1����ͼ�ǲ��������������� /  ������������  �����ּ��㷽����PIMVC�ǲ�һ���ģ��÷���Ҫ��ÿ����ͼ��ȱ������ͬ�� 
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
    perGrid = [0.1:0.1:0.9]; %  the percentage of paired instances   ��ͼ������missing ����
    
    for per_iter = 1:length(perGrid)  %% ���� ��ͼȱ����������0.1-0.9�������������
        per = perGrid(per_iter); % partial example ratio    ��ͼȱ������������ı���
        miss_n = fix((per)*N); % the number of missing instances   
        folds = cell(1,30);
        
        for ii = 1: 30
            misingExampleVector = randperm(N); %% �����������
            MissingStatus = zeros(N, n_view); % indicate the missing status of instance in each view (���ٴ���1����ͼ���ұ�֤��ͼ�ǲ������ģ�)
            for id = 1:N
                missingViewVector = randi([0, 1], n_view, 1, 'int8');
                while(0 == sum(missingViewVector) || n_view == sum(missingViewVector))
                    % in case of all views mising
                    missingViewVector = randi([0,1], n_view,1, 'int8');
                end
                MissingStatus(id, :) = missingViewVector;
            end
            
            Temp = ones(N,n_view); %% ��ʼ��Ϊȫ1
            for id = 1: miss_n
                for j = 1 : n_view
                    if 0 == MissingStatus(misingExampleVector(id), j)
                        Temp(misingExampleVector(id),j) = 0;  %% ��ÿ����ͼ��ȱ���������0
                    end
                end
            end
             folds{ii} = Temp;  %% n*v, ����ÿ����ͼ��1��ʾ�������ڣ�0 ��ʾȱ��
        end       
        
        save([resultdir,char(dataname(idata)),'_PercentDel',num2str(per),'.mat'],'folds');
        fprintf('%s finished_ %f \n',cell2mat(dataname(idata)),per);
    end
end

