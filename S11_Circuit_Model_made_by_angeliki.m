%Phase measurements - coax cable

f_begin = 1e6;
f_end = 1e9;
f_step = (f_end-f_begin)/1000;

f = linspace(f_begin, f_end, f_step);
w = 2*pi.*f;

l =0e-2; %Coax length
C= 33e-12 ; %[C]=F capacitor of the circuit
L= 5e-9; %Inductor of the circuit
Cp = 100e-12; %capacitance per unit length of coax
Lp = 250e-9; %inductance per unit length of coax
Uf = 1/(sqrt(Cp*Lp)); %phase velocity

%Mutual indictance


Zo = 50; %[Ro]=Ohm - RF source
Zc = 1 ./ (1i * C .* w);%sample
ZL = 1i .* w * L; %Inductance

%L and C in series
Z_series = Zc + ZL;

%L and C in parallel
Z_parallel = (Zc.*ZL)./((Zc+ZL));

Z_total =  Zo + Z_series;
Z_total_p = Zo + Z_parallel ;
%........................................................
%R in series with C and RC in parallel with L
R=1.7;
ZRC = R+Zc;
Ztol_A = ((ZRC.*ZL)./(ZRC+ZL));
S11_A = ((Ztol_A-Zo)./(Ztol_A+Zo)).*exp((-2*1i.*w*l)/Uf);
S11_mag_A = abs(S11_A);
S11_db_A = 20*log10(S11_mag_A);
figure(5);
plot(f,S11_db_A,'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('|S_{11}|');
ylim([-12 2]);
title('Magnitude of S_{11} db, L and C in parallel');
grid on;

% R2=10;
% ZRC2 = R2+Zc;
% Ztol_A2 = ((ZRC2.*ZL)./(ZRC+ZL));
% S11_A2 = ((Ztol_A2-Zo)./(Ztol_A2+Zo)).*exp((-2*1i.*w*l)/Uf);
% S11_mag_A2 = abs(S11_A2);
% S11_db_A2 = 20*log10(S11_mag_A2);
% figure(6);
% plot(f,S11_db_A2,'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|S_{11}|');
% ylim([-20 2]);
% title('Magnitude of S_{11} db, L and C in parallel');
% grid on;
% % %........................................................
% % %R in series with L and RC in parallel with L
% R=1.3;
% ZRL = R+ZL;
% Ztol_B = ((ZRL.*Zc)./(ZRL+Zc));
% S11_B = ((Ztol_B-Zo)./(Ztol_B+Zo)).*exp((-2*1i.*w*l)/Uf);
% S11_mag_B = abs(S11_B);
% S11_db_B = 20*log10(S11_mag_B);
% figure(6);
% plot(f,S11_db_B,'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|S_{11}|');
% ylim([-20 20]);
% title('Magnitude of S_{11} db, L and C in parallel');
% grid on;
% % %.......................................................
% % %R in parallel with C and RC in parallel with L
% R=100;
% ZRL = ((R.*ZL)./(R+ZL));
% Z_tol_C = ((ZRL.*Zc)./(ZRL+Zc));
% S11_C = ((Z_tol_C-Zo)./(Z_tol_C+Zo)).*exp((-2*1i.*w*l)/Uf);
% S11_mag_C = abs(S11_C);
% S11_db_C = 20*log10(S11_mag_C);
% figure(7);
% plot(f,S11_db_C,'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|S_{11}|');
% ylim([-20 20]);
% title('Magnitude of S_{11} db, L and C in parallel');
% grid on;
% % %.........................................................
% 
% %R in parallel with with C and L 
% R=5;
% Z_parallel = (Zc.*ZL)./((Zc+ZL))
% Z_tol_D = R + Z_parallel;
% S11_D = ((Z_tol_D-Zo)./(Z_tol_D+Zo)).*exp((-2*1i.*w*l)/Uf);
% S11_mag_D = abs(S11_D);
% S11_db_D = 20*log10(S11_mag_D);
% figure(8);
% plot(f,S11_db_D,'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|S_{11}|');
% ylim([-20 20]);
% title('Magnitude of S_{11} db, L and C in parallel');
% grid on;
%.........................................................




% %S11 in L and c in series
% S11 = ((Z_series-Zo)./(Z_series+Zo)).*exp((-2*1i.*w*l)/Uf);
% phi_S11 = angle(S11)/pi;
% Vout = Z_series./Z_total;
% Vout_p = Z_parallel./Z_total_p;
% 
% 
% figure(1);
% subplot(3,1,1);
% plot(f,abs(S11),'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|S_{11}|');
% title('Magnitude of S_{11}, L and C in series');
% grid on;
% 
% 
% subplot(3,1,2);
% plot(f,abs(Vout),'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|Vout/Vin|');
% title('Magnitude of Vout/Vin, L and C in series');
% grid on;
% 
% subplot(3,1,3);   % 2 rows, 1 column, second plot
% plot(f, phi_S11, 'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('Phase(S_{11}) [rad/pi]');
% title('Phase of S_{11},L and C in series');
% grid on;
% 
% % 
% % 
% % %S11 in L and c in parallel
% S11_p = ((Z_parallel-Zo)./(Z_parallel+Zo)).*exp((-2*1i.*w*l)/Uf);
% phi_S11_p = angle(S11_p)/pi;
% 
% S11_mag = abs(S11_p);
% S11_db = 20*log10(S11_mag);
% 
% figure(2)
% subplot(3,1,1);
% plot(f,abs(S11_p),'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|S_{11}|');
% title('Magnitude of S_{11}, L and C in parallel');
% grid on;
% 
% subplot(3,1,3);   % 2 rows, 1 column, second plot
% plot(f, phi_S11_p, 'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('Phase(S_{11}) [rad/pi]');
% title('Phase of S_{11}, L and C in parallel');
% grid on;
% 
% subplot(3,1,2);
% plot(f,abs(Vout_p),'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|Vout/Vin|');
% title('Magnitude of Vout/Vin, L and C in parallel');
% grid on;
% 
% figure(4);
% 
% plot(f,S11_db,'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('|S_{11}|');
% ylim([-20 20]);
% title('Magnitude of S_{11} db, L and C in parallel');
% grid on;
