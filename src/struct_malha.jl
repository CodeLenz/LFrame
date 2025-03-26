#
# Estrutura que contém as informações sobre o problema
#
struct Malha

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

    
    apoios::Array{Float64}
    dicionario_materiais
    dicionario_geometrias
    dados_elementos::Array{String}
    loads::Array{Float64}
    mpc::Array{Float64}
    floads::Array{Float64}

end