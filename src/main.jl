
#
# Rotina para calcular o equilíbrio do pórtico 3D
#
"""
Analise3D Rotina para análise estática de pórticos espaciais

Entrada: arquivo::AbstractString:  nome de um arquivo .yaml com a definição do problema

Saida: Vetor de deslocamentos do pórtico
"""
function Analise3D(arquivo::AbstractString)

    # Le os dado::AbstractStrings do problema
    malha = Le_YAML(arquivo)

    # Pré processamento para calcular os comprimentos dos elementos da malha
    L = Pre_processamento(malha)
 
    # Cria o vetor ρ
    ρ0 = ones(malha.ne) 
 
    # Monta a matriz de rigidez global
    KG = Monta_Kg(malha,L,ρ0)

    # Monta o vetor global de forças concentradas - não muda
    FG = Monta_FG(malha)

    # Monta o vetor global de forças distribuídas - não muda
    FD = Monta_FD(malha.floads, malha.conect, malha.nnos, L, 
                  malha.dicionario_geometrias, malha.coord, 
                  malha.dados_elementos, malha.ne)

    # Vetor de forças do problema - não muda
    F = FG .+ FD

    # Modifica o sistema para considerar as restrições de apoios - já vai ser influenciado por ρ
    KA, FA = Aumenta_sistema(malha.apoios, malha.mpc, KG, F)

    # Soluciona o sistema global de equações para obter U

    # Cria um problema linear para ser solucionado pelo LinearSolve
    # U = KA\FA - também já está influenciado por ρ
    prob = LinearProblem(KA,FA)
    linsolve = init(prob)
    U_ = solve(linsolve)
    U = U_.u[1:6*malha.nnos]

    # Retorna o vetor de deslocamentos da estrutura
    return U
   
end