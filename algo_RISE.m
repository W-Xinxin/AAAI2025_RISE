%% sum_{v=1}^m av ( ||YY' - QvFvFv'Qv'||_F^2 + beta* Tr(Fv'(Iv- BvBv')Fv'))
%% s.t.  Fv'*Fv = I ,Y'Y = I;
%% coded by xinxin 2024/03/16

function [Y,iter, obj] = algo_RISE(B,dim, k,ind,Yt,beta)
% B : normalized anchor graph
% dim : embedding dimension
% k:  the number of classes 
% Bv : normalized anchor graph  nv * nv
% ind:   the index matrix  n * vm, 1 indicate exist , 0 indicate missing
% Y :   consensus representation : n * d
% Fv :  embedding representation : nv * d  
% Yt:  the ground truth

% ------ initialization -------- %
n = size(Yt,1);
ka = size(B{1},2);ls
av = ones(length(B),1);

%% acquire Q with n*nv
%for iv = 1 : length(Q)
%    Q{iv} = Q{iv}';
%end

% Initial Fv
for iv = 1: length(B)
     nv = size(B{iv},1);
    [Uf,Eig,Vf] = svd(B{iv},'econ');
    if dim <= ka
%         F{iv} = Uf(:,1:dim);
        F{iv} = eye(nv,dim);
    else
        F{iv} = zeros(nv,dim);
        F{iv}(:,1:ka) = Uf;
    end
end

% %% Initial Y
% Y = eye(n,dim);

iter = 0;
iter_max = 100;
converged = false;
Y_old = zeros(n,dim);

while ~converged && iter < iter_max
    iter = iter +1 ;
    
   %% update Y
   Ybar =[];
   for iv =1 : length(B)
      QF= zeros(n,dim);
      index = find(ind(:,iv) == 1);
      QF(index,:) = F{iv};
      Ybar = cat(2,Ybar,sqrt(av(iv))*QF);
   end 
   [Uy,~,Vy] = mySVD(Ybar,dim); 
   Y = Uy;
    
    %% update Fv   
    for iv = 1: length(B)   
        index = find(ind(:,iv) == 1);
        QtY = Y(index,:);
        Pbar =  cat(2,sqrt(beta)*B{iv},sqrt(2*av(iv))*QtY);
        [Up,~,Vp] = mySVD(Pbar,dim);
        F{iv} = Up;
    end
       
    %% updata av
    for iv = 1: length(B)
        QvF = zeros(n,dim);
        index = find(ind(:,iv) == 1);
        QvF(index,:) = F{iv};  
        aloss(iv) = sqrt(trace(Y'*QvF*QvF'*Y));  
    end 
       %av=1./(2*aloss);
       
        % -------------- obj --------------- %
        loss2 = 0; %%for trace
        loss1 = 0; %%for residual
        for iv =1: length(B)
            loss2  = loss2 + dim- trace(F{iv}'*B{iv}*B{iv}'*F{iv});
%             loss1  = loss1 + av(iv)* (2*n - aloss(iv)^2); %%% xin3_1
              loss1  = loss1 + av(iv)* (2*n - aloss(iv)^2); %%% xin3_1 for loss convergence
            %loss1  = loss1 + av(iv)* aloss(iv)^2;   %%% xin3_1(copy)
        end
       obj(iter) = loss1 + beta* loss2; 
       Y_old  = Y;   
       converged = ( iter > 19  && abs(obj(iter)-obj(iter-1))<1e-3);
end