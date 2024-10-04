#
#  Transforma um array em uma string
#
function Converte_Array_String(A)

    # Dimensões da A
    nl, nc = size(A)

    # Inicializa a string
    s = ""

    # Loop pelas posições de A
    for l = 1:nl
        for c = 1:nc
            s = s*string(A[l,c])*" "
        end
        s = s*"\n"
    end

    return s[1:end-1]

end



