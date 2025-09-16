# Função Heaviside
function Heaviside(a::T) where T
      max(a,zero(T))
end

#
# Devolve os gls de um elemento
#
function Gls(ele,elems)

    # Descobre os nós do elemento
    no1,no2 = elems[ele,:]

    # Monta o vetor com os graus de liberdade do elemento
    gls = [6*(no1-1)+1; 6*(no1-1)+2; 6*(no1-1)+3; 6*(no1-1)+4; 6*(no1-1)+5; 6*(no1-1)+6;
           6*(no2-1)+1; 6*(no2-1)+2; 6*(no2-1)+3; 6*(no2-1)+4; 6*(no2-1)+5; 6*(no2-1)+6]

    # Retorna os gls
    return gls

end

function Dados_fundamentais(ele, dados_elementos, dicionario_materiais, dicionario_geometrias)

    # Dados dos materais
    mat = dados_elementos[ele,1]

    # Todos os dados do material estão em um dicionário local
    material = dicionario_materiais[mat]

    # E podemos recuperar os dados usando os nomes como chaves
    Ee = material["Ex"]
    Ge = material["G"]

    # O nome da geometria do elemento pode ser acessado diretamente da matriz de dados_elementos
    geo = dados_elementos[ele,2]

    # Todos os dados da geometria do elemento estão em um dicionário local
    geometria = dicionario_geometrias[geo]

    Ize = geometria["Iz"]
    Iye = geometria["Iy"]
    J0e = geometria["J0"]
    Ae  = geometria["A"]
    αe  = geometria["α"]

    return  Ize, Iye, J0e, Ae, αe, Ee, Ge, geo
    
end