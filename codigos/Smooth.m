clear all;
close all;
clc;

% Carregue os dados
dado = importdata('imbi_718_2001_2021.txt');
data = dado.textdata(:, 1);
hora = dado.textdata(:, 2);
altura_zero = dado.data(:, 1);
datum = 1.580;
altura_zero = altura_zero - datum;
% Converter datas e horas para datetimes
data_hora_str = strcat(data, {' '}, hora);
data_hora = datetime(data_hora_str, 'InputFormat', 'dd/MM/yyyy HH:mm');
des = std(altura_zero)
% Criar uma tabela com as datas e alturas
tabela = table(data_hora, altura_zero);

% Converter para timetable
timetableDados = table2timetable(tabela);

% Calcular a média mensal usando retime
timetableMediaMensal = retime(timetableDados, 'monthly', @mean);

% Extrair as alturas médias mensais
media_mensal = timetableMediaMensal.altura_zero';

tempo = timetableMediaMensal.data_hora;
altura = timetableMediaMensal.altura_zero;
tempo_numerica = datenum(tempo);
%altura_01 = mean(altura);
%altura = altura - altura_01;

% modelo linear para remover a tendencia
vetor_tmp = [ones(length(tempo_numerica), 1) tempo_numerica];
x1 = vetor_tmp\altura;
b1 = (vetor_tmp*x1);
altura_detrend = altura - b1;


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
%title('Análise espectral do nível médio do mar em Imbituba', 'FontSize', 14);

% Ajustar limites do eixo x para mostrar frequências de 0 a 0.2 ciclos/mês
%xlim([0 0.2]); % Ajustar o limite superior do eixo x para a frequência máxima

% Ajustar limites do eixo y para melhor visualização
%ylim([min(P1(f >= 0 & f <= 0.2)) max(P1(f >= 0 & f <= 0.2))]); % Ajustar os limites do eixo y conforme necessário

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
print('Espectro_Fourier_Tidal_Signal_Imbituba_01_sem_titulo', '-dsvg', '-r300');




