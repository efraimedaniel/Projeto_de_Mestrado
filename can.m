clc;
clear all;
close all;

% Diretório onde estão os arquivos de texto
diretorio = 'C:\Users\labdi\Desktop\UTideCurrentVersion (5)\dados';

% Obter a lista de nomes de arquivos no diretório
lista_arquivos = dir(fullfile(diretorio, '*.mat'));
num_arquivos = length(lista_arquivos);

% Inicializar vetores para armazenar os dados de tempo e alturas de todos os arquivos
tempo_total = [];
alturas_total = [];

% Loop para carregar e combinar os dados de cada arquivo
for i = 1:num_arquivos
    arquivo_atual = fullfile(diretorio, lista_arquivos(i).name);
    dados_arquivo = load(arquivo_atual); % Carrega os dados do arquivo
    
    % Certifique-se de que os dados de tempo estão em um formato adequado (datetime, datenum, etc.)
    % Suponha que os dados de tempo estão em uma variável chamada 'tempo' e os dados de altura em 'alturas'
    
    % Adicione os dados de tempo e alturas aos vetores totais
    tempo_total = [tempo_total; dados_arquivo.dados.tempo];
    alturas_total = [alturas_total; dados_arquivo.dados.alturas];
end

% Agora, 'tempo_total' e 'alturas_total' contêm todos os dados de tempo e alturas de todos os arquivos concatenados
%{
% Criar uma tabela com as datas e os dados observados
tabela = table(tempo_total, alturas_total);

% Extrair o ano e o mês separadamente
dados_tabela.Ano = year(tabela.tempo_total);
dados_tabela.Mes = month(tabela.tempo_total);
% Adicionar a coluna alturas_total à tabela dados_tabela
% Crir um número de série no formato YYYYMM
dados_tabela.MesAno = dados_tabela.Ano * 100 + dados_tabela.Mes;

dados_tabela.alturas_total = alturas_total;


% Crie uma tabela auxiliar apenas com a coluna 'alturas_total'
tabela_auxiliar = table(dados_tabela.alturas_total);

% Calcule a média mensal da coluna 'alturas_total' usando a tabela auxiliar
media_mensal = varfun(@mean, tabela_auxiliar, 'GroupingVariables', dados_tabela.MesAno);

% Renomeie a variável resultante
media_mensal.Properties.VariableNames{'alturas_total_mean'} = 'MediaMensal';
%}

altura_total_01 = nanmean(alturas_total);
alturas_total = alturas_total - altura_total_01;

% Criar uma tabela com as datas e os dados observados
%tabela = table(tempo_total, var * 100);
% Criar uma tabela com as datas e os dados observados
tabela = table(tempo_total, alturas_total * 100, 'VariableNames', {'tempo_total', 'alturas_total'});

% Criar uma tabela com as datas e as alturas
tabela = table(tabela.tempo_total, tabela.alturas_total, 'VariableNames', {'Tempo', 'Alturas'});

% Extrair o ano e o mês separadamente
dados_tabela.Ano = year(tabela.Tempo);
dados_tabela.Mes = month(tabela.Tempo);

% Criar um número de série no formato YYYYMM
dados_tabela.MesAno = dados_tabela.Ano * 100 + dados_tabela.Mes;

% Criar uma função anônima para calcular a média
funcao_media = @(x) mean(x);

% Calcular a média mensal das alturas
media_mensal = splitapply(funcao_media, tabela.Alturas, findgroups(dados_tabela.MesAno));
% Exibir a tabela com as médias mensais
%disp(media_mensal);
% Criar uma tabela com as médias mensais
tabela_media_mensal = table(unique(dados_tabela.MesAno), media_mensal, 'VariableNames', {'MesAno', 'MediaMensal'});

% Valores médios mensais ja calculado.
meses_numericos = table2array(tabela_media_mensal(:, 'MesAno'));

media_mensal_numericos = table2array(tabela_media_mensal(:, 'MediaMensal'));

% Converter os meses numéricos em datas numéricas usando datenum
tmp = datenum(num2str(meses_numericos), 'yyyymm');
desvio = nanstd(media_mensal_numericos)

% Crie o gráfico
figure (1)
plot(tmp, media_mensal_numericos);
xlabel('Data');
ylabel('Média Mensal');


%reg linear dado
% Preencha os valores NaN com a média dos valores não NaN
% Encontre os índices dos valores NaN em media_mensal_numericos
indices_nan = isnan(media_mensal_numericos);

% Remova os valores NaN dos vetores de entrada
tmp_sem_nan = tmp(~indices_nan);
media_mensal_sem_nan = media_mensal_numericos(~indices_nan);

% Ajuste o modelo aos dados sem NaN
vetor_tmp_sem_nan = [ones(length(tmp_sem_nan), 1) tmp_sem_nan];
x1_sem_nan = vetor_tmp_sem_nan\media_mensal_sem_nan;

% Calcule os coeficientes do modelo ajustado
b1_sem_nan = (vetor_tmp_sem_nan * x1_sem_nan);
%maxb1_sem_nan = max(b1_sem_nan);
%minb1_sem_nan = min(b1_sem_nan);
%slr1_sem_nan = maxb1_sem_nan - minb1_sem_nan;
%maxb1 = max(b1);
%minb1 = min(b1);
%slr1 = maxb1 - minb1;
Trend = 0.4088



figure('PaperSize',[20 20],...
       'PaperUnits','centimeters',...
       'InvertHardcopy','on',...
       'PaperPosition',[0 0 20 20],...
       'PaperPositionMode','auto',...
       'Position',[80 80 1800 900]);
plot(tmp_sem_nan, media_mensal_sem_nan, 'k', 'LineWidth', 1.5, 'DisplayName', 'Observado'); % Observado em azul
hold on;
plot(tmp_sem_nan, b1_sem_nan, 'r', 'LineWidth', 1.5, 'DisplayName', 'Tendência'); % Tendência em vermelho
xlabel('Tempo (meses)','FontSize', 18);
ylabel('Nível do mar (cm)','FontSize', 18);
title('Nível médio do mar anual de Cananéia','FontSize', 22);
grid on;
datetick('x', 'mmm yyyy', 'keepticks');
ax = gca; % Obter o eixo atual
ax.FontSize = 14; % Tamanho da fonte
ax.FontWeight = 'bold'; % Negrito
legend('Média Mensal', 'Tendência Linear', 'Location', 'northwest','FontSize', 18);
annotation('textbox', [0.2, 0.05, 0.1, 0.1], 'String', ['Tend: ' num2str(Trend, '%.4f') ' cm/ano'], 'FitBoxToText', 'on', 'BackgroundColor', 'w','FontSize', 16,'FontWeight', 'bold');

saveas(gcf, 'can.svg', 'svg');
%%
%criar uma serie temporal com uma media anual
tabela_01 = table(tempo_total, alturas_total);

% Extrair o ano e o mês separadamente
dados_tabela_01.Ano = year(tabela.Tempo);

% Criar um número de série no formato YYYY
dados_tabela_01.Ano = dados_tabela.Ano

% Criar uma função anônima para calcular a média
funcao_media = @(x) mean(x);

% Calcular a média mensal das alturas
media_anual = splitapply(funcao_media, tabela_01.alturas_total, findgroups(dados_tabela_01.Ano));

tabela_media_anual = table(unique(dados_tabela.Ano), media_anual, 'VariableNames', {'Ano', 'MediaMensal'});

% Valores médios mensais ja calculado.
anual_numericos = table2array(tabela_media_anual(:, 'Ano'));

media_anual_numericos = table2array(tabela_media_anual(:, 'MediaMensal'));

% Converter os meses numéricos em datas numéricas usando datenum
tmp_01 = datenum(num2str(anual_numericos), 'yyyy');



figure
plot(tmp_01, media_anual_numericos);
xlabel('Tempo (anos)');
ylabel('Nível do mar (cm)');
title('Nível médio do mar anual de Imbituba');
grid on;
datetick('x', 'yyyy', 'keepticks');

%%


%analise harmonica
coef = ut_solv (tmp_sem_nan, media_mensal_sem_nan, [],-12.97397,'auto'); 
[u_fit_i] = ut_reconstr(tmp, coef);








