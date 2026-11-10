struct TaskLocalDict{K, V, F}
    local_value::TaskLocalValue{Dict{K, V}, F}
end

function TaskLocalDict{K, V}() where {K, V}
    new_dict() = Dict{K, V}()
    local_value = TaskLocalValue(new_dict)
    return TaskLocalDict{K, V, typeof(new_dict)}(local_value)
end

TaskLocalDict() = TaskLocalDict{Any, Any}()

get_dict(tld::TaskLocalDict{K, V}) where {K, V} = tld.local_value[]

Base.getindex(tld::TaskLocalDict{K, V}, key::K) where {K, V} = get_dict(tld)[key]
Base.setindex(tld::TaskLocalDict{K, V}, key::K, val::V) where {K, V} = (get_dict(tld)[key] = val)
Base.haskey(tld::TaskLocalDict{K, V}, key) where {K, V} = haskey(get_dict(tld), key)
Base.get!(f, tld::TaskLocalDict, key) = get!(f, get_dict(tld), key)
Base.empty!(tld::TaskLocalDict) = empty!(get_dict(tld))
