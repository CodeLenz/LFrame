
# Rotina que calcula a derivada do volume

# Das deduções em sala:
# dV = Lk*Ak
# dρ

# A boa notícia é que já temos os comprimentos e áreas da seção transversal dos elementos.
# A função então vai precisar do dicionário de geometrias, do número de elementos e do vetor de comprimentos. 

function Derivada_volume(ne::Int64, dicionario_geometrias, L::Vector{Float64}, dados_elementos::Matrix{String})
    
    # Aloca dV
    dv = zeros(ne)

    # Loop pelos elementos
    for e=1:ne

        Le, Ize, Iye, J0e, Ae, αe, Ke, Re, Ee, Ge = dados_fundamentais(ele, dados_elementos, dicionario_materiais)
    

        # dV fica:
        dv[e] = Le*Ae

    end

    return dv

end

# Rotina que calcula o volume total da estrutura

# Vamos calcular o volume total usando o dicionário de geometrias para as áreas das 
# seções transversais, o vetor de comprimento dos elementos e o vetor de densidade relativa.
function Volume(ne::Int64, dicionario_geometrias, L::Vector, ρ::Vector, dados_elementos::Matrix{String})

    # Alocando o volume
    V = 0.0

    # loop pelos elementos
    for e=1:ne

        Le, Ize, Iye, J0e, Ae, αe, Ke, Re, Ee, Ge = dados_fundamentais(L,ele, dados_elementos, dicionario_materiais, dicionario_geometrias, elems, coord)

        # Descobre ρ do elemento (é isso mesmo?)
        ρe = ρ[e]

        # Volume do elemento
        Ve = Ae*Le*ρe

        # Acumula o volume
        V += Ve

    end

    return V

end