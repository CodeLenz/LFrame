#####################################################################################
#                 Rotina para montagem da matriz de rigidez global                  #
#####################################################################################

function Monta_Kg(malha::Malha, L::Vector{Float64}, ρ::Vector)
    
    # Acessa as definições de malha
    ne    = malha.ne 
    nnos  = malha.nnos 
    elems = malha.conect 
    coord = malha.coord
    dados_elementos = malha.dados_elementos
    dicionario_materiais = malha.dicionario_materiais
    dicionario_geometrias = malha.dicionario_geometrias

    # Aloca a matriz de rigidez global
    KG = spzeros(6*nnos, 6*nnos)

    # Passando pelos elementos da malha
    for e=1:ne

        # Descobre os dados do Elemento
        Le = L[e]

        # Recupera os dados do elemento (geometria e material)
        Ize, Iye, J0e, Ae, αe, Ee, Ge = Dados_fundamentais(e, dados_elementos, dicionario_materiais,
                                                           dicionario_geometrias)

        # Parametrização SIMP da rigidez
        Ke = Ke_portico3d(Ee, Ize, Iye, Ge, J0e, Le, Ae)

        # Monta a matriz de rotação do elemento
        R = Rotacao3d(e, elems, coord, αe)

        # Descobre os Gls do elemento
        gls = Gls(e,elems)

        # Sobreposição na matriz global
        KG[gls,gls] .= KG[gls,gls] .+ R'*Ke*R

    end

    return KG


end

#####################################################################################
#                      Montagem do vetor de forças concentradas                     #
#####################################################################################

function Monta_FG(loads::Array{Float64}, nnos::Int64)

    # Aloca o vetor global
    FG = zeros(6*nnos)

    # Loop pelas informações dos carregamentos concentrados
    for i=1:size(loads,1)


        # Descobre o nó
        no = Int(loads[i,1])

        # Descobre o gl(local)
        gl = Int(loads[i,2])

        #Descobre o valor
        valor = loads[i,3]

        # O grau de liberdade global
        glg = 6*(no-1)+gl

        # Sobrepoe no gl
        FG[glg] = FG[glg] + valor
    end

    # Retorna o vetor
    return FG
end


#####################################################################################
#                      Montagem do vetor de forças distribuídas                     #
#####################################################################################

function Monta_FD(floads::Array{Float64}, elems::Matrix{Int64}, nnos::Int64, L, dicionario_geometrias, coord, dados_elementos::Matrix{String}, ne::Int64)


    # Vetor global
    FD = zeros(6*nnos)

    # Usando um laço para a montagem de FD, passando pelas linhas do fload
    for j=1:size(floads,1)

        e=Int(floads[j,1])

        # O nome da geometria do elemento pode ser acessado diretamente da matriz de dados_elementos
        geo = dados_elementos[e,2]

        # Todos os dados da geometria do elemento estão em um dicionário local
        geometria = dicionario_geometrias[geo]

        # Descobre o valor do carregamento "inicial" em y
        q1y = floads[j,2]

        # Descobre o valor do carregamento "final" em y
        q2y = floads[j,3]

        # Descobre o valor do carregamento "inicial" em z
        q1z = floads[j,4]

        # Descobre o valor do carregamento "final" em z
        q2z = floads[j,5]

        αe  = geometria["α"]

        # Descobre o nó:
        # (Precisamos incluir tanto o nó referente a q1 quanto o nó referente a q2)
        no1, no2 = elems[e,:]

        Le = L[e]

        # Descobre os graus de liberdade globais
        gls = Gls(e,elems)

        # Calcula o vetor de forças no sistema local do elemento
        F_elemento = Fe_viga(Le, q1y, q2y, q1z, q2z)

        # Monta a matriz de rotação do elemento
        R = Rotacao3d(e, elems, coord, αe)

        # Rotaciona a força para o sistema global e sobrepoe
        # no vetor FD
        FD[gls] .= FD[gls] .+ R'*F_elemento

    end

    return FD
end
