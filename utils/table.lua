local function deepcopy(orig, copies)
    copies = copies or {}
    local copy
    if type(orig) == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function copy(tbl)
    return deepcopy(tbl)
end

local function print_table(t)
    local printTable_cache = {}
    local function sub_print_table(t, indent)
        if printTable_cache[tostring(t)] then
            print(indent .. "*" .. tostring(t))
        else
            printTable_cache[tostring(t)] = true
            if type(t) == "table" then
                for pos,val in pairs(t) do
                    if type(val) == "table" then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t).. " {")
                        sub_print_table(val, indent .. string.rep(" ", string.len(pos)+8))
                        print( indent .. string.rep(" ", string.len(pos)+6 ) .. "}")
                    elseif type(val) == "string" then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end

    if ( type(t) == "table" ) then
        print(tostring(t) .. " {")
        sub_print_table(t, "  ")
        print("}")
    else
        sub_print_table(t, "  ")
    end
end

local function compare_table(table1, table2)
    local avoid_loops = {}
    local function recurse(t1, t2)
       -- compare value types
       if type(t1) ~= type(t2) then return false end
       -- Base case: compare simple values
       if type(t1) ~= "table" then return t1 == t2 end
       -- Now, on to tables.
       -- First, let's avoid looping forever.
       if avoid_loops[t1] then return avoid_loops[t1] == t2 end
       avoid_loops[t1] = t2
       -- Copy keys from t2
       local t2keys = {}
       local t2tablekeys = {}
       for k, _ in pairs(t2) do
          if type(k) == "table" then table.insert(t2tablekeys, k) end
          t2keys[k] = true
       end
       -- Let's iterate keys from t1
       for k1, v1 in pairs(t1) do
          local v2 = t2[k1]
          if type(k1) == "table" then
             -- if key is a table, we need to find an equivalent one.
             local ok = false
             for i, tk in ipairs(t2tablekeys) do
                if compare_table(k1, tk) and recurse(v1, t2[tk]) then
                   table.remove(t2tablekeys, i)
                   t2keys[tk] = nil
                   ok = true
                   break
                end
             end
             if not ok then return false end
          else
             -- t1 has a key which t2 doesn't have, fail.
             if v2 == nil then return false end
             t2keys[k1] = nil
             if not recurse(v1, v2) then return false end
          end
       end
       -- if t2 has a key which t1 doesn't have, fail.
       if next(t2keys) then return false end
       return true
    end
    return recurse(table1, table2)
end

local function print_args(...)
    for i = 1, select('#', ...) do
        print(select(i, ...))
    end
end

_G.__utils__.table = {
    copy = copy,
    print = print_table,
    compare = compare_table,
    print_args = print_args
}