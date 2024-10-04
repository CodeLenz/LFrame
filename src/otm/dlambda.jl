#
# Parcela da derivada da função Lagrangiana Aumentada que depende do vetor 
# adjunto e da derivada da rigidez global.
#
function derivada_λ(ne::Int64,elems::Matrix{Int64},dados_elementos::Matrix{String},
                    dicionario_materiais, dicionario_geometrias, L::Vector{Float64},
                    coord::Matrix, U::Vector,ρ::Vector, λ::Vector) 

    # Aloca o vetor df
    dλ = zeros(ne)

    # Loop pelos elementos (posições da derivada)
    for e=1:ne

        Le, Ize, Iye, J0e, Ae, αe, Ke, Re, Ee, Ge = dados_fundamentais(ele, dados_elementos, dicionario_materiais)

        # Montra a matriz do elemento (Ke0)
        # no sistema local
        Ke0 = Ke_portico3d(Ee, Ize, Iye, Ge, J0e, Le, Ae)

        # Monta a matriz de rotação do elemento
        R = Rotacao3d(e, elems, coord, αe)

        # Passa a matriz do elemento para o sistema global
        Ke0g = R'*Ke0*R

        # Descobre os gls globais do elemento
        gls = Gls(e,elems)

        # Pega somente as componentes de U que pertencem ao elemento
        ue = U[gls]

        # Faz o mesmo para λ
        λe = λ[gls]

        # Densidade relativa do elemento
        ρe = ρ[e]

        # dλ fica:
        dλ[e] = (3*ρe^2)*dot(λe,Ke0g,ue)

    end

    return dλ

end

