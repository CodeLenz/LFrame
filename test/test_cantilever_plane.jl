
@testset "Cantilever point loads - Plane XY" begin
    
    ##############################################
    # FX (axial - bar)
    U = Analise3D("data/cantilever_point/cantilever_fx.yaml")

    # Verifica a resposta
    @test U[7] ≈  1.0


    ##############################################
    # FY (beam)
    U = Analise3D("data/cantilever_point/cantilever_fy.yaml")

    # Verifica as respostas
    @test U[8]  ≈ 0.4
    @test U[12] ≈ 0.3


    ##############################################
    # FZ (beam)
    U = Analise3D("data/cantilever_point/cantilever_fz.yaml")

    # Verifica as respostas
    @test U[9]  ≈   1.6
    @test U[11] ≈  -1.2


    
end
