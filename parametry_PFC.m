%% Blazej Wieczorek
% Sprawozdanie z projektu ukladu PFC
%%
%% Parametry modelu
clear; clc; close all;
warning('off')
L = 2000e-6; %indukcyjnosc cewki
Uz = 230; %wartosc skuteczna;
fz = 50; %czestotliwosc sieci zasilajacej
Rload = 150; %obciazenie ukladu
C = 1000e-6; %pojemnosc ukladu
Rs = 1;
Ls = 10e-6;
Tsc = 1e-6;  %czas probkowania
%% Symulacja i jej wyniki
sim('PFC', 0.2);
time = UI_signals.time;
Us = UI_signals.signals.values(:,1);
Is = UI_signals.signals.values(:,2);
Uo = UI_signals.signals.values(:,3);
iL = UI_signals.signals.values(:,4);
Ud = UI_signals.signals.values(:,5);
figure();
yyaxis left
plot(time, Us);
hold on;
plot(time, Uo, 'k-');
yyaxis right
plot(time, Is);
xlabel('Czas [s]');
ylabel('Prad [A]');
yyaxis left
ylabel('Napiecie [V]');
legend('Napicie sieci','Napiecie wyjsciowe','Prad sieci');
%% Schemat ukladu
figure();
imshow('schemat.png');
figure();
imshow('schemat2.png');
%% Analiza dla roznych wartosci rezystancji wejsciowej sieci
% Przeprowadzono analize napiecia sieci w zaleznosci od rezystancji
% wejsciowej. Dla duzych rezystancji dla wylaczonego ukladu PFC sinusodia
% wykazuje mocne splaszczenie szczytu. Nie wystepuje to dla dzialajacego
% ukladu PFC.
rs = [2, 4, 8, 10];
figure()
for i = 1:length(rs)
    Rs = rs(i);
    sim('PFC', 0.2);
    plot(UI_signals.time, UI_signals.signals.values(:,1)); hold on;
    if i == length(rs)
       xlabel('Czas [s]')
       ylabel('Napiecie [V]');
       legend('Rs = 2','Rs = 4','Rs = 8', 'Rs = 10');
    end
end
Rs = 1;
sim('PFC', 0.2);
%% Analiza FFT dla wylaczonego ukladu PFC
% Wartosc thd otrzymywana w tej analize dotyczy pradu pobieranego przez
% uklad dla czesci przebiegu bez dzialania regulatora PFC.
figure();
t2 = 80e-3;
t1 = t2-20e-3;
rows = find(time>=t1 & time<=t2);
time20 = time(rows);
fs = 1/(time20(2)-time20(1));
x20 = Is(rows);
time20 = (0:length(time20)-1)'/fs;
plot(time20,x20);
xlabel('Czas [s]');
ylabel('Prad [A]');
title('Wycinek pradu do analizy FFT brak PFC');
X_cmplx = fft(x20)/length(x20)*2;
X_cmplx(1) = X_cmplx(1)/2;
N_h = floor(length(X_cmplx)/2)-1;
if N_h > 20
    N_h = 20;
end
X_cmplx = X_cmplx(1:N_h +1);
X = abs(X_cmplx);
d_f = fs/length(x20);
f_h = (0:N_h)'*d_f;
X = X(1:N_h+1);
X = X/sqrt(2);
figure()
bar(f_h/1, X, 'linewidth', 0.1);
xlabel('Czestotliwosc [Hz]');
title('Analiza FFT sygnalu dla wartosci skutecznych bez PFC');
grid on;
Is20rms_OFF_PFC = rms(x20)
thd_OFF_PFC = (100*(sqrt(Is20rms_OFF_PFC^2-(X(2))^2))/(X(2)))
%% Dopuszczalne harmoniczne pradu bez ukladu PFC
% Projektowany uklad znajduje sie w klasie A. Wartosci pradow wyzszych
% harmonicznych sa przekroczone dla ukladu z wylaczonym modulem PFC.
% Przekroczenie wystepuje dla 3, 5 oraz 7 harmonicznej. Wartosci zostaly przeskalowane do wartosci
% skutecznych kazdej harmonicznej.
figure();
imshow('harmoniczne.png');
disp('Numer harmonicznej - Wartosc skuteczna harmonicznej');
disp([(0:20)', X]);
%% Analiza FFT pradu dla dzialajacego ukladu PFC
% Wartosc thd otrzymywana w tej analize dotyczy pradu pobieranego przez
% uklad dla czesci przebiegu z dzialajacym PFC.
figure();
t2 = 180e-3;
t1 = t2-20e-3;
rows = find(time>=t1 & time<=t2);
time20 = time(rows);
fs = 1/(time20(2)-time20(1));
x20 = Is(rows);
time20 = (0:length(time20)-1)'/fs;
plot(time20,x20);
xlabel('Czas [s]');
ylabel('Prad [A]');
title('Wycinek pradu do analizy FFT z PFC');
X_cmplx = fft(x20)/length(x20)*2;
X_cmplx(1) = X_cmplx(1)/2;
N_h = floor(length(X_cmplx)/2)-1;
if N_h > 20
    N_h = 20;
end
X_cmplx = X_cmplx(1:N_h +1);
X = abs(X_cmplx);
d_f = fs/length(x20);
f_h = (0:N_h)'*d_f;
X = X(1:N_h+1);
X = X/sqrt(2);
figure()
bar(f_h/1, X, 'linewidth', 0.1);
xlabel('Czestotliwosc [Hz]');
title('Analiza FFT sygnalu dla wartosci skutecznych z PFC');
grid on;
Is20rms = rms(x20)
thd = (100*(sqrt(Is20rms^2-(X(2))^2))/(X(2)))
%% Dopuszczalne harmoniczne pradu podczas pracy ukladu PFC
% Zadna harmoniczna pradu nie przekracza wartosci dopuszczalnej wymienionej
% w ponizszej tabeli. Wartosci zostaly przeskalowane do wartosci
% skutecznych kazdej harmonicznej
figure();
imshow('harmoniczne.png');
disp('Numer harmonicznej ---- Wartosc skuteczna harmonicznej');
disp([(0:20)', X]);
%% Analiza FFT napiecia zasilania
% W tym punkcie zostanie przeprowadzona analiza FFT napiecia sieci dla
% ukladu podczas pracy modulatora PFC oraz bez niej. Do tego zostanie
% sprawdzona zgodnosc z norma dla pracy z oraz bez regulatora.
figure();
t2 = 180e-3;
t1 = t2-20e-3;
rows = find(time>=t1 & time<=t2);
time20 = time(rows);
fs = 1/(time20(2)-time20(1));
x20 = Us(rows);
time20 = (0:length(time20)-1)'/fs;
plot(time20,x20);
xlabel('Czas [s]');
ylabel('Napiecie [V]');
title('Wycinek napiecia do analizy FFT z PFC');
X_cmplx = fft(x20)/length(x20)*2;
X_cmplx(1) = X_cmplx(1)/2;
N_h = floor(length(X_cmplx)/2)-1;
if N_h > 20
    N_h = 20;
end
X_cmplx = X_cmplx(1:N_h +1);
X = abs(X_cmplx);
d_f = fs/length(x20);
f_h = (0:N_h)'*d_f;
X = X(1:N_h+1);
X = X/sqrt(2);
figure()
bar(f_h/1, X, 'linewidth', 0.1);
xlabel('Czestotliwosc [Hz]');
title('Analiza FFT sygnalu dla wartosci skutecznych z PFC');
grid on;
Us20rms = rms(x20)
thd = (100*(sqrt(Us20rms^2-(X(2))^2))/(X(2)))

figure();
t2 = 80e-3;
t1 = t2-20e-3;
rows = find(time>=t1 & time<=t2);
time20 = time(rows);
fs = 1/(time20(2)-time20(1));
x20 = Us(rows);
time20 = (0:length(time20)-1)'/fs;
plot(time20,x20);
xlabel('Czas [s]');
ylabel('Napiecie [V]');
title('Wycinek napiecia do analizy FFT z PFC');
X_cmplx = fft(x20)/length(x20)*2;
X_cmplx(1) = X_cmplx(1)/2;
N_h = floor(length(X_cmplx)/2)-1;
if N_h > 20
    N_h = 20;
end
X_cmplx = X_cmplx(1:N_h +1);
X = abs(X_cmplx);
d_f = fs/length(x20);
f_h = (0:N_h)'*d_f;
X = X(1:N_h+1);
X = X/sqrt(2);
figure()
bar(f_h/1, X, 'linewidth', 0.1);
xlabel('Czestotliwosc [Hz]');
title('Analiza FFT sygnalu dla wartosci skutecznych z PFC');
grid on;
Us20rms = rms(x20)
thd_PFC_OFF = (100*(sqrt(Us20rms^2-(X(2))^2))/(X(2)))
if thd_PFC_OFF > 8
    disp('Wartosc thd napiecia przy braku dzialania PFC nie spelnia wymagan normy');
else
    disp('Wartosc thd napiecia przy braku dzialania PFC spelnia wymagania normy');
end

if thd > 8
    disp('Wartosc thd napiecia podczas dzialania PFC nie spelnia wymagan normy');
else
    disp('Wartosc thd napiecia podczas dzialania PFC spelnia wymagania normy');
end


