%%  Calcoli di supporto per il report
%   Stefano Milantoni

% load('Workspace_progetto.mat')

% Caricare il workspace del progetto o eseguire tutto il codice
% matlab del progetto prima runnare questo codice.

fprintf('---------------------------------------------------------------\n');

%% Calcolo tempo di assestamento per xc_out
% Calcolo tempo di assestamento per xc_out dopo lo scalino
% Prefiltro - Proporzionale - Gxc(s)
%xc_out = simOut_controllo_CL_prefiltro.xc_out.signals.values;
%riferimento_xc = simOut_controllo_CL_prefiltro.riferimento.signals.values;
%t_xc_out = simOut_controllo_CL_prefiltro.xc_out.time;

% Prefiltro - Regolatore con poli e zeri complessi e coniugati - Gxc(s)
% xc_out = simOut_controllo_CL_pre_reg.xc_out.signals.values;
% riferimento_xc = simOut_controllo_CL_pre_reg.riferimento.signals.values;
% t_xc_out = simOut_controllo_CL_pre_reg.xc_out.time;

% Controllo completo - Gxc(s) e Galpha(s)
xc_out = simOut_controllo_CL_completo.xc_out.signals.values;
riferimento_xc = simOut_controllo_CL_completo.riferimento_xc.signals.values;
t_xc_out = simOut_controllo_CL_completo.xc_out.time;

idx_step_xc = find(t_xc_out >= 15, 1, 'first'); % istante in cui c'è lo scalino

rif_finale_xc = riferimento_xc(end); % riferimento finale
soglia_98_xc = 0.98 * rif_finale_xc; % calcolo soglia per il tempo di assestamento

% trovo la posizione nell'array in cui il segnale raggiunge il riferimento 
idx_98_xc = find(xc_out(idx_step_xc:end) >= soglia_98_xc, 1, 'first') + idx_step_xc - 1;
tempo_98_xc = t_xc_out(idx_98_xc); % trovo a quale tempo corrisponde quella posizione dell'array
ta_xc = tempo_98_xc - 15;

fprintf('Per t ≥ 15s il segnale xc_out raggiunge il 98%% del riferimento a ta = %.4f secondi\n', ta_xc);

% Il segnale xc_out raggiunge il 98% del riferimento a ta= 8.6060 secondi 
% Il segnale xc_out raggiunge il 98% del riferimento a ta = 5.4180 secondi
% Il segnale xc_out raggiunge il 98% del riferimento a ta = 6.1390 secondi

% Calcolo tempo di assestamento per xc_out prima dello scalino

% Valore finale del riferimento per t < 15 secondi
rif_finale_xc_before = riferimento_xc(1);
toll_xc = 0.01;  % tolleranza dell'1%

% Limiti superiori e inferiori entro cui stare
banda_sup_xc = rif_finale_xc_before + toll_xc;
banda_inf_xc = rif_finale_xc_before - toll_xc;

xc_pre = xc_out(1:idx_step_xc);
t_pre = t_xc_out(1:idx_step_xc);

% Limito la ricerca ai soli valori che sono all'interno della banda selezionata
inside_band_xc_out = (xc_pre >= banda_inf_xc) & (xc_pre <= banda_sup_xc);

% Cerco il primo punto in cui xc resta sempre dentro la banda
ta_xc_out_2 = NaN;
for i = 1:length(inside_band_xc_out)
    if all(inside_band_xc_out(i:end))
        ta_xc_out_2 = t_pre(i);
        break;
    end
end

% Output
if isnan(ta_xc_out_2)
    fprintf("Il segnale xc NON si stabilizza entro ±1%% del riferimento PRIMA di 15 secondi.\n");
else
    fprintf("Per t < 15s il segnale xc si stabilizza entro ±1%% del riferimento " + ...
        "a ta = %.4f secondi\n", ta_xc_out_2);
end

% Il segnale xc si stabilizza entro ±1% del riferimento PRIMA di 15 secondi a t = 6.2230 secondi

% Il segnale xc si stabilizza entro ±1% del riferimento PRIMA di 15 secondi a t = 5.5450 secondi

% Il segnale xc si stabilizza entro ±1% del riferimento PRIMA di 15 secondi a t = 6.2220 secondi

% Calcolo sovraelongazione xc

% Definizione dei riferimenti
x_rif_pre_sovra = riferimento_xc(1);
x_rif_post_sovra = riferimento_xc(end);

% Estrazione intervalli
idx_pre_sovra = find(t_xc_out < 15);
idx_post_sovra = find(t_xc_out >= 15);

tempo_pre_xc_sovra = t_xc_out(idx_pre_sovra);
tempo_post_xc_sovra = t_xc_out(idx_post_sovra);

xc_pre_sovra = xc_out(idx_pre_sovra);
xc_post_sovra = xc_out(idx_post_sovra);

% Calcolo sovraelongazione pre-scalino
max_xc_pre_sovra = max(xc_pre_sovra);
overshoot_pre_sovra = 0;
if x_rif_pre_sovra ~= 0
    overshoot_pre_sovra = (max_xc_pre_sovra - x_rif_pre_sovra) / x_rif_pre_sovra * 100;
else
    % Calcolo assoluto se riferimento è zero
    overshoot_pre_sovra = max_xc_pre_sovra * 100;
end

% Calcolo sovraelongazione post-scalino
max_xc_post_sovra = max(xc_post_sovra);
overshoot_post_sovra = (max_xc_post_sovra - x_rif_post_sovra) / x_rif_post_sovra * 100;

% Output
fprintf("Sovraelongazione xc_out pre-scalino (t < 15s): %.2f%%\n", overshoot_pre_sovra);
fprintf("Sovraelongazione xc_out post-scalino (t ≥ 15s): %.2f%%\n", overshoot_post_sovra);

fprintf('---------------------------------------------------------------\n');

% Sovraelongazione xc_out pre-scalino (t < 15s): 11.09%
% Sovraelongazione xc_out post-scalino (t ≥ 15s): -0.00%

% Sovraelongazione xc_out pre-scalino (t < 15s): 8.27%
% Sovraelongazione xc_out post-scalino (t ≥ 15s): 0.00%

% Sovraelongazione xc_out pre-scalino (t < 15s): 11.10%
% Sovraelongazione xc_out post-scalino (t ≥ 15s): 0.08%

%% Calcolo tempo di assestamento per alpha 
% Calcolo tempo di assestamento per alpha dopo lo scalino
% Prefiltro - Proporzionale - Gxc(s)
%alpha_out = simOut_controllo_CL_prefiltro.alpha_out.signals.values;
%riferimento_alpha = rif_alpha3;

% Prefiltro - Regolatore con poli e zeri complessi e coniugati - Gxc(s)
% alpha_out = simOut_controllo_CL_pre_reg.alpha_out.signals.values;
% riferimento_alpha = rif_alpha4;

% Controllo completo - Gxc(s) e Galpha(s)
alpha_out = simOut_controllo_CL_completo.alpha_out.signals.values;
riferimento_alpha = rif_alpha5;

t_alpha = linspace(0, 30, length(alpha_out));

idx_step_alpha = find(t_alpha >= 15, 1, 'first');

rif_finale_alpha = riferimento_alpha(end);
toll_alpha = 0.01 * abs(rif_finale_alpha);  % tolleranza dell'1%

banda_sup_alpha = rif_finale_alpha + toll_alpha;
banda_inf_alpha = rif_finale_alpha - toll_alpha;

alpha_post = alpha_out(idx_step_alpha:end);
t_post_alpha = t_alpha(idx_step_alpha:end);

inside_band_alpha = (alpha_post >= banda_inf_alpha) & (alpha_post <= banda_sup_alpha);

% Cerco il primo punto in cui alpha resta sempre dentro la banda
ta_alpha = NaN;
for i = 1:length(inside_band_alpha)
    if all(inside_band_alpha(i:end))
        ta_alpha = t_post_alpha(i);
        break;
    end
end

% Output
if isnan(ta_alpha)
    fprintf("Il segnale alpha non si stabilizza entro ±1%% del riferimento.\n");
else
    fprintf("Il segnale alpha si stabilizza entro ±1%% del riferimento " + ...
        "a ta = %.4f secondi\n", (ta_alpha-15));
end

% Il segnale alpha si stabilizza entro ±1% del riferimento a ta = 3.6020 secondi

% Il segnale alpha non si stabilizza entro ±1% del riferimento.

% Il segnale alpha si stabilizza entro ±1% del riferimento a ta = 4.3860 secondi

% Calcolo tempo di assestamento per alpha prima dello scalino

rif_finale_alpha_before = riferimento_alpha(1);  % o un valore adatto per t<15
toll_alpha_before = 0.01 * abs(rif_finale_alpha_before);  % tolleranza dell'1%

% Limiti superiori e inferiori della banda
banda_sup_alpha_before = rif_finale_alpha_before + toll_alpha_before;
banda_inf_alpha_before = rif_finale_alpha_before - toll_alpha_before;

% Segmento del segnale prima di 15s
alpha_pre = alpha_out(1:idx_step_alpha);
t_pre = t_alpha(1:idx_step_alpha);

% Trova tutti gli indici dove alpha è dentro la banda
inside_band_alpha_before = (alpha_pre >= banda_inf_alpha_before) & (alpha_pre <= banda_sup_alpha_before);

% Cerca il primo punto da cui in poi alpha resta sempre dentro la banda
ta_alpha_before = NaN;
for i = 1:length(inside_band_alpha_before)
    if all(inside_band_alpha_before(i:end))
        ta_alpha_before = t_pre(i);
        break;
    end
end

% Output
if isnan(ta_alpha_before)
    fprintf("Il segnale alpha NON si stabilizza entro ±1%% del riferimento PRIMA di 15 secondi.\n");
else
    fprintf("Il segnale alpha si stabilizza entro ±1%% del riferimento PRIMA di 15 secondi a t = %.4f secondi\n", ta_alpha_before);
end

% Il segnale alpha si stabilizza entro ±1% del riferimento PRIMA di 15 secondi a t = 5.2180 secondi
% Il segnale alpha si stabilizza entro ±0.5% del riferimento PRIMA di 15 secondi a t = 6.8630 secondi

% Il segnale alpha NON si stabilizza entro ±1% del riferimento PRIMA di 15 secondi.

% Il segnale alpha si stabilizza entro ±1% del riferimento PRIMA di 15 secondi a t = 5.2170 secondi
% Il segnale alpha si stabilizza entro ±0.5% del riferimento PRIMA di 15 secondi a t = 6.8610 secondi

% Calcolo oscillazioni alpha

idx_pre_alpha_sovra = find(t_alpha < 15);
idx_post_alpha_sovra = find(t_alpha > 15);

alpha_pre_sovra = alpha_out(idx_pre_alpha_sovra);
alpha_post_sovra = alpha_out(idx_post_alpha_sovra);
tempo_pre_alpha_sovra = t_alpha(idx_pre_alpha_sovra);
tempo_post_alpha_sovra = t_alpha(idx_post_alpha_sovra);

oscillazione_pre_alpha_sovra = max(alpha_pre_sovra) - riferimento_alpha(end);
oscillazione_post_alpha_sovra = max(alpha_post_sovra) - riferimento_alpha(end);

% Oscillazione percentuale
oscillazione_pre_pct_alpha_sovra = (oscillazione_pre_alpha_sovra / riferimento_alpha(end)) * 100;
oscillazione_post_pct_alpha_sovra = (oscillazione_post_alpha_sovra / riferimento_alpha(end)) * 100;

% Output
fprintf("Oscillazione angolare pre-scalino: %.4f rad (%.2f%%)\n", oscillazione_pre_alpha_sovra, oscillazione_pre_pct_alpha_sovra);
fprintf("Oscillazione angolare post-scalino: %.4f rad (%.2f%%)\n", oscillazione_post_alpha_sovra, oscillazione_post_pct_alpha_sovra);

fprintf('---------------------------------------------------------------\n');

% Oscillazione angolare pre-scalino: 0.0942 rad (6.00%)
% Oscillazione angolare post-scalino: 0.0399 rad (2.54%)

% Oscillazione angolare pre-scalino: 0.1053 rad (6.70%)
% Oscillazione angolare post-scalino: 0.0675 rad (4.30%)

% Oscillazione angolare pre-scalino: 0.0942 rad (6.00%)
% Oscillazione angolare post-scalino: 0.0777 rad (4.95%)
