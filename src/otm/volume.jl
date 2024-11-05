
# Rotina que calcula a derivada do volume

# Das deduções em sala:
# dV = Lk*Ak
# dρ

# A boa notícia é que já temos os comprimentos e áreas da seção transversal dos elementos.
# A função então vai precisar do dicionário de geometrias, do número de elementos e do vetor de comprimentos. 

function Derivada_volume(ne::Int64, dicionario_geometrias, dicionario_materiais, L::Vector{Float64}, dados_elementos::Matrix{String})
    
    # Aloca dV
    dv = zeros(ne)

    # Loop pelos elementos
    for e=1:ne

        # Dados que vamos precisar:
        Ize, Iye, J0e, Ae, αe, Ee, Ge = Dados_fundamentais(e, dados_elementos, dicionario_materiais, dicionario_geometrias)

        # dV fica:
        dv[e] = L[e]*Ae

    end

    return dv

end

# Rotina que calcula o volume total da estrutura

# Vamos calcular o volume total usando o dicionário de geometrias para as áreas das 
# seções transversais, o vetor de comprimento dos elementos e o vetor de densidade relativa.
function Volume(ne::Int64, dicionario_geometrias, dicionario_materiais, L::Vector, ρ::Vector, dados_elementos::Matrix{String})

    # Alocando o volume
    V = 0.0

    # loop pelos elementos
    for e=1:ne

        # Dados que vamos precisar:
        Ize, Iye, J0e, Ae, αe, Ee, Ge = Dados_fundamentais(e, dados_elementos, dicionario_materiais, dicionario_geometrias)

        # Descobre ρ do elemento (é isso mesmo?)
        ρe = ρ[e]

        # Volume do elemento
        Ve = Ae*L[e]*ρe

        # Acumula o volume
        V += Ve

    end

    return V

end