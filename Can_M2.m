clear all;
close all;
clc;

% Diretório onde estão os arquivos de texto
diretorio = 'C:\Users\labdi\Documents\MATLAB\t_tide_v1.5beta\NM';

% Obter a lista de nomes de arquivos no diretório
lista_arquivos = dir(fullfile(diretorio, '*.dtf'));
num_arquivos = length(lista_arquivos);

% Inicializar uma matriz para armazenar os dados de todos os arquivos
dados_totais = [];

% Loop para carregar e combinar os dados de cada arquivo
for i = 1:num_arquivos
    arquivo_atual = fullfile(diretorio, lista_arquivos(i).name);
    dados_arquivo = importdata(arquivo_atual); % Carrega os dados do arquivo
    dados_totais = [dados_totais; dados_arquivo]; % Adiciona os dados à matriz total
end

dados_bsr = find(dados_totais(:,6) == -9.9900);
coluna_indice = 6;  % Defina o índice da coluna que deseja limpar

% Encontre os índices dos valores que precisam ser cortados na coluna específica
indices_a_remover = find(dados_totais(:, coluna_indice) == 9.990);

% Encontre os índices dos valores que precisam ser mantidos na coluna específica
indices_a_manter = dados_totais(:, coluna_indice) ~= 9.990;
% Crie uma nova matriz excluindo as linhas indesejadas
dados_bsr = dados_totais(indices_a_manter, :);

% Criar a matriz para armazenar os valores numéricos
ano = dados_bsr(:,2);
mes = dados_bsr(:,3);
dias = dados_bsr(:,4);
horas = dados_bsr(:,5);

altura = dados_bsr(:,6);

% Criar uma matriz com as informações de ano, mês, dias e horas
tmp_matriz = [dados_bsr(:, 2:4)];