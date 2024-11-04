clc; clear all; close all;

% Carregue os dados
dado = importdata('sant_716_2005_2022.txt');
data = dado.textdata(:, 1);
hora = dado.textdata(:, 2);
altura_01 = dado.data(:, 1);

%datum vertical, enconto o valor nas ficha maregráfica; 
datum = 5.2363 ;

% Referenciar o dado ao maregrafo de imbituba
altura_zero = altura_01 - datum;

% Calcular a nova média após referenciar ao imbituba. 
media_alt = mean(altura_zero);

% Remover a média dos dados para que esteja em torno do zero.
altura_referenciada_01 = altura_zero - media_alt;

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
Trend = 0.2873


%{
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
title('Nível médio anual do Santana','FontSize', 22);
grid on;
datetick('x', 'mmm yyyy', 'keepticks');
%}


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
title('Nível médio anual do Santana','FontSize', 22);
grid on;

% Exemplo para aumentar o tamanho e a fonte do eixo de datas (datetick)
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
legend('Média Mensal', 'Tendência Linear', 'Location', 'northwest','FontSize', 18);
annotation('textbox', [0.2, 0.05, 0.1, 0.1], 'String', ['Tend: ' num2str(Trend, '%.4f') ' cm/ano'], 'FitBoxToText', 'on', 'BackgroundColor', 'w','FontSize', 16, 'FontWeight', 'bold');
%saveas(gcf, 'Santana.svg', 'svg');
%{
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
title('Nível médio do mar anual de santana');
grid on;
datetick('x', 'yyyy', 'keepticks'); 




%analise harmonica
coef = ut_solv (data_numerica, altura_referenciada, [],-0.06139,'auto'); 
[u_fit_i] = ut_reconstr(data_numerica, coef);
residuo = altura_referenciada - u_fit_i;

figure('PaperSize',[20 20],...
       'PaperUnits','centimeters',...
       'InvertHardcopy','on',...
       'PaperPosition',[0 0 20 20],...
       'PaperPositionMode','auto',...
       'Position',[80 80 1800 900]);
plot(data_numerica, residuo,'LineWidth', 1.5); % Médias mensais em preto
%hold on;
%plot(tmp, b1, 'r', 'LineWidth', 1.5); % Tendência em vermelho
xlabel('Tempo (meses)');
ylabel('Residuo (cm)');
title('Variação do Residuo em Santana');
grid on;
datetick('x', 'dd mmm yyyy', 'keepticks');

% Adicione a legenda
%legend('Média Mensal', 'Tendência Linear', 'Location', 'northwest');

% Adicione o valor da tendência linear abaixo da legenda
%annotation('textbox', [0.2, 0.05, 0.1, 0.1], 'String', ['Tend: ' num2str(Trend, '%.4f') ' cm/ano'], 'FitBoxToText', 'on', 'BackgroundColor', 'w');
%saveas(gcf, 'santana 1 .svg', 'svg');


datetime_combined = datetime(strcat(data, {' '}, hora), 'InputFormat', 'dd/MM/yyyy HH:mm');

disp(datetime_combined);
%}