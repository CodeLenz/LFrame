######################################################################################
# Rotina para fazer a montagem da matriz de rotação já no caso da viga em 3 dimensões#
######################################################################################

function Rotacao3d(e, elems, coord, α)

    # Descobre os nós de cada elemento
    no1, no2 = elems[e, :] # Usa o nó inicial e final da matriz de conectividades

    # As coordenadas dos nós de cada elemento:
    x1, y1, z1 = coord[no1, :]
    x2, y2, z2 = coord[no2, :]

    dx = x2 - x1
    dy = y2 - y1
    dz = z2 - z1

    # O comprimento do elemento será
    Le = sqrt(dx^2 + dy^2 + dz^2)

    # Cossenos diretores (X)
    cos_xx = dx / Le
    cos_yx = dy / Le
    cos_zx = dz / Le

    # Calcula "d"
    h = sqrt(cos_xx^2 + cos_zx^2)

    if h == 0

        # Eixo Y'
        # Para podermos usar direto no caso 2D
        cos_xy = -cos_yx
        cos_yy = 0.0
        cos_zy = 0.0

        # Eixo Z´
        cos_xz = 0.0
        cos_yz = 0.0
        cos_zz = 0.0

        # Compatibiliza com a notação do TCC da Verônica
        mox = cos_yx

        # Caso particular em que x local do elemento está na direção Y
        R = [0.0 mox 0.0
            -mox*cosd(α) 0.0 mox*sind(α)
            sind(α) 0.0 cosd(α)]

    else

        # Eixo Y'
        cos_xy = -(cos_xx * cos_yx) / h
        cos_yy = (cos_zx^2 + cos_xx^2) / h
        cos_zy = -(cos_yx * cos_zx) / h

        # Eixo Z´
        cos_xz = -cos_zx / h
        cos_yz = 0.0
        cos_zz = cos_xx / h

        # Matriz de rotação z' paralelo ao plano XZ
        T1 = [cos_xx cos_yx cos_zx
            cos_xy cos_yy cos_zy
            cos_xz cos_yz cos_zz]

        # Rotaciona em torno de X
        T2 = [1.0 0.0 0.0
            0.0 cosd(α) sind(α)
            0.0 -sind(α) cosd(α)]

        # rotacionamos => Primeiro em X e depois em z'    
        R = T1 * T2

    end

    # Posiciona R em T (aqui temos 4 blocos 3x3 pois temos 2 nós c 6 gdl cada)
    z = zeros(3, 3)
    T = [R z z z
        z R z z
        z z R z
        z z z R]

    return T
end