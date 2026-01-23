
#
# Rotina para calcular o equilíbrio do pórtico 3D
#
"""
Analise3D Rotina para análise estática de pórticos espaciais

Entrada: malha :   estrutuda de dados com as informações da malha do problema
         x0    :   vetor com variáveis de projeto (deve ter dimensão ne × 1)
         kparam:   vetor com função 

Saidas: Vetor de deslocamentos do pórtico e estrutura de malha
        estrutura com os dados da malha 

"""
function Analise3D(malha::Malha, posfile=true; x0=[], kparam=Function[])

   # Se ρ não foi informado, inicializamos com 1.0
   if isempty(x0)
      x0 = ones(malha.ne) 

   else
      
      # Testa para ver se a dimensão está correta
      if length(x0)!=malha.ne
         error("Analise3D:: vetor de variáveis de projeto tem a dimensão errada") 
      end

      # Testa por consistência de valores
      if !all(0.0 .<x0 .<= 1)
         error("Analise3D:: vetor de variáveis de projeto tem valores inconsistentes") 
      end

   end

   # Verifica se kparam tem alguma definição de função 
   # caso não tenhamos, definimos o mapeamento direto
   if isempty(kparam)

      push!(kparam,x->x)

   end

   # Monta a matriz de rigidez global
   KG = Monta_Kg(malha,x0, kparam[1])

   # Monta o vetor global de forças concentradas - não muda
   FG = Monta_FG(malha)

   # Monta o vetor global de forças distribuídas - não muda
   FD = Monta_FD(malha)

   # Vetor de forças do problema - não muda
   F = FG .+ FD

   # Modifica o sistema para considerar as restrições de apoios - já vai ser influenciado por ρ
   KA, FA = Aumenta_sistema(malha, KG, F)

   # Cria um problema linear para ser solucionado pelo LinearSolve
   # U = KA\FA - também já está influenciado por ρ
   prob = LinearProblem(KA,FA)
   linsolve = init(prob)
   U_ = solve!(linsolve)
   U = U_.u[1:6*malha.nnos]


   # Se posfile=true, grava os arquivos de saída (padrão)
   if posfile 
      
      # Cria arquivo .pos na pasta Pos para a visualização no Gmsh
      Gera_pos_U(malha,U)

      # Cria o arquivo .esf na pasta Esforcos para pos processamento
      Gera_esforcos(malha,U)

   end #posfile

   # Retorna o vetor de deslocamentos da estrutura
   return U, malha
   
end

"""
Analise3D Rotina para análise estática de pórticos espaciais

Entrada: arquivo:  nome de um arquivo .yaml com a definição do problema
         verbose:  indica (true) se a leitura do arquivo deve mostrar informações na tela
         x0     :   vetor com variáveis de projeto (deve ter dimensão ne × 1)

Saidas: Vetor de deslocamentos do pórtico e estrutura de malha
        estrutura com os dados da malha 
"""
function Analise3D(arquivo::AbstractString, posfile=true; verbose=false , x0=[], kparam=Function[])

   # Le os dado::AbstractStrings do problema
   malha = Le_YAML(arquivo; verbose=verbose)

   # Roda a rotina principal, devolvendo U e a estrutura de malha
   Analise3D(malha, posfile; x0=x0, kparam=kparam)

end

#
# Rotina para calcular as frequencia naturais de pórtico 3D
#
"""
Modal3D Rotina para análise modal de pórticos espaciais

Entrada: malha :   estrutuda de dados com as informações da malha do problema
         x0    :   vetor com variáveis de projeto (deve ter dimensão ne × 1)
         kparam:   vetor com função 

Saidas: Vetor das frequencia naturais do pórtico e estrutura de malha
        estrutura com os dados da malha 

"""
function Modal3D(malha::Malha, posfile=true; x0=[], kparam=Function[])

   # Se ρ não foi informado, inicializamos com 1.0
   if isempty(x0)
      x0 = ones(malha.ne) 

   else
      
      # Testa para ver se a dimensão está correta
      if length(x0)!=malha.ne
         error("Analise3D:: vetor de variáveis de projeto tem a dimensão errada") 
      end

      # Testa por consistência de valores
      if !all(0.0 .<x0 .<= 1)
         error("Analise3D:: vetor de variáveis de projeto tem valores inconsistentes") 
      end

   end

   # Verifica se kparam tem alguma definição de função 
   # caso não tenhamos, definimos o mapeamento direto
   if isempty(kparam)

      push!(kparam,x->x)

   end

   # Monta a matriz de rigidez global
   KG = Monta_Kg(malha,x0, kparam[1])

   # Monta a matriz mássica global
   MG = Monta_Mg(malha,x0, kparam[1])

   # Aplica as CC
   Kr,Mr = Condition(malha,KG,MG)

   # Resolução do problema de autovalor generalizado
   λ, U0 = eigen(Matrix(Kr), Matrix(Mr))

   # Loop pelo autovalores
   for i in eachindex(λ)

      # Verifica se é um modo de corpo rígido e faz ele ser 0.0 para quando tirar a raiz não dar problema
      if isapprox(λ[i], 0.0; atol=1e-6)
         λ[i] = 0.0
      end

   end
   
   # frequencia natural
   ωn = sqrt.(λ)

   return ωn,U0,malha
   
end

"""
Modal3D Rotina para análise modal de pórticos espaciais

Entrada: malha :   estrutuda de dados com as informações da malha do problema
         x0    :   vetor com variáveis de projeto (deve ter dimensão ne × 1)
         kparam:   vetor com função 

Saidas: Vetor das frequencia naturais do pórtico e estrutura de malha
        estrutura com os dados da malha 

"""
function Modal3D(arquivo::AbstractString, posfile=true; verbose=false , x0=[], kparam=Function[])

   # Le os dado::AbstractStrings do problema
   malha = Le_YAML(arquivo; verbose=verbose)

   # Roda a rotina principal, devolvendo U e a estrutura de malha
   Modal3D(malha, posfile; x0=x0, kparam=kparam)

end

