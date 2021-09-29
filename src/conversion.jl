###############################################################################
###############################################################################
### Conversion between GAP and polymake objects
###############################################################################
###############################################################################

@doc Markdown.doc"""
    ntv_gap2polymake( v::GapObj )

Convert a `GAP` toric variety `v` into a `Polymake` toric variety.
"""
function ntv_gap2polymake(GapNTV::GapObj)
    ff = GAP.Globals.Fan(GapNTV)
    R = GAP.Globals.RayGenerators(ff)
    MC = GAP.Globals.RaysInMaximalCones(ff)
    rays = Matrix{Int}(R)
    cones = [findall(x->x!=0, vec) for vec in [[e for e in mc] for mc in MC]]
    Incidence = Oscar.IncidenceMatrix(cones)
    arr = @Polymake.convert_to Array{Set{Int}} Polymake.common.rows(Incidence.pm_incidencematrix)
    pmntv = Polymake.fulton.NormalToricVariety(
        RAYS = Oscar.matrix_for_polymake(rays),
        MAXIMAL_CONES = arr,
    )
    return pmntv
end
export ntv_gap2polymake


@doc Markdown.doc"""
    ntv_polymake2gap( v::Polymake.BigObject )

Convert a `Polymake` toric variety `v` into a `GAP` toric variety.
"""
function ntv_polymake2gap(polymakeNTV::Polymake.BigObject)
    rays = Matrix{Int}(polymakeNTV.RAYS)
    gap_rays = GapObj( rays, recursive = true )
    cones = [findall(x->x!=0, v) for v in eachrow(polymakeNTV.MAXIMAL_CONES)]
    gap_cones = GapObj( cones, recursive = true )
    fan = Oscar.GAP.Globals.Fan( gap_rays, gap_cones )
    variety = Oscar.GAP.Globals.ToricVariety( fan )
    return variety
end
export ntv_polymake2gap

