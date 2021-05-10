%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Delay-feedback Reservoir (DFR)
%   Modified by Kangjun
%   Department of Electrical and Computer Engineering
%   Virginia Tech
%   Last modify at 06/20/2019
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%	Reset the environment

clc
close all;
clear all;


%%	Configure the property of figures

format long 
set(gcf, 'DefaultFigureColor', [0.5 0.5 0.5]);
set(gcf, 'DefaultAxesFontSize', 22);
set(gca, 'FontWeight', 'bold')
set(gcf, 'DefaultAxesLineWidth', 2);
set(gcf, 'Position', [50 500 560*1.2 420*1.2]);
set(gca, 'xtick',[])
set(gca, 'ytick',[])


%%	Import dataset

% 10th order nonlinear auto-regressive moving average (NARMA10)
seed = 50;
[data, target] = narma10_create(10000, seed);

% FPGA Scale


bitSize = 8;
outputScale = 2^(2 * bitSize - 1);
inputScale = 2^(bitSize - 1);
xadcScale = 2^12;

minM = 0;
maxM = 2^(bitSize - 2);

target = round( outputScale * target );
data = round( inputScale * data );

mackey_glass_matrix = get_mackey_glass_matrix();

%%	Reservoir Parameters

% Tp        = sample/hold time frame for input (length of input mask)
% N         = number of virtual nodes in the reservoir (must equal to Tp)
% theta     = distance between virtual nodes
% gamma     = input gain
% eta       = feedback gain (leaking rate)
% initLen	= number of samples used in initialization
% trainLen	= number of samples used in training
% testLen	= number of samples used in testing

Tp          = 100;
N           = Tp;
theta       = Tp / N;
gamma       = 0.99;
eta         = 1 - gamma;
initLen     = 500;
trainLen	= 5500;
testLen     = 500;


%%  Define the masking (input weight, choose one of the followings)

% Random Uniform [-1, 1]
% M = rand(Tp, 1) * 2 - 1;

% Random Uniform [0, 1]
M = rand(Tp, 1);

% Random Uniform [0, 65536]
%M = rand(Tp, 1) * 65536;

% Random from group [-0.1, +0.1]

% Random normal
% M = randn(Tp, 1) * 1;

% Constant
% M = ones(Tp, 1) * 0.5;
% M = ones(Tp, 1) * 65536;
% M = ones(Tp, 1);

% Linearly cover [-1, 1]
% M = linspace(-1, 1, Tp);

% Linearly cover, with added random perturbation
% M = linspace(-1, 1, Tp);
% M = M + randn(size(M)) * 0.05;


%%  (Training) Initialization of reservoir dynamics

% nodeC     = reservoir dynamic at the current cycle
% nodeN     = reservoir dynamic at the next cycle
% nodeE     = reservoir dynamic at every timestep during training
% nodeTR    = a snapshot of all node states at each full rotation through 
%             the reservoir during training

nodeC   = zeros(N, 1);
nodeN   = zeros(N, 1);
nodeE	= zeros(N , trainLen * Tp);
nodeTR	= zeros(N , trainLen);


%%  (Training) Apply masking to training data

inputTR = [];

for k = 1:(initLen + trainLen)
    uTR = data(k);
    inputTR = [inputTR; round(M * uTR)];
end


%%  (Training) Initialize the reservoir layer

% No need to store these values since they won't be used in training

for k = 1:(initLen * Tp)
    % Compute the new input data for initialization
    % initJTR = round( (gamma * inputTR(k)) + (eta * nodeC(N)) );
    initJTR = round(inputTR(k) +  nodeC(N) / 128);
    
    % Activation
    nodeN(1)	= round( inputScale * mackey_glass(initJTR,minM,maxM,mackey_glass_matrix) / xadcScale );   
    nodeN(2:N)  = nodeC(1:(N - 1));
    
    % Update the current node state
    nodeC       = nodeN;
end


%%	(Training) Run data through the reservoir

for k = 1:(trainLen * Tp)
    % Define the time step that starts storing node states
    t = initLen * Tp + k;
    
    % Compute the new input data for training
    % trainJ = round( (gamma * inputTR(t)) + (eta * nodeC(N)) );
    trainJ = round(inputTR(k) +  nodeC(N) / 128);
    
    % Activation
    nodeN(1)	= round( inputScale * mackey_glass(trainJ,minM,maxM,mackey_glass_matrix) / xadcScale );	
	nodeN(2:N)  = nodeC(1:(N - 1));
    
    % Update the current node state
    nodeC       = nodeN;
    
    % Updete all node states
    nodeE(:, k) = nodeC;
end

% Consider the data just once everytime it loops around
nodeTR(:, (1:trainLen)) = nodeE(:, (Tp * (1:trainLen)));


%%  Train output weights using ridge regression

% Define the regularization coefficient
regC = 1e-8;

% Call-out the target outputs
Yt = target((initLen + 1):(initLen + trainLen));


% Transpose nodeR for matrix claculation
nodeTR_T = nodeTR';

% Calculate output weights
% TODO: Convert this for simple FPGA logic
% Wout = (Yt * nodeTR_T) / (nodeTR * nodeTR_T);
% Wout = (Yt * nodeTR_T) / ((nodeTR * nodeTR_T) + (regC * eye(N)));

% Backprop
Wout = zeros(1,Tp);
for rates = 32:34
    Wout = rand(1,Tp) * 2^3;
    learningRate = 1 / (2^rates);
    for epoch = 1:100
        delta_Wout = zeros(1,Tp);
        for weight_idx = 1:Tp
             delta_Wout(weight_idx) = learningRate * sum( (Yt - (Wout * nodeTR)) * nodeTR(weight_idx)) / trainLen;
        end
        Wout = Wout - delta_Wout;

    end
    
    mseTR = (norm( (Yt - (Wout * nodeTR)) / outputScale , 2)^2) / trainLen;
    fprintf('training MSE     = %e \n', mseTR)    
end

%%  Compute training error

% Claculate the MSE through L2 norm
mseTR = (norm( (Yt - (Wout * nodeTR)) / outputScale , 2)^2) / trainLen;

% Calculate the NMSE
nmseTR = (norm(Yt - (Wout * nodeTR)) / norm(Yt))^2;


disp('--------------------------------------------------')
disp('Training Errors')
fprintf('training MSE     = %e \n', mseTR)
fprintf('training NMSE    = %e \n', nmseTR)


%% (Testing) Initialize the reservoir layer

% nodeC     = reservoir dynamic at the current cycle
% nodeN     = reservoir dynamic at the next cycle
% nodeE     = reservoir dynamic at every timestep during training
% nodeTS    = a snapshot of all node states at each full rotation through 
%             the reservoir during testing

nodeC   = zeros(N, 1);
nodeN   = zeros(N, 1);
nodeE	= zeros(N , testLen * Tp);
nodeTS  = zeros(N , testLen);


%%  (Testing) Apply masking to input testing data

inputTS = [];

for k = 1:(initLen + testLen)
    uTS = data(initLen + trainLen + k);
    inputTS = [inputTS; round(M * uTS)];
end


%% (Testing) Initialize the reservoir layer

% No need to store these values since they won't be used in testing

for k = 1:(testLen * Tp)
    % Compute the new input data for initialization during testing
    %initJTS = round( (gamma * inputTS(k)) + (eta * nodeC(N)) );
    initJTS = round(inputTS(k) +  nodeC(N) / 128);
    
    % Activation
    nodeN(1)	= round( inputScale * mackey_glass(initJTS,minM,maxM,mackey_glass_matrix) / xadcScale );	   
    nodeN(2:N)  = nodeC(1:(N - 1));
    
    % Update the current node state
    nodeC       = nodeN;
end


%%  (Testing) Run data through the reservoir

for k = 1:(testLen * Tp)
    % Define the time step that starts storing node states
    t = initLen * Tp + k;
    
    % Compute the new input data for training
    %testJ = round( (gamma * inputTS(t)) + (eta * nodeC(N)) );
    testJ = round(inputTS(k) + nodeC(N) / 128);
    
    % Activation
    nodeN(1)	= round( inputScale * mackey_glass(testJ,minM,maxM,mackey_glass_matrix) / xadcScale );	
	nodeN(2:N)  = nodeC(1:(N - 1));
    
    % Update the current node state
    nodeC       = nodeN;
    
    % Updete all node states
    nodeE(:, k) = nodeC;
end

% Consider the data just once everytime it loops around
nodeTS(:, (1:testLen)) = nodeE(:, (Tp * (1:testLen)));


%%  Compute testing errors

% Call-out the target outputs
Ytest = target(initLen + trainLen + 1: initLen + trainLen + testLen);

% Claculate the MSE through L2 norm
mse_testing = (norm( (Ytest - Wout * nodeTS) / outputScale )^2) / testLen;

% Calculate the NMSE
nmse_testing = (norm(Ytest - Wout * nodeTS) / norm(Ytest))^2;


disp('--------------------------------------------------')
disp('Testing Errors')
fprintf('Testing MSE     = %e \n',  mse_testing)
fprintf('Testing NMSE    = %e \n', nmse_testing)


%%  Compare actual outputs and target outputs

plot(Ytest, '-')
hold on
plot(Wout * nodeTS, '--')
hold off
grid on
ylabel('Sampled Value')
xlabel('#')
legend('target output', 'predicted output')
