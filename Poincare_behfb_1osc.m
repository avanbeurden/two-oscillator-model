%% Poincare model with behavioral feedback 
% 09-08-2022

% Simulate the effect of behavioral feedback and light on the rhythm amplitude in the SCN  

clear all
close all

%% Parameters to set: 

for beh=1:2;    %0=no feedback, 1=night active, 2=day active, 3=always active 
N=1;            %number of oscillators 
N_light=1;      %number of light sensitive neurons 
days=200;       %number of days in simulation
day_length=24;  %day length
light_on=12;    %hours of light during the day 
tp=4;           %time points per hour

% create vectors with time steps 
time=days*day_length;
timesteps=time*tp;
t=linspace(0,time,timesteps);
t2=linspace(0,time,timesteps-1);
%ts=t2*3600;                          %time in seconds 
ts=t*3600;

%% RUN THE MODEL  

for uu=1:9  %take different inputs for L 
for xx=1:41 %take different inputs for B 

%set initial condition: state = [X, Y]
X0=0.95 + (1.05-0.95).*rand(N,1);
Y0=0.95 + (1.05-0.95).*rand(N,1);

dS2=zeros(timesteps-1,2*N); % fill with zeros for speed 

for jj=1:timesteps-1

%run simulation
[tt,dS]=ode45(@(tt,dS) poincaredt_behfb(tt,dS,day_length,N_light,jj,ts,beh,tp,light_on,days,xx,uu), [t(jj),t(jj+1)], [X0,Y0]);

%update initial conditions each timestep
X0=dS(size(dS,1),1:N);
Y0=dS(size(dS,1),N+1:2*N);
dS2(jj,:)=dS(size(dS,1),:);
end 

X=dS2(:,1:N);
Y=dS2(:,N+1:2*N);

%% Analyze signal 

[pks_pop,locs_pop]=findpeaks(mean(X,2));%,'MinPeakHeight',0.5);
trs_pop=findpeaks(-mean(X,2));%,'MinPeakHeight',0.5);

% calculate phase of the peak 
rPhase=locs_pop(numel(locs_pop))/(24*tp);
nPhase=floor(rPhase);
relPhase(xx,uu)=(rPhase-nPhase)*24;

peak_pop(xx,uu)=mean(pks_pop(numel(pks_pop)-10:numel(pks_pop)));
trough_pop(xx,uu)=mean(trs_pop(numel(trs_pop)-10:numel(trs_pop)));

period(xx,uu)=[(locs_pop(numel(locs_pop))-locs_pop((numel(locs_pop))-1))*(1/tp)]


end 
end 

%% Save results
filename='sim1.xlsx';
range='A1';

result=[period(:) peak_pop(:) trough_pop(:) relPhase(:)];
xlswrite(filename,result,beh,range);

clear all
end 
