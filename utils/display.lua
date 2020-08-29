local GetPhysicalScreenSize = GetPhysicalScreenSize
local function pixel_scale()
    local _, screenHeight = GetPhysicalScreenSize()
    return (768.0 / screenHeight) / 0.64
end

_G.__utils__ = {
    display = {
        pixel_scale = pixel_scale,
    }
}