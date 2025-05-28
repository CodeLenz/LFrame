#
# Processa uma malha gerada no gmsh (.msh) 
# e retorna o centróide, os momentos de inércia e a orientação principal
#
function Secao_transversal(arquivo)

    # Le as informações sobre a malha 
    malha =  Parsemsh_FEM_Solid(arquivo)

    # Incializa os valores
    area = 0.0 
    sy   = 0.0
    sx   = 0.0
    
    # Matriz ne × 2 com os centróides de cada elemento 
    centroides = zeros(malha.ne,2)

    # Vetor com as áreas dos elementos
    A = zeros(malha.ne)

    # Loop sobre todos os elementos da malha
    for ele=1:malha.ne

        # Tipo do elemento 
        tipo = malha.connect[ele,1]

        # Coordenadas dos nós do elemento 
        X,Y = MontaXY(ele,tipo,malha.connect,malha.coord)

        # Centroide do elemento 
        centroides[ele,1] = sum(X)/length(X)
        centroides[ele,2] = sum(Y)/length(Y)

        # Área do elemento 
        A[ele] = Calcula_Area(tipo,X,Y)

        # Acumula a área
        area = area + A[ele]

        # Acumula o somatório de áreas de também dos centróides
        sx = sx + A[ele]*centroides[ele,1]
        sy = sy + A[ele]*centroides[ele,2]

    end #ele

    # Centróide da seção 
    centroide_x = sx/area
    centroide_y = sy/area

    # Podemos calcular os momentos de inércia
    
    Ix   = 0.0 
    Iy   = 0.0
    Ixy  = 0.0
    for ele=1:malha.ne
        Ix  = Ix  + A[ele]*(centroide_y - centroides[ele,2])^2
        Iy  = Iy  + A[ele]*(centroide_x - centroides[ele,1])^2
        Ixy = Ixy + A[ele]*(centroide_x - centroides[ele,1])*(centroide_y - centroides[ele,2])
    end

    # Mudamos a nomenclatura para zy
    Iz  = Ix
    Izy = -Ixy
     
    # Se o produto de inércia for nulo, não precisamos calcular a rotação do sistema 
    # de referência
    if isapprox(Izy,0.0, atol=1E-12)
 
       α = 0.0
       Izl = Iz
       Iyl = Iy
 
    else
 
       # Podemos calcular o α da direção principal;
       # Evitamos divisão por zero
       if isapprox(Iz,Iy,atol=1E-12)
          α = sign(Izy)*45.0
       else
          α = 0.5*atand( 2*Izy/(Iz-Iy) )
       end
 
       # Com isso, temos os valores extremos dados por
       Im = (Iz + Iy) / 2
       R = sqrt( ((Iz-Iy)/2)^2 + Ixy^2 )
       Izl = Im + R
       Iyl = Im - R
    end
 
    
    # Retorna as propriedades da seção 
    return area, α, Izl , Iyl

end


#
# Devolve dois vetores com as coordenadas dos nós do elemento 
#
function MontaXY(ele,tipo,connect,coord)

    # O número de nós depende do tipo de elemento 
    # default para triângulo (tipo 2)
    nn = 3
    if tipo==3
        nn = 4
    end

    # Aloca os vetores de saída
    X = zeros(nn)
    Y = zeros(nn)

    # Loop pelos nós deste elemento
    for n=1:nn

        # Descobre quem é o nó i do elemento 
        no = connect[ele,2+n]

        # Recupera as coordeandas deste nó 
        X[n] = coord[no,1]
        Y[n] = coord[no,2]

    end

    # Retorna os vetores 
    return X,Y

end


#
# Calcula a área de um elemento 
#
function Calcula_Area(tipo,X,Y)

    # Inicializa
    area = 0.0

    # Se for triângulo
    if tipo==2

        # Area pelo det do triângulo
        area = (1/2)*det([X[1] Y[1] 1 ;
                          X[2] Y[2] 1 ;
                          X[3] Y[3] 1])

    else

        # Area utilizando quadratura de Gauss
        area = Area_quad(X,Y)

    end

    # Retorna a área do elemento 
    return area


end


function MontadN(r,s)

    # Matriz com as derivadas das funções de interpo
    # primeira linha em relação a r
    # segunda linha em relação a s
    dNrs = (1/4)*[s-1   1-s   1+s -(1+s) ;
                  r-1 -(1+r)  1+r   1-r ]

    # Retorna a matriz
    return dNrs

end


#
# Monta a matriz J em um ponto (r,s)
#
function MontaJ(dNrs,X,Y)

    # Aloca a matriz J
    J = zeros(2,2)

    # Loop do somatório
    for i=1:4

        # dx/dr
        J[1,1] = J[1,1] + dNrs[1,i]*X[i]

        # dy/dr
        J[1,2] = J[1,2] + dNrs[1,i]*Y[i]

        # dx/ds
        J[2,1] = J[2,1] + dNrs[2,i]*X[i]

        # dy/ds
        J[2,2] = J[2,2] + dNrs[2,i]*Y[i]

    end #i

    # Retorna a matriz J no ponto (r,s)
    return J

end

function Area_quad(X,Y)

    area = 0.0

    pg = (1/sqrt(3))*[-1 ; 1]

    for r in pg
        for s in pg
            dN = MontadN(r,s)
            J = MontaJ(dN,X,Y)
            area = area + det(J)
        end
    end

    return area

end