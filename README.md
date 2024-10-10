# LFrame - Otimização Topológica de Pórticos 3D

Este repositório contém os códigos desenvolvidos para o projeto de Iniciação Científica que visa otimizar estruturas compostas por elementos de pórtico em três dimensões, sem perdas no desempenho com a retirada de material.

## Sobre o nosso projeto

Utilizando o Método dos Elementos Finitos, implementamos técnicas de Otimização Topológica para elementos com seis graus de liberdade por nó. Buscamos minimizar o volume da estrututura com restrições de tensão e deslocamento.

### Pontos principais

- Modelagem de elementos de pórtico
- Função objetivo
- Utilização de ferramentas de visualização para a geração da malha e resultados
- Fácil implementação de exemplos para validação

### Como funciona

  - Definimos o problema em um arquivo .yaml
  - Realizamos a análise inicial por MEF
  - Inicia-se o processo de otimização e análise de sensibilidade
  - Verificamos a convergência
  - Caso o processo tenha fnalizado, o arquivo para visualização .pos para uso no software livre Gmsh é gravado.

## Como usar:
### Requerimentos:
- Linguagem Julia
- O módulo 'Viga3D'
- Outras dependências que podem ser vistas em 'colocar aqui'

## Exemplos de uso:
Colocar os exemplos aqui

<p align="center">
<img src="./docs/beam.jpeg"  width="300">
</p>
 
