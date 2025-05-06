# LFrame - Finite Element Analysis of Spatial Frames


Welcome to our repository 🫶

This is my Undergraduate Research Project from the past one and a half years. Its goal is to perform a comprehensive analysis of structures discretized into frame elements.


## About Our Project 💻


### Key Points 🔐

- Modeling of frame elements
- Easy implementation of examples for validation

### How it works 

  - We define the problem in a `.yaml` file
  - We perform the  analysis using FEM
  
## How to use
### Requirements:
- Julia Language -- make sure it's up to date
- Gmsh -- required for visualizing the results

### Installation:

```bash
]add https://github.com/CodeLenz/LFrame
```

## Input file

O arquivo de entrada deve ser informado no formato YAML, com campos opcionais e campos obrigatórios...

### Campos opcionais

### Título do arquivo

```bash

titulo = "Titulo"

```

### Data de criação do arquivo 
```bash
data = "01/01/2000"
```

### Versão do arquivo 
```bash
versao = 1.0
```

### Informação sobre os materiais 
 Nome do material 

 Ex    - Módulo de elasticidade longitudinal

 G     - Módulo de cisalhamento

 S_esc - Tensão de escoamento

```bash
materiais:               
  - nome: "aco"          
    G: 8.0e10            
    Ex: 2.1e11           
    S_esc: 350e6      

  - nome: "aluminio"          
    G: 2.6e10            
    Ex: 7.0e10           
    S_esc: 276e6      
```

### Informações sobre as forças concentradas
loads: nó gdl intensidade

```bash
loads:  4 3 -3000
        4 4 -5000
        4 2 -1000
```
### Informações de geometria
 Nome da geometria

 Iz - Momento de inércia em torno do eixo z

 A  - Área da seção transversal

 Iy - Momento de inércia em torno do eixo y

 α - Ângulo de rotação para o eixo principal de inércia

 J0 - Momento polar de inércia

```bash
geometrias:
  - nome: "tubo1"
    Iz: 1.256637061e-7
    A: 1.256637061e-3
    Iy: 1.256637061e-7
    α: 0
    J0: 2.513274123e-7

  - nome: "tubo2"
    Iz: 2.25e-7
    A: 1.50e-3
    Iy: 2.25e-7
    α: 0
    J0: 3.00e-7


```

### Coordenadas
As coordenadas precisam ser descritas em x, y, z, cada linha trata-se de um nó


```bash
coordenadas:
  0.0 -0.125 0.0
  0.0  0.0   0.0
  0.0  0.150 0.0
  0.20 0.150 0.0
```

### Conectividades
A conectividade informa quais nós, estão ligados ou seja está se tornando um elemento.
```bash
  conectividades: 
    1 2 
    2 3
    3 4
```

### Apaios
Para a definição dos apoios precisa definir: Nó, gdl e intencidade.

```bash
apoios: 
  1 1 0.0
  1 2 0.0
  1 3 0.0
  1 4 0.0
  1 5 0.0
  1 6 0.0
```

### Dados dos Elementos
Para os elementos criados, tem duas opções para informar os dados. 
A primeira define-se que todos os elementos tem o mesmo material e a mesma geometria.
```bash
dados_elementos:
  aco tubo1
```
Lebrar que define sempre o nome do material e depois o nome da geometria definidos anteriormente. 

Para dois tipo de materiais e gometria:
```bash
dados_elementos
  aco tubo1
  aco tubo2
  aluminio tubo2

```

## Exemplos e validação

### Exemplo 8.6 Hibbler (Força Concentrada)

Exemplo 8.6 do livro Resistência dos Materiais de Russell Charles Hibbeler, 10º edição
 
<p align="center">
  <img src="Imagens/Força Concentrada.png" alt="Exemplo 8.6 Livro Hibbeler 10º edição" width="50%">
</p>

Criando o arquivo hibbeler86.yaml

```bash
materiais:            
  - nome: "aco"        
    G: 8.0e10          
    Ex: 2.1e11        
    S_esc: 350e6

loads: 4 3 -3000       

geometrias:
  - nome: "tubo1"
    Iz: 1.256637061e-7
    A: 1.256637061e-3
    Iy: 1.256637061e-7
    α: 0
    J0: 2.513274123e-7

coordenadas:
  0.0 -0.125 0.0
  0.0  0.0   0.0
  0.0  0.150 0.0
  0.20 0.150 0.0

conectividades: 
  1 2 
  2 3
  3 4

apoios: 
  1 1 0.0
  1 2 0.0
  1 3 0.0
  1 4 0.0
  1 5 0.0
  1 6 0.0

dados_elementos:
  aco tubo1
  aco tubo1
  aco tubo1
```

### Running an Example:
Para rodar o exemplo, abra o Prompt de Comando e inicie o Julia
```bash
julia
```
Após, localize o local do Arquivo LFrame

```bash
cd("Local do arquivo")
```
Com isso, utilize o LFrame
```bash
using LFrame: Analise3D
```
Assim é só rodar o arquivo escolhido, neste caso é o hibbeler86.yaml
```bash
Analise3D("hibbeler86.yaml")
```