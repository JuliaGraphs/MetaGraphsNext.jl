function reverse(mg::MetaDiGraph)
    rg = reverse(mg.graph)
    rvprops = copy(mg.vprops)
    reprops = empty(mg.eprops)
    rgprops = mg.gprops
    rweightfunction = mg.weightfunction
    rdefaultweight = mg.defaultweight
    rindices = copy(mg.metaindex)

    for (u, v) in keys(mg.eprops)
        reprops[(v, u)] = mg.eprops[(u, v)]
    end

    rmg =
        MetaGraph(rg, rvprops, reprops, rgprops, rweightfunction, rdefaultweight, rindices)

    return rmg
end
