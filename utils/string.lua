local format, strmatch = format, strmatch

-- THIS LANGUAGE IS FUCKING RETARDED
local function __concat_table_delim(tab, delim, getter)
    local result = ""
    local i = 0
    for k,v in pairs(tab) do
        local str = getter(k, v)
        if i == 0 then
            result = str
        else
            result = format("%s%s%s", result, delim, str)
        end

        i = i + 1
    end
    return result
end

local function concat_table_values_delim(tab, delim)
    return __concat_table_delim(tab, delim, function(_, v) return v end)
end

local function concat_table_values(tab)
    return concat_table_values_delim(tab, ",")
end

local function concat_table_keys_delim(tab, delim)
    return __concat_table_delim(tab, delim, function(k) return k end)
end

local function concat_table_keys(tab)
    return concat_table_keys_delim(tab, ",")
end

local function concat_table_delim(tab, delim)
    return __concat_table_delim(tab, delim, function(k, v) return k .. "=" .. v end)
end

local function concat_table(tab)
    return concat_table_delim(tab, ",")
end

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function rgb_to_hex(r, g, b, header, ending)
	r = r <= 1 and r >= 0 and r or 1
	g = g <= 1 and g >= 0 and g or 1
	b = b <= 1 and b >= 0 and b or 1
	return format('%s%02x%02x%02x%s', header or '|cff', r*255, g*255, b*255, ending or '')
end

local function hex_to_rgb(hex)
	local a, r, g, b = strmatch(hex, '^|?c?(%x%x)(%x%x)(%x%x)(%x?%x?)|?r?$')
	if not a then return 0, 0, 0, 0 end
    if b == '' then r, g, b, a = a, r, g, 'ff' end
    local rn = tonumber(r, 16) / 255
    local gn = tonumber(g, 16) / 255
    local bn = tonumber(b, 16) / 255
    return rn, gn, bn
end

_G.__utils__.string = {
    concat_table_values_delim = concat_table_values_delim,
    concat_table_values = concat_table_values,
    concat_table_keys_delim = concat_table_keys_delim,
    concat_table_keys = concat_table_keys,
    concat_table_delim = concat_table_delim,
    concat_table = concat_table,
    trim = trim,
    rgb_to_hex = rgb_to_hex,
    hex_to_rgb = hex_to_rgb,
}