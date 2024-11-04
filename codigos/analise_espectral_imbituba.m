clear all;
close all;
clc;

% Carregue os dados
dado = importdata('imbi_718_2001_2021.txt');
data = dado.textdata(:, 1);
hora = dado.textdata(:, 2);
altura_zero = dado.data(:, 1);
altura_zero = (altura_zero*100);
% Converter datas e horas para datetimes
data_hora_str = strcat(data, {' '}, hora);
data_hora = datetime(data_hora_str, 'InputFormat', 'dd/MM/yyyy HH:mm');

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
altura_01 = mean(altura);
altura = altura - altura_01;

% modelo linear para remover a tendencia
vetor_tmp = [ones(length(tempo_numerica), 1) tempo_numerica];
x1 = vetor_tmp\altura;
b1 = (vetor_tmp*x1);

%subtração da tendencia b1
altura_detrend = altura - b1;
%%
% Calculando a média móvel de 12 períodos com janelas centradas
media_movel_12 = movmean(altura_detrend, 12, 'Endpoints', 'discard');
% Calculando a média móvel de segundo período com janelas centradas
media_movel_2_centralizada = movmean(media_movel_12, [1,1], 'Endpoints', 'discard');
% Calculando a média móvel centrada dividida por 24
media_movel_centrada = media_movel_2_centralizada / 24;
%%
% Frequência de amostragem
Fs = 1;  % Amostragem mensal

% Comprimento do sinal
L = length(altura_detrend);

% Tempo
t = (0:L-1)/Fs;

% Transformada de Fourier
fft_altura = fft(altura_detrend);
P2 = abs(fft_altura/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% Frequências correspondentes
f = Fs*(0:(L/2))/L;

% Plot do espectro
figure(1);
plot(f, P1);
xlabel('Frequência (ciclos/mês)');
ylabel('Amplitude');
title('Espectro de Frequência');
xlim([0.0 0.2])

% Marcar o período 22
periodo_228 = 1/228;
xline(periodo_228, 'r--', 'Periodo 228');
%%
Fs = 1;  % Amostragem mensal

% Comprimento do sinal
L = length(media_movel_centrada);

% Tempo
t = (0:L-1)/Fs;

% Transformada de Fourier
fft_altura = fft(media_movel_centrada);
P2 = abs(fft_altura/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% Frequências correspondentes
f = Fs*(0:(L/2))/L;

% Plot do espectro
figure(2);
plot(f, P1);
xlabel('Frequência (ciclos/mês)');
ylabel('Amplitude');
title('Espectro de Frequência');
xlim([0.0 0.2])

% Marcar o período 225
periodo_225 = 1/225;
xline(periodo_225, 'r--', 'Periodo 225');

% Marcar o período 450
periodo_450 = 1/450;
xline(periodo_450, 'r--', 'Periodo 450');

%%
figure(3)
plot(media_movel_centrada)
figure(4)
plot(altura_detrend)

%%
