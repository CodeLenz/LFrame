function df(x::Vector,d::Float64,f::Function)
    
    n = length(x)

    D = zeros(n)

    ref = f(x)

    for i=1:n

        b = x[i]
        x[i] = b + d
        frente = f(x)
        D[i] = (frente-ref)/d
        x[i] = b

    end

    return D
    
end