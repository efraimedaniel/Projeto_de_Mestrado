clc; clear all; close all;

% Carregue os dados
dado = importdata('fort_283_2008_2021.txt');
data = dado.textdata(:, 1);
hora = dado.textdata(:, 2);
altura_01 = dado.data(:, 1);

%datum vertical, enconto o valor nas ficha maregráfica; 
%datum = 5.850;

% Referenciar o dado ao maregrafo de imbituba
%altura_zero = 5.850;  

% Calcular a nova média após referenciar ao imbituba. 
media_alt = mean(altura_01);

% Remover a média dos dados para que esteja em torno do zero.
altura_referenciada_01 = altura_01 - media_alt;

%Converter para centimetros
altura_referenciada = (altura_referenciada_01 * 100);  % em centímetros

% Converter data e hora na mesma coluna e transformar em datenum
data_hora_str = strcat(data, {' '}, hora);
%data_numerica = datenum(data_hora_str, 'dd/mm/yyyy HH:MM');
data_numerica = datenum(data_hora_str, 'dd/mm/yyyy HH:MM');

% Criar uma tabela com as datas e os dados observados
tabela = table(data_numerica, altura_referenciada);

% Converter a coluna DataHora para datetime e a adicionar na tabela ja existente.
dados_tabela = addvars(tabela, datetime(tabela.data_numerica, 'ConvertFrom', 'datenum'), 'Before', 2, 'NewVariableNames', 'DataHora');

% Extrair o ano e o mês separadamente
dados_tabela.Ano = year(dados_tabela.DataHora);
dados_tabela.Mes = month(dados_tabela.DataHora);

% Crir um número de série no formato YYYYMM
dados_tabela.MesAno = dados_tabela.Ano * 100 + dados_tabela.Mes;

% Agrupar os dados por mês e calcular a média mensal
media_mensal = varfun(@mean, dados_tabela, 'GroupingVariables', 'MesAno', 'InputVariables', 'altura_referenciada');

% Exibir a tabela com as médias mensais
%disp(media_mensal);

% 'tabela' é sua tabela com colunas 'MesAno' e 'media_mensal'
%mês e anos (AAAAMM)
meses_numericos = table2array(media_mensal(:, 'MesAno'));

% Valores médios mensais ja calculado.
media_mensal_numericos = table2array(media_mensal(:, 'mean_altura_referenciada'));

% Converter os meses numéricos em datas numéricas usando datenum
tmp = datenum(num2str(meses_numericos), 'yyyymm');

desvio = std(media_mensal_numericos)

% Crie o gráfico
figure (1)
plot(tmp, media_mensal_numericos);
xlabel('Data');
ylabel('Média Mensal');

%reg linear dado
vetor_tmp = [ones(length(tmp), 1) tmp];
x1 = vetor_tmp\media_mensal_numericos;
b1 = (vetor_tmp*x1);
%maxb1 = max(b1);
%minb1 = min(b1);
%slr1 = maxb1 - minb1;
Trend = 0.1529


figure('PaperSize',[20 20],...
       'PaperUnits','centimeters',...
       'InvertHardcopy','on',...
       'PaperPosition',[0 0 20 20],...
       'PaperPositionMode','auto',...
       'Position',[80 80 1800 900]);
plot(tmp, media_mensal_numericos, 'k', 'LineWidth', 1.5, 'DisplayName', 'Observado'); % Observado em azul
hold on;
plot(tmp, b1, 'r', 'LineWidth', 1.5, 'DisplayName', 'Tendência'); % Tendência em vermelho
xlabel('Tempo (meses)','FontSize', 18);
ylabel('Nível do mar (cm)','FontSize', 18);
title('Nível médio do mar anual de Fortaleza','FontSize', 22);
grid on;
datetick('x', 'mmm yyyy', 'keepticks');
ax = gca; % Obter o eixo atual
ax.FontSize = 14; % Tamanho da fonte
ax.FontWeight = 'bold'; % Negrito

% Adicione a legenda
legend('show');
% Adicione o valor de slr1 como um texto no gráfico
% Adicione o valor de slr1 em centímetros como texto no gráfico
%slr1_str = sprintf('Trend %.2f cm/ano', slr1);
%text(tmp(1), max(media_mensal_numericos), slr1_str, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'blue');
% Adicione o valor da tendência linear abaixo da legenda
% Adicione a legenda
legend('Média Mensal', 'Tendência Linear', 'Location', 'northwest','FontSize', 18);
annotation('textbox', [0.2, 0.05, 0.1, 0.1], 'String', ['Tend: ' num2str(Trend, '%.4f') ' cm/ano'], 'FitBoxToText', 'on', 'BackgroundColor', 'w','FontSize', 16, 'FontWeight', 'bold');
%saveas(gcf, 'fig_Fortaleza.svg', 'svg');

%analise harmonica
coef = ut_solv (data_numerica, altura_referenciada, [],-3.71460,'auto'); 
[u_fit_i] = ut_reconstr(data_numerica, coef);
residuo = altura_referenciada - u_fit_i;

%%
%Rpresentação das médias anuais das series temporais %%%%%
%criar uma serie temporal com uma media anual
tabela_01 = table(data_numerica, altura_referenciada);

% Converter a coluna DataHora para datetime e a adicionar na tabela ja existente.
dados_tabela_01 = addvars(tabela_01, datetime(tabela_01.data_numerica, 'ConvertFrom', 'datenum'), 'Before', 2, 'NewVariableNames', 'DataHora');
% criar uma tabela de anos apenas
dados_tabela_01.Ano = year(dados_tabela_01.DataHora); 
% Crir um número de série no formato YYYY
dados_tabela.Ano = dados_tabela_01.Ano * 100;

% Agrupar os dados por ano e calcular a média anual =
media_anual = varfun(@mean, dados_tabela_01, 'GroupingVariables', 'Ano', 'InputVariables', 'altura_referenciada');

alt_anual = table2array(media_anual(:, 'Ano'));

% Valores médios mensais ja calculado.
media_Anual_numericos = table2array(media_anual(:, 'mean_altura_referenciada'));

% Converter os meses numéricos em datas numéricas usando datenum
tmp_01 = datenum(num2str(alt_anual), 'yyyy');
figure
plot(tmp_01, media_Anual_numericos);
xlabel('Tempo (anos)');
ylabel('Nível do mar (cm)');
title('Nível médio do mar anual de Fortaleza');
grid on;
datetick('x', 'yyyy', 'keepticks'); 
%%

time_vector = datetime(data_numerica, 'ConvertFrom', 'datenum');
% Fourier analysis to identify seasonal components
num_samples = length(residuo);
sampling_frequency = 1 / days(time_vector(2) - time_vector(1)); % Assuming daily data

% Perform Fourier transform
residual_fft = fft(residuo);
frequency_axis = (0:num_samples-1) * sampling_frequency / num_samples;

% Plot the frequency spectrum
figure;
plot(frequency_axis, abs(residual_fft));
title('Frequency Spectrum');
xlabel('Frequency');
ylabel('Amplitude');
xlim([0, sampling_frequency/2]); % Show only positive frequencies

% Identify dominant frequencies representing seasonal components
% Find peaks in the frequency spectrum
[pks, locs] = findpeaks(abs(residual_fft), 'MinPeakHeight', max(abs(residual_fft)) * 0.1); % Adjust threshold as needed

% Extract corresponding frequencies
dominant_frequencies = frequency_axis(locs);
% Display dominant frequencies representing potential seasonal components
disp('Dominant frequencies representing potential seasonal components:');
disp(dominant_frequencies);

% You can further analyze or filter the seasonal components based on identified frequencies.


