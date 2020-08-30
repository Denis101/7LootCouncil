local GetPhysicalScreenSize = GetPhysicalScreenSize
local function pixel_scale()
    local _, screenHeight = GetPhysicalScreenSize()
    return (768.0 / screenHeight) / 0.64
end

local function pixel_perfect(value)
    return _G.__utils__.math.num_round(value, pixel_scale())
end

local function clear_frame(frame)
    if frame == nil then
        return
    end

    frame:ClearAllPoints()
    frame:SetSize(0, 0)
    frame:Hide()

    if frame.text == nil then
        return
    end

    frame.text:ClearAllPoints()
    frame.text:SetSize(0, 0)
    frame.text:Hide()
end

local function clear_frame_table(frames)
    if frames == nil then
        return
    end

    for _,frame in ipairs(frames) do
        clear_frame(frame)
    end
end

_G.__utils__ = {
    display = {
        pixel_scale = pixel_scale,
        pixel_perfect = pixel_perfect,
        clear_frame = clear_frame,
        clear_frame_table = clear_frame_table,
    }
}