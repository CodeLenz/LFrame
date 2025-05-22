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

# Input file


O arquivo de entrada deve ser informado no formato YAML, com campos opcionais e campos obrigatórios...

## Campos opcionais

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
## Campos Obrigatórios 


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
```bash
loads: nó gdl intensidade
```

```bash
loads:  4 3 -3000
        4 4 -5000
        4 2 -1000
```

### Informações sobre o carregamento distribuído

A seção floads deve ser utilizada apenas quando há carregamentos distribuídos atuando sobre os elementos do modelo. Ou seja, não é um campo obrigatório para todos os arquivos de entrada, mas deve ser incluído quando aplicável.

```bash
floads: elemento q1y q2y q1z q2z
```

```bash
floads:
  1 -150E3  -150E3  0.0  0.0                                                    
  2 -150E3   0.0    0.0  0.0
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
### MPCs
Multipoint Constraints (MPCs) são restrições que relacionam diretamente os graus de liberdade (GDLs) de dois ou mais nós em uma estrutura. Elas são úteis para impor vínculos entre deslocamentos ou rotações de diferentes nós, como em conexões rígidas ou movimentos dependentes.

A seção mpc deve ser utilizada apenas quando houver necessidade de criar uma relação entre GDLs. Caso contrário, essa seção pode ser omitida do arquivo .yaml.

```bash
mpc:
  nó gdl nó gdl
```

```bash
mpc:
 2 1 3 1
 2 2 3 2
 2 3 3 3
 2 4 3 4
 2 5 3 5
 2 6 3 6
```

Lembrar que nestes casos não existe elemento entre o nó 2 e nó 3, então eles não podem ser definidos na conectividade.

### Apoios

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

# Exemplos:

### Exemplo resolvido 8.6 Hibbler (Força Concentrada)

Exemplo 8.6 do livro Resistência dos Materiais de Russell Charles Hibbeler, 10º edição
 
<p align="center">
  <img src="Imagens/Força Concentrada.png" alt="Exemplo 8.6 Livro Hibbeler 10º edição" width="50%">
</p>

#### Criando o arquivo hibbeler86.yaml

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

### Exercício 12.49 Hibbler (Carregamento Distribuído)

Exercício 12.49 do livro Resistência dos Materiais de Russell Charles Hibbeler, 10º edição
 
<p align="center">
  <img src="Imagens/Carregamento Distribuído.png" alt="Exercício 12.49 Livro Hibbeler 10º edição" width="50%">
</p>

#### Criando o arquivo carregamento_distribuido.yaml

```bash
#
#Exercicio 12-49 do Hibbeler 7ºedição utilizando o material aço e 
#seção transversal de um circulo de raio 20 mm
#

versao: 1.0

materiais:
  - nome: "aco"
    G: 8.0e10
    Ex: 2.1e11
    S_esc: 350e6

floads:
  1 -150E3  -150E3  0.0  0.0                                                    
  2 -150E3   0.0    0.0  0.0
  
loads: # loads precisa estar definida, mesmo se não ter 
#forças concentradas

geometrias:
  - Iz: 1.256637061e-7
    A: 1.256637061e-3
    Iy: 1.256637061e-7
    nome: "tubo1"
    α: 0
    J0: 2.513274123e-7

coordenadas:
  0.0 0.0 0.0
  2.0 0.0 0.0
  5.0 0.0 0.0

conectividades: 
  1 2 
  2 3

#
# Lembrando que o exercício é 2D, mas o programa é 3D sempre
# então devemos também restringir as translações em Z. O Ideal 
# seria também restringir a rotação em X (gl 4) no nó 3, 
# só para garantir
#
apoios: 
  2 2 0.0
  2 3 0.0
  3 1 0.0
  3 2 0.0
  3 3 0.0
  3 4 0.0


dados_elementos:
  aco tubo1

#
# Os resultados esperados são 
#
# Uy no nó 1 (gl 2) = -720E3/(E*I) =   -27.283704539503688
#
# teta_z no no 2 (gl 12) = 210E9 / (E*I) =  7.957747157355244
#
#
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
using LFrame
```
Assim é só rodar o arquivo escolhido, neste caso é o hibbeler86.yaml
```bash
U,_ = Analise3D("examples/hibbeler86.yaml")
```
Para melhor visulização, pode-se printar somente o vetor deslocamento
```bash
U
```

# Esforços internos

Para a visualização dos esforços interno do exemplo 8.6, abra o Prompt de Comando e inicie o Julia
```bash
julia
```

Lembrando que você precisa ter a biblioteca Plots para a visualização dos esforços internos. Caso você não tenha faça:

```bash
]add Plots
```

Utilize as bibliotecas: LFrame e Plots.

```bash
Using LFrame, Plots
```

Calcule o deslocamentos do problema, neste caso é o hibbeler86.yaml.

```bash
U,malha = Analise3D("examples/hibbeler86.yaml")
```

Obtenha as equações dos esforços internos para o elemento escolhido, neste caso é o elemento "1".

```bash
esforcos,L = Esforcos_internos_elemento(1,malha,U)
```

Gerar os pontos x para o gráfico 

x = inicial : posição final/numero de pontos: posição final

```bash
x = 0:L/100:L
```

Por fim, decida qual esforço você quer visualizar e colque em esforcos[número]:

1 - Normal [ N(x) ]

2 - Cortante em y [ Vy(x) ]

3 - Cortante em z [ Vz(x) ]

4 - Torque [ T(x) ]

5 - Momento em y [ My(x) ]

6 - Momento em z [ Mz(x) ]

```bash
plot(x,esforcos[5].(x),title="Momento em y", xlabel = "Comprimento [m]", ylabel = "My [Nm]")
```

<p align="center">
  <img src="Imagens/Momento em y" alt="Gráfico de momento fletor em y" width="50%">
</p>

# Testes 

No Julia, o módulo Test é utilizado para escrever testes automatizados, que ajudam a garantir que seu código funciona corretamente agora e continue funcionando no futuro, mesmo após modificações. Ele faz parte da biblioteca padrão do Julia, então você não precisa instalar nada extra para usá-lo.


### Running test

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
using Test
```
Assim é só rodar o teste para validar os deslocamentos 
```bash
include("test/runtest.jl")
```