
clear;
addpath('./fun');

dataName = {'prokaryotic'};
del={'0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9'}; 
del={'0.1'}; 

dsPath = './incomplete/';
resPath = './results/';
ResBest = 'bestResults';

for idata = 1
   for dataIndex = 1
        Datafold=[dsPath,cell2mat(dataName(idata)),'_Per',cell2mat(del(dataIndex)),'.mat'];  % xinxin
        disp([cell2mat(dataName(idata)),cell2mat(del(dataIndex))]);
        load([dsPath,dataName{idata},'.mat']);         % äž?äž?žªæ ·æ¬
        load(Datafold);
    
        for iv = 1: length(X)         % require input : dim * N
            X{iv} = X{iv}';
        end
    
        numClust=length(unique(Y));  k = numClust;
        numSample=length(Y);         n = numSample;
        numView=length(X);
%         ka_list = [3*k,4*k,5*k];  % the anchor number
        ka_list = [2*k,3*k,4*k,5*k,6*k];
%         kn_list = [3,4,5,6,7,8,9,10];  % the neighbors number   require : ka  > kn;   fault set: kn =10; as SFMC
        %kn_list = [10,11,12,13,14];
        kn_list = [3,4,5,6,7];
        dim_list = [1*k,2*k,3*k,4*k];
        beta_list = [0.01,0.1,1,10,20,50,100,500,1000,10000];
        %beta_list = [0.01];
        rep = 10;  % number of repeat 

        txtpath = strcat(resPath,strcat(cell2mat(dataName(idata)),'_Per',cell2mat(del(dataIndex)),'.txt')); % file path
        bestResult = strcat(dataName(idata),'_',ResBest);                % filename
        bestpath = strcat(resPath,strcat(cell2mat(bestResult),'.txt'));   % file path
        if (~exist(resPath,'file'))
            mkdir(resPath);
            addpath(genpath(resPath));
        end
        dlmwrite(txtpath, strcat('Dataset:',cell2mat(dataName(idata)),'_Per',cell2mat(del(dataIndex)), '_Date:',datestr(now)),'-append','delimiter','','newline','pc');
        dlmwrite(bestpath, strcat('Dataset:',cell2mat(dataName(idata)),'_Per',cell2mat(del(dataIndex)), '_Date:',datestr(now),'-best results'),'-append','delimiter','','newline','pc');

        fold = folds;
        %% data pre-processing 
        for iv = 1:length(X)
            %X1{iv} = NormalizeFea(X{iv},0);    % Normalization on entire data

            ind_1 = find(fold(:,iv) == 1);
            numS{iv} = length(ind_1);           % the number of exist instance for each view
            ind_0 = find(fold(:,iv) == 0);
            X{iv}(:,ind_0) = [];                % obtain  the  original imcomplete data : d *nv   
            %X1{iv}(:,ind_0) = [];  

            X1{iv} = NormalizeFea(X{iv},0);     % d*nv   get each column to have unit norm ;  refers to  PIMVC.m   
            %linshi_W = diag(fold(:,iv));
            %linshi_W(:,ind_0) = [];
            %Q{iv} = linshi_W';                 % nv * n
        end 
 
        %% for different anchor number ka:    generate anchors and constructed anchor graph 
        for g = 1 : length(kn_list);   %%% the neighbors number
             kn = kn_list(g);
           for p =1: length(ka_list)   %%% the anchors number 
             ka = ka_list(p);
             for iv = 1:length(X)
                rand('seed',6666);
                Xa = X1{iv};
                %% anchor generation: k-means
                [~,anchor{iv}] = litekmeans(X1{iv}', ka, 'MaxIter', 100,'Replicates',10); % m *dv
                method =1001;

                distX{iv} = EuDist2(X1{iv}', anchor{iv});
                [~, idx] = sort(distX{iv}, 2);       
                S = zeros(numS{iv},ka);
                       for i =1 : numS{iv}
                           id = idx(i,1:kn+1);
                           di = distX{iv}(i,id);
                           S(i,id) =  (di(kn+1)-di)/(kn*di(kn+1)-sum(di(1:kn))+eps);
                       end
                graph{iv} = S;
                sumD= diag(sqrt(sum(graph{iv},1)))^-1;
                B{iv} = graph{iv}*sumD;   %% 
                clear S Xa;        
            end    
        
            bestR = zeros(1,6);
            
            for i=1: length(beta_list)
                beta = beta_list(i);
                for j = 1: length(dim_list)   %% the dimension of embedding 
                    dim = dim_list(j);
                     tic;
                    [P,iter, obj] = algo3_RISE(B,dim,k,fold,Y ,beta);  % Óëalgo1.m ²»Í¬µÄ×ÔÊÊÓŠ°Ú·ÅÎ»ÖÃ
                     time1 = toc;
                    T_metric = zeros(rep,3);    
                     tic;
                    for ir = 1: rep        
                       pre_labels = kmeans(real(P),k,'emptyaction','singleton','replicates',20,'display','off');
                       resultY = ClusteringMeasure(pre_labels,Y);
                       T_metric(ir,:) = resultY;
                    end 
                    time2 = toc;
                    timemean = time1 + time2/rep;
                    result= mean(T_metric);
                    result_std = std(T_metric);

                    fprintf('Result: ratio: %s, kn:%d, ka: %d,beta:%.6f, dim: %d, iter: %d, ACC:%.6f, NMI:%.6f, Purity: %.6f \n',cell2mat(del(dataIndex)),kn, ka,beta,dim,iter,result(1),result(2),result(3));             
                    dlmwrite( txtpath ,[result, kn, ka,beta,dim,timemean, method],'-append','delimiter','\t','newline','pc');
                    dlmwrite( txtpath ,[result_std],'-append','delimiter','\t','newline','pc');

                    if result(1) > bestR(1)
                        bestR = [result,kn, ka,beta,dim,timemean, method];
                    end
                end
           end
              dlmwrite(bestpath,[bestR],'-append','delimiter','\t','newline','pc'); %% for each set of anchor number 
           end
        end
   end
   clear X X1 Q B;
end
