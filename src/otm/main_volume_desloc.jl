"""
Rotina principal que calcula o vetor de deslocamento de um pórtico 3D

Uso:

Otimiza_Portico3D(arquivo;verbose=true)

onde arquivo deve apontar para um .yaml com os dados  e verbose
indica se queremos que a rotina faça comentários ao longo da
execução.

"""

function Otimiza_Portico3D_volume_desloc(arquivo; verbose=true)

    # Le os dados do problema
    ne,nnos,coord,elems,apoios,dicionario_materiais,dicionario_geometrias,dados_elementos,loads,mpc, floads, deslocamentos = Le_YAML(arquivo)

    # Pré processamento para calcular os comprimentos dos elementos da malha
    L = Pre_processamento(elems, coord)

    # Cria o vetor ρ
    ρ0 = 0.5*ones(ne) 

    # Restrições laterais do problema
    ρmin = 1E-3*ones(ne)
    ρmax = ones(ne)

    # Número de iterações do procedimento de otimização
    niter = 2

    # Calcula o Vb (limite da restrição de volume)
    V0 = Volume(ne,dicionario_geometrias,L,ρ0,dados_elementos)

    # Número de restrições vai ser a de volume + as restrições de deslocamento
    numero_gls_restritos = size(deslocamentos, 1)
    m = 1 + numero_gls_restritos
    
    # Penalização inicial
    r0 = 1.0

    # Alocando o vetor μ
    μ = zeros(m)

    # Limite - 50% do volume original (exmeplo)
    Vb = 0.2*V0

    # Usa o nome do arquivo .yaml como base para o arquivo de saída
    arquivo_saida = arquivo[1:end-5]*".txt"

    verbose && println("Abrindo $(arquivo_saida) para escrita dos resultados")

    # Abre um arquivo de texto para saída
    saida = open(arquivo_saida,"w")

    # Define os drivers
    LA(ρ) = Driver_volume_desloc(ρ,r0,μ,Vb,m,ne,nnos,elems,dados_elementos,dicionario_materiais, 
            dicionario_geometrias,L,coord, loads,floads, apoios, mpc, deslocamentos,"LA")

    dLA(ρ) = Driver_volume_desloc(ρ,r0,μ,Vb,m,ne,nnos,elems,dados_elementos,dicionario_materiais, 
            dicionario_geometrias,L,coord, loads,floads, apoios, mpc, deslocamentos,"dLA")

    restr(ρ) = Driver_volume_desloc(ρ,r0,μ,Vb,m,ne,nnos,elems,dados_elementos,dicionario_materiais, 
            dicionario_geometrias,L,coord, loads,floads, apoios, mpc, deslocamentos, "g")
          
    equil(ρ) = Driver_volume_desloc(ρ,r0,μ,Vb,m,ne,nnos,elems,dados_elementos,dicionario_materiais, 
            dicionario_geometrias,L,coord, loads,floads, apoios, mpc, deslocamentos, "U")


            ###################################################################
            ############################## TESTANDO ###########################

    #println("Testando a derivada... :)")
    #@show restr(ρ0)

    # Testa a derivada
    #d_codigo = dLA(ρ0)        
    #d_dfc = df(ρ0,1E-4,LA)
    #@show d_codigo, d_dfc
    
    #return [d_codigo d_dfc]
    
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

        #ρ = Steepest(LA,dLA,ρ0,ρmin,ρmax) 
        
        # Agora vamos precisar calcular as restrições:
        # Vamos chamar a função de compreensao de lista das restrições
        g1 = restr1(ρ)

        # Atualiza a penalização
        r0 = r0*1.1

        # Atualiza os multiplicadores
        μ .= Heaviside.(μ .+ r0*g1)

        @show g1, μ, g.*μ

        # Atualiza o ponto de ótimo
        ρ0 .= ρ

        # Critério de parada seria 
        if all(g1.*μ.<=1E-6)
            println("Critério de parada atingido na iteração $iter ",g1.*μ)
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