#####################################################################################
#                   Rotina para aplicar as condições de contorno                    #
#####################################################################################

function Aumenta_sistema(apoios::Matrix{Float64},MPC::Array,KG::AbstractMatrix,F::Vector)

    # Numero de restrições no sistema
    m = size(apoios, 1)

    # Número de MPCs
    s = size(MPC,1)

    # Dimensão do problema
    n = length(F)

    # Alocando a matriz A
    A = spzeros(m+s, n)

    # Alocando o vetor de deslocamentos com restrição
    b = zeros(m+s)

    # Loop pelas c.c
    for i= 1:m

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

        A[m+i,glg1] = 1.0
        A[m+i,glg2] = -1.0

    end

    # A matriz de rigidez aumentada, KA
    KA = [KG A'; A spzeros(m+s, m+s)]

    # O vetor de força aumentado FA
    FA = [F; b]

    return KA, FA

end
