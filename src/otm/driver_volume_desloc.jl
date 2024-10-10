# Função Heaviside
Heaviside(a) = max(a,0.0)



function Driver_volume_desloc(ρ::Vector,r0::Float64, μ::Vector, Vb::Float64,
                              m::Int64,
                              ne,nnos,elems,dados_elementos,dicionario_materiais, 
                              dicionario_geometrias,L,coord, loads,floads, apoios, mpc, deslocamentos,
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
    objetivo = dot(F,U)

    ################### RESTRIÇÃO DE VOLUME ##################

    # Calcula o volume da estrutura
    Vatual = Volume(ne,dicionario_geometrias,L,ρ, dados_elementos)

    # Calcula o vetor de restrições
    g1 = [Vatual/Vb - 1]

    ################ RESTRIÇÃO DE DESLOCAMENTO ##############

    # Pega o numero de gls restritos
    numero_gls_restritos = size(deslocamentos, 1)
    #@show numero_gls_restritos

    # Inicializa o vetor de restrições de deslocamento
    g2 = zeros(numero_gls_restritos)


    # Loop para calcular as restrições de deslocamento
    for i=1:numero_gls_restritos
        no  = deslocamentos[i,1]
        gl  = deslocamentos[i,2]
        val = deslocamentos[i,3]
        pos = Int(6*(no-1)+gl)
        #@show U[pos]
        u = U[pos]
        g2[i] = (u/val)^2 - 1
        #@show no, gl, val, pos, u, g2
    end
    #@show U

    # Calcula a função LA
    g = [g1 ;  g2]

    if opcao=="g"
        return g
    end

    LA = objetivo
    for i=1:m
        LA += (r0/2)*Heaviside(μ[i]/r0 + g[i])^2
    end

    if opcao=="LA"
        return LA
    end

    ################### DERIVADAS ##################

    # Calcula as derivadas da função objetivo

    df = Derivada_flex(ne,elems,dados_elementos, dicionario_materiais,
                       dicionario_geometrias, L, coord, U, ρ)

    # Calcula as derivadas da restrição de volume
    # Normalizando
    dV = Derivada_volume(ne, dicionario_geometrias, L, dados_elementos)./Vb

    # Calcula a derivada do LA
    dLA = df .+ (r0)*Heaviside(μ[1]/r0 + g[1])*dV

    # NOVOS TERMOS DA DERIVADA DE DESLOCAMENTO
    
    #### Problema adjunto
   
    # Número total de graus de liberdade do sistema
    n_gl = length(U)

    # Inicializa o vetor de carregamento adjunto
    # reaproveitando o vetor já aumentado do 
    # problema de equilíbrio
    FA[1:n_gl] .=  0 

    # Loop pelas restrições
    # de deslocamento
    for j=1:numero_gls_restritos

        # Indice do gl restrito
        no = deslocamentos[j, 1]
        gl = deslocamentos[j, 2]
        pos = Int(6*(no-1)+gl)

        # Deslocamento restrito
        val = deslocamentos[j, 3]

        # Deslocamento calculado para o gl correspondente
        u_j = U[pos]

        # Calcula a parte escalar da derivada parcial
        dg_dU = 2/(val^2) * u_j

        # Acumula as derivadas no vetor de "carregamento"
        escalar = (r0)*Heaviside(μ[j+1]/r0 + g[j+1])*dg_dU

        # Acumula no vetor de "carregamento" adjunto
        FA[pos] -= escalar

    end

    # Atualiza o lado da direita
    linsolve.b = FA
    U_ = solve(linsolve)
    λ = U_.u[1:n_gl]

    # Calcula o último termo restante, λ^T(dK/dρm)U
    Dλ = derivada_λ(ne,elems,dados_elementos, dicionario_materiais,
                    dicionario_geometrias, L, coord, U, ρ, λ)

    # Adiciona tudo na derivada da função de Lagrange Aumentada
    dLA .= dLA .+ Dλ

    if opcao=="dLA"
       return dLA
    end

end