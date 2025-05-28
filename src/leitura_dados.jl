###############################################################
#
# Le um arquivo de dados em YAML e retorna estrutuas de dados 
# para o programa principal na forma de uma estrutura de dados 
# Malha -> ver struct_malha.jl
#
###############################################################
#
# Os dados que são lidos e processados atualmente são 
#
# versao: {numero}
#
# titulo: {String} 
#
# data: {string}
#
# coordenadas: 
#              x_1  y_1  z_1
#                 ....
#              x_n  y_n  z_n 
#
# conectividades: 
#                n1_1  n2_1  
#                  ...
#               n1_ne  n2_ne
#
# materiais:
#         - nome: {String}
#           G: {numero}
#           Ex: {numero}
#           S_esc: {numero}
#               ....
#         - nome: {String}
#           G: {numero}
#           Ex: {numero}
#           S_esc: {numero}
#
# geometrias:
#         - nome: {string}
#            Iz: {numero}
#            A:  {numero}
#            Iy: {numero}
#            α:  {numero}
#            J0: {numero}
#                ...
#         - nome: {string}
#            Iz: {numero}
#            A:  {numero}
#            Iy: {numero}
#            α:  {numero}
#            J0: {numero}
#
# floads: 
#        ele q1y q2y q1z q2z
#               ...
#      
# loads: 
#         no  gl  valor
#              ...
#
# apoios: 
#         no  gl  valor 
#             ...
#
# dados_elementos:
#          material geometria
#
# mpc: 
#      no1 gl1 no2 gl2
#            ... 
#
##########################################################################
#
# Sendo que: 
#
# coordenadas
# conectividades
# materiais
# geometrias 
# apoios 
#
# são obrigatórios.
#
# Dentro de materiais, temos que 
#
# nome
# Ex 
# G
#
# são obrigatórios.
#
# Dentro de geometrias, temos que TODOS os dados são obrigatórios
#
#########################################################################
#
# Graus de liberdade locais podem ser informados por número 
#
# 1 a 6 
# 
# ou por simbolos. A rotina Converte_array é responsável pela convesão
# e os símbolos são 
# 
# gls["ux"]=1; gls["uy"]=2; gls["uz"]=3
# gls["θx"]=4; gls["θy"]=5; gls["θz"]=6
# gls["fx"]=1; gls["fy"]=2; gls["fz"]=3
# gls["mx"]=4; gls["my"]=5; gls["mz"]=6#
#
#
########################################################################
function Le_YAML(arquivo::AbstractString,ver=1.0;verbose=false)

   # Primeiro verificamos se existe o arquivo
   #if !isfile(arquivo)
   #    error("Le_YAML:: arquivo $arquivo não existe")
   #end

   # Teste idiota, se tem alguma coisa no arquivo
   if filesize(arquivo)==0
       error("Le_YAML:: arquivo $arquivo está vazio")
   end

   # Primeiro lemos o arquivo de dados
   dados = YAML.load_file(arquivo)

   # Verifica se temos informação sobre a versão do arquivo de dados
   versao = 0.0
   if haskey(dados,"versao")

      # Le a versão do arquivo
      versao = dados["versao"]

      # Verifica se a versão é compatível
      versao==ver || throw("Le_YAML::versão do arquivo não é compatível com a versão atual") 
        
   end

   # Dados obrigatórios para o arquivo de entrada
   dados_obrigatorios=["coordenadas","conectividades","apoios","materiais","geometrias","dados_elementos"]

   # Vamos verificar se os dados obrigatorios estão informados
   for dado in dados_obrigatorios
       haskey(dados,dado) || error("Dado obrigatório $dado não foi infomado no arquivo $arquivo")
   end

   # Vamos ver se o título e/ou a data estão definidos
   titulo = ""
   if haskey(dados,"titulo")
      titulo = dados["titulo"]
   end

   data = ""
   if haskey(dados,"data")
      data = dados["data"]
   end

   if verbose
      println("Lendo    ",arquivo)
      if versao>0 
          println("Versão:  ", versao)
      end
      println("Título:  ", titulo)
      println("Data:    ", data)
   end


   ########################################### Coordenadas ########################################

   # Para debug
   verbose && println("Coordenadas")  

   # Recupera as informações (como uma longa string)
   string_coordenadas = dados["coordenadas"]

   # Converte para uma matriz Float64
   coord = Converte_array(string_coordenadas,3,Float64)

   # O número de nós vai ser o número de linhas em coord
   nnos = size(coord,1)

   # Teste basicão
   nnos>=2 || error("leitura_dados::ao menos 2 nós são necessários")

   ########################################### Materiais ########################################

   # Para debug
   verbose && println("Materiais")  

   # Vetor de dicionários dos materiais
   vetor_materiais = dados["materiais"]

   # Dados obrigatórios para cada um dos materiais
   dados_obrigatorios_materiais = ["nome","Ex","G"]

   # Precisamos ter ao menos uma informação
   length(vetor_materiais)>=1 || error("leitura_dados:: ao menos um material é necessário")

   # Podemos iterar em cada um dos materais para ver se o básico está sendo definido
   contador = 0
   for mat in vetor_materiais
       contador += 1
       for dat in dados_obrigatorios_materiais
          haskey(mat,dat) || error("Dado obrigatório $dat não foi informado para o material $contador")
       end
    end

    # Beleza. Só vou fazer o seguinte agora. Vou fazer um dicionário onde o nome é a chave e 
    # os dados ficam em um outro dicionário. Isso vai facilitar muito o acesso depois
    dicionario_materiais = OrderedDict{String,Dict{String,Float64}}()

    # Eu vou criar um vetor só com os nomes para verificar a consistência em dados_elementos
    # mais abaixo
    nomes_materiais = String[]

    # Para debug
    verbose && println("Loop pelos materiais")  

    #  Novo loop pelos 
    for mat in vetor_materiais

        # Nome do material
        nome = mat["nome"]

        # Guarda o nome em nomes_materiais
        push!(nomes_materiais,nome)

        # Cria um dicionário interno. 
        interno = Dict{String,Float64}()

        # Itera pelas chaves de mat, pulando o campo nome
        for (key,value) in mat
            if key!="nome"
               try
                    interno[key]= value 
               catch
                    interno[key]=parse(Float64,value)
               end 
            end
        end

        # Armazena o dicionário interno no dicionário de materiais 
        dicionario_materiais[nome]=interno

    end

   ########################################### Geometrias ########################################
   
   # Para debug
   verbose && println("Geometrias")  

   # Vetor de dicionários dos geometrias
   vetor_geometrias = dados["geometrias"]

   # Dados obrigatórios para cada uma das geometrias
   dados_obrigatorios_geometrias = ["nome","A","Iz","Iy","J0", "α"]

   # Precisamos ter ao menos uma informação
   length(vetor_geometrias)>=1 || error("leitura_dados:: ao menos uma geometria é necessária")

   # Podemos iterar em cada uma das geometrias para ver se o básico está sendo definido
   contador = 0
   for geo in vetor_geometrias
       contador += 1
       for dat in dados_obrigatorios_geometrias
          haskey(geo,dat) || error("Dado obrigatório $dat não foi infomado para a geometria $contador")
       end
    end

    # Beleza. Só vou fazer o seguinte agora. Vou fazer um dicionário onde o nome é a chave e 
    # os dados ficam em um outro dicionário. Isso vai facilitar muito o acesso depois
    dicionario_geometrias = OrderedDict{String,Dict{String,Float64}}()

    # Eu vou criar um vetor só com os nomes para verificar a consistência em dados_elementos
    # mais abaixo
    nomes_geometrias = String[]

    # Para debug
    verbose && println("Loop pelas geometrias")  

    #  Novo loop pelo vetor de geometrias
    for geo in vetor_geometrias

        # Nome da geometria
        nome = geo["nome"]

        # Guarda o nome em nomes_geometrias
        push!(nomes_geometrias,nome)

        # Cria um dicionário interno. 
        interno = Dict{String,Float64}()

        # Itera pelas chaves de geo, pulando o campo nome
        for (key,value) in geo
            if key!="nome"
               try
                    interno[key]= value 
               catch
                    interno[key]=parse(Float64,value)
               end 
            end
        end

        # Armazena o dicionário interno no dicionário de geometrias
        dicionario_geometrias[nome] = interno

    end

   ########################################### Apoios ########################################

   # Para debug
   verbose && println("Apoios")  

   # Recupera as informações (como uma longa string)
   string_apoios = dados["apoios"]

   # Converte para uma matriz Float64
   apoios = Converte_array(string_apoios,3,Float64)

   ########################################### Conectividades ########################################

   # Para debug
   verbose && println("Conectividades")  

   # Recupera as informações (como uma longa string)
   string_conect = dados["conectividades"]

   # Converte para uma matriz Int64
   conect = Converte_array(string_conect,2,Int64)

   # Número de elementos é o número de linhas em conect
   ne = size(conect,1)

   # Teste basicão
   ne>=1 || throw("leitura_dados:: ao menos um elemento é necessário")

   ########################################### Dados elementos ######################################
   
   # Para debug
   verbose && println("Dados elementos")  

   # Recupera as informações (como uma longa string)
   string_dados_elementos = dados["dados_elementos"]

   # Converte para uma matriz de strings (chaves para os dicionários)
   dados_elementos_ = Converte_array(string_dados_elementos,2,String)

   # Testa se temos somente uma linha - neste caso, assumimos que todos os elementos
   # tem o mesmo material e a mesma geometria
   if size(dados_elementos_,1)==1
  
      verbose && println("Caso particular de somente um linha em dados_elementos:") 

      # Vamos ter que redimensionar o array e copiar a linha 1 para das demais
      dados_elementos = ones(String,ne,2)

      # Loop preenchendo todos com o valor da primeira linha de dados_elementos_
      for ele=1:ne
          dados_elementos[ele,:] .= dados_elementos_[1,:]
      end

    else
        # Só copia dados_elementos_ para dados_elementos
        dados_elementos = dados_elementos_
   end

   # Teste de consistência
   size(dados_elementos,1)==ne || error("leitura_dados::dados_elementos deve ter $ne linhas")
   
   # Para debug
   verbose && println("Loop pelos elementos")  

   # Precisamos verificar se os dados informados são coerentes com as definições de mat e geo
   # Verificação de consistência dos dados de cada elemento
   for linha=1:ne

        # material do elemento
        mat = dados_elementos[linha,1]

        # Verifica se está em nomes_materiais
        mat in nomes_materiais || error("leitura_dados::dados_elementos linha $linha:: material $mat não foi definido")

        # material do elemento
        geo = dados_elementos[linha,2]

        # Verifica se está em nomes_materiais
        geo in nomes_geometrias || error("leitura_dados::dados_elementos linha $linha:: geometria $geo não foi definida")
        
    end
   
   ################################# Forças concentradas ######################################

   # Para debug
   verbose && println("Forças concentradas")  

   # Recupera as informações (como uma longa string)
   string_loads = dados["loads"]

   # Converte para uma matriz de strings (chaves para os dicionários)
   loads = Converte_array(string_loads,3,Float64)

   ################################ MPC ######################################

   # Para debug
   verbose && println("MPC")  

   # Recupera as informações (como uma longa string)
   if haskey(dados,"mpc")
      string_mpc = dados["mpc"]

      # Converte para uma matriz de strings (chaves para os dicionários)
      mpc = Converte_array(string_mpc,4,Float64)
   else
      mpc = Float64[]
   end

   
   ######################### Forças distribuídas #################################

   # Para debug
   verbose && println("Forças distribuídas")  

   # Recupera as informações (como uma longa string)
   if haskey(dados,"floads")
      string_floads = dados["floads"]

      # Converte para uma matriz de strings (chaves para os dicionários)
      floads = Converte_array(string_floads,5,Float64)
      
   else
      floads = Float64[]
   end

   # Calcula os comprimentos da malha
   L = Calcula_comprimentos(ne,conect,coord)

   # Cria a estrutura com os dados da malha e retorna para o programa
   # principal
   return Malha(ne, nnos, coord, conect, apoios, dicionario_materiais, dicionario_geometrias, dados_elementos, loads, mpc, floads, L)
   
end


#
# Função que vai funcionar somente para dados opcionais não 
# informados, como MPC, por exemplo
#
function Converte_array(dado::Nothing,ncol::Int64,T::Type)
    return T[]
end


#
# Converte uma string para uma matriz do tipo T com ncol colunas 
# Entende-se que dado é uma string com os dados do array separados por
# espaços. A ordem dos dados é linha por linha, com cada linha separada
# por um delimitador de linha (\n) 
#
function Converte_array(dado::String,ncol::Int64,T::Type)

   # Dicionários entre símbolos e graus de liberdade
   gls = Dict{String,Int64}()
   gls["ux"]=1; gls["uy"]=2; gls["uz"]=3
   gls["θx"]=4; gls["θy"]=5; gls["θz"]=6
   gls["fx"]=1; gls["fy"]=2; gls["fz"]=3
   gls["mx"]=4; gls["my"]=5; gls["mz"]=6

   # Começamos separando os dados por espaço
   separado = split(dado)

   # E precisamos verificar se a dimensão está correta
   if !(rem(length(separado),ncol)==0)
       error("Converte_array:: a informação não tem a dimensão esperada (não é múltiplo de $col)")
   end

   # Número de linhas
   nlinhas = div(length(separado),ncol)

   # Aloca a matriz de saída
   saida = Array{T}(undef,nlinhas,ncol)

   # Agora iteramos o vetor de strings e convertemos para o tipo desejado.
   # Os dados são lidos linha por linha no arquivo de entrada
   contador = 1
   for i=1:nlinhas
        for j=1:ncol

            # Informação a ser avaliada
            informacao = separado[contador]

            # Primeiro testamos se o dado é uma das chaves dos dicionários. Se for, 
            # trocamos o símbolo pelo número
            if haskey(gls,informacao)
                valor = gls[informacao]
            else
                # Se T não for String, converte a informação para o tipo de dado desejado
                if T===String
                    valor = informacao
                else
                    try
                        valor  = parse(T,informacao)
                    catch
                        error("Não foi possível converter $(informacao) para o tipo $T")
                    end
                end
            end

            # Grava a informação na matriz
            saida[i,j] = valor

            # Incrementa o contador
            contador += 1

        end #j
    end #i  
     
    # Retorna o array 
    return saida

end