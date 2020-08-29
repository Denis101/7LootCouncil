local GetPhysicalScreenSize = GetPhysicalScreenSize
local function pixel_scale()
    local _, screenHeight = GetPhysicalScreenSize()
    return (768.0 / screenHeight) / 0.64
end

local function pixel_perfect(value)
    return _G.__utils__.math.num_round(value, pixel_scale())
end

_G.__utils__ = {
    display = {
        pixel_scale = pixel_scale,
        pixel_perfect = pixel_perfect,
    }
}