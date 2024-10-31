#
# Arquivo que contém as alterações entre as linhas 60 e 161 do driver_volume_desloc.jl.
#

    ################ RESTRIÇÃO DE DESLOCAMENTO ##############

    # Pega o numero de gls restritos
    numero_gls_restritos = size(deslocamentos, 1)

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

    # Calcula a derivada do LA - ainda sem o termo adjunto
    dLA = dV .+ (r_sigma)*Heaviside(μ[1]/r_sigma + g[1])*dgsigma_dxm 

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

        # Acumula as derivadas no vetor de "carregamento" para as restrições de deslocamento
        escalar_deslocamento = (r_u)*Heaviside(μ[j+1]/r_u + g[j+1])*dg_dU


    end

    # Acumula as derivadas no vetor de "carregamento" para as restrições de tensão
    escalar_tensao = ((r_sigma)/(4*ne))*Heaviside(μ[j+1]/r_sigma + g[j+1])*dg_dU

    # Somando
    escalar = escalar_tensao + escalar_tensao
    
    # Acumula no vetor de "carregamento" adjunto
    FA[pos] -= escalar





    # Atualiza o lado da direita
    linsolve.b = FA
    U_ = solve(linsolve)
    λ = U_.u[1:n_gl]

    # Calcula o último termo restante, λ^T(dK/dρm)U
    Dλ = derivada_λ(ne,elems,dados_elementos, dicionario_materiais,
                    dicionario_geometrias, L, coord, U, ρ, λ)

    # Adiciona tudo na derivada da função de Lagrange Aumentada
    dLA .= dLA .+ Dλ