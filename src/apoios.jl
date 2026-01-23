#####################################################################################
#                   Rotina para aplicar as condições de contorno                    #
#####################################################################################

function Aumenta_sistema(malha::Malha,KG::AbstractMatrix,F::Vector)

    # Acessa os dados da estrutura Malha
    apoios = malha.apoios
    MPC    = malha.mpc

    # Numero de restrições no sistema
    m = size(apoios, 1)

    # Número de MPCs
    s = size(MPC,1)

    # Dimensão do problema
    n = length(F)

    # Alocando a matriz A, que contém as relações
    # entre os gls restritos
    A = spzeros(m+s, n)

    # Alocando o vetor de deslocamentos com restrição
    b = zeros(m+s)

    # Loop pelas c.c
    for i=1:m

         # Descobre o nó do apoio
         no = Int64(apoios[i,1])

         # Descobre o gl(local) do apoio
         gl = Int64(apoios[i,2])

         # Gl global do apoio
         glg = 6*(no-1)+gl

         # Preenchendo com 1 as posições globais onde os deslocamentos são restritos
         A[i,glg] = 1

         # B é o vetor que possui os valores dos deslocamentos restritos
         b[i] = apoios[i,3]

    end

    # Loop pelos MPCs
    for i=1:s

        # Nó 1 do MPC
        no1 = Int64(MPC[i,1])
        gl1 = Int64(MPC[i,2])
        glg1 = 6*(no1-1)+gl1


        # Nó 2 do MPC
        no2 = Int64(MPC[i,3])
        gl2 = Int64(MPC[i,4])
        glg2 = 6*(no2-1)+gl2

        A[m+i,glg1] =  1.0
        A[m+i,glg2] = -1.0

    end

    # A matriz de rigidez aumentada, KA
    KA = [KG A'; A spzeros(m+s, m+s)]

    # O vetor de força aumentado FA
    FA = [F; b]

    return KA, FA

end

#
# Rotina para aplicar as condições de contorno para modal
#
function Condition(malha::Malha, KG::AbstractMatrix, MG::AbstractMatrix)
    
    # Recupera os dados da malha
    apoios = malha.apoios

    # numero de apoios
    m = size(apoios, 1)

    # numero total de GDLs
    ngdl = size(KG, 1)

    # Vetor de GDLs fixos
    fixos = Int[]

    # Loop pelos apoios
    for i in 1:m 

        # Recupera o nó
        no    = Int(apoios[i,1])  
        
        # Recupera o GDL
        gdl   = Int(apoios[i,2])   

        # Recupera o valor
        valor = apoios[i,3]        

        # Aloca o gdl local no global 
        glg = 6*(no-1) + gdl

        # Verifica se o deslocamento prescrito é zero 
        if valor == 0
            push!(fixos, glg)
        else
            error("O nó $no está com o GDL $gdl livre")
        end
        
    end

    # GDLs livres
    livres = Int[]
    
    # Loop por todos os GDLs globais
    for i in 1:ngdl

        # Verifica se i não é um gdl fixo
        if !(i in fixos)

            # Armazena no vetor livres
            push!(livres, i)
        end
    end

    # Matrizes reduzidas
    Kr = KG[livres, livres]
    Mr = MG[livres, livres]

    return Kr, Mr
end
