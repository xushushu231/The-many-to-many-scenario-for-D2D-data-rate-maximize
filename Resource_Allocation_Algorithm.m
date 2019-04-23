clear all ;
tic
clc;
fid11               =      ['R_DUE','.txt'];
c1                  =      fopen(fid11,'w');
fid22               =      ['Rm1_DUE_ini','.txt'];
c2                  =      fopen(fid22,'w');
fid33               =      ['Rm1_DUE','.txt'];
c3                  =      fopen(fid33,'w');
for l = 1 : 1
%% 函数作用：实现用户的资源分配


%global  submodeltype;

global K I J Pmax Gain Gain1 Gain2 Gain3 Gain4 Rreqj gkj0 gkji gki0 gki_i

submodeltype    =       0;
K               =       10; %载波数
I               =       3; %D2D用户数
J               =       3; %CUE用户数

B               =       1.5*10^4;         %子载波的带宽为15kHz
N0              =       10^(-(174/10))*10^(-3)*B;%每个子载波的噪声功率 W   -174dBm/Hz
%% 初始迭代功率
pmki            =       (0.2/K)*ones(K,I); %DUE功率集合
pmkj            =       (0.2/K)*ones(K,J); %CUE功率集合
%% 最大功率限制
Pmaxi           =       0.2*ones(I,1);
Pmaxj           =       0.2*ones(J,1);
Pmax            =       [Pmaxi;Pmaxj];
%% 基本数据速率需求
Rreqj           =       5*ones(J,1);
%% CUE-BS信道增益
[Gain]          =       Gain_CUE(K,J);
%Gain = rand(J,K);


gkj0            =       Gain';
%% DUE i - DUE i信道增益
[Gain1]         =       Gain_DUE(K,I);%DUE对之间的信道增益
%Gain1 = rand(I,K);

%% CUE-DUE 信道增益
[Gain2]          =       Gain_CUE_DUE(K,I,J);


gkji            =       zeros(K,J,I);
for i           =       1:I
    gkji(:,:,i) =       Gain2(:,:,i)';
end
%% DUE-CUE 信道增益
[Gain3]         =       Gain_DUE_CUE(K,I);
%Gain3 = rand(I,K);
%Gain3           =      [2.2629e-09,3.8472e-09,5.8309e-09,2.5191e-09,2.9054e-09,6.1719e-09,2.6538e-09,8.2448e-09;9.8276e-09,7.3035e-09,3.4398e-09,5.8417e-09,1.0787e-09,9.0641e-09,8.7975e-09,8.1786e-09];


gki0            =       Gain3';
%% DUE i-DUE i' 信道增益
[Gain4]         =       Gain_DUE_DUE(I,K);

gki_i           =       zeros(K,I,I);
for i=1:I
    gki_i(:,:,i)=Gain4(:,:,i)';
    gki_i(:,i,i)=Gain1(i,:);
end

%%
%[Phom1ki,Phom1kj,R_DUE] =   Subcarrier_Allocation_Algorithm5(pmki,pmkj)
[Phom1ki,Phom1kj,R_DUE] = Subcarrier_Allocation_Algorithm(pmki,pmkj);
fprintf(c1,'%1.16f\n',R_DUE);
Phomki                  =   Phom1ki;
Phomkj                  =   Phom1kj;
Rm_DUE                  =   R_DUE;
p0ki                    =  Phomki.*pmki;
p0kj                    =  Phomkj.*pmkj;
%[pm1ki,pm1kj,Rm1_DUE]=SQP_Power_Allocation_Algorithm(Phomki,Phomkj,pmki,pmkj);
[pm1ki,pm1kj,Rm1_DUE,Rm1_DUE_ini]   =   cvx_Power_Allocation_Algorithm(Phomki, Phomkj,p0ki,p0kj);
fprintf(c2,'%1.16f\n',Rm1_DUE_ini);
Rm1_DUE  =  Rm1_DUE  +357.0823
fprintf(c3,'%1.16f\n',Rm1_DUE);
pi_val                  =   pm1ki;
pj_val                  =   pm1kj;

end 
power_control_time=toc
