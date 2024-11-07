"""
Rotina principal que otimiza uma estrutura com elementos de pórtico 3D

Uso:

Otimiza_Portico3D_V_sigma(arquivo;verbose=true)

onde arquivo deve apontar para um .yaml com os dados  e verbose
indica se queremos que a rotina faça comentários ao longo da
execução.

"""

function Otimiza_Portico3D_V_sigma(arquivo; verbose=true)

    # Le os dados do problema
    ne,nnos,coord,elems,apoios,dicionario_materiais,dicionario_geometrias,dados_elementos,loads,mpc, floads = Le_YAML(arquivo)

    # Pré processamento para calcular os comprimentos dos elementos da malha
    L = Pre_processamento(elems, coord)

    # Cria o vetor ρ - vamos continuar usando essa parametrização né?
    ρ0 = 0.5*ones(ne) 

    # Restrições laterais do problema
    ρmin = 1E-3*ones(ne)
    ρmax = ones(ne)

    # Número de iterações do procedimento de otimização
    niter = 1

    # Fator de segurança da estrutura
    n = 2.5

    # Recuperando a tensão de escoamento

    # Dados dos materais
    mat = dados_elementos[2,1]

    # Todos os dados do material estão em um dicionário local
    material = dicionario_materiais[mat]

    # E podemos recuperar os dados usando os nomes como chaves
    σ_esc = material["S_esc"]
    
    # Calcula o σ_limite (limite da restrição de tensao) - vai ser um vetor
    σ_limite = σ_esc/n

    # Número de restrições - no momento, apenas de tensão - 4 restrições por elemento
    m = 4*ne
    
    # Penalização inicial
    r0 = 1.0

    # Alocando o vetor μ
    μ = zeros(m)

    # Usa o nome do arquivo .yaml como base para o arquivo de saída
    arquivo_saida = arquivo[1:end-5]*".txt"

    verbose && println("Abrindo $(arquivo_saida) para escrita dos resultados")

    # Abre um arquivo de texto para saída
    saida = open(arquivo_saida,"w")

    # Define os drivers
    LA(ρ) = Driver_V_sigma(ρ,r0,μ,σ_limite,m,ne,nnos,elems,dados_elementos,dicionario_materiais, 
            dicionario_geometrias,L,coord, loads,floads, apoios, mpc, "LA")

    dLA(ρ) = Driver_V_sigma(ρ,r0,μ,σ_limite,m,ne,nnos,elems,dados_elementos,dicionario_materiais, 
            dicionario_geometrias,L,coord, loads,floads, apoios, mpc, "dLA")

    restr(ρ) = Driver_V_sigma(ρ,r0,μ,σ_limite,m,ne,nnos,elems,dados_elementos,dicionario_materiais, 
            dicionario_geometrias,L,coord, loads,floads, apoios, mpc,  "g")
          
    equil(ρ) = Driver_V_sigma(ρ,r0,μ,σ_limite,m,ne,nnos,elems,dados_elementos,dicionario_materiais, 
            dicionario_geometrias,L,coord, loads,floads, apoios, mpc,  "U")


            ###################################################################
            ############################## TESTANDO ###########################

    println("Testando a derivada... :)")
    @show restr(ρ0)

    #Testa a derivada
    d_codigo = dLA(ρ0)        
    d_dfc = df(ρ0,1E-4,LA)
    @show d_codigo, d_dfc
    
    return [d_codigo d_dfc]
    
            ###################################################################

    # Loop de otimização que vai alterar os ρ para minimizar a função objetivo
    #     e satistfazer a restrição de volume
    for iter=1:niter

        # Início do loop interno, de otimização, que vai devolver x*
        options = WallE.Init()
        options["NITER"] = 1_000
        output = WallE.Solve(LA,dLA,ρ0,ρmin,ρmax,options)

        # Recovering solution
        ρ = output["RESULT"]
        flag_converged = output["CONVERGED"]
        opt_norm = output["NORM"]
        @show flag_converged, opt_norm
  
        # Agora vamos precisar calcular as restrições:
        # Vamos chamar a função de compreensao de lista das restrições
        g = restr(ρ)

        # Atualiza a penalização
        r0 = r0*1.1

        # Atualiza os multiplicadores
        μ .= Heaviside.(μ .+ r0*g)

        @show g, μ, g.*μ

        # Atualiza o ponto de ótimo
        ρ0 .= ρ

        # Critério de parada seria 
        if all(g.*μ.<=1E-6)
            println("Critério de parada atingido na iteração $iter ",g.*μ)
            break
        end
        
        
    end

    # Calcula o U para essa distribuição de variáveis de projeto
    U = equil(ρ0)

    # Mostra de forma organizada os resultados
    gls = ["ux","uy","uz","θx", "θy", "θz"]
    contador = 1
    println(saida,"********** Deslocamentos e rotações do modelo **********")
    for no=1:nnos

        println(saida,"Nó ",no)

        for gl=1:6
            println(saida,"     ",gls[gl]," ",U[contador])
            contador += 1
        end

    end

    println(saida)
    println(saida)

    # Fecha o arquivo de escrita
    close(saida)

    # Exporta dados para o gmsh
    etypes = ones(Int64,ne)
    Lgmsh_export_init("saida.pos",nnos,ne,coord,etypes,elems)
    Lgmsh_export_element_scalar("saida.pos",ρ0,"Variáveis de projeto")


    return ρ0
end