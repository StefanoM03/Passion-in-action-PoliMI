%% Codice per salvare le figure aperte in png
% Stefano Milantoni

% Cartella di destinazione
save_folder = fullfile(pwd, 'figure_output');
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end

% Figure aperte
figHandles = findall(0, 'Type', 'figure');

% Salva ciascuna figura
for k = 1:length(figHandles)
    fig = figHandles(k);
    filename = fullfile(save_folder, sprintf('Figura_%d.png', fig.Number));
    saveas(fig, filename);
end

disp('Tutte le figure sono state salvate nella cartella:');
disp(save_folder);