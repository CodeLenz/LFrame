#
# Aqui vamos ter a função que calcula a derivada da restrição de tensão dgσ_dxm do material
#
function Derivada_gtensao(ne, ρ, μ, c_σ, g, dados_elementos, dicionario_materiais,
                          dicionario_geometrias,L, U, elems, coord, sigma_esc)

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

        # Calculando o raio externo:
        re = sqrt(J0e/Ae + Ae/(2*pi)) 

        # Calcula os esforços no elemento - ordem: X Y Z
        Fe = Esforcos_elemento(ele,elems,dados_elementos,dicionario_materiais,dicionario_geometrias,
                               L,coord,U)

        # Matriz de von-Mises:
        # N
        # T
        # M
        VM = Matriz_VM()

        # Assumindo que fe(x) = x_e
        # a derivada parcial em relação a x_m
        # vai ser 1 se e==m e 0 se e != m
        dfe_dxm = dfe(ρ[ele])

        # Matriz de rigidez do elemento
        Ke0 = Ke_portico3d(Ee, Ize, Iye, Ge, J0e, L[ele], Ae)

        # Matriz de rotação do elemento
        Re = Rotacao3d(ele, elems, coord, αe)

        # Nós...
        for no = 1:2

            # Matriz Mn:
            # N 
            # T 
            # M    
            if no == 1
                Mn = [-1   0   0   0   0   0   0   0   0   0   0   0; # N
                       0   0   0  -1   0   0   0   0   0   0   0   0; # T
                       0   0   0   0  -1   0   0   0   0   0   0   0; # My
                       0   0   0   0   0  -1   0   0   0   0   0   0] # Mz
            else
                Mn = [0    0   0  0   0   0   1   0   0   0   0   0; # N
                      0    0   0  0   0   0   0   0   0   1   0   0; # T
                      0    0   0  0   0   0   0   0   0   0   1   0; # My
                      0    0   0  0   0   0   0   0   0   0   0   1] # Mz
            end 
            

            # Esforços no nó n (4x1)
            # N T My Mz
            En = Mn*Fe

            # Extrai os momentos de En (esforços internos no nó)
            My = En[3]
            Mz = En[4]

            # Candidatos...
            for a = 0:1

                # Matriz Pna:
                Pn = [1/Ae    0            0;        # N
                       0    re/J0e         0;        # T
                       0     0    ((-1)^a)*(re/Ize)] # M


                # O momento resultante é:
                Mr = sqrt(My^2 + Mz^2)

                # Matriz utilizada nas derivadas de tensão equivalente
                D = [1     0       0       0;   # N
                     0     1       0       0;   # T
                     0     0     My/Mr   Mz/Mr] # M


                # Vetor de tensões: N T M
                vec_sigma = Tensao_no_elemento(ele,no,a,Fe,dados_elementos,dicionario_geometrias)

                # Tensão equivalente de von-Mises:
                sigma_eq = Tensao_equivalente(vec_sigma)

                # A derivada parcial de g em relação a x_ele será 
                dg_dxm = (1/sigma_esc) * (1/sigma_eq) * transpose(vec_sigma)* VM * Pn * D * Mn * dfe_dxm * Fe

                # Acumula no vetor D2
                D2[ele] += Heaviside(μ[contador]/c_σ + g[contador])*dg_dxm

                # Derivada parcial em relação ao U
                # vetor 12 x 1
                produto = Pn * D * Mn * fe(ρ[ele]) * Ke0 * Re
                dg_dU = (1/sigma_esc) * (1/sigma_eq) * transpose(vec_sigma)* VM * produto

                # Acumula no vetor de carregamento adjunto
                Ds[gls] .+= Heaviside(μ[contador]/c_σ + g[contador])*dg_dU[:]

                # incrementa o contador
                contador += 1

            end # a
        end # nó
    end # ele

    # Por fim, multiplicamos os somatórios obtidos pelo termo com a penalização

    # Devolvemos tudo isso ponto: a derivada parcial e também vetor de carregamento adjunto
     return (c_σ/(4*ne))*D2, (c_σ/(4*ne))*Ds

end
