%dynamics of Poincare model
% four different configurations are used
% con. 1: 1 oscillator with both light and behaviour input
% con. 2: 2 oscillators, one the first acts light on the second acts
% behaviour 
% con. 3: 2 oscillators, one the first acts light and behaviour and on the
% second acts only behaviour 
% con. 4: 2 oscillators, one the first acts light and behaviour and on the
% seconds acts neither light or behaviour 
% con. 5: 2 oscillators with both light and behaviour input 

function [dS]=poincaredt_behfb_v3(~,x,day_length,N_light,jj,ts,beh,tp,light_on,days,xx,uu)

%number of oscillators 
N=size(x,1)/2;
x=reshape(x,[N,2]);
F=(1/N)*sum(x(:,1));

for ii=1:N

%parameters 
gamma = 1;
A = 1;
tau = 23.5; 
g=0.1;
a=-0.2:0.05:0.2;
b=-0.2:0.01:0.2;
%b=[-0.1:0.01:-0.01];
%b=[0.01:0.01:0.1];
K=a(uu);
K2=b(xx);
per=24;     % period in hours 

%Create block function for behavioral feedback and light 
light_off=day_length-light_on;
move=ones(light_on*tp,1);
sleep=zeros(light_off*tp,1);
Nocturnal=repmat([sleep;move],days,1);
Diurnal=repmat([move;sleep],days,1);

% Light function
if ii <= N_light
    L=K*Diurnal(jj);
else
    L=0;
end 

% Behavioral feedback function 
if beh==1 && ii<N_light         %night active; con2: && ii>N_light, con3: %&& ... con4: && ii<=N_light
    B=K2*Nocturnal(jj);
elseif beh==2 && ii<N_light     %day active 
    B=K2*Diurnal(jj);
else                              %no activity
    B=0;
end 

% initial conditions 
X=x(ii,1);
Y=x(ii,2);
r=sqrt(X^2+Y^2); 
%G = g*(1+S*mu*d); % for heterogenous coupling strength S=+1/-1, d=5

dX(ii,:) = gamma*X*(A-r)-((2*Y*pi)/(tau))+g*F+L+B;  %(tau*(1+mu))
dY(ii,:) = gamma*Y*(A-r)+((2*X*pi)/(tau));          %(tau*(1+mu))

dS=[dX;dY];

end

end