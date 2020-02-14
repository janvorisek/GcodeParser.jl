using GcodeParser;
using Test;

@testset begin
    @test parseLine("G1 (move) X6.66 ; some command description") == Union{Pair{String,String}, String}["G" => "1", "X" => "6.66"]
    @test parseLine("G1 (move) X6.66 ; some command description", false) == Union{Pair{String,String}, String}["G1", "X6.66"]
end


