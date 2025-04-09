#####################################################################################
#                 Contém a matriz de rigidez do elemento de viga 3d                 #
#####################################################################################

function Ke_portico3d(Ee::Float64, Ize::Float64, Iye::Float64, Ge::Float64, J0e::Float64, Le::Float64, Ae::Float64)



    # Termos de barra
    K_barra = (Ee*Ae/Le)*[1.0 -1.0 ; -1.0 1.0]
    gls_barra = [1;7]

    # Termos de eixo
    K_eixo = (Ge*J0e/Le)*[1.0 -1.0 ; -1.0 1.0]
    gls_eixo = [4;10]

    # Viga no plano xy
    K_xy = (Ee*Ize)*[12/Le^3   6/Le^2  -12/Le^3  6/Le^2  ;
                     6/Le^2    4/Le   -6/Le^2    2/Le   ;
                    -12/Le^3  -6/Le^2  12/Le^3  -6/Le^2 ;
                     6/Le^2     2/Le    -6/Le^2  4/Le]
    gls_xy = [2;6;8;12]


    # OBSERVAÇÃO: NO LIVRO DO RAO AS ROTAÇÕES EM Z ESTÃO TROCADAS. Por isso não há mudança de sinal.
    # No nosso caso estamos usando a notação vetorial, então as trocas de sinal precisam ser feitas.
    # Viga no plano xz
    K_xz = (Ee*Iye)*[12/Le^3   -6/Le^2  -12/Le^3  -6/Le^2  ;
                     -6/Le^2    4/Le   6/Le^2    2/Le   ;
                    -12/Le^3   6/Le^2  12/Le^3  6/Le^2 ;
                     -6/Le^2     2/Le    6/Le^2  4/Le]
    gls_xz = [3;5;9;11]

    # Monta a matriz do elemento de pórtico 3D
    K = zeros(12,12)

    K[gls_barra, gls_barra] .= K_barra
    K[gls_eixo, gls_eixo] .= K_eixo
    K[gls_xy, gls_xy] .= K_xy
    K[gls_xz, gls_xz] .= K_xz

    # Utilizando ρ na matriz do elemento


    #=
    #              1              2               3                 4                5                    6                    7               8                  9               10               11              12
      [       Ee*Ae/Le         0                0                  0               0                    0                   -Ee*Ae/Le        0                  0                0                0                0;
                 0       (12*Ee*Ize)/Le^3       0                  0               0                (6*Ee*Ize)/Le^2           0         -(12*Ee*Ize)/Le^3       0                0                0         (6*Ee*Ize)/Le^2;
                 0              0          (12*Ee*Iye)/Le^3        0          -(6*Ee*Iye)/Le^2          0                     0                0         -(12*Ee*Iye)/Le^3       0         -(6*Ee*Iye)/Le^2        0;
                 0              0               0             (Ge*J0e)/Le          0                    0                     0                0                0           -(Ge*J0e)/Le          0                0;
                 0              0        -(6*Ee*Iye)/Le^2          0          (4*Ee*Iye)/Le             0                     0                0          (6*Ee*Iye)/Le^2        0           (2*Ee*Iye)/Le          0;
                 0      (6*Ee*Ize)/Le^2         0                  0               0              (4*Ee*Ize)/Le               0        -(6*Ee*Ize)/Le^2         0                0                0          (2*Ee*Ize)/Le;
              -Ee*Ae/Le        0                0                  0               0                    0                 Ee*Ae/Le             0                0                0                0                0;
                 0     -(12*Ee*Ize)/Le^3        0                  0               0            -(6*Ee*Ize)/Le^2              0         (12*Ee*Ize)/Le^3        0                0                0         -(6*Ee*Ize)/Le^2;
                 0             0        -(12*Ee*Iye)/Le^3          0           (6*Ee*Iye)/Le^2          0                     0                0          (12*Ee*Iye)/Le^3       0           (6*Ee*Iye)/Le^2       0;
                 0             0                0           -(Ge*J0e)/Le           0                    0                     0                0                0            (Ge*J0e)/Le          0                0;
                 0             0        -(6*Ee*Iye)/Le^2           0          (2*Ee*Iye)/Le             0                     0                0        (6*Ee*Iye)/Le^2          0           (4*Ee*Iye)/Le         0;
                 0     (6*Ee*Ize)/Le^2          0                  0               0             (2*Ee*Ize)/Le                0         -(6*Ee*Ize)/Le^2         0                 0                 0        (4*Ee*Ize)/Le]
                 =#

   return K              
  end

# A matriz de forças de engastamento perfeito (distribuidos)

# Esse vetor deverá conter as forças nos graus de liberdade em x (da barra, que serão zero) e da viga em y e da viga em z. 
# Isso foi definido usando o Maxima com as funções de interpolação lineares e estão todas documentadas


function Fe_viga(Le, q1y, q2y, q1z, q2z)

  [             0               ;
    (3*q2y*Le)/20+(7*q1y*Le)/20 ;
    (3*q2z*Le)/20+(7*q1z*Le)/20 ;
                0               ;
    (q2z*Le^2)/30+(q1z*Le^2)/20 ;
    (q2y*Le^2)/30+(q1y*Le^2)/20 ;
                0               ;
    (7*q2y*Le)/20+(3*q1y*Le)/20 ;
    (7*q2z*Le)/20+(3*q1z*Le)/20 ;
                0               ;
    -(q2z*Le^2)/20-(q1z*Le^2)/30;
    -(q2y*Le^2)/20-(q1y*Le^2)/30]

end

