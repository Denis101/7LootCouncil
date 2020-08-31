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
local AceGUI = Addon.Libs.AceGUI
local LSM = Addon.Libs.LSM
local pp = Addon.utils.display.pixel_perfect

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local ROW_HEIGHT = 20

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

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

function TableBuilder:ClearHeadings(frame)
    Addon.utils.display.clear_frame_table(frame.headings)
    frame.headings = {}
end

function TableBuilder:ClearFrame(widget)
    self:ClearHeadings(widget.frame)
    widget:ReleaseChildren()
end

function TableBuilder:BuildArrow(parent)
    local arrow = CreateFrame("Button", nil, parent)
    arrow:SetHitRectInsets(0, 0, -10, 0)
    arrow:SetWidth(pp(16))
    arrow:SetHeight(pp(16))
    arrow:SetFrameStrata("FULLSCREEN_DIALOG")

    local arrowIndex = parent.obj.arrowIndices[parent.index]
    if arrowIndex > 1 then
        local texture = ARROW_TEXTURES[arrowIndex - 1]

        if texture == ARROW_TEXTURES[1] then
            arrow:SetPoint("TOPLEFT", parent, "TOPRIGHT", pp(-20), pp(-5))
            arrow:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", pp(-20), 0)
        elseif texture == ARROW_TEXTURES[2] then
            arrow:SetPoint("TOPLEFT", parent, "TOPRIGHT", pp(-20), 0)
            arrow:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", pp(-20), pp(5))
        end
        arrow:SetNormalTexture(texture)
    else
        arrow:SetNormalTexture(nil)
    end

    return arrow
end

function TableBuilder:BuildHeading(index, heading, parent, size, offset)
    local btn = CreateFrame("Button", widgetType .. "Heading" .. heading.slug, parent)
    btn.children = {}
    btn.obj = parent.obj
    btn.parent = parent
    btn.slug = heading.slug
    btn.index = index

    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", pp(offset), 0)
    btn:SetWidth(pp(size))
    btn:SetHeight(pp(ROW_HEIGHT))

    local texture = LSM:Fetch("background", "Solid")
    btn:SetNormalTexture(texture)
    btn:GetNormalTexture():SetColorTexture(.5, .5, .5, .5)

    local txt = btn:CreateFontString(btn, "OVERLAY", "GameTooltipText")
    txt:SetFont(Addon.profile.general.fontSettings.font, Addon.profile.general.fontSettings.size, Addon.profile.general.fontSettings.outline)
    txt:SetText(heading.displayText)
    txt:SetDrawLayer("OVERLAY")
    txt:SetPoint("CENTER", 0, 0)
    btn.text = txt
    table.insert(btn.children, txt)
    btn:Show()

    if not self.disabled then
        btn:SetHighlightTexture(texture)
        btn:GetHighlightTexture():SetColorTexture(.6, .6, .6, .5)

        btn:SetScript("OnClick", self.headingOnClick)
        btn:SetScript("OnEnter", self.headingOnEnter)
        btn:SetScript("OnLeave", self.headingOnLeave)
    end

    btn.arrow = self:BuildArrow(btn)
    return btn
end

function TableBuilder:BuildHeadings(frame, headings)
    if not frame.headings then
        frame.headings = {}
    end

    local height = 0
    local offset = 0
    for i,v in ipairs(headings) do
        if i > 1 then
            offset = offset + (headings[i - 1].width or 200)
        end

        table.insert(frame.headings, self:BuildHeading(i, v, frame, v.width or 200, offset))
        -- TODO, make height configurable
        height = height + 20
    end

    return offset + (headings[#headings].width or 200), height
end

function TableBuilder:BuildRow(data, yIndex, headings, parent)
    local xOffset = 0
    for i,v in ipairs(data) do
        if i > 1 then
            xOffset = xOffset + (headings[i - 1].width or 200)
        end

        local rowWidget = AceGUI:Create(headings[i].widget or "7LC_TableLabel")
        rowWidget:SetHeading(headings[i])
        rowWidget:SetValue(v)
        -- TODO, make height configurable
        rowWidget:SetOffset(xOffset, -((yIndex - 1) * ROW_HEIGHT))
        parent:AddChild(rowWidget)
    end
end

function TableBuilder:BuildRows(widget, headings, data)
    local height = 0
    for i,v in ipairs(data) do
        self:BuildRow(v, i, headings, widget)
        -- TODO, make height configurable
        height = height + ROW_HEIGHT
    end

    return height
end

local function Button_OnClick(frame)
    local descDefault = function(a, b)
        return a > b
    end

    local descStringDefault = function(a, b)
        return a:upper() > b:upper()
    end

    local ascDefault = function(a, b)
        return a < b
    end

    local ascStringDefault = function(a, b)
        return a:upper() < b:upper()
    end

    AceGUI:ClearFocus()
    PlaySound(852)
    local widget = frame.parent.obj
    local arrowIndex = widget.arrowIndices[frame.index] + 1
    if arrowIndex > 3 then
        arrowIndex = 1
    end

    for i in ipairs(widget.arrowIndices) do
        widget.arrowIndices[i] = 1
    end

    local newData = {}
    if arrowIndex > 1 then
        local heading = widget.headings[frame.index]

        newData = Addon.utils.table.copy(widget.data)
        table.sort(newData, function(a,b)
            local isString = type(a) == "string" and type(b) == "string"
            local desc = heading.desc
            local asc = heading.asc

            if isString then
                if not desc then
                    desc = descStringDefault
                end

                if not asc then
                    asc = ascStringDefault
                end
            else
                if not asc then
                    asc = ascDefault
                end
            end

            if arrowIndex == 2 then
                return desc(a[frame.index], b[frame.index])
            elseif arrowIndex == 3 then
                return asc(a[frame.index], b[frame.index])
            else
                return true
            end
        end)
    else
        newData = widget.unsortedData
    end

    widget.arrowIndices[frame.index] = arrowIndex

    TableBuilder:ClearHeadings(widget.frame)

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
        TableBuilder.headingOnClick = Button_OnClick
        TableBuilder.headingOnEnter = Control_OnEnter
        TableBuilder.headingOnLeave = Control_OnLeave
    end,
    ["OnRelease"] = function(self)
        TableBuilder:ClearFrame(self)
    end,
    ["SetDisabled"] = function(self, disabled)
        self.disabled = disabled
        TableBuilder.disabled = disabled
    end,
    ["SetData"] = function(self, data)
        self:SetList(data)
    end,
    ["SetList"] = function(self, value)
        local sameHeadings = Addon.utils.table.compare(self.headings, value.headings)
        local sameData = Addon.utils.table.compare(self.unsortedData, value.data)
        if sameHeadings and sameData then
            self:DoLayout()
            return
        end

        self:PauseLayout()
        self:SetHeadings(value.headings)
        self.data = value.data
        self.unsortedData = value.data
        local rowsHeight = TableBuilder:BuildRows(self, self.headings, value.data)
        self:SetHeight(self:GetHeight() + pp(rowsHeight))
        self:ResumeLayout()
        self:DoLayout()
    end,
    ["SetHeadings"] = function(self, headings)
        if self.headings and (#headings ~= #self.headings) then
            TableBuilder:ClearFrame(self)
        end

        self.headings = headings
        self.arrowIndices = {}
        for _ = 1, #headings do
            table.insert(self.arrowIndices, 1)
        end

        self.data = nil
        self.unsortedData = nil
        local headingWidth, headingHeight = TableBuilder:BuildHeadings(self.frame, self.headings)

        self:SetWidth(pp(headingWidth))
        self:SetHeight(pp(headingHeight))
    end,
    ["DoLayout"] = function(self)
        if not self.children then
            return
        end

        for i = 1, #self.children do
            local child = self.children[i]
            if child.DoLayout then
                child:DoLayout()
            end
        end
    end,
    ["GetWidth"] = function(self)
        return self.frame.width
    end,
    ["GetHeight"] = function(self)
        return self.frame.height
    end,
    ["OnWidthSet"] = function(self)
        if self.content then
            self.content:SetWidth(self.frame.width)
        end
    end,
    ["OnHeightSet"] = function(self)
        if self.content then
            -- TODO, make heading height configurable
            self.content:SetHeight(self.frame.height - pp(20))
        end
    end,
    ["SetValue"] = function() --[[Stub for "input" types]] end,
    ["GetValue"] = function() --[[Stub for "input" types]] end,
    ["SetItemValue"] = function() --[[Stub for "select" types]] end,
    ["SetText"] = function() --[[Stub for "input" types]] end,
    ["SetLabel"] = function() --[[Stub for "input" types]] end,
    ["OnEnterPressed"] = function() --[[Stub for "input" types]] end,
}

--[[-----------------------------------------------------------------------------
    Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
    local frame = CreateMainFrame(widgetType, Addon.UIParent)
    frame:Hide()

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 0, -ROW_HEIGHT)

    local widget = {
        frame = frame,
        content = content,
        type = widgetType,
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)