#
# Retorna o vetor 12x1 com os esforços nodais do elemento ele
#
function Forcas_elemento(ele,malha::Malha,U::Vector{Float64})
    
    # Recupera dados da estrutura malha
    conect = malha.conect
    coord = malha.coord
    dados_elementos = malha.dados_elementos
    dicionario_materiais = malha.dicionario_materiais
    dicionario_geometrias = malha.dicionario_geometrias

    # Recupera os dados do elemento
    Ize, Iye, J0e, Ae, αe, Ee, Ge, geo = Dados_fundamentais(ele, dados_elementos, dicionario_materiais, 
                                                       dicionario_geometrias)
    
    
    # Descobre os dados do Elemento
    Le = malha.L[ele]
                                                                                                                    
    # Monta a matriz do elemento no sistema local
    Ke = Ke_portico3d(Ee, Ize, Iye, Ge, J0e, Le, Ae)

    # Monta a matriz de rotação do elemento
    Re = Rotacao3d(ele, conect, coord, αe)

    # Descobre os gls globais do elemento 
    gls = Gls(ele,conect)   
 
    # Recupera os deslocamentos do elemento (ainda no sistema global)
    ug = U[gls]

    # Rotaciona para o sistema local
    ul = Re*ug

    # Se tivermos carregamentos distribuídos, calculamos o valor
    fde = zeros(12)

    # Verifica se temos carregamentos distribuídos no elemento 
    # e, se for o caso, calcula o fde associado
    fload = malha.floads

    # Determina se existe alguma linha cuja a coluna 1 é igual 
    # a ele. Se for o caso, pega os valores de q..
    for linha in eachrow(fload)

        # Testa se é o elemento
        if linha[1]==ele

            # Recupera os valores dos q's
            q1y,q2y,q1z,q2z = linha[2:5]

            # Calcula o vetor fde
            fde .= Fe_viga(Le, q1y, q2y, q1z, q2z)

            # Pula fora do loop
            break

        end

    end

    # Multiplica pela rigidez (também no sistema local)
    # e compensa pelo carregamento distribuídos (reações de 
    # engastamento perfeito)
    fe = Ke*ul - fde

    # Devolve as forças generalizadas nos nós deste elemento
    return geo,fe 

end

#
# Retorna as equações dos esforços internos no elemento, como um 
# vetor de funções 6 × 1 e também o comprimento do elemento.
#
#
# Exemplo de uso 
#
# Using LFrame, Plots
#
# Calcula os deslocamentos do problema  
#
# U,malha = Analise3D(arquivo)
#
# Obtém as equações dos esforços internos para o elemento 1
#
# E,L = Esforcos_internos_elemento(1,malha,U)
#
# Gera os pontos x para o gráfico 
#
# x = 0:L/100:L
#
# Gera o gráfico do Mz (por exemplo)
#
# plot(x,E[6].(x),title="Momento Mz")
#
#
#
function Esforcos_internos_elemento(ele,malha::Malha,U::Vector{Float64})

    # Primeiro obtemos as forças nodais do elemento
    geo,Fe = Forcas_elemento(ele,malha,U)

    # Comprimento do elemento 
    L = malha.L[ele]

    # Podemos começar assumindo que os carregamentos distribuídos 
    # são nulos
    q1y = q2y = q1z = q2z = 0.0 

    # Agora precisamos determinar se o elemento tem carregamento distribuído
    #
    # ele q1y q2y q1z q2z
    #
    fload = malha.floads

    # Determina se existe alguma linha cuja a coluna 1 é igual 
    # a ele. Se for o caso, pega os valores de q..
    for linha in eachrow(fload)

        # Testa se é o elemento
        if linha[1]==ele

            # Recupera as informações
            q1y,q2y,q1z,q2z = linha[2:5]

            # Pula fora do loop
            break

        end

    end
        
    # Com isso, podemos montar as equações dos carregamentos distribuídos 
    # usando os q´s
    #
    # TODO verificar os sinais destas expressões
    #
    N(x) = -Fe[1]
    T(x) = -Fe[4]
    Vy(x) = -Fe[2] -q1y*x - (x^2)*(q2y-q1y)/(2*L)
    Vz(x) = -Fe[3] -q1z*x - (x^2)*(q2z-q1z)/(2*L)
    Mz(x) = ((q2y-q1y)*x^3+3*L*q1y*x^2+6*Fe[2]*L*x-6*Fe[6]*L)/(6*L)
    My(x) = -(((q2z-q1z)*x^3+3*L*q1z*x^2+6*Fe[3]*L*x+6*Fe[5]*L)/(6*L))

    # Retorna um vetor com as funções e também o comprimento do elemento
    return [N,Vy,Vz,T,My,Mz], L

end