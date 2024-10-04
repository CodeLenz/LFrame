#####################################################################################
#                        Rotina que faz o pré-processamento                         #
#####################################################################################
# Retorna o numero de elementos, o numero de nós e o 
# vetor com o comprimento dos elementos
#
function Pre_processamento(elems::Matrix{Int64}, coord::Matrix{Float64})
    
    # O numero de elementos será o numero de linhas da matriz de conectividades
    ne = size(elems,1)

    # Podemos alocar o vetor de comprimento
    L = zeros(ne)

    for e=1: ne

        # Descobre os nós de cada elemento
        no1, no2 = elems[e,:] # Usa o nó inicial e final da matriz de conectividades

        # As coordenadas dos nós de cada elemento:
        x1,y1, z1 = coord[no1,:]
        x2,y2, z2 = coord[no2,:]
        
        # Calcula a diferença de coordenadas dos nós
        dx = x2-x1
        dy = y2-y1 
        dz = z2-z1

        # O comprimento do elemento será
        Le = sqrt(dx^2 + dy^2+ dz^2)

        if (Le == 0.0)
            throw("comprimento 0 no elemento $e")
        end
        
        # Armazena o vetor
        L[e] = Le

    end

    return L

end