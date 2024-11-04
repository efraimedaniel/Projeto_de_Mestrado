clear
%cd ~/Desktop/Daniel
cd('D:/Sazonalidade');
%
load Cananeia_01.mat
altura_detrend = ciclo_anual;
%

% Supondo que 'media_mensal' já está carregado e contém os dados de altura média mensal
N = length(altura_detrend); % Número de pontos de dados
fs = 1; % Frequência de amostragem (mensal)
T = 1/fs; % Período de amostragem
t = (0:N-1)*T; % Vetor de tempo

% Aplicar suavização ao sinal
tmp = smoothdata(altura_detrend, 'lowess', 6); % Ajustar o parâmetro de suavização conforme necessário

% Transformada de Fourier
Y = fft(tmp);
P2 = abs(Y/N); % Normalizar o espectro
P1 = P2(1:N/2+1); % Pegar apenas a metade positiva
P1(2:end-1) = 2*P1(2:end-1); % Ajuste de amplitude

f = fs*(0:(N/2))/N; % Vetor de frequências

% Plotar o espectro
figure;
loglog(f, P1, 'k', 'LineWidth', 1.5); % Plotar o espectro com linha azul
hold on;

% Adicionar etiquetas e título
xlabel('Frequência (ciclos.mês^{-1})', 'FontSize', 12);
ylabel('Densidade espectral (m^2.mês^{-1})', 'FontSize', 12); % Unidades específicas
% Adicionar uma grade para melhor leitura
grid on;
ax = gca;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
% Ajustar layout para garantir que tudo fique visível
set(gca, 'LooseInset', get(gca, 'TightInset'));

% Ajustar a posição da figura para garantir que tudo fique visível
set(gcf, 'Position', [100, 100, 800, 600]); % Largura x Altura

% Salvar a figura com 300 DPI
print('Espectral_cananeia', '-dsvg', '-r300');


