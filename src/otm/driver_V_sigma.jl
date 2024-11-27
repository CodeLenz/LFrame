
# define a função de relaxação para as tensões
function fe(ρ_e)

    return ρ_e

end

# derivada da função de relaxação
function dfe(ρ_e)

    return 1.0

end


#
# Minimização de volume com restrição de tensão 
#
#

# tensao_limite::Vector <= pre-processar com os dados dos materiais de cada elemento
function Driver_V_sigma(ρ::Vector,r0::Float64, μ::Vector, σ_limite::Float64,
                        m::Int64, ne,nnos,elems,dados_elementos,dicionario_materiais, 
                        dicionario_geometrias,L,coord, loads,floads, apoios, mpc, 
                        opcao::String )

    # Verifica se opção é algo válido
    opcao in ["LA","dLA","g","U"] || error("Driver::opção $opcao inválida")

    ################### EQUILIBRIO ##################

    # Monta a matriz de rigidez global
    KG = Monta_Kg(ne,nnos,elems,dados_elementos,dicionario_materiais, 
                  dicionario_geometrias,L,coord, ρ)

    # Monta o vetor global de forças concentradas - não muda
    FG = Monta_FG(loads,nnos)

    # Monta o vetor global de forças distribuídas - não muda
    FD = Monta_FD(floads, elems, nnos, L, dicionario_geometrias, coord, dados_elementos, ne)

    # Vetor de forças do problema - não muda
    F = FG .+ FD

    # Modifica o sistema para considerar as restrições de apoios - já vai ser influenciado por ρ
    KA, FA = Aumenta_sistema(apoios, mpc, KG, F)

    # Soluciona o sistema global de equações para obter U

    # Cria um problema linear para ser solucionado pelo LinearSolve
    # U = KA\FA - também já está influenciado por ρ
    prob = LinearProblem(KA,FA)
    linsolve = init(prob)
    U_ = solve(linsolve)
    U = U_.u[1:6*nnos]

    if opcao=="U"
        return U
    end

    ################### OBJETIVO ##################

    # Calcula a função objetivo do problema
    objetivo = Volume(ne,dicionario_geometrias,dicionario_materiais,L,ρ, dados_elementos)

    ################### CALCULA AS TENSÕES EQUIVALENTES ##################

    # Vetor com as tensões equivalentes em cada elemento/nó/pto a
    vetor_vm = zeros(m)

    # Loop pelos elementos
    contador = 1
    for e=1:ne

        # Calcula esforços no elemento 1
        Fe = Esforcos_elemento(e,elems,dados_elementos,dicionario_materiais,dicionario_geometrias,
                               L,coord,U)

        # loop pelos nós do elemento
        for no=1:2

            # loop pelos pontos a do nó
            for a=0:1

                # calcula o vetor de tensões
                s = Tensao_no_elemento(e,no,a,Fe,dados_elementos,dicionario_geometrias)

                # e a tensão equivalente
                eq = Tensao_equivalente(s)

                # guarda no vetor_vm - COM RELAXAÇÃO
                vetor_vm[contador] = fe(ρ[e])*eq

                # atualiza o contador
                contador += 1

            end #a
        end #no
    end #ele

    # Cálculo das restrições
    g = vetor_vm./σ_limite[1] .- 1

    if opcao=="g"
        return g
    end

    LA = objetivo
    for i=1:m
        LA += (1/m)*(r0/2)*Heaviside(μ[i]/r0 + g[i])^2
    end

    if opcao=="LA"
        return LA
    end

    ################### DERIVADAS ##################

    # Calcula as derivadas da função objetivo
    df = Derivada_volume(ne, dicionario_geometrias, dicionario_materiais, L, dados_elementos)

    # Calcular as derivadas relativas as restrições de tensão
    D2, F_s = Derivada_gtensao(ne, ρ, μ, r0, g, dados_elementos, dicionario_materiais, 
                               dicionario_geometrias, L, σ_limite, U, elems, coord)


    
    ################### PROBLEMA ADJUNTO (Tensão) ##################

    # Número total de graus de liberdade do sistema
    n_gl = length(U)

    # Inicializa o vetor de carregamento adjunto
    # reaproveitando o vetor já aumentado do 
    # problema de equilíbrio
    FA[1:n_gl] .=  F_s

    # Atualiza o lado da direita
    linsolve.b = -FA
    U_ = solve(linsolve)
    λ = U_.u[1:n_gl]

    # Calcula o último termo restante, λ^T(dK/dρm)U
    Dλ = derivada_λ(ne,elems,dados_elementos, dicionario_materiais,
                    dicionario_geometrias, L, coord, U, ρ, λ)

    # Adiciona tudo na derivada da função de Lagrange Aumentada
    dLA = df .+ Dλ .+ D2

    if opcao=="dLA"
       return dLA
    end

end