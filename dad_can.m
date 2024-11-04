% Limpar o ambiente
clear all;
close all;
clc;

% Carregar os dados do arquivo
try
    dado = importdata('dad01.txt');
    data = dado.textdata(:,1);
    hora = dado.textdata(:,2);
    altura_zero = dado.data(:,1); %em milimetro 
    %altura = mean(altura_zero);
    
    data_hora_str = strcat(data, {' '}, hora);
    data_numerica = datenum(data_hora_str, 'dd/mm/yyyy HH:MM');
catch
    error('Erro ao carregar os dados do arquivo.');
end

% Calcular os percentis anuais
try
    % Extrair o ano de cada data
    anos = year(datetime(data_numerica, 'ConvertFrom', 'datenum'));
    anos_unicos = unique(anos); % Obter os anos únicos presentes nos dados

    % Inicializar arrays para armazenar os percentis anuais
    percentis = zeros(length(anos_unicos), 13); % 13 percentis, de 0.05 a 99.95

    % Calcular os percentis para cada ano
    for i = 1:length(anos_unicos)
        ano_atual = anos_unicos(i);
        indices_ano_atual = find(anos == ano_atual); % Índices das datas do ano atual
        alturas_ano_atual = altura_zero(indices_ano_atual); % Alturas correspondentes ao ano atual
        percentis_ano_atual = prctile(alturas_ano_atual, [0.05 0.5 2 5 10 20 50 80 90 95 98 99.5 99.95]); % Calcular percentis
        percentis(i, :) = percentis_ano_atual; % Armazenar os percentis calculados
    end
catch
    error('Erro ao calcular os percentis anuais.');
end

% Inicializar matrizes para armazenar os coeficientes harmônicos para cada ano
coeficientes_harmonicos = cell(length(anos_unicos), 1);
componentes_mare = cell(length(anos_unicos), 1);

% Especificar os constituintes manualmente
constituintes_manual = struct();
constituintes_manual.NR.name = {'M2', 'S2', 'N2', 'K2', 'K1'};
constituintes_manual.NR.frq = [1.932273, 2.0, 2.798847, 1.9323, 1.845066];
constituintes_manual.NR.lind = [1, 2, 3, 4, 5]; % Índices dos constituintes na lista de constantes

% Definir o tempo de referência
tref = datenum('26-02-1954'); % Por exemplo, 1 de janeiro de 2000

% Definir a frequência mínima de separação
minres = 1 / (24 * 60); % Por exemplo, 1 minuto

% Chamar UT_CNSTITSEL() com as constituintes especificadas manualmente
try
    [nNR, nR, nI, cnstit, coef] = ut_cnstitsel(tref, minres, constituintes_manual);
catch
    error('Erro ao chamar UT_CNSTITSEL.');
end

% Realizar análise harmônica para cada ano separadamente
for i = 1:length(anos_unicos)
    ano_atual = anos_unicos(i);
    indices_ano_atual = find(anos == ano_atual); % Índices das datas do ano atual
    
    % Extrair alturas do nível do mar para o ano atual
    alturas_ano_atual = altura_zero(indices_ano_atual); 
    
    % Realizar análise harmônica usando o UTide
    coeficientes_harmonicos{i} = ut_solv(data_numerica(indices_ano_atual), ...
                                         alturas_ano_atual, [], -25.01805, 'auto');
    
    % Reconstruir as alturas da maré para o ano atual
    [componentes_mare{i}] = ut_reconstr(data_numerica(indices_ano_atual), coeficientes_harmonicos{i});
end

% Agora temos os coeficientes harmônicos e as alturas da maré reconstruídas para cada ano.
% Podemos utilizar essas informações para análises adicionais, se necessário.
% Inicializar matrizes para armazenar as principais componentes de maré e seus sinais-ruído para cada ano
% Inicializar matrizes para armazenar as principais componentes de maré e seus sinais-ruído para cada ano
principais_componentes = cell(length(anos_unicos), 1);
sinal_ruido = cell(length(anos_unicos), 1);


% Inicializar matrizes para armazenar as amplitudes e fases da componente M2 para cada ano
amplitudes_M2 = zeros(length(anos_unicos), 1);
fases_M2 = zeros(length(anos_unicos), 1);

% Extrair amplitudes e fases da componente M2 para cada ano
for i = 1:length(anos_unicos)
    % Obter os coeficientes harmônicos para o ano atual
    coeficientes_atual = coeficientes_harmonicos{i};
    
    % Encontrar o índice da componente M2 nos coeficientes
    indice_M2 = find(strcmp(coeficientes_atual.name, 'M2'));
    
    % Extrair amplitude e fase da componente M2
    amplitude_M2 = coeficientes_atual.A(indice_M2);
    fase_M2 = coeficientes_atual.g(indice_M2);
    
    % Armazenar amplitude e fase da componente M2 para o ano atual
    amplitudes_M2(i) = amplitude_M2;
    fases_M2(i) = fase_M2;
end

% Plotar amplitudes da componente M2 ao longo do tempo
figure;
plot(anos_unicos, amplitudes_M2, 'o-', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Amplitude da Componente M2');
title('Amplitude da Componente M2 ao Longo do Tempo');
grid on;

% Plotar fases da componente M2 ao longo do tempo
figure;
plot(anos_unicos, fases_M2, 'o-', 'LineWidth', 1.5);
xlabel('Ano');
ylabel('Fase da Componente M2 (graus)');
title('Fase da Componente M2 ao Longo do Tempo');
grid on;





























