
#
# Rotina para calcular o equilíbrio do pórtico 3D
#
function Analise3D(arquivo)

    # Le os dados do problema
    ne,nnos,coord,elems,apoios,dicionario_materiais,dicionario_geometrias,dados_elementos,loads,mpc, floads = Le_YAML(arquivo)

    # Pré processamento para calcular os comprimentos dos elementos da malha
    L = Pre_processamento(elems, coord)
 
    # Cria o vetor ρ
    ρ0 = ones(ne) 
 
    # Monta a matriz de rigidez global
    KG = Monta_Kg(ne,nnos,elems,dados_elementos,dicionario_materiais, 
                  dicionario_geometrias,L,coord, ρ0)

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


    #=

        Daqui para baixo é basicamente o cálculo da restrição de tensão. Passar
        para uma rotina específica

    =#
    # Vetor com as tensões equivalentes em cada elemento/nó/pto a
    vetor_vm = zeros(2*2*ne)

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

                # guarda no vetor_vm
                vetor_vm[contador] = eq

                # atualiza o contador
                contador += 1

            end
        end 

        # Calcula as tensões no nó 1 do elemento no ponto 0 e 1
        #=
        s_e_1_0 = Tensao_no_elemento(e,1,0,Fe,dados_elementos,dicionario_geometrias)
        s_e_1_1 = Tensao_no_elemento(e,1,1,Fe,dados_elementos,dicionario_geometrias)
1.5517606955286935e8
 1.5517606955286935e8

        # Calcula as tensões no nó 2 do elemento no ponto 0 e 1
        s_e_2_0 = Tensao_no_elemento(e,2,0,Fe,dados_elementos,dicionario_geometrias)
        s_e_2_1 = Tensao_no_elemento(e,2,1,Fe,dados_elementos,dicionario_geometrias)

        println("*******ELEMENTO ", e, "*******")

        println("A tensão no nó 1, a = 0 é ",s_e_1_0)
        println("A tensão no nó 1, a = 1 é ",s_e_1_1)
        println("A tensão no nó 2, a = 0 é ",s_e_2_0)
        println("A tensão no nó 2, a = 1 é ",s_e_2_1)
        =#
            
    end

    return vetor_vm 
end