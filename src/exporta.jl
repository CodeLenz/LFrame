#
# Grava os resultados .pos (gmsh) e
#
# Atualmente está gravando somente os deslocamentos 
#
function Gera_pos_U(malha::Malha,U::AbstractVector)

   # Cria o arquivo completo do .pos com o nome do yaml
   #nome_pos = joinpath(pos, basename(malha.nome_arquivo) * ".pos")
   nome_pos = malha.nome_arquivo*".pos"

   # Todos os elementos são do tipo 1
   etype = ones(Int64,malha.ne)
   
   # Inicializa o arquivo para o gmsh 
   Lgmsh_export_init(nome_pos,malha.nnos,malha.ne,malha.coord,etype,malha.conect)

   # Como estamos trabalhando com vigas, temos que cuidar que existem informações 
   # sobre rotação que o gmsh não processa. Por isso, vamos filtrar para 
   # exportar somente as translações (os 3 primeiros gls de cada nó)
   U_trans = zeros(3*malha.nnos)
   
   cont = 1
   for i=1:malha.nnos
       for j=1:3
           U_trans[cont] = U[6*(i-1)+j]
           cont += 1
       end
   end
   
   @show U
   @show U_trans

   # Grava os deslocamentos para visualização 
   Lgmsh_export_nodal_vector(nome_pos,U_trans,3,"Deslocamentos")
    
end


#
# Grava os esforços internos em uma pasta específica
#
function Gera_esforcos(malha::Malha,U::AbstractVector)
   
   # Cria o arquivo completo do .esf com o nome do yaml
   #nome_esf = joinpath(esf, basename(malha.nome_arquivo) * ".esf")
   nome_esf = malha.nome_arquivo*".esf"

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