#
# Aqui vamos ter a função que calcula a derivada da restrição de tensão dgσ_dxm do material
#
function Derivada_gtensao(ne,dados_elementos, dicionario_materiais, 
                          dicionario_geometrias,L, tensao_limite,  U, elems, coord)

    # Inicializa um vetor de saída
    D2 = zeros(ne)

    # Vetor de carregamento adjunto para a tensão
    Ds = zeros(length(U))

    # Cada elemento possui 2 nós e cada nó possui dois "a"s:
    # Elementos...
    contador = 1   #<-----aqui assumimos que as primeiras restrições (tanto em g quanto em mu serão de tensão)
    for ele = 1:ne

        # Dados que vamos precisar:
        Ize, Iye, J0e, Ae, αe, Ee, Ge = Dados_fundamentais(ele, dados_elementos, dicionario_materiais, dicionario_geometrias)

        # Gls do elemento
        gls = Gls(ele,elems)

        # Extraindo o raio externo:
        re = sqrt(Ae/pi) 

        # Calcula os esforços no elemento
        Fe = Esforcos_elemento(ele,elems,dados_elementos,dicionario_materiais,dicionario_geometrias,
                               L,coord,U)

        # Matriz de von-Mises:
        VM = [1.0 1.0 0.0 ;
              1.0 1.0 0.0 ;
              0.0 0.0 3.0]

        # Tensão limite do material do elemento 
        sigma_esc = tensao_limite[ele]

        # Assumindo que fe(x) = x_e
        # a derivada parcial em relação a x_m
        # vai ser 1 se e==m e 0 se e != m
        dfe_dxm = dfe(ρ[ele])

        # Nós...
        for no = 1:2

            # Matriz Mn:
            if no == 1
                Mn = [-1   0   0   0   0   0   0   0   0   0   0   0;
                       0   0   0  -1   0   0   0   0   0   0   0   0;
                       0   0   0   0  -1   0   0   0   0   0   0   0;
                       0   0   0   0   0  -1   0   0   0   0   0   0]
            else
                Mn = [0    0   0  0   0   0   1   0   0   0   0   0;
                      0    0   0  0   0   0   0   0   0   1   0   0;
                      0    0   0  0   0   0   0   0   0   0   1   0;
                      0    0   0  0   0   0   0   0   0   0   0   1]
            end

            # Esforços no nó n (4x1)
            # N T My Mz
            En = Mn*fe

            # Extrai os momentos de En (esforços internos no nó)
            My = En[3]
            Mz = En[4]

            # Candidatos...
            for a = 0:1

                # Matriz Pna:
                Pn = [1/Ae     0        0;
                        0     0    (-re/Ize)^a;
                        0    re/J0e     0]


                # O momento resultante é:
                Mr = sqrt(My^2 + Mz^2)

                # Matriz utilizada nas derivadas de tensão equivalente
                D = [1     0       0       0;
                     0     1       0       0;
                     0     0     My/Mr   Mz/Mr]


                # Vetor de tensões:
                vec_sigma = Tensao_no_elemento(e,no,a,Fe,dados_elementos,dicionario_geometrias)

                # Tensão equivalente de von-Mises:
                sigma_eq = sqrt(transpose(vec_sigma)*VM*vec_sigma)

                # A derivada parcial de g em relação a x_ele será 
                dg_dxm = 1/sigma_esc * 1/sigma_eq * transpose(vec_sigma)* VM * Pn * D * Mn * dfe_dxm * Fe

                # Acumula no vetor D2
                D2[ele] += Heaviside(mu[contador]/c_σ + g[contador])*dg_dxm

                # Derivada parcial em relação ao U
                # vetor 12 x 1
                dg_dU = (1/sigma_esc) * (1/sigma_eq) * transpose(vec_sigma) * VM * Pn * D * Mn * fe * Ke0 * Re 

                # Acumula no vetor de carregamento adjunto
                Ds[gls] += Heaviside(mu[contador]/c_σ + g[contador])*dg_dU

                # incrementa o contador
                contador += 1

            end # a
        end # nó
    end # ele

    # Derivada parcial e também vetor de carregamento adjunto
    return (c_σ/(4*ne))*D2, (c_σ * transpose(vec_sigma)/(4*ne))*Ds

end
