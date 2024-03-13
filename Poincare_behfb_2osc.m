%% Poincare model with behavioral feedback 
% 09-08-2022

% Simulate the effect of behavioral feedback and light on the rhythm amplitude in the SCN  

clear all
close all

%% Parameters to set: 

for beh=1;      %0=no feedback, 1=night active, 2=day active, 3=always active 
N=2;            %number of oscillators 
N_light=2;      %number of light sensitive neurons 
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

for uu=1:9  %take different values for L 
for xx=1:41 %take different values for B 

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


%% Figure of resulting oscillations 

% figure;
% set(gca,'fontsize',14)
% plot(t2/24,X(:,1))
% hold on
% plot(t2/24,Y(:,1))
% %plot(t2/24,mean(Y,2))
% %plot(t2/24,mean(X,2))
% fill([195 195.5 195.5 195],[1.5 1.5 1.6 1.6],'y')
% fill([196 196.5 196.5 196],[1.5 1.5 1.6 1.6],'y')
% fill([197 197.5 197.5 197],[1.5 1.5 1.6 1.6],'y')
% fill([198 198.5 198.5 198],[1.5 1.5 1.6 1.6],'y')
% fill([199 199.5 199.5 199],[1.5 1.5 1.6 1.6],'y')
% yline(0,'--');
% xlabel('Time (days)')
% ylabel('Concentration (arbitrary units)')
% legend('Oscillator 1','Oscillator 2')
% xlim([195 200])
% xticks([495 496 497 498 499 500])


%% Analyze signal 
[pks1,locs1]=findpeaks(X(:,1));%,'MinPeakHeight',0.5);
[pks2,locs2]=findpeaks(X(:,2));
trs1=findpeaks(-X(:,1));%,'MinPeakHeight',0.5);
trs2=findpeaks(-X(:,2));

[pks_pop,locs_pop]=findpeaks(mean(X,2));%,'MinPeakHeight',0.5);
trs_pop=findpeaks(-mean(X,2));%,'MinPeakHeight',0.5);

% calculate phase of the peak 
rPhase=locs_pop(numel(locs_pop))/(24*tp);
nPhase=floor(rPhase);
relPhase(xx,uu)=(rPhase-nPhase)*24;

rPhase1=locs1(numel(locs1))/(24*tp);
nPhase1=floor(rPhase1);
relPhase1(xx,uu)=(rPhase1-nPhase1)*24;

rPhase2=locs2(numel(locs2))/(24*tp);
nPhase2=floor(rPhase2);
relPhase2(xx,uu)=(rPhase2-nPhase2)*24;

peak1(xx,uu)=mean(pks1(numel(pks1)-10:numel(pks1))); % take average of last 10 peaks 
peak2(xx,uu)=mean(pks2(numel(pks2)-10:numel(pks2)));
peak_pop(xx,uu)=mean(pks_pop(numel(pks_pop)-10:numel(pks_pop)));

trough1(xx,uu)=mean(trs1(numel(trs1)-10:numel(trs1)));
trough2(xx,uu)=mean(trs2(numel(trs2)-10:numel(trs2)));
trough_pop(xx,uu)=mean(trs_pop(numel(trs_pop)-10:numel(trs_pop)));

period1(xx,uu)=[(locs1(numel(locs1))-locs1((numel(locs1))-1))*(1/tp)]
period2(xx,uu)=[(locs2(numel(locs2))-locs2((numel(locs2))-1))*(1/tp)]

end 
end 

%% Save results
filename='sim.xlsx';
range='A1';

result=[period1(:) period2(:) peak_pop(:) peak1(:) peak2(:) trough_pop(:) trough1(:) trough2(:) relPhase(:) relPhase1(:) relPhase2(:)];
xlswrite(filename,result,beh,range);

clear all
end 
