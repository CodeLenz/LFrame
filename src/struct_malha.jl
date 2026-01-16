#
# Estrutura que contém as informações sobre o problema
#
struct Malha{TI,TF,TL}

    # Número de elementos
    ne::TI

    # Número de nós
    nnos::TI

    # Coordenadas de cada nó
    # linha = nó
    # colunas = x y z
    coord::Array{TF}

    # Conectividades dos elementos
    # linha = elemento
    # colunas = nó 1 e nó 2
    conect::Array{TI}

    # Array com as informações dos apoios
    # nó gl valor 
    apoios::Array{TF}

    # Dicionário com os dados dos materiais
    dicionario_materiais::OrderedDict{String,Dict{String,Float64}}

    # Dicionário com os dados das geometrias
    dicionario_geometrias::OrderedDict{String,Dict{String,Float64}}

    # Dados sobre os elementos 
    # Matriz ne × 2 onde a primeira coluna tem o nome 
    # do material e a segunda coluna o nome da geometria
    dados_elementos::Array{String}

    # Array com as informações de forças e momentos concentrados
    # cada linha é uma informação e as colunas são 
    # nó gl valor
    loads::Array{TL}

    # Array com as informações de massas concentradas
    # cada linha é uma informação e as colunas são 
    # nó gl valor
    mass::Array{TL}


    # Array com as informações de MPC (multi point constraint)
    # cada linha é uma informação e as colunas são 
    # nó1 gl1 nó2 gl2
    mpc::Array{TF}

    # Array com as informações sobre os carregamentos distribuídos.
    # cada linha é uma informação e as colunas são
    # elemento qy1 qy2 qz1 qz2
    floads::Array{TF}

    # Vetor de comprimentos da malha
    L::Vector{TF}

    # Nome do arquivo yaml
    nome_arquivo::String

end