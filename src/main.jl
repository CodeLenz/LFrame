
#
# Rotina para calcular o equilíbrio do pórtico 3D
#
"""
Analise3D Rotina para análise estática de pórticos espaciais

Entrada: malha:   estrutuda de dados com as informações da malha do problema
         ρ0   :   vetor com variáveis de projeto (deve ter dimensão ne × 1)

Saidas: Vetor de deslocamentos do pórtico e estrutura de malha
        estrutura com os dados da malha 

"""
function Analise3D(malha::Malha, posfile=true; ρ0=[])

   # Se ρ não foi informado, inicializamos com 1.0
    if isempty(ρ0)
       ρ0 = ones(malha.ne) 
    else
       # Testa para ver se a dimensão está correta
       if length(ρ0)!=malha.ne
          error("Analise3D:: vetor de variáveis de projeto tem a dimensão errada") 
       end
    end

    # Recupera o nome do arquivo na malha 
    nome = malha.nome_arquivo
 
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
    linsolve = init(prob,KLUFactorization())
    U_ = solve!(linsolve)
    U = U_.u[1:6*malha.nnos]


    # Se posfile=true, grava os arquivos de saída (padrão)
    if posfile 

      # Path para o pacote LFrame
      caminho = pathof(LFrame)[1:end-14]
      
      # Cria arquivo .pos na pasta Pos para a visualização no Gmsh
      pos(malha,caminho,U)

      # Cria o arquivo .esf na pasta Esforcos para pos processamento
      esf(malha,caminho,U)

   end #posfile

    # Retorna o vetor de deslocamentos da estrutura
    return U, malha
   
end

"""
Analise3D Rotina para análise estática de pórticos espaciais

Entrada: arquivo:  nome de um arquivo .yaml com a definição do problema
         verbose:  indica (true) se a leitura do arquivo deve mostrar informações na tela
         ρ0     :   vetor com variáveis de projeto (deve ter dimensão ne × 1)

Saidas: Vetor de deslocamentos do pórtico e estrutura de malha
        estrutura com os dados da malha 
"""

function Analise3D(arquivo::AbstractString, posfile=true; verbose=false, ρ0=[])

   # Le os dado::AbstractStrings do problema
   malha = Le_YAML(arquivo; verbose=verbose)

   # Roda a rotina principal, devolvendo U e a estrutura de malha
   Analise3D(malha, posfile; ρ0=ρ0)

end