local min, max, floor = min, max, floor

local function clamp(n, mi, ma)
    if n > ma then
        return ma
    elseif n < mi then
        return mi
    end
    return n
end

local function num_round(n, mult)
    if not n then return end
    mult = mult or 1
    return floor(n / mult + (n >= 0 and 1 or -1) * 0.5) * mult
end

local function num_truncate(n, decimals)
    return n - (n % (0.1 ^ (decimals or 0)))
end

_G.__utils__.math = {
    min = min,
    max = max,
    clamp = clamp,
    floor = floor,
    num_round = num_round,
    num_truncate = num_truncate,
}