function [XScaleCorr,YScaleCorr]=corrected_scales(Scale,rotation_angle,lat)

%Berechnung der Skalierung f�r gedrehte Bilder samt
%Korrektur f�r Breitenabh�ngigkeit
alpha=rotation_angle/180*pi;
beta=alpha+pi/2;
latcorrfactor=cos(lat/180*pi);
xfactor=sqrt(latcorrfactor^2*cos(alpha)^2+1^2*sin(alpha)^2);
yfactor=sqrt(latcorrfactor^2*cos(beta)^2 +1^2*sin(beta)^2 );
XScaleCorr=Scale*xfactor;
YScaleCorr=Scale*yfactor;


