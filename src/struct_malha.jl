#
# Estrutura que contém as informações sobre o problema
#
mutable struct Malha

    # Número de elementos
    ne::Int64

    # Número de nós
    nnos::Int64

    # Coordenadas de cada nó
    # linha = nó
    # colunas = x y z
    coord::Array{Float64}

    # Conectividades dos elementos
    # linha = elemento
    # colunas = nó 1 e nó 2
    conect::Array{Int64}

    # Array com as informações dos apoios
    # nó gl valor 
    apoios::Array{Float64}

    # Dicionário com os dados dos materiais
    dicionario_materiais

    # Dicionário com os dados das geometrias
    dicionario_geometrias

    # Dados sobre os elementos 
    # Matriz ne × 2 onde a primeira coluna tem o nome 
    # do material e a segunda coluna o nome da geometria
    dados_elementos::Array{String}

    # Array com as informações de forças e momentos concentrados
    # cada linha é uma informação e as colunas são 
    # nó gl valor
    loads::Array{Float64}

    # Array com as informações de MPC (multi point constraint)
    # cada linha é uma informação e as colunas são 
    # nó1 gl1 nó2 gl2
    mpc::Array{Float64}

    # Array com as informações sobre os carregamentos distribuídos.
    # cada linha é uma informação e as colunas são
    # elemento qy1 qy2 qz1 qz2
    floads::Array{Float64}

    # Vetor de comprimentos da malha
    L::Vector{Float64}

end