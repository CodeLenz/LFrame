#
# Grava os resultados .pos (gmsh) em uma pasta específica
#
# Atualmente está gravando somente os deslocamentos 
#
function Gera_pos(malha::Malha,U::AbstractVector)

   # Caminho para o arquivo de entrada do problema 
   dir_base = dirname(malha.nome_arquivo)

   # Constroi o caminho para os arquivos de saída
   Pos = joinpath(dir_base, "Pos")

   # Cria o arquivo completo do .pos com o nome do yaml
   nome_pos = joinpath(Pos, basename(malha.nome_arquivo) * ".pos")

   # Todos os elementos são do tipo 1
   etype = ones(Int64,malha.ne)
   
   # Inicializa o arquivo para o gmsh 
   Lgmsh_export_init(nome_pos,malha.nnos,malha.ne,malha.coord,etype,malha.conect)

   # Grava os deslocamentos para visualização 
   Lgmsh_export_nodal_vector(nome_pos,U,3,"Deslocamentos")
    
end


#
# Grava os esforços internos em uma pasta específica
#
function Gera_esforcos(malha::Malha,U::AbstractVector)
   
   # Caminho para o arquivo de entrada do problema 
   dir_base = dirname(malha.nome_arquivo)

   # Caminho para a pasta esforços
   esf = joinpath(dir_base, "Esforcos")

   # Cria o arquivo completo do .esf com o nome do yaml
   nome_esf = joinpath(esf, basename(malha.nome_arquivo) * ".esf")

   # Exporta os esforços externos (12 × 1) para cada elemento da malha
   fd = open(nome_esf,"w")

   # Primeira linha é uma string Esforcos para o P2Poffo
   println(fd,"Esforcos")
   
   # Loop pelo elementos
   for ele = 1:malha.ne

      # Calcula as forças nodais no elemento e recupera a geometria do elemento 
      geo,Fe =  Forcas_elemento(ele,malha,U)

      print(fd,geo," ")

      # Grava na linha do arquivo
      for v in Fe
         print(fd," ", v)
      end

      # Pula uma linha 
      println(fd)

   end
      
   # Fecha o arquivo 
   close(fd)
    
end