#
# Tests to verify the stiffness matrix of a single element 
# in the XY plane
#
@testset "Cantilever point loads - Plane XY" begin
    
    # Path para o pacote LFrame
    caminho = pathof(LFrame)[1:end-14]*"\\test"

    ##############################################
    # FX (axial - bar)
    arquivo = joinpath([caminho,"data","cantilever_point","cantilever_fx.yaml"])
    U,_ = Analise3D(arquivo)

    # Verifica a resposta
    @test U[7] ≈  1.0

    #=

    ##############################################
    # FY (beam)
    U,_ = Analise3D("test/data/cantilever_point/cantilever_fy.yaml")

    # Verifica as respostas
    @test U[8]  ≈ 0.4
    @test U[12] ≈ 0.3


    ##############################################
    # FZ (beam)
    U,_ = Analise3D("test/data/cantilever_point/cantilever_fz.yaml")

    # Verifica as respostas
    @test U[9]  ≈   1.6
    @test U[11] ≈  -1.2

    
    ##############################################
    # MX (torsion)
    U,_ = Analise3D("test/data/cantilever_point/cantilever_mx.yaml")

    # Verifica as respostas
    @test U[10]  ≈   8.888888888888
  
    ##############################################
    # MY 
    U,_ = Analise3D("test/data/cantilever_point/cantilever_my.yaml")

    # Verifica as respostas
    @test U[9]   ≈   -12.0
    @test U[11]  ≈    12.0

    ##############################################
    # MZ 
    U,_ = Analise3D("test/data/cantilever_point/cantilever_mz.yaml")

    # Verifica as respostas
    @test U[8]   ≈    3.0
    @test U[12]  ≈    3.0

    =#

end
