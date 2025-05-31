%%  Progetto finale 
%   Modello del carroponte: analisi e progetto del controllore
%   Stefano Milantoni

% Per salvare tutto il workspace del codice eseguito
% save('Workspace_progetto.mat')
% Per caricare il workspace già rannato precedentemente e funzionante
% load('Workspace_progetto.mat') 

%% Impostazioni iniziali
clear; 
close all;
clc;

%% Parametri del sistema
% Parametri 
mm = 1000;  % massa carico [kg]
mc = 300;   % massa carrello [kg]
cm = 100;   % coefficiente attrito carico [N/(m/s)]
cc = 5e3;   % coefficiente attrito carrello [N/(m/s)]
L = 2.5;    % Lunghezza cavo rigido [m]
g = 9.81;   % Accelerazione di gravità [m/s^2]

% Tempo di simulazione
dt = 0.01;        % Tempo di campionamento [s]
tempo = 0:dt:30;  % Vettore tempo di simulazione [s]

% Definizione delle condizioni iniziali per gli stati del sistema:

% Inizializzazione Stato
alpha_0 = 80 * pi/180;      % Condizione iniziale alpha [rad]
alpha_dot_0 = 0;            % Condizione iniziale velocità angolare [rad/s]
xc_0 = 0;                   % Condizione iniziale posizione carrello [m]
xc_dot_0 = 0;               % Condizione iniziale velocità carrello [m/s]

% Inizializzazione Stato all'equilibrio
alpha_0_eq = pi/2;   % Condizione iniziale alpha
alpha_dot_0_eq = 0;  % Condizione iniziale velocità angolare
xc_0_eq = 0;         % Condizione iniziale posizione carrello
xc_dot_0_eq = 0;     % Condizione iniziale velocità carrello

i = sqrt(-1);

%% Modello carroponte non lineare
% Creazione e simulazione del modello non lineare con Simulink
simOut_non_lin = sim("Modello_carroponte_non_lin.slx");
% Grafici di xc_out e alpha_out del modello non lineare
figure(1)
plot(simOut_non_lin.tout, simOut_non_lin.alpha, 'LineWidth',2, 'Color','red');
hold on;
alpha_inf = simOut_non_lin.alpha(end);
yline(alpha_inf, 'LineWidth',1.5, 'Color','yellow', 'LineStyle', '--');
grid on;
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title(sprintf('Modello non lineare \nPosizione angolare carico'));
legend('Andamento posizione angolare', 'Posizione angolare finale');

figure(2)
plot(simOut_non_lin.tout, simOut_non_lin.xc, 'LineWidth',2, 'Color','blu');
hold on;
xc_inf = simOut_non_lin.xc(end);
yline(xc_inf, 'LineWidth',1.5, 'Color','cyan', 'LineStyle', '--');
grid on;
xlabel('Tempo [s]');
ylabel('Posizione carello [m]');
title(sprintf('Modello non lineare \nPosizione lineare carrello'));
legend('Andamento posizione carrello', 'Posizione carrello finale');

%% Linearizzazione del modello del carroponte
% Creazione e simulazione del modello linearizzato con Simulink
% Linearizzazione a T = 10
simOut_linearizzato = sim("Modello_carroponte_lineare.slx");

% Estraggo le matrici (A, B, C, D) del sistema linearizzato
A = Modello_carroponte_lineare_Timed_Based_Linearization.a;
B = Modello_carroponte_lineare_Timed_Based_Linearization.b;
C = Modello_carroponte_lineare_Timed_Based_Linearization.c;
D = Modello_carroponte_lineare_Timed_Based_Linearization.d;

% Grafici di xc_out e alpha_out del modello linearizzato
figure(3)
plot(simOut_linearizzato.tout, simOut_linearizzato.alpha_sim, 'LineWidth',2, 'Color','red');
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title(sprintf('Modello linearizzato \nPosizione angolare carico'));
ylim([1.4 1.7]);
grid on;
text(1,1.58, '90°', 'Color','r','FontSize',12, 'FontWeight','bold');

figure(4)
plot(simOut_linearizzato.tout, simOut_linearizzato.xc_sim, 'LineWidth',2, 'Color','blu');
xlabel('Tempo [s]');
ylabel('Posizione carello [m]');
title(sprintf('Modello linearizzato \nPosizione lineare carrello'));
grid on;
ylim([-1 2]);
text(1,0.1, '0 m', 'Color','blu','FontSize',12, 'FontWeight','bold');

%% Definizione delle funzioni di trasferimento
sys = ss(A, B, C, D);
G = tf(sys); % Funzione di trasferimento totale

% Funzione di Trasferimento alpha: input Fc -> posizione angolare
Ga = G(1,1);
disp('Funzione di trasferimento G_alpha(s): ');
zpk(Ga)         % Visualizzo nella command window la F.d.T G_alpha

% Funzione di Trasferimento xc: input Fc -> posizione lineare carrello
Gxc = G(2,1);
disp('Funzione di trasferimento G_xc(s): ');
zpk(Gxc)        % Visualizzo nella command window la F.d.T G_xc

% Digramma di Bode per Galpha e Gxc
figure(5)
bode(Ga, 'r');
grid on;
title(sprintf('Diagramma di Bode G_{alpha}(s)'));

figure(6)
bode(Gxc);
grid on;
title(sprintf('Diagramma di Bode G_{xc}(s)'));

%% Poli e zeri del sistema
% Stampa dei poli e zeri di G_alpha
[z_Ga, p_Ga, k_Ga] = zpkdata(Ga,"v");
fprintf('Zero della Ga: \n');
disp(z_Ga);
fprintf('Polo della Ga: \n');
disp(p_Ga);

% Mappa poli e zeri di G_alpha
figure(7)
pzmap(Ga);
grid on;
title('Mappa dei poli e zeri di G_{alpha}(s)');
for j = 1:length(p_Ga)
    text(real(p_Ga(j))+0.1, imag(p_Ga(j)), ['p' num2str(j)], ...
        'Color','r','FontSize',12, 'FontWeight','bold');
end
for j = 1:length(z_Ga)
    text(real(z_Ga(j))+0.1, imag(z_Ga(j)), ['z' num2str(j)], ...
        'Color','#EDB120','FontSize',12, 'FontWeight','bold');
end

% Stampa dei poli e zeri di G_xc
[z_Gxc, p_Gxc, k_Gxc]= zpkdata(Gxc,"v");
fprintf('Zeri della Gxc: \n');
disp(z_Gxc);
fprintf('Poli della Gxc: \n');
disp(p_Gxc);

% Mappa poli e zeri di G_xc
figure(8)
pzmap(Gxc);
grid on;
title('Mappa dei poli e zeri di G_{xc}(s)');
for j = 1:length(p_Gxc)
    text(real(p_Gxc(j)-0.2), imag(p_Gxc(j)+0.15i), ['p' num2str(j)], ...
        'Color','r','FontSize',12, 'FontWeight','bold');
end
for j = 1:length(z_Gxc)
    text(real(z_Gxc(j))+0.1, imag(z_Gxc(j)), ['z' num2str(j)], ...
        'Color','#EDB120','FontSize',12, 'FontWeight','bold');
end

%% Progettazione sistema di controllo del modello Carroponte 
% Usiamo il sistema non linerae con le condizioni inziali e lo
% linearizziamo a T = 25 s, istante in cui i transitori sono esauriti

%% Task 0: Progetto controllo in anello aperto 
% Creazione e simulazione del controllo in anello aperto con Simulink
simOut_controllo_OL = sim("Controllo_modello_OL.slx");

% Grafici di xc_out e alpha_out del controllo in anello aperto
% Risposta libera
figure(9)
plot(simOut_controllo_OL.alpha_libero.time, ...
    simOut_controllo_OL.alpha_libero.signals.values, 'LineWidth',2, 'Color','red');
hold on;
rif_alpha0_l = simOut_controllo_OL.riferimento_alpha_libero.signals.values ...
                * ones(size(simOut_controllo_OL.alpha_libero.time));
plot(simOut_controllo_OL.alpha_libero.time, ...
    rif_alpha0_l, 'LineWidth',1, 'Color','yellow', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title(sprintf('Controllo posizione angolare carico \nIn anello aperto con Fc = 0'));
grid on;
legend('alpha_{out}', 'Posizione angolare finale');

figure(10)
plot(simOut_controllo_OL.xc_libero.time, ...
    simOut_controllo_OL.xc_libero.signals.values, 'LineWidth',2, 'Color','blu');
hold on;
rif_fc = simOut_controllo_OL.riferimento_libero.signals.values ...
                * ones(size(simOut_controllo_OL.xc_libero.time));
plot(simOut_controllo_OL.xc_libero.time, ...
    rif_fc, 'LineWidth',1, 'Color','cyan', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione carrello [m]');
title(sprintf('Controllo posizione lineare carrello \nIn anello aperto con Fc = 0'));
grid on;
legend('xc_{out}', 'Posizione carrello finale');

% Risposta forzata 
% Gli output dipendono da quale tipologia di forza Fc
% è stata selezionata nello schema di Simulink se un gradino oppure una sinusoide
% e dalla tipologia di parametri che li caratterizzano.
figure(11)
plot(simOut_controllo_OL.alpha_forzato.time, ...
    simOut_controllo_OL.alpha_forzato.signals.values, ...
    'LineWidth',2, 'Color','red');
hold on;
rif_alpha0_f = simOut_controllo_OL.riferimento_alpha_forzato.signals.values ...
                * ones(size(simOut_controllo_OL.alpha_forzato.time));
plot(simOut_controllo_OL.alpha_forzato.time, ...
    rif_alpha0_f, 'LineWidth',1, 'Color','yellow', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title(sprintf('Controllo posizione angolare carico \nIn anello aperto con Fc forzato'));
grid on;
legend('alpha_{out}', 'Posizione angolare finale');

figure(12)
plot(simOut_controllo_OL.xc_forzato.time, ...
    simOut_controllo_OL.xc_forzato.signals.values, ...
    'LineWidth',2, 'Color','blu');
hold on;
plot(simOut_controllo_OL.riferimento_forzato.time, ...
    simOut_controllo_OL.riferimento_forzato.signals.values, ...
    'LineWidth',1, 'Color','cyan', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione carrello [m]');
title(sprintf('Controllo posizione lineare carrello \nIn anello aperto con Fc forzato'));
grid on;
legend('xc_{out}', 'Posizione carrello finale');

% Sono state effettuate diverse simulazioni per verificarei risultati dell’analisi in frequenza:
%	- Risposta libera (Fc = 0): il sistema converge all’equilibrio, α→90° e xc→0; 
%	- Gradino da 1 N: nessuna risposta osservabile, il sistema converge all’equilibrio, α→90° e xc→0; 
%	- Gradini da 50 e 100 N: α(t) si assesta su 90° dopo una lieve oscillazione e xc(t) cresce linearmente, 
%                           (coerente con la presenza dell’integratore in Gxc(s)).
% Ingressi sinusoidali a frequenze crescenti: 
%	- A 0.2 rad/s (o < 1 rad/s): il sistema segue bene il segnale con oscillazioni minime;
%	- A 2 rad/s (valore della risonanza): a basse ampiezze, l’effetto è contenuto, 
%     ma all’aumentare dell’ampiezza, il sistema presenta oscillazioni ampieo, 
%     evidenziando la sensibilità del sistema alla frequenza naturale;
%	- A 5–10 rad/s: risposta smorzata e attenuata.
% L’analisi mostra che: 
%	- Gα(s) è un sistema di secondo ordine con risonanza sottosmorzata; 
%	- Gxc(s) è instabile in anello aperto a causa del polo in zero; 
% Entrambi i sistemi evidenziano risonanze critiche intorno a 2 rad/s, 
% che devono essere smorzate dal controllore.

%% Task 1: Progetto di un regolatore proporzionale 
% Controllo in anello chiuso con regolatore puramente proporzionale.
% Per il Tuning a mano del controllore è stata utilizzata la funzione:
% pidTuner(Gxc);
% Questa funzione ci permette di gestire e scegliere il miglior controllore
% PID per la funzione di trasferimento inserita in ingresso.
% Possiamo vedere sia come evolve il diagramma di Bode al variare dei
% coefficienti del PID e sia come evolve la risposta allo scalino.

% Studio della funzione d'anello con diagramma di Bode per alcuni valori di K_p
kp = [1000, 5000, 8000, 15000];
figure(13)
for j = 1:length(kp)
    Lxc = Gxc*kp(j);       % funzione d'anello
    margin(Lxc);
    hold on;
    grid on;
end
title(sprintf('Diagramma di Bode della funzione d''anello \n L_{xc} = G_{xc} * K_{p}'));
legend('K_{p} = 1000', 'K_{p} = 5000', 'K_{p} = 8000', 'K_{p} = 15000');

% Design del PID controller automatico - scelta: puramente proporzionale
Reg_pintune = pidtune(Gxc, 'P');  % 8.6e+03 

% Analisi prestazioni dinamiche con relativi diagrammi di Bode
L_CL_pro = Gxc * Reg_pintune;     % funzione d'anello
S_CL_pro = 1/(1+L_CL_pro);        % funzione di sensitività
F_CL_pro = 1 - S_CL_pro;          % funzione di sensitività complementare

figure(14)
bode(L_CL_pro, 'red');
grid on;
title(sprintf(['Diagramma di Bode - Funzione d''anello ' ...
    '\nRegolatore proporzionale - Gxc(s)']));

figure(15)
bode(F_CL_pro, 'blu');
grid on;
title(sprintf(['Diagramma di Bode - Funzione di sensitività complementare ' ...
    '\nRegolatore proporzionale - Gxc(s)']));

% Risposte in anello chiuso con regolatore puramente proporzionale.
% Gli output dipendono da quale tipologia di forza Fc
% è stata selezionata nello schema di Simulink se un gradino oppure una sinusoide
% e dalla tipologia di parametri che li caratterizzano.

% Creazione e simulazione del controllo in anello chiuso con Simulink
simOut_controllo_CL_proporzionale = sim("Controllo_CL_Prop.slx");

% Grafici di xc_out e alpha_out del controllo in anello chiuso
figure(16)
plot(simOut_controllo_CL_proporzionale.alpha_out.time, ...
    simOut_controllo_CL_proporzionale.alpha_out.signals.values, ...
    'LineWidth',2, 'Color','red');
hold on;
rif_alpha1 = simOut_controllo_CL_proporzionale.riferimento_alpha.signals.values ...
                * ones(size(simOut_controllo_CL_proporzionale.alpha_out.time));
plot(simOut_controllo_CL_proporzionale.alpha_out.time, ...
    rif_alpha1, 'LineWidth',1, 'Color','yellow', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title('Controllo posizione angolare - Regolatore Proporzionale');
grid on;
legend('alpha_{out}', 'riferimento');

figure(17)
plot(simOut_controllo_CL_proporzionale.xc_out.time, ...
    simOut_controllo_CL_proporzionale.xc_out.signals.values, ...
    'LineWidth',2, 'Color','blu');
hold on;
plot(simOut_controllo_CL_proporzionale.riferimento_xc.time, ...
    simOut_controllo_CL_proporzionale.riferimento_xc.signals.values, ...
    'LineWidth',1, 'Color','cyan', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione carrello [m]');
title('Controllo posizione lineare carrello - Regolatore Proporzionale');
grid on;
legend('xc_{out}', 'riferimento xc', 'Location','southeast');

figure(18)
plot(simOut_controllo_CL_proporzionale.Azione_di_controllo.time, ...
    simOut_controllo_CL_proporzionale.Azione_di_controllo.signals.values, ...
    'LineWidth',2, 'Color','green');
xlabel('Tempo [s]');
ylabel('Forza Fc [N]');
title('Azione di controllo - Regolatore Proporzionale');
grid on;
legend('Forza Fc');

%% Task 2: Progetto di un regolatore per cancellazione di poli e zeri c.c
% Per progettare un regolatore che cancelli la dinamica dei poli e zeri
% complessi e coniugati della FdT Gxc(s) dobbiamo:
% - trovare gli zeri e poli complessi coniugati della FdT Gxc(s)
% - definire il regolatore nel seguente modo:
%       Numeratore = poli complessi e coniugati di Gx(s)
%       Denominatore = zeri complessi e coniugati di Gx(s)

% Zeri e poli della Gxc: 
% z_Gxc =
%       -0.0500 + 1.9803i
%       -0.0500 - 1.9803i
% p_Gxc =
%       0.0000 + 0.0000i
%       -15.8544 + 0.0000i
%       -0.4561 + 1.9999i
%       -0.4561 - 1.9999i

% Un altro modo per scegliere il regolatore opportuno per la funzione di
% trasferimento è usare:
% sisotool
% E' un Control System Designer che ci permette di selezionare la tipologia
% di anello di retroazione utilizzato, inserire nei blocchi le funzioni di
% trasferimento, così da studiarne il comportamento con i diagrammi di
% bode, luogo delle radici e risposta allo scalino.
% Si possono aggiungere direttamente nei grafici i nostri requisiti 
% tradotti correttamente.

%i = sqrt(-1);
num_r = [(-0.4561 + 1.9999i) (-0.4561 - 1.9999i)]; % poli c.c. di Gx(s)
den_r = [(-0.0500 + 1.9803i) (-0.0500 - 1.9803i)]; % zeri c.c. di Gx(s)
Reg_cc = tf(num_r, den_r);

Reg_ZPK = zpk(p_Gxc(3:4),z_Gxc,8000);
disp('Regolatore realizzato per la cancellazione dei poli e zeri c.c:');
zpk(Reg_ZPK)

% Analisi prestazioni dinamiche con relativi diagrammi di Bode
L_CL_Reg = Gxc * Reg_ZPK;       % funzione d'anello
S_CL_Reg = 1/(1+L_CL_Reg);      % funzione di sensitività
F_CL_Reg = 1 - S_CL_Reg;        % funzione di sensitività complementare

figure(19)
bode(L_CL_Reg, 'red');
grid on;
title(sprintf(['Diagramma di Bode - Funzione d''anello ' ...
    '\nRegolatore con poli e zeri complessi e coniugati - Gxc(s)']));

figure(20)
bode(F_CL_Reg, 'blu');
grid on;
title(sprintf(['Diagramma di Bode - Funzione di sensitività complementare ' ...
    '\nRegolatore con poli e zeri complessi e coniugati - Gxc(s)']));

% Creazione e simulazione del controllo in anello chiuso con Simulink
simOut_controllo_CL_regolatore = sim("Controllo_CL_Regolatore.slx");

% Grafici di xc_out e alpha_out del controllo in anello chiuso
figure(21)
plot(simOut_controllo_CL_regolatore.alpha_out.time, ...
    simOut_controllo_CL_regolatore.alpha_out.signals.values, ...
    'LineWidth',2, 'Color','red');
hold on;
rif_alpha2 = simOut_controllo_CL_regolatore.riferimento_alpha.signals.values ...
                * ones(size(simOut_controllo_CL_regolatore.alpha_out.time));
plot(simOut_controllo_CL_regolatore.alpha_out.time, ...
    rif_alpha2, 'LineWidth',1, 'Color','yellow', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title(sprintf('Controllo posizione angolare \nRegolatore con poli e zeri complessi e coniugati'));
grid on;
legend('alpha_{out}','riferimento');

figure(22)
plot(simOut_controllo_CL_regolatore.xc_out.time, ...
    simOut_controllo_CL_regolatore.xc_out.signals.values, ...
    'LineWidth',2, 'Color','blu');
hold on;
plot(simOut_controllo_CL_regolatore.riferimento.time, ...
    simOut_controllo_CL_regolatore.riferimento.signals.values, ...
    'LineWidth',1, 'Color','cyan', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione carello [m]');
title(sprintf('Controllo posizione lineare carrello \nRegolatore con poli e zeri complessi e coniugati'));
grid on;
legend('xc_{out}', 'riferimento', 'Location','southeast');

figure(23)
plot(simOut_controllo_CL_regolatore.Azione_di_controllo.time, ...
    simOut_controllo_CL_regolatore.Azione_di_controllo.signals.values, ...
    'LineWidth',2, 'Color','green');
xlabel('Tempo [s]');
ylabel('Forza Fc [N]');
title(sprintf('Azione di controllo \nRegolatore con poli e zeri complessi e coniugati'));
grid on;
legend('Forza Fc');

%% Task 3: Progetto di un regolatore proporzionale e prefiltro
% Definizione Prefiltro 
num_pre = 1;
den_pre = [1 1];
disp('Prefiltro:');
Prefiltro = tf(num_pre, den_pre)
Reg_Proporzionale = 3e3;

% Analisi prestazioni dinamiche con relativi diagrammi di Bode
L_CL_pre_pro = minreal(Gxc * Reg_Proporzionale, 0.01);     % funzione d'anello
disp('Funzione d''anello - Proporzionale - Gxc(s): ')
zpk(L_CL_pre_pro)
S_CL_pre_pro = minreal(1/(1+L_CL_pre_pro), 0.01);          % funzione di sensitività
F_CL_pre_pro = minreal(1 - S_CL_pre_pro, 0.01);            % funzione di sensitività complementare
disp('Funzione di sensitività complementare - Proporzionale - Gxc(s): ')
zpk(F_CL_pre_pro)
Q_pre_pro = minreal(Reg_Proporzionale/(1+L_CL_pre_pro ), 0.01); % funzione di sensitività del controllo
disp('Funzione di sensitività del controllo - Prefiltro - Proporzionale - Gxc(s): ');
zpk(Q_pre_pro)
% Gyw(s) = P(s)*F(s) 
G_yw_pre_pro = minreal(Prefiltro * F_CL_pre_pro, 0.01);    % sistema in anello chiuso con prefiltro
disp('Funzione Gyw(s) - Prefiltro - Proporzionale - Gxc(s): ')
zpk(G_yw_pre_pro)

figure(24)
bode(L_CL_pre_pro, 'red');
grid on;
title(sprintf(['Diagramma di Bode - Funzione d''anello ' ...
    '\nRegolatore puramente proporzionale - Gxc(s)']));

figure(25)
bode(F_CL_pre_pro, 'blu');
grid on;
title(sprintf(['Diagramma di Bode - Funzione di sensitività complementare ' ...
    '\nRegolatore puramente proporzionale - Gxc(s)']));

figure(26)
bode(Q_pre_pro, 'green');
grid on;
legend('Q(s)');
title(sprintf(['Diagramma di Bode - Funzione di sensitività del controllo' ...
    '\nRegolatore puramente proporzionale - Gxc(s)']));

figure(27)
bode(G_yw_pre_pro, 'magenta');
grid on;
legend('Gyw(s) = P(s)*F(s)');
title(sprintf(['Diagramma di Bode - Gyw(s) ' ...
    '\nPrefiltro - Regolatore puramente proporzionale - Gxc(s)']));

% Creazione e simulazione del controllo in anello chiuso con Simulink
simOut_controllo_CL_prefiltro = sim("Controllo_CL_Prefiltro.slx");

% Grafici di xc_out e alpha_out del controllo in anello chiuso
figure(28)
plot(simOut_controllo_CL_prefiltro.alpha_out.time, ...
    simOut_controllo_CL_prefiltro.alpha_out.signals.values, ...
    'LineWidth',2, 'Color','red');
hold on;
rif_alpha3 = simOut_controllo_CL_prefiltro.riferimento_alpha.signals.values ...
                * ones(size(simOut_controllo_CL_prefiltro.alpha_out.time));
plot(simOut_controllo_CL_prefiltro.alpha_out.time, ...
    rif_alpha3, 'LineWidth',1, 'Color','yellow', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title(sprintf('Controllo posizione angolare \nPrefiltro e Regolatore puramente proporzionale'));
grid on;
legend('alpha_{out}', 'riferimento');

figure(29)
plot(simOut_controllo_CL_prefiltro.xc_out.time, ...
    simOut_controllo_CL_prefiltro.xc_out.signals.values, ...
    'LineWidth',2, 'Color','blu');
hold on;
plot(simOut_controllo_CL_prefiltro.riferimento.time, ...
    simOut_controllo_CL_prefiltro.riferimento.signals.values, ...
    'LineWidth',1, 'Color','cyan', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione carello [m]');
title(sprintf('Controllo posizione carrello \nPrefiltro e Regolatore puramente proporzionale'));
grid on;
legend('xc_{out}', 'riferimento','Location','southeast');

figure(30)
plot(simOut_controllo_CL_prefiltro.Azione_di_controllo.time, ...
    simOut_controllo_CL_prefiltro.Azione_di_controllo.signals.values, ...
    'LineWidth',2, 'Color','green');
xlabel('Tempo [s]');
ylabel('Forza Fc [N]');
title(sprintf('Azione di controllo \nPrefiltro e Regolatore puramente proporzionale'));
grid on;
legend('Forza Fc');

%% Task 4: Progetto di un regolatore per cancellazione di poli e zeri c.c e prefiltro

% Analisi prestazioni dinamiche con relativi diagrammi di Bode
L_CL_pre_reg = minreal(Gxc * Reg_ZPK, 0.01);               % funzione d'anello
disp('Funzione d''anello - Regolatore con poli e zeri complessi e coniugati - Gxc(s): ')
zpk(L_CL_pre_reg)
S_CL_pre_reg = minreal(1/(1+L_CL_pre_reg), 0.01);          % funzione di sensitività
F_CL_pre_reg = minreal(1 - S_CL_pre_reg, 0.01);            % funzione di sensitività complementare
disp('Funzione di sensitività complementare - Regolatore con poli e zeri complessi e coniugati - Gxc(s): ')
zpk(F_CL_pre_reg)
Q_pre_reg = minreal(Reg_ZPK/(1+L_CL_pre_reg), 0.01);
disp('Funzione di sensitività del controllo - Regolatore con poli e zeri complessi e coniugati - Gxc(s): ');
zpk(Q_pre_reg)
G_yw_pre_reg = minreal(Prefiltro * F_CL_pre_reg, 0.01);    % sistema in anello chiuso con prefiltro
disp('Funzione Gyw(s) - Prefiltro - Regolatore con poli e zeri complessi e coniugati - Gxc(s): ')
zpk(G_yw_pre_reg)

figure(31)
bode(L_CL_pre_reg, 'red');
grid on;
title(sprintf(['Diagramma di Bode - Funzione d''anello ' ...
    '\nRegolatore con poli e zeri complessi e coniugati - Gxc(s)']));

figure(32)
bode(F_CL_pre_reg, 'blu');
grid on;
title(sprintf(['Diagramma di Bode - Funzione di sensitività complementare ' ...
    '\nRegolatore con poli e zeri complessi e coniugati - Gxc(s)']));

figure(33)
bode(G_yw_pre_reg, 'magenta');
grid on;
legend('Gyw(s) = P(s)*F(s)');
title(sprintf(['Diagramma di Bode - Gyw(s) ' ...
    '\nPrefiltro - Regolatore con poli e zeri complessi e coniugati - Gxc(s)']));

figure(34)
bode(Q_pre_reg, 'green');
grid on;
legend('Q(s)');
title(sprintf(['Diagramma di Bode - Funzione di sensitività del controllo' ...
    '\nRegolatore con poli e zeri complessi e coniugati - Gxc(s)']));


% Creazione e simulazione del controllo in anello chiuso con Simulink
simOut_controllo_CL_pre_reg = sim("Controllo_CL_Pre_reg.slx");

% Grafici di xc_out e alpha_out del controllo in anello chiuso
figure(35)
plot(simOut_controllo_CL_pre_reg.alpha_out.time, ...
    simOut_controllo_CL_pre_reg.alpha_out.signals.values, ...
    'LineWidth',2, 'Color','red');
hold on;
rif_alpha4 = simOut_controllo_CL_pre_reg.riferimento_alpha.signals.values ...
                * ones(size(simOut_controllo_CL_pre_reg.alpha_out.time));
plot(simOut_controllo_CL_pre_reg.alpha_out.time, ...
    rif_alpha4, 'LineWidth',1, 'Color','yellow', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title(sprintf('Controllo posizione angolare \nPrefiltro e Regolatore con poli e zeri complessi e coniugati'));
grid on;
legend('alpha_{out}', 'riferimento');

figure(36)
plot(simOut_controllo_CL_pre_reg.xc_out.time, ...
    simOut_controllo_CL_pre_reg.xc_out.signals.values, ...
    'LineWidth',2, 'Color','blu');
hold on;
plot(simOut_controllo_CL_pre_reg.riferimento.time, ...
    simOut_controllo_CL_pre_reg.riferimento.signals.values, ...
    'LineWidth',1, 'Color','cyan', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione carello [m]');
title(sprintf('Controllo posizione carrello \nPrefiltro e Regolatore con poli e zeri complessi e coniugati'));
grid on;
legend('xc_{out}', 'riferimento','Location','southeast');

figure(37)
plot(simOut_controllo_CL_pre_reg.Azione_di_controllo.time, ...
    simOut_controllo_CL_pre_reg.Azione_di_controllo.signals.values, ...
    'LineWidth',2, 'Color','green');
xlabel('Tempo [s]');
ylabel('Forza Fc [N]');
title(sprintf('Azione di controllo \nPrefiltro e Regolatore con poli e zeri complessi e coniugati'));
grid on;
legend('Forza Fc');

%% Task 5: Architettura di controllo alternativa
% Regolatore su G_alpha(s) e G_xc(s) senza prefiltro del riferimento

% Regolatori scelti sulla base di alcune simulazioni svolte:
% Rxc(s) = 3000
% Ralpha(s) = 
%  100
% ------
% (s+10)

% Creazione e simulazione del controllo in anello chiuso con Simulink
simOut_controllo_CL_completo = sim("Controllo_CL_Completo.slx");

% Grafici di xc_out e alpha_out del controllo in anello chiuso
figure(38)
plot(simOut_controllo_CL_completo.alpha_out.time, ...
    simOut_controllo_CL_completo.alpha_out.signals.values, ...
    'LineWidth',2, 'Color','red');
hold on;
rif_alpha5 = simOut_controllo_CL_completo.riferimento_alpha.signals.values ...
                * ones(size(simOut_controllo_CL_completo.alpha_out.time));
plot(simOut_controllo_CL_completo.alpha_out.time, ...
    rif_alpha5, 'LineWidth',1, 'Color','yellow', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione angolare [rad]');
title(sprintf('Controllo posizione angolare\nArchitettura di controllo alternativa'));
grid on;
legend('alpha_{out}', 'riferimento');

figure(39)
plot(simOut_controllo_CL_completo.xc_out.time, ...
    simOut_controllo_CL_completo.xc_out.signals.values, ...
    'LineWidth',2, 'Color','blu');
hold on;
plot(simOut_controllo_CL_completo.riferimento_xc.time, ...
    simOut_controllo_CL_completo.riferimento_xc.signals.values, ...
    'LineWidth',1, 'Color','cyan', 'LineStyle', '--');
xlabel('Tempo [s]');
ylabel('Posizione carello [m]');
title(sprintf('Controllo posizione lineare carrello\nArchitettura di controllo alternativa'));
grid on;
legend('xc_{out}', 'riferimento', 'Location','southeast');

figure(40)
plot(simOut_controllo_CL_completo.Azione_di_controllo.time, ...
    simOut_controllo_CL_completo.Azione_di_controllo.signals.values, ...
    'LineWidth',2, 'Color','green');
xlabel('Tempo [s]');
ylabel('Forza Fc [N]');
title(sprintf('Azione di controllo Fc\nArchitettura di controllo alternativa'));
grid on;
legend('Forza Fc');

figure(41)
plot(simOut_controllo_CL_completo.Azione_alpha.time, ...
    simOut_controllo_CL_completo.Azione_alpha.signals.values, ...
    'LineWidth',2, 'Color','green');
xlabel('Tempo [s]');
ylabel('Forza Fc [N]');
title(sprintf('Azione di controllo su alpha\nArchitettura di controllo alternativa'));
grid on;
legend('Forza Fc');

figure(42)
plot(simOut_controllo_CL_completo.Azione_xc.time, ...
    simOut_controllo_CL_completo.Azione_xc.signals.values, ...
    'LineWidth',2, 'Color','green');
xlabel('Tempo [s]');
ylabel('Forza Fc [N]');
title(sprintf('Azione di controllo su xc\nArchitettura di controllo alternativa'));
grid on;
legend('Forza Fc');
