#
# Rotina que monta a matriz mássica de um elemento
#
function Me_portico3d(Ae::T, ρe::T, Le::T) where T

    # Termos de barra
    M_barra = (Ae*ρe*Le)*[1.0/3.0 1.0/6.0 ; 1.0/6.0 1.0/3.0]
    gls_barra = [1;7]

    # Termos de eixo
    M_eixo = (Ae*ρe*Le)*[1.0/3.0 1.0/6.0 ; 1.0/6.0 1.0/3.0]
    gls_eixo = [4;10]

    # Viga no plano xy
    M_xy = ((Ae*ρe*Le)/420)*[156   22*Le  54  -13*Le  ;
                     22*Le    4*Le^2   13*Le    -3*Le^2   ;
                     54  13*Le  156  -22*Le ;
                     -13Le -3Le^2 -22*Le 4*Le^2]
    gls_xy = [2;6;8;12]


    # A matriz massica independe do sentido de coordenadas
    M_xz = M_xy
    gls_xz = [3;5;9;11]

    # Monta a matriz mássica do elemento de pórtico 3D
    M = zeros(T,12,12)

    M[gls_barra, gls_barra] .= M_barra
    M[gls_eixo, gls_eixo] .= M_eixo
    M[gls_xy, gls_xy] .= M_xy
    M[gls_xz, gls_xz] .= M_xz


   return M            
  end