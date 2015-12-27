function F=ExtendedModelFunction(t,tau,A,B,conv_XScale,conv_Tobs)

%30.1.2014
%ErweiterteModellfunktion: 
%Punktquelle,
%Exponentieller Abfall, 
%Background mit linearem und quadratischem Term,
%Faltung mit Gau?(sigma)

%Diese Funktion ist hier noch universell und kann sowohl mit Ort als auch
%Zeit für x aufgerufen werden. 
%Die Einheit von t bestimmt die Einheiten von
%tau und t0

%attention, tau is actually tau*wind speed here
t_extended=conv_XScale(conv_XScale<2.5*tau&conv_XScale>-2.5*tau);
%t_extended=conv_XScale;
Y1=exp(-t_extended/tau);%Exponential function
Y1(Y1>1)=0; %Eliminates the upwind values>1

%figure;plot(t_extended,Y1);

%extended conv_XScale: append shifted conv_XScale to the left and the right
%copy boundary of conv_Tobs to remove edge effects
%dist=mean(diff(conv_XScale));
%L=length(conv_XScale);
%conv_XScale_extended=[conv_XScale-(L*dist) conv_XScale conv_XScale+(L*dist)];
%conv_Tobs=[ones(1,L)*(sum(conv_Tobs(1:3))/3) conv_Tobs ones(1,L)*(sum(conv_Tobs(length(conv_Tobs)-2:length(conv_Tobs)))/3)];
%Convolution
Y2=conv2(A*conv_Tobs,Y1/sum(Y1),'same');
Y2=Y2+B;
%figure;plot(Y2);


%F=interp1(conv_XScale_extended,Y2,t);
F=interp1(conv_XScale,Y2,t);



