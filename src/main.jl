
#
# Rotina para calcular o equilíbrio do pórtico 3D
#
"""
Analise3D Rotina para análise estática de pórticos espaciais

Entrada: arquivo::AbstractString:  nome de um arquivo .yaml com a definição do problema

Saida: Vetor de deslocamentos do pórtico e estrutura de malha

"""
function Analise3D(arquivo::AbstractString, verbose=false; ρ0=Float64[])

    # Le os dado::AbstractStrings do problema
    malha = Le_YAML(arquivo; verbose=verbose)

    # Se ρ não foi informado, inicializamos com 1.0
    if isempty(ρ0)
       ρ0 = ones(malha.ne) 
    else
       # Testa para ver se a dimensão está correta
       if length(ρ0)!=malha.ne
          error("Analise3D:: vetor de variáveis de projeto tem a dimensão errada") 
       end
    end
 
    # Monta a matriz de rigidez global
    KG = Monta_Kg(malha,ρ0)

    # Monta o vetor global de forças concentradas - não muda
    FG = Monta_FG(malha)

    # Monta o vetor global de forças distribuídas - não muda
    FD = Monta_FD(malha)

    # Vetor de forças do problema - não muda
    F = FG .+ FD

    # Modifica o sistema para considerar as restrições de apoios - já vai ser influenciado por ρ
    KA, FA = Aumenta_sistema(malha, KG, F)

    # Soluciona o sistema global de equações para obter U

    # Cria um problema linear para ser solucionado pelo LinearSolve
    # U = KA\FA - também já está influenciado por ρ
    prob = LinearProblem(KA,FA)
    linsolve = init(prob)
    U_ = solve!(linsolve)
    U = U_.u[1:6*malha.nnos]

    # Retorna o vetor de deslocamentos da estrutura
    return U, malha
   
end