using Test
using HierarchicalUtils
using Base.Iterators: product
using Combinatorics
using HierarchicalUtils: OrderedDict
import HierarchicalUtils: _children_pairs, _childsort, _iter
import HierarchicalUtils: _node_predicate, PairVec

using Random; Random.seed!(42)

# definitions of all trees needed
abstract type AbstractVertex end

mutable struct Leaf <: AbstractVertex
    n::Int64
end
# vector of pairs as children
mutable struct VectorVertex <: AbstractVertex
    n::Int64
    chs::Vector
end
# named tuple as children
mutable struct NTVertex{T, U <: Tuple{Vararg{AbstractVertex}}} <: AbstractVertex
    n::Int64
    chs::NamedTuple{T, U}
end
# vector as children
mutable struct BinaryVertex{T <: AbstractVertex, U <: AbstractVertex} <: AbstractVertex
    n::Int64
    ch1::T
    ch2::U
end
# tuple as children
mutable struct SingletonVertex{T <: AbstractVertex} <: AbstractVertex
    n::Int64
    ch::T
end

HierarchicalUtils.@primitives
# dictionary as children
HierarchicalUtils.@hierarchical_dict
# vector as children
HierarchicalUtils.@hierarchical_vector
# tuple as children
HierarchicalUtils.@hierarchical_tuple
# vector of pairs as children
HierarchicalUtils.@hierarchical_pairvector

import HierarchicalUtils: NodeType, noderepr, children

NodeType(::Type{Leaf}) = HierarchicalUtils.LeafNode()

NodeType(::Type{<:VectorVertex}) = HierarchicalUtils.InnerNode()
# we shuffle each time for the sake of testing
children(t::VectorVertex) = shuffle([k => ch for (k,ch) in enumerate(t.chs)])

NodeType(::Type{<:NTVertex}) = HierarchicalUtils.InnerNode()
children(t::NTVertex) = t.chs

NodeType(::Type{<:BinaryVertex}) = HierarchicalUtils.InnerNode()
children(t::BinaryVertex) = [t.ch1, t.ch2]

NodeType(::Type{<:SingletonVertex}) = HierarchicalUtils.InnerNode()
children(t::SingletonVertex) = (t.ch,)

noderepr(t::T) where T <: AbstractVertex = string(Base.typename(T)) * " ($(t.n))"
Base.show(io::IO, t::T) where T <: AbstractVertex = print(io, "$(Base.typename(T))($(t.n))")

NodeType(::Type{<:SingletonVertex}) = HierarchicalUtils.InnerNode()
children(t::SingletonVertex) = (t.ch,)

noderepr(t::T) where T <: AbstractVertex = string(Base.typename(T)) * " ($(t.n))"
Base.show(io::IO, t::T) where T <: AbstractVertex = print(io, "$(Base.typename(T))($(t.n))")

const SINGLE_NODE_1 = NTVertex(1, NamedTuple())
const SINGLE_NODE_2 = Dict()
const SINGLE_NODE_3 = Leaf(1)
const SINGLE_NODE_4 = VectorVertex(1, AbstractVertex[])
const SINGLE_NODE_5 = AbstractVertex[]
const SINGLE_NODE_6 = Pair[]
const SINGLE_NODE_7 = ()
const SINGLE_NODES = [SINGLE_NODE_1, SINGLE_NODE_2, SINGLE_NODE_3, SINGLE_NODE_4, SINGLE_NODE_5, SINGLE_NODE_6, SINGLE_NODE_7]

const LINEAR_TREE_1 = VectorVertex(1,[
                                      NTVertex(2, (;
                                                   a=SingletonVertex(3,
                                                                     Leaf(4)
                                                                    )
                                                  ))
                                     ])

const LINEAR_TREE_2 = SingletonVertex(1, 
                                      SingletonVertex(2, 
                                                      VectorVertex(3, [
                                                                       NTVertex(4, NamedTuple())
                                                                      ])
                                                     )
                                     )

const LINEAR_TREE_3 = [[[[[[[Leaf(1)]]]]]]]

const COMPLETE_BINARY_TREE_1 = BinaryVertex(1,
                                            BinaryVertex(2,
                                                         Leaf(4),
                                                         Leaf(5)
                                                        ),
                                            BinaryVertex(3,
                                                         Leaf(6),
                                                         Leaf(7)
                                                        )
                                           )

const COMPLETE_BINARY_TREE_2 = NTVertex(1, (
                                            b = VectorVertex(3, [Leaf(6), NTVertex(7, NamedTuple())]),
                                            a = NTVertex(2, (b = NTVertex(5, NamedTuple()), a = VectorVertex(4, [])))
                                           ))

const T1 = NTVertex(1, (
                        ch1 = NTVertex(2, (
                                           ch1 = Leaf(4),
                                           ch2 = NTVertex(5, NamedTuple())
                                          )),
                        ch2 = BinaryVertex(3,
                                           Leaf(6),
                                           NTVertex(7, NamedTuple())
                                          )
                       ))
const T2 = NTVertex(1, (
                        ch2 = BinaryVertex(3,
                                           Leaf(6),
                                           Leaf(7)
                                          )
                        ,
                        ch1 = NTVertex(2, (
                                           ch2 = NTVertex(5, NamedTuple()),
                                          ))
                       ))
const T3 = NTVertex(1, (
                        ch1 = NTVertex(2, (
                                           ch1 = VectorVertex(4, []),
                                           ch2 = NTVertex(5, NamedTuple())
                                          )),
                       ))
const T4 = NTVertex(1, (
                        ch2 = BinaryVertex(3,
                                           Leaf(6),
                                           NTVertex(7, NamedTuple())),
                       ))
const T5 = NTVertex(1, NamedTuple())

const TEST_TREES = [
                    SINGLE_NODES...,
                    LINEAR_TREE_1, LINEAR_TREE_2, LINEAR_TREE_3,
                    COMPLETE_BINARY_TREE_1, COMPLETE_BINARY_TREE_2,
                    T1, T2, T3, T4, T5
                   ]

const TYPES = [Leaf, VectorVertex, BinaryVertex, NTVertex, Vector, Dict, Tuple, PairVec]
const ORDERS = [PreOrder(), PostOrder(), LevelOrder()]

@testset "Utilities" begin
    include("utilities.jl")
end
@testset "Simple statistics" begin
    include("statistics.jl")
end
@testset "Traversals" begin
    include("traversal_encoding.jl")
end
@testset "Printing" begin
    include("printing.jl")
end
@testset "Iterators" begin
    include("iterators.jl")
end
@testset "Maps" begin
    include("maps.jl")
end
