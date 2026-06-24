struct PerThreadCache{K, V}
    dicts::Dict{Int, Dict{K, V}}
end

PerThreadCache{K, V}() where {K, V} = PerThreadCache{K, V}(Dict{Int, Dict{K, V}}())
PerThreadCache() = PerThreadCache{Any, Any}()

get_dict(pt::PerThreadCache{K, V}) where {K, V} = get!(pt.dicts, Threads.threadid()) do
    return Dict{K, V}()
end

Base.getindex(pt::PerThreadCache{K, V}, key::K) where {K, V} = get_dict(pt)[key]
Base.setindex(pt::PerThreadCache{K, V}, key::K, val::V) where {K, V} = (get_dict(pt)[key] = val)
Base.haskey(pt::PerThreadCache{K, V}, key) where {K, V} = haskey(get_dict(pt), key)
Base.get!(f, pt::PerThreadCache, key) = get!(f, get_dict(pt), key)
Base.empty!(pt::PerThreadCache) = empty!(pt.dicts)