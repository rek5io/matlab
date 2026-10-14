clear; clc; close all;

% 1. Parametry fizyczne materiałów
cpp = 1000;   % Ciepło właściwe powietrza [J/(kg*K)]
rhop = 1.2;   % Gęstość powietrza [kg/m^3]
cpo = 2400;   % Ciepło właściwe oleju [J/(kg*K)]
rhoo = 1200;  % Gęstość oleju [kg/m^3]
t_on_g = 600 % Ton grzałki
t_off_g = 3600 * 1 % Toff grzałki

% 2. Objętości
Vw = 2.5 * 10;       % Objętość pomieszczenia [m^3] (2.5m * 10m^2)
Vg = 10 / 1000;      % Objętość grzejnika [m^3] (10 litrów)

% 3. Pojemności cieplne
Cvw = cpp * rhop * Vw;   % Pojemność cieplna pomieszczenia [J/K]
Cvg = cpo * rhoo * Vg;   % Pojemność cieplna grzejnika [J/K]

% 4. init
TzewN = -20;  % Temperatura zewnętrzna [°C]
TwewN = 20;   % Temperatura wewnątrz [°C]
TgN = 30;     % Temperatura grzejnika [°C]
PgN = 1500;   % Moc nominalna grzejnika [W]

% Przepływ powietrza wentylacyjnego (np. 6 wymian na godzinę)
fp = (0 * Vw) / 3600;

% 5. Identyfikacja współczynników strat ciepła
%K1 = (PgN - cpp * rhop * fp * (TwewN - TzewN)) / (TwewN - TzewN);
%Kg = PgN / (TgN - TwewN);
%K1 = PgN / (TwewN - TzewN);
Kg = 150 % [W/K]
K1 = 40

% 6. Konfiguracja czasu symulacji i kroku pętli
dt = 1;            % Krok czasowy [s]
czas_max = 3600 * 4;  % Czas całkowity [s] (4 godziny)
t = 0:dt:czas_max; % Wektor czasu
N = length(t);

% Inicjalizacja wektorów wyników
Tg = zeros(1, N);
Twew = zeros(1, N);
Pg_history = zeros(1, N);

% Warunki początkowe (stan równowagi)
Tg(1) = TgN;
Twew(1) = TwewN;

for i = 1:(N-1)
    if t(i) >= t_on_g && t(i) <= t_off_g
        Pg = PgN;
    else
        Pg = 0;
    end
    
    Pg_history(i) = Pg;

    % Pochodne (równania różniczkowe)
    dTg_dt = (1 / Cvg) * (Pg - Kg * (Tg(i) - Twew(i)));
    dTwew_dt = (1 / Cvw) * (Kg * (Tg(i) - Twew(i)) - K1 * (Twew(i) - TzewN) - cpp * rhop * fp * (Twew(i) - TzewN));

    % Wyznaczenie wartości w kolejnym kroku czasowym (Euler)
    Tg(i+1) = Tg(i) + dTg_dt * dt;
    Twew(i+1) = Twew(i) + dTwew_dt * dt;
end
Pg_history(N) = Pg_history(N-1); % domknięcie ostatniego punktu mocy

% Przeliczenie czasu na minuty
t_min = t / 60;

% 8. Wykres mocy
figure('Theme', 'light');
plot(t_min, Pg_history, 'm-', 'LineWidth', 1.5);
grid on;
title('Impuls mocy grzejnika P_g');
xlabel('Czas [min]');
ylabel('Moc [W]');
ylim([-200, 2800]);

% 9. Wykres temperatur
figure('Theme', 'light');
plot(t_min, Tg, 'r-', 'LineWidth', 1.5);
hold on;
plot(t_min, Twew, 'b-', 'LineWidth', 1.5);
grid on;
title('Wzrost i spadek temperatur w układzie (pętla for)');
xlabel('Czas [min]');
ylabel('Temperatura [°C]');
legend('Temperatura grzejnika T_g', 'Temperatura wewnątrz T_{wew}', 'Location', 'Southeast');