#
# Rotina que vai exportar os arquivos na sua pasta
#

function pos(malha::Malha,caminho,U)
    # caminho para a pasta pos
    Pos = caminho *"\\Pos"

    # Cria o arquivo completo do .pos com o nome do yaml
    nome_pos = joinpath(Pos, basename(malha.nome_arquivo) * ".pos")

    # Inicializa um arquivo do Gmsh para visualização
    etype = ones(Int64,malha.ne)
    
    Lgmsh_export_init(nome_pos,malha.nnos,malha.ne,malha.coord,etype,malha.conect)

    # Grava os deslocamentos para visualização 
    Lgmsh_export_nodal_vector(nome_pos,U,3,"Deslocamentos")
    
end

function esf(malha::Malha,caminho,U)
    # caminho para a pasta esforços
      esf = caminho *"\\Esforcos"

      # Cria o arquivo completo do .esf com o nome do yaml
      nome_esf = joinpath(esf, basename(malha.nome_arquivo) * ".esf")

      # Exporta os esforços externos (12 × 1) para cada elemento da malha
      fd = open(nome_esf,"w")

      # Primeira linha é uma string Esforcos para o P2Poffo
      print(fd,"Esforcos")
      println(fd)

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