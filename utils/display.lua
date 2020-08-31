local GetPhysicalScreenSize = GetPhysicalScreenSize
local function pixel_scale()
    local _, screenHeight = GetPhysicalScreenSize()
    return (768.0 / screenHeight) / 0.64
end

local function pixel_perfect(value)
    return _G.__utils__.math.num_round(value, pixel_scale())
end

local function __clear_frame(frame)
    if frame == nil then
        return
    end

    frame:ClearAllPoints()
    frame:SetSize(0, 0)
    frame:Hide()

    -- some hacky shit involved here, where we ignore AceGUI hierarchy
    -- so manually add children to frames and then clean them up here
    -- That's #YOLO WoW GUI development for ou
    if frame.children == nil then
        return
    end

    for _,child in ipairs(frame.children) do
        child:ClearAllPoints()
        child:SetSize(0, 0)
        child:Hide()
    end
end

local function clear_frame(frame)
    if frame == nil then
        return
    end

    -- This seems dumb, but they're AceGUI widgets and i cba :)
    if frame.frame ~= nil then
        __clear_frame(frame.frame)
    else
        __clear_frame(frame)
    end
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