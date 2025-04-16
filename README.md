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

#### Título do arquivo

```bash

titulo = "Titulo"

```

#### Data de criação do arquivo 
```bash
data = "01/01/2000"
```

#### Versão do arquivo 
```bash
versao = 1.0
```

##### Informação sobre os materiais 
 nome do material 

 Ex    - Módulo de elasticidade longitudinal

 G     - Módulo de cisalhamento

 S_esc - Tensão de escoamento

```bash
materiais:               
  - nome: "mat1"          
    G: 8.0e10            
    Ex: 2.1e11           
    S_esc: 350e6      
  - nome: "mat2"          
    G: 9.0e10            
    Ex: 1.1e11           
    S_esc: 250e6      
```

   

### Exemplo de análise

Creating the .yaml file using Example 8.6 from the book Resistência dos Materiais by Russell Charles Hibbeler, 10th edition.

```bash
materiais:               # Material properties are listed here. Multiple materials can be defined in the same script.
  - nome: "aco"          # Material Name 
    G: 8.0e10            # Modulus of rigidity.
    Ex: 2.1e11           # Young's modulus.
    S_esc: 350e6         # Yield strength.
    
loads: 4 3 -3000        # Concentrated force at node 4 at DOF 3 with an intensity of -3000 N.

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
To run an exemple, simply use
```bash
   Analise3D(file)
```