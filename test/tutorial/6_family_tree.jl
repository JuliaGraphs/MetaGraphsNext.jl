# # Family Tree -- adding graphs to an existing codebase

# A graph provides an abstraction for how objects relate to one another.
# A graph consists of *nodes* or *vertices* that are connected by
# *edges*.

# An application's data model might already directly represent these
# relationships.

# One example of information that can be represented in a graph is a
# family tree.  This example uses the `Person` struct to model family
# trees.


ALL_PERSONS = []

let
    ## See the note on isless below.
    next_ordinal = 1
    
    struct Person
        ordinal
        name::String
        mother::Union{Person, Nothing}
        father::Union{Person, Nothing}
        
        function Person(name, mother, father)
            ordinal = next_ordinal
            next_ordinal += 1
            p = new(ordinal, name, mother, father)
            push!(ALL_PERSONS, p)
            p
        end
    end
end

name(p::Person) = p.name

# Here's our family tree data.  I wanted to code this in a FOAF file,
# but couldn't find a reader.
let
    jan2 = Person("Jan II", nothing, nothing)
    karl5 = Person("Karl V", nothing, jan2)
    fs = Person("Filips de Stoute", nothing, jan2)
    jzv = Person("Jan zonder Vrees", nothing, fs)
    fg = Person("Filips de Goede", nothing, jzv)
    ks = Person("Karel de Stoute", nothing, fg)
    mb = Person("Maria v. Bourgondie", nothing, ks)

    r1h = Person("Rudolph I v. Habsburg", nothing, nothing)
    f3 = Person("Frederik III", nothing, nothing)
    max1 = Person("Maximilliaan I", nothing, f3)
    f1s = Person("Filips I de Schone", mb, max1)

    j2k = Person("Johan II v. Kastile", nothing, nothing)
    h4 = Person("Hendrick IV", nothing, j2k)
    i1 = Person("Isabella I v. Kastile", nothing, j2k)
    j2a = Person("Johan II v. Aragon", nothing, nothing)
    f5a = Person("Ferdinand V v. Aragon", nothing, j2a)
    jw = Person("Johanna de Waanzinnige", i1, f5a)
    
    Person("Maria v. Hongarije", jw, f1s)
    f1 = Person("Ferdinand I", jw, f1s)
    Person("Karel V", jw, f1s)
    Person("Eleonora", jw, f1s)
    
    Person("Maximiliaan II", nothing, f1)
    nothing
end

# It might only represent the relationships in one direction though.
# If the data are represented by immutable structs then it can't
# represent the relationships in both directions.  In our Person
# example a Person has a mother and a father.  Person can't also have
# a field for children though because there is no way to construct
# circular references in immutable structures (actually, since the
# children would be a collection, Person could have a Vector valued
# slot named children, though the value of the slot can not be
# changed, the contents of the vector could, this might violate the
# spirit of the the programmer made Person immutable though).
# Computing the children of a Person would be O(n) in the number of
# Persons without maintaining a child relationship or reverse index.
# If we model our Persons in a graph though, the children relationship
# derives naturally from the parent (mother or father) relationship.
# One can think of the graph as providing a reverse index on the
# parent relationship that is captured in the Person struct.

# By adopting a graph abstraction we can also make use of generic code
# to perform powerful operations without having to reimplement those
# algorithms.

using Graphs: DiGraph, add_vertex!, add_edge!
using MetaGraphsNext

# The Graphs ecosystem requires that a total ordering be defined:
Base.isless(p1::Person, p2::Person) = isless(p1.ordinal, p2.ordinal)

# We can label a graph edge to indicate whether it points to a mother
# or a father:
@enum Parent Mother Father

FAMILY_TREE = MetaGraph(DiGraph();
                        label_type=Person,
                        edge_data_type=Parent)

# Load the people into the graph.  Note that we could have done this
# in the Person constructor.  In this contrived example we're "adding"
# the use of graphs to an "existing" application.

for p in ALL_PERSONS
    @assert add_vertex!(FAMILY_TREE, p)
end

for p in ALL_PERSONS
    p_node = code_for(FAMILY_TREE, p)
    if p.mother isa Person
        @assert add_edge!(FAMILY_TREE, p, p.mother, Mother)
    end
    if p.father isa Person
        @assert add_edge!(FAMILY_TREE, p, p.father, Father)
    end
end

# Now we want to be able to find the parents and children of a Person:

children(p::Person) = inneighbor_labels(FAMILY_TREE, p)
parents(p::Person) = outneighbor_labels(FAMILY_TREE, p)
nothing

# Lets try it:

let
    dad = filter(p -> p.name == "Johan II v. Kastile",
                 ALL_PERSONS)[1]
    @assert Set(name.(children(dad))) ==
        Set(["Hendrick IV", "Isabella I v. Kastile"])
    name.(children(dad))
end
