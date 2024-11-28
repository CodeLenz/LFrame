#
# Retorna o vetor 12x1 com os esforços nodais do elemento ele
#
function Esforcos_elemento(ele,elems,dados_elementos::Matrix{String},
                           dicionario_materiais, dicionario_geometrias,
                           L::Vector{Float64}, coord::Matrix, U::Vector)

    # Recupera os dados do elemento
    Ize, Iye, J0e, Ae, αe, Ee, Ge = Dados_fundamentais(ele, dados_elementos, dicionario_materiais, 
                                                       dicionario_geometrias)
    
    
    # Descobre os dados do Elemento
    Le = L[ele]
                                                                                                                    
    # Montra a matriz do elemento
    # Essse cara aqui seria a Ke0
    Ke = Ke_portico3d(Ee, Ize, Iye, Ge, J0e, Le, Ae)

    # Monta a matriz de rotação do elemento
    Re = Rotacao3d(ele, elems, coord, αe)

    # Descobre os gls globais do elemento 
    gls = Gls(ele,elems)   
 
    # Primeira operação é H U
    ug = U[gls]

    # Rotaciona para o sistema local
    ul = Re*ug

    # Multiplica pela rigidez (também no sistema local)
    fe = Ke*ul

    # Devolve as forças generalizadas nos nós deste elemento
    #@show fe
    return fe 

end

#
# Calcula as tensões em um nó n do elemento ele na posição a (0/1)
#
# fe é o vetor 12x1 de esforços do elemento ele
#
function Tensao_no_elemento(ele::Int,n::Int,a::Int,fe::Vector,dados_elementos::Matrix{String},
                           dicionario_geometrias)

    # Testa se as entradas são consistentes
    n in [1,2] || error("Tensao_no_elemento::n deve ser 1 ou 2")
    a in [0,1] || error("Tensao_no_elemento::a deve ser 0 ou 1")

    # Dependendo no nó, pegamos as componentes relativas aos 
    # esforços N, T, My e Mz. Para o primeiro nó, invertemos
    # os sinais (estamos trabalhando com esforços internos)
    if n==1
        E = -[fe[1];fe[4];fe[5];fe[6]]
    else
        E = [fe[7];fe[10];fe[11];fe[12]]
    end

    # Os esforços internos no nó
    N = E[1]
    T = E[2]
    Mr = sqrt(E[3]^2 + E[4]^2)

    # Descobre os dados da geometria do elemento 
    geo = dados_elementos[ele,2]
    geometria = dicionario_geometrias[geo]
    Ize = geometria["Iz"]
    Iye = geometria["Iy"]
    J0e = geometria["J0"]
    Ae  = geometria["A"]

    # Teste de pânico
    isapprox(Ize,Iye) || error("Tensao_no_elemento:: momentos de inércia são diferentes..")

    # Super método avançado para obtermos o r_e
    r_e = sqrt(J0e/Ae + Ae/(2*pi))

    # Tensão normal (barra)
    s_xx_N = N/Ae

    # Tensão cisalhante devido ao torque
    s_xy_T = T*r_e / J0e

    # Tensão normal devido à flexão oblíqua
    s_xx_Mr = ((-1)^a) * Mr*r_e / Ize 

    # Retorna o vetor com as tensões do elemento
    return [s_xx_N  ;  s_xy_T ; s_xx_Mr]

end

#
# Calcula a tensão equivalente
#
function Tensao_equivalente(tensao::Vector)

    # Matriz de von-Mises
    VM = [1.0 1.0 0.0 ;
          0.0 0.0 3.0 ;
          1.0 1.0 0.0 ]

    # Tensão equivalente de von-Mises
    sqrt(dot(vec_sigma,VM,vec_sigma))

end