# Implementando o teste passado em aula

function Testando(LA, )
    D = 0.0

    # Pegando a posição atual
    ref = LA(ρ)

    # Tamanho do vetor para o loop:
    n = length(D)

    # Inicializando o loop

    for j=1:n
        b =  ρ[j]
        # Faz a perturbação
        ρ[j] = b + δ
        f = LA(ρ)
        D[j] = (f - ref)/δ
        # Desfaz a perturbação
        ρ[j] = b 
    end

    return D
end

