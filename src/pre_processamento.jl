#####################################################################################
#                        Rotina que faz o pré-processamento                         #
#####################################################################################
# Retorna o numero de elementos, o numero de nós e o 
# vetor com o comprimento dos elementos
#
function Pre_processamento(malha::Malha)

    # Acessa as informações que precisamos da estrutura de dados
    ne = malha.ne
    conect = malha.conect
    coord = malha.coord
    
    # Podemos alocar o vetor de comprimento
    L = Array{Float64}(undef,ne)

    # Loop pelos elementos da malha
    for e = 1:ne

        # Descobre os nós de cada elemento
        no1, no2 = conect[e,:] # Usa o nó inicial e final da matriz de conectividades

        # Coordenadas dos nós
        #= Maneira mais eficiente e compacta de fazer 
           o mesmo cálculo
        c1 = coord[no1,:]
        c2 = coord[no2,:]
        Le = norm(c1.-c2)
        =#

        # As coordenadas dos nós de cada elemento:
        x1,y1,z1 = coord[no1,:]
        x2,y2,z2 = coord[no2,:]
        
        # Calcula a diferença de coordenadas dos nós
        dx = x2-x1
        dy = y2-y1 
        dz = z2-z1

        # O comprimento do elemento será
        Le = sqrt(dx^2 + dy^2+ dz^2)

        # Evita comprimento nulo
        if (Le == 0.0)
            throw("comprimento 0 no elemento $e")
        end
        
        # Armazena o vetor
        L[e] = Le

    end
    
    # Retorna o vetor com os comprimentos de cada elemento
    return L

end