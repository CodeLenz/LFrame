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


### Using the package

Para rodar o exemplo, abra o Prompt de Comando e inicie o Julia
```bash
julia
```
e carregue o pacote LFrame
```bash
using LFrame
```

Após, localize o local do arquivo .yaml de entrada
```bash
cd("Local do arquivo")
```
Assim é só rodar o arquivo escolhido
```bash
U, malha = Analise3D("arquivo.yaml")
```
em que U é o vetor de deslocamentos generalizados da estrutura e malha é uma struct com os dados da malha do problema.

Para rodar os arquivos de exemplo que estão disponíveis no pacote LFrame, pode-se localizar a pasta de instalação com 
```bash
  # Path do LFrame 
  path_LFrame = dirname(dirname(pathof(LFrame)))

  # Path para o diretorio de exemplos
  caminho = joinpath(path_LFrame, "examples")

  # Muda para o diretório 
  cd(caminho)
```
e selecionar um dos exemplos disponíveis no diretório
```bash
U,malha = Analise3D("hibbeler86.yaml")
```


# Esforços internos

Para a visualização dos esforços interno do exemplo 8.6

Carregue o pacote Plots
```bash
using Plots
```


Obtenha as equações dos esforços internos para o elemento escolhido, neste caso é o elemento "1".

```bash
esforcos,L = Esforcos_internos_elemento(1,malha,U)
```
em que malha e U foram obtidos com Analise3D. L é o comprimento do elemento, que será utilizado para gerarmos os pontos x para os gráficos.

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
  <img src="Imagens/Momento em y.png" alt="Gráfico de momento fletor em y" width="50%">
</p>


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

 Iz - Momento de inércia em torno do eixo z (deve ser central principal de inércia)

 Iy - Momento de inércia em torno do eixo y (deve ser central principal de inércia)

 A  - Área da seção transversal

 α - Ângulo de rotação para o eixo principal de inércia

 J0 - Momento polar de inércia

```bash
geometrias:
  - nome: "tubo1"
    Iz: 1.256637061e-7
    Iy: 1.256637061e-7
    A: 1.256637061e-3
    α: 0
    J0: 2.513274123e-7

  - nome: "tubo2"
    Iz: 2.25e-7
    Iy: 2.25e-7
    A: 1.50e-3
    α: 0
    J0: 3.00e-7

```

Também é possível ler os dados de um arquivo 

```bash
geometrias:
  - File: circular.dat
  - nome: "tubo2"
    Iz: 2.25e-7
    A: 1.50e-3
    Iy: 2.25e-7
    α: 0
    J0: 3.00e-7

```

em que os dados do arquivo .dat devem *obrigatóriamente* na sequência 

```bash
nome:: String
area:: Float
Iz  :: Float
Iyl :: Float
Jeq :: Float
α   :: Float

```

Esse arquivo pode ser gerado automaticamente pelo pacote https://github.com/CodeLenz/Torcao

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

Cada linha é relativa a um elemento. A primeira coluna indica o primeiro nó e a segunda coluna indica o segundo nó.
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

Por exemplo, podemos relacionar os graus de liberdade UX, UY e UZ entre os nós 2 e 3 e também as rotações $\theta_X$, $\theta_Y$ e $\theta_Z$ entre estes mesmos nós

```bash
mpc:
 2 1 3 1
 2 2 3 2
 2 3 3 3
 2 4 3 4
 2 5 3 5
 2 6 3 6
```


### Apoios

Para a definição dos apoios precisamos definir: Nó, gdl local e intensidade. Por exemplo, para engastar o nó 1

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

Esta seção do arquivo tem como objetivo relacionar, com cada elemento da malha, um material e uma seção transversal.
Quanto todos os elementos tem exatamente o mesmo material e a mesma seção, podemos informar apenas uma linha
```bash
dados_elementos:
  aco tubo1
```

Quanto temos mais materiais e seções transversais, devemos informar uma linha para cada elemento (mesmo que isso implique em repetição)
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
#Exercicio 12-49 do Hibbeler 7ºedição utilizando o material aço e seção transversal de um circulo de raio 20 mm
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
  
# loads precisa estar definida, mesmo se não ter forças concentradas
loads: 

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


# Testes 

No Julia, o módulo Test é utilizado para escrever testes automatizados, que ajudam a garantir que seu código funciona corretamente agora e continue funcionando no futuro, mesmo após modificações. Ele faz parte da biblioteca padrão do Julia, então você não precisa instalar nada extra para usá-lo.


### Running test

Para rodar o exemplo, abra o Prompt de Comando e inicie o Julia
```bash
julia
```
Após, entre em modo Pkg e execute os testes

```bash
] test LFrame
```
