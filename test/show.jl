@testset "show" begin
    @testset "set" begin
        a = SetDifference(Set([]), Set([]), Set([]))
        @test sprint(show, MIME("text/plain"), a) == """
        SetDifference with values:
         common: Set{Any}()
         added: Set{Any}()
         removed: Set{Any}()"""
    end

    @testset "vector" begin
        a = VectorDifference([3], [1], [2], [-1], [3], [4])
        @test sprint(show, MIME("text/plain"), a) == """
        VectorDifference with indices:
         common: [3]
         added: [1]
         removed: [2]
        and values:
         common: [-1]
         added: [3]
         removed: [4]"""
    end

    @testset "matrix" begin
        a = MatrixDifference(([1], [1]), ([2], [2]), ([3], [3]), [1], [2, 2], [3, 3])
        @test sprint(show, MIME("text/plain"), a) == """
        MatrixDifference with indices:
         common: ([1], [1])
         added: ([2], [2])
         removed: ([3], [3])
        and values:
         common: [1]
         added: [2, 2]
         removed: [3, 3]"""
    end
end
