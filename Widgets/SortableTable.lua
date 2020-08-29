--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local CreateFrame = CreateFrame
local PlaySound = PlaySound

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]

local Addon = unpack(select(2, ...))

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local ROW_HEIGHT = 20

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local AceGUI = Addon.Libs.AceGUI
local LSM = Addon.Libs.LSM

local pp = Addon.utils.display.pixel_perfect

local widgetType = "7LC_SortableTable"
local widgetVersion = 1

local ARROW_TEXTURES = {
    "Interface\\Buttons\\Arrow-Down-Down",
    "Interface\\Buttons\\Arrow-Up-Down",
}

local TableBuilder = {
    headingOnClick = nil,
    headingOnEnter = nil,
    headingOnLeave = nil,
    disabled = false,
}

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function ClearFrameTable(frames)
    if frames == nil then
        return
    end

    for _,frame in ipairs(frames) do
        if frame ~= nil then
            frame:ClearAllPoints()
            frame:SetSize(0, 0)
            frame:Hide()

            if frame.text ~= nil then
                frame.text:ClearAllPoints()
                frame.text:SetSize(0, 0)
                frame.text:Hide()
            end
        end
    end
end

function TableBuilder:BuildArrow(parent)
    local arrow = CreateFrame("Button", nil, parent)
    arrow:SetHitRectInsets(0, 0, -10, 0)
    arrow:SetWidth(pp(16))
    arrow:SetHeight(pp(16))
    arrow:SetFrameStrata("FULLSCREEN_DIALOG")
    return arrow
end

function TableBuilder:BuildHeading(index, heading, parent, size, offset)
    local btn = CreateFrame("Button", widgetType .. "Heading" .. heading.slug, parent)
    btn:Point("TOPLEFT", parent, "TOPLEFT", pp(offset - 1), 0)
    btn:SetWidth(pp(size - 1))
    btn:SetHeight(pp(ROW_HEIGHT))

    local texture = LSM:Fetch("background", "Solid")
    btn:SetNormalTexture(texture)
    btn:GetNormalTexture():SetColorTexture(.5, .5, .5, .5)

    local txt = btn:CreateFontString(btn, "OVERLAY", "GameTooltipText")
    txt:SetFont(Addon.profile.general.fontSettings.font, Addon.profile.general.fontSettings.size, Addon.profile.general.fontSettings.outline)
    txt:SetText(heading.displayText)
    txt:SetDrawLayer("OVERLAY")
    txt:Point("CENTER", 0, 0)
    btn.text = txt
    btn:Show()

    if not self.disabled then
        btn:SetHighlightTexture(texture)
        btn:GetHighlightTexture():SetColorTexture(.6, .6, .6, .5)

        btn:SetScript("OnClick", self.headingOnClick)
        btn:SetScript("OnEnter", self.headingOnEnter)
        btn:SetScript("OnLeave", self.headingOnLeave)
    end

    btn.arrow = self:BuildArrow(btn)
    btn.parent = parent
    btn.slug = heading.slug
    btn.index = index
    return btn
end

function TableBuilder:BuildRow(data, index, headings, parent)
    local row = {}

    local offset = 0
    for i,v in ipairs(data) do
        if i == 1 then
            offset = 0
        else
            offset = offset + (headings[i - 1].width or 100)
        end

        local btn = CreateFrame("Button", widgetType .. "Row" .. index .. "-" .. i, parent)
        btn:Point("TOPLEFT", parent, "TOPLEFT", pp(offset - 1), pp(-(index * ROW_HEIGHT + 1)))
        btn:SetWidth(pp(headings[i].width - 1))
        btn:SetHeight(pp(ROW_HEIGHT))

        btn.parent = parent
        btn.slug = headings[i].slug
        btn.data = v

        local texture = LSM:Fetch("background", "Solid")
        btn:SetNormalTexture(texture)
        btn:GetNormalTexture():SetColorTexture(.2, .2, .2, .2)
        btn:SetHighlightTexture(texture)
	    btn:GetHighlightTexture():SetColorTexture(.3, .3, .3, .3)

        local txt = btn:CreateFontString(btn, "OVERLAY", "GameTooltipText")
        txt:SetFont(Addon.profile.general.fontSettings.font, Addon.profile.general.fontSettings.size, Addon.profile.general.fontSettings.outline)
        txt:SetText(v)
        txt:SetDrawLayer("OVERLAY")
        txt:Point("LEFT", pp(5), 0)
        btn.text = txt
        table.insert(row, btn)
    end

    return row
end

function TableBuilder:Build(frame, headings, data)
    ClearFrameTable(frame.headings)

    if frame.rows then
        for _,v in ipairs(frame.rows) do
            ClearFrameTable(v)
        end
    end

    frame.headings = {}
    frame.rows = {}

    local offset = 0
    for i,v in ipairs(headings) do
        if i == 1 then
            offset = 0
        else
            offset = offset + (headings[i - 1].width or 100)
        end
        table.insert(frame.headings, self:BuildHeading(i, v, frame, v.width or 100, offset))
    end

    for i,v in ipairs(data) do
        table.insert(frame.rows, self:BuildRow(v, i, headings, frame))
    end

    frame:SetHeight(pp(ROW_HEIGHT + (#frame.rows * ROW_HEIGHT)))
    frame:Show()
end

local function Button_OnClick(frame, ...)
    AceGUI:ClearFocus()
    PlaySound(852)
    local widget = frame.parent.obj
    local arrowIndex = widget.arrowIndices[frame.index] + 1
    if arrowIndex > 3 then
        arrowIndex = 1
    end

    local newData = {}
    if arrowIndex > 1 then
        local texture = ARROW_TEXTURES[arrowIndex - 1]
        if texture == "Interface\\Buttons\\Arrow-Down-Down" then
            frame.arrow:ClearAllPoints()
            frame.arrow:SetPoint("TOPLEFT", frame, "TOPRIGHT", pp(-20), pp(-5))
            frame.arrow:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", pp(-20), 0)
        elseif texture == "Interface\\Buttons\\Arrow-Up-Down" then
            frame.arrow:ClearAllPoints()
            frame.arrow:SetPoint("TOPLEFT", frame, "TOPRIGHT", pp(-20), 0)
            frame.arrow:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", pp(-20), pp(5))
        end
        frame.arrow:SetNormalTexture(texture)
        frame.arrow:Show()

        local heading = widget.headings[frame.index]
        newData = Addon.utils.table.copy(widget.data)
        table.sort(newData, function(a,b)
            if arrowIndex == 2 then
                return heading.desc(a[frame.index], b[frame.index])
            elseif arrowIndex == 3 then
                return heading.asc(a[frame.index], b[frame.index])
            else
                return true
            end
        end)
    else
        --frame.arrow:SetNormalTexture(nil)
        newData = widget.unsortedData
    end

    widget.arrowIndices[frame.index] = arrowIndex
    TableBuilder:Build(widget.frame, widget.headings, newData)
    widget:Fire("OnClick", frame.slug)
end

local function Control_OnEnter(frame)
    frame.parent.obj:Fire("OnEnter", frame.slug)
end

local function Control_OnLeave(frame)
    frame.parent.obj:Fire("OnLeave", frame.slug)
end

local function CreateMainFrame(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:Hide()
    return frame
end

--[[-----------------------------------------------------------------------------
    Methods
-------------------------------------------------------------------------------]]

local methods = {
    ["OnAcquire"] = function(self)
        self:SetDisabled(false)
        TableBuilder.disabled = false
        TableBuilder.headingOnClick = Button_OnClick
        TableBuilder.headingOnEnter = Control_OnEnter
        TableBuilder.headingOnLeave = Control_OnLeave
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        TableBuilder.disabled = disabled
    end,
    ["SetValue"] = function(self) --[[Stub for "input" types]] end,
    ["GetValue"] = function(self) --[[Stub for "input" types]] end,
    ["SetList"] = function(self, value)
        self.headings = value.headings
        self.data = value.data
        self.unsortedData = value.data

        self.arrowIndices = {}
        for _ in ipairs(value.headings) do
            table.insert(self.arrowIndices, 1)
        end

        TableBuilder:Build(self.frame, value.headings, value.data)
    end,
    ["SetItemValue"] = function() end,
    ["SetText"] = function(self, text)
        self.text = text
    end,
    ["SetLabel"] = function(self, label)
        self.label = label
    end,
    ["OnEnterPressed"] = function(self, text) --[[Stub for "input" types]] end,
}

--[[-----------------------------------------------------------------------------
    Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
    local widget = {
        frame = CreateMainFrame(widgetType, Addon.UIParent),
        type = widgetType,
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)