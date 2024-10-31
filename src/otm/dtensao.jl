#
# Aqui vamos ter a função que calcula a derivada da restrição de tensão dgσ_dxm do material
#

function Derivada_parcial_gtensao(ne,dados_elementos, dicionario_materiais, 
    dicionario_geometrias, U, elems, coord)


# Inicializa um vetor de saída
D2 = zeros(ne)

# Vetor de carregamento adjunto para a tensão
Ds = zeros(n_gl)

# Cada elemento possui 2 nós e cada nó possui dois "a"s:
# Elementos...
contador = 1
for ele = 1:ne

# Dados que vamos precisar:
Ize, Iye, J0e, Ae, αe, Ee, Ge = Dados_fundamentais(ele, dados_elementos, dicionario_materiais, dicionario_geometrias)

# Gls do elemento
gls = [.......]

# Extraindo o raio externo:
re = sqrt(A/pi) 

# Calcula os esforços no elemento
Fe = Esforcos_elemento(ele,elems,dados_elementos,dicionario_materiais,dicionario_geometrias,
 L,coord,U)

# Matriz de von-Mises:
VM = [1.0 1.0 0.0 ;
1.0 1.0 0.0 ;
0.0 0.0 3.0]

# Assumindo que fe(x) = x_e
# a derivada parcial em relação a x_m
# vai ser 1 se e==m e 0 se e != m
dfe_dxm = 1.0

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
Pn = [1/A     0        0;
0     0    (-re/I)^a;
0    re/J0     0]


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
D2[ele] += Heaviside(mu[contador]/c_σ + g2[contador])*dg_dxm

# Derivada parcial em relação ao U
# vetor 12 x 1
dg_dU = 1/sigma_esc * 1/sigma_eq * transpose(vec_sigma) * VM * Pn * D * Mn * fe * Ke0 * Re 

# Acumula no vetor de carregamento adjunto
Ds[gls] += Heaviside(mu[contador]/c_σ + g2[contador])*dg_dU

# incrementa o contador
contador += 1

end # a
end # nó
end # ele

return (c_σ/(4*ne))*D2, (c_σ transpose(vec_sigma)/(4*ne))*Ds


end

#
# E agora a função que calcula dgσ_dU
#

function Derivada_tensao_dU(Pn, D, Mn, VM, vec_sigma, fe, ne,dados_elementos, dicionario_materiais, dicionario_geometrias, U, elems, coord)

# Elementos...
for ele = 1:ne
# Dados que vamos precisar:
Ize, Iye, J0e, Ae, αe, Ee, Ge = Dados_fundamentais(ele, dados_elementos, dicionario_materiais, dicionario_geometrias)
# Extraindo o raio externo:
re = sqrt(A/pi) #?????
# Vamos precisar da rotação
Re = Rotacao3d(ele, elem transpose(vec_sigma)s, coord, αe)
# E da matriz de rigidez:
Ke0 = Ke_portico3d(Ee, Ize, Iye, Ge, J0e, Le, Ae)
# Nós...
for no = 1:2
# Candidatos...
for a = 0:1
# Termo b:
b = fe * Ke0 * Re * He 
# Finalmente,
# A posição a ser ocupada no vetor é
pos = ele + no + a 
# E portanto,
dg_dU[pos] = 1/sigma_esc * 1/sigma_eq * transpose(vec_sigma) * VM * Pn * D * Mn * b
end
end
end
return dg_dU
end