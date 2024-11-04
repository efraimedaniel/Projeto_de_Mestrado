clc; clear all; close all;

% Carregue os dados
dado = importdata('imbi_718_2001_2021.txt');
data = dado.textdata(:, 1);
hora = dado.textdata(:, 2);
altura_01 = dado.data(:, 1);

%datum vertical, enconto o valor nas ficha maregráfica; 
datum = 1.580;

% Referenciar o dado ao maregrafo de imbituba
altura_zero = altura_01 - datum;

% Calcular a nova média após referenciar ao imbituba. 
media_alt = mean(altura_zero);

% Remover a média dos dados para que esteja em torno do zero.
altura_referenciada_01 = altura_zero - media_alt; 
des1 = std(altura_referenciada_01)
%Converter para centimetros
altura_referenciada = (altura_referenciada_01 * 100);  % em centímetros

% Converter data e hora na mesma coluna e transformar em datenum
data_hora_str = strcat(data, {' '}, hora);
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
des = std(media_mensal_numericos)

% Crie o gráfico
figure(1)
plot(tmp, media_mensal_numericos);
xlabel('Data');
ylabel('Média Mensal');
title('Média Mensal do Nível do Mar em Imbituba (2001-2021)');

%reg linear dado
vetor_tmp = [ones(length(tmp), 1) tmp];
x1 = vetor_tmp\media_mensal_numericos;
b1 = (vetor_tmp*x1);
%maxb1 = max(b1);
%minb1 = min(b1);
%slr1 = maxb1 - minb1;
Trend = 0.3942

figure('PaperSize',[20 20],...
       'PaperUnits','centimeters',...
       'InvertHardcopy','on',...
       'PaperPosition',[0 0 20 20],...
       'PaperPositionMode','auto',...
       'Position',[80 80 1800 900]);
plot(tmp, media_mensal_numericos, 'k', 'LineWidth', 1.5); % Médias mensais em preto
hold on;
plot(tmp, b1, 'r', 'LineWidth', 1.5); % Tendência em vermelho
xlabel('Tempo (meses)', 'Fontsize', 18);
ylabel('Nível do mar (cm)', 'Fontsize', 18);
title('Nível Médio do Mar Anual de Imbituba ao Longo do Tempo', 'FontSize', 22);
grid on;
datetick('x', 'mmm yyyy', 'keepticks');
ax = gca; % Obter o eixo atual
ax.FontSize = 14; % Tamanho da fonte
ax.FontWeight = 'bold'; % Negrito
% Adicione a legenda
legend('Média Mensal', 'Tendência Linear', 'Location', 'northwest' , 'FontSize', 18);

% Adicione o valor da tendência linear abaixo da legenda
annotation('textbox', [0.2, 0.05, 0.1, 0.1], 'String', ['Tend: ' num2str(Trend, '%.4f') ' cm/ano'], 'FitBoxToText', 'on', 'BackgroundColor', 'w', 'FontSize', 16,'FontWeight', 'bold');
%saveas(gcf, 'fig_imbituba01.svg', 'svg');
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

% Agrupar os dados por ano e calcular a média anual 
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
title('Nível médio do mar anual de Imbituba');
grid on;
datetick('x', 'yyyy', 'keepticks');




%%
%analise harmonica

cnstit02 = {'K1'};

%coef = ut_solv (tmp_01, media_Anual_numericos, [],-22.97250,'auto'); 
coef02 = ut_solv(tmp_01, media_Anual_numericos, [], -22.97250, cnstit02);

%[u_fit_i] = ut_reconstr(tmp_01, coef);
[mare_dani02] = ut_reconstr(tmp_01, coef02);

% Plot the reconstructed tidal signal
figure;
plot(tmp_01, mare_dani02, 'r');
datetick('x', 'dd/mm/yyyy HH:MM', 'keepticks');
xlabel('Data e Hora');
ylabel('Altura da Maré (mm)');
title('Reconstrução da Altura da Maré para M2');




residuo = altura_referenciada - u_fit_i;
figure('PaperSize',[20 20],...
       'PaperUnits','centimeters',...
       'InvertHardcopy','on',...
       'PaperPosition',[0 0 20 20],...
       'PaperPositionMode','auto',...
       'Position',[80 80 1800 900]);
plot(data_numerica, residuo, 'c', 'LineWidth', 1.5); % Médias mensais em preto
%hold on;
%plot(tmp, b1, 'r', 'LineWidth', 1.5); % Tendência em vermelho
xlabel('Tempo (meses)');
ylabel('Residuo (cm)');
title('Variação do Residuo em Imbituba');
grid on;
datetick('x', 'dd mmm yyyy', 'keepticks');

% Adicione a legenda
%legend('Média Mensal', 'Tendência Linear', 'Location', 'northwest');

% Adicione o valor da tendência linear abaixo da legenda
%annotation('textbox', [0.2, 0.05, 0.1, 0.1], 'String', ['Tend: ' num2str(Trend, '%.4f') ' cm/ano'], 'FitBoxToText', 'on', 'BackgroundColor', 'w');
%saveas(gcf, 'fig_imbituba 1 .svg', 'svg');

% Montar a matriz de projeto para uma regressão linear
%A0 = [ones(length(tmp), 1) tmp];

% Calcular os coeficientes da regressão linear
%x2 = A0 \ media_mensal_numericos;

% Calcular os valores ajustados
%b2 = A0 * x2;
%{
% Plotar os resultados
figure(3);
plot(tmp, media_mensal_numericos, 'r'); % Dados observados em vermelho
hold on;
plot(tmp, b2, 'k'); % Modelo ajustado em preto
title('Variação Sazonal dos Dados', 'FontSize', 16);
hold off;

% regressão quadratica oferece melhor ajuste
A3 = [ones(length(tmp),1) tmp tmp.^2]
x3 = A3\media_mensal_numericos
b3 = (A3*x3)
figure(4)
subplot(2,1,1)
plot(tmp,media_mensal_numericos,'r')
hold on;
    title(['Calculo da media (regressao quadratica) de CO2'],'FontSize',16);
plot(tmp,b2,'b')
%regressao quadratica
plot(tmp, b3,'k')
hold on;
subplot(2,1,2)
plot(tmp,media_mensal_numericos - b3);
%remover = media_mensal_numericos - b2
% Regressão linear
vetor_tmp = [ones(length(tmp), 1) tmp];
x1 = vetor_tmp \ media_mensal_numericos;
b1 = vetor_tmp * x1;
maxb1 = max(b1);
minb1 = min(b1);
slr1 = maxb1 - minb1;

% Figura 2 - Gráfico de Resíduos e Modelo Ajustado
figure(2);
plot(tmp, media_mensal_numericos, 'k', 'LineWidth', 1.5); % Resíduos em azul
hold on;
plot(tmp, b1, 'r', 'LineWidth', 1.5); % Modelo ajustado em vermelho
xlabel('Data');
ylabel('Variação de nível do mar');
title('Gráfico de Resíduos e Modelo Ajustado');
grid on;
datetick('x', 'mmm yyyy', 'keepticks');
%}
% Regressão linear
A2 = [ones(length(tmp), 1) tmp];
x2 = A2 \ media_mensal_numericos;
b2 = A2 * x2;

% Figura 3 - Variação Sazonal dos Dados
figure(3);
plot(tmp, media_mensal_numericos, 'r'); % Dados observados em vermelho
hold on;
plot(tmp, b2, 'k'); % Modelo ajustado em preto
title('Variação Sazonal dos Dados', 'FontSize', 16);
hold off;

% Regressão quadrática oferece melhor ajuste
A3 = [ones(length(tmp), 1) tmp tmp.^2];
x3 = A3 \ media_mensal_numericos;
b3 = A3 * x3;

% Figura 4 - Comparação de Regressões
figure(4);
subplot(2, 1, 1);
plot(tmp, media_mensal_numericos, 'r');
hold on;
title('Calculo da média (regressão quadrática)', 'FontSize', 16);
plot(tmp, b2, 'b'); % Regressão linear
plot(tmp, b3, 'k'); % Regressão quadrática
hold off;

subplot(2, 1, 2);
plot(tmp, media_mensal_numericos - b3);

A4 = [ones(length(tmp), 1) tmp];

x4 = A4 \ media_mensal_numericos;

b4 = A4 * x4;

slr4 = media_mensal_numericos - b4;
% plotes
figure(5)
plot(tmp, media_mensal_numericos, 'r');

hold on 

plot(tmp, b4, 'k');
title(['modelo linear ajustado']);

figure(6)
plot(tmp, slr4);
title(['sinal residual da maré']);
 % remover as tendencias linear 
A5 = [ones(length(tmp), 1) tmp tmp.^2];
x5 = A5 \ media_mensal_numericos;

slr5 = A5 * x5;

slr5_sen_tnd = media_mensal_numericos - slr5;
figure(7)
plot(tmp, media_mensal_numericos, 'r');
hold on;
plot(tmp, slr5_sen_tnd, 'k');
title(['nivel do mar sem tendencia linear em (preto) sinal sem a tendencia quadratica (vermelho)']);

%analise do ciclo anual das marés
A6 = [ones(length(tmp), 1) sin(2*pi*tmp) cos(2*pi*tmp) sin(4*pi*tmp) cos(4*pi*tmp)];
x6 = A6 \ slr5_sen_tnd;
slr6 = A6 * x6;
slr6sen_01 = media_mensal_numericos - slr6;

figure(8)
subplot(2,1,1)
plot(tmp, b3, 'r');
hold on
plot(tmp, slr6sen_01, 'k');
hold on;
title(['nivel sem sinal sazonal'])
subplot(2,1,2)
plot(tmp, slr5_sen_tnd,'r');
hold on;
plot(tmp, slr6, 'k');
hold on; 
title(['ciclos anuais'])
hold off;

% sinal residual sem tendencias quadraticas e sem oscilações anuais
slr_st_08 = media_mensal_numericos - b3 - slr6;
figure (9)
plot(tmp, slr_st_08, 'k')
title(['sinal residual de nivel, sem tendencia ^2 e oscilações anual'])


%{
altura_media_diaria = mean(altura_referenciada, 2);
% Crie uma série temporal com as médias diárias
dados_serie_temporal = timeseries(altura_media_diaria, 1:size(altura_media_diaria, 1));
% Resample os dados para média mensal
dados_mensais = resample(dados_serie_temporal, 'monthly');







%converter datas e horas para números
data_hora_str = strcat(data, {' '}, hora);
data_numerica = datenum(data_hora_str, 'dd/mm/yyyy HH:MM');

 % Subtrair a média móvel de 30 dias centrada de cada hora de dados
%window_size = 30 * 24; % 30 dias em horas
%trend_removed_data = data_numerica - movmean(data_numerica, window_size);



%calcular os confiente usando a função ut_solv
coef = ut_solv (data_numerica, altura_referenciada, [],-22.97250,'auto'); 

%renconstruir a função coefinciente
 %[u_fit_i] = ut_reconstr(data_numerica, coef);

 
 % Suponha que você queira obter as amplitudes e fases dos constituintes M2 e S2
M2_amplitude = coef.A(1); % Ajuste o índice para M2
M2_phase = coef.g(1);    % Ajuste o índice para M2

S2_amplitude = coef.A(2); % Ajuste o índice para S2
S2_phase = coef.g(2);    % Ajuste o índice para S2
 
 % Suponha que você queira prever os níveis de maré astronômicos para o ano 'ano'
% Use os constituintes estimados para aquele ano
[u_fit_i] = ut_reconstr(data_numerica, coef);
 res = altura_referenciada - u_fit_i;

%reg linear dado
vetor_tmp = [ones(length(data_numerica), 1) data_numerica];
x1 = vetor_tmp\altura_referenciada;
b1 = (vetor_tmp*x1);
maxb1 = max(b1);
minb1 = min(b1);
slr1 = maxb1 - minb1


%reg linear astronomica
vetor_tmp = [ones(length(data_numerica), 1) data_numerica];
x2 = vetor_tmp\u_fit_i;
b2 = (vetor_tmp*x2);
maxb2 = max(b2);
minb2 = min(b2);
slr2 = maxb2 - minb2

%reg linear residuo
vetor_tmp = [ones(length(data_numerica), 1) data_numerica];
x3 = vetor_tmp\res;
b3 = (vetor_tmp*x3);
maxb3 = max(b3);
minb3 = min(b3);
slr3 = maxb3 - minb3
 
%{ 
 %modelo linear 
vetor_tmp = [ones(length(data_numerica), 1) data_numerica];
x1 = altura_referenciada\vetor_tmp;
b = (altura_referenciada*x1);
%}
% Determinar os limites dos eixos Y
%limite_inferior_y = min([min(res), min(b)]) - 0.02; % Reduzir 2 cm para margem
%limite_superior_y = max([max(res), max(b)]) + 0.02; % Adicionar 2 cm para margem

figure;
subplot(3,1,1)
plot(data_numerica, altura_referenciada, 'k', 'LineWidth', 1.5); % Resíduos em azul
hold on;
plot(data_numerica, b1, 'r', 'LineWidth', 1.5); % Modelo ajustado em vermelho
xlabel('Data');
ylabel('Resíduos / Modelo');
title('Gráfico de Resíduos e Modelo Ajustado');
grid on;
legend('Resíduos', 'Modelo Ajustado');
datetick('x', 'mmm yyyy', 'keepticks'); 

subplot(3,1,2)
plot(data_numerica, u_fit_i, 'b', 'LineWidth', 1.5); % Resíduos em azul
hold on;
plot(data_numerica, b2, 'm', 'LineWidth', 1.5); % Modelo ajustado em vermelho
xlabel('Data');
ylabel('Resíduos / Modelo');
title('Gráfico de Resíduos e Modelo Ajustado');
grid on;
legend('Resíduos', 'Modelo Ajustado');
datetick('x', 'mmm yyyy', 'keepticks'); 

subplot(3,1,3)
plot(data_numerica, res, 'c', 'LineWidth', 1.5); % Resíduos em azul
hold on;
plot(data_numerica, b3, 'y', 'LineWidth', 1.5); % Modelo ajustado em vermelho
xlabel('Data');
ylabel('Resíduos / Modelo');
title('Gráfico de Resíduos e Modelo Ajustado');
grid on;
legend('Resíduos', 'Modelo Ajustado');
datetick('x', 'mmm yyyy', 'keepticks'); 
%}
