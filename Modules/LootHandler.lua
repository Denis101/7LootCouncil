--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local GetTime = GetTime
local GetNumLootItems = GetNumLootItems
local GetLootSlotType = GetLootSlotType
local GetLootSourceInfo = GetLootSourceInfo
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLinks
local GetItemInfo = GetItemInfo
local GetItemInfoInstant = GetItemInfoInstant

local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LOOT_SLOT_ITEM = LOOT_SLOT_ITEM

local LE_ITEM_CLASS_CONTAINER = LE_ITEM_CLASS_CONTAINER
local LE_ITEM_CLASS_WEAPON = LE_ITEM_CLASS_WEAPON
local LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_QUESTITEM = LE_ITEM_CLASS_QUESTITEM
local LE_ITEM_CLASS_RECIPE = LE_ITEM_CLASS_RECIPE

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]
local Addon = unpack(select(2, ...))
local LootHandler = Addon:NewModule("LootHandler", "AceEvent-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0")
local UI = Addon:GetModule("UI")
local RollManager = Addon:GetModule("RollManager")

--[[-----------------------------------------------------------------------------
    Constants
-------------------------------------------------------------------------------]]

local COMMS_PREFIX = "7LC-LH"

local ALLOWED_ITEM_TYPES = {
    [LE_ITEM_CLASS_CONTAINER] = true,
    [LE_ITEM_CLASS_WEAPON] = true,
    [LE_ITEM_CLASS_ARMOR] = true,
    [LE_ITEM_CLASS_QUESTITEM] = true,
    [LE_ITEM_CLASS_RECIPE] = true,
}

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

LootHandler.trackingRolls = false
LootHandler.cache = {}

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
    Public
-------------------------------------------------------------------------------]]

function LootHandler:OnInitialize()
    self:RegisterComm(COMMS_PREFIX)

    self:RegisterEvent('LOOT_OPENED')
	self:RegisterEvent('LOOT_SLOT_CLEARED')
	self:RegisterEvent('LOOT_CLOSED')
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
end

function LootHandler:OnDisable()
    self:UnregisterEvent('LOOT_OPENED')
	self:UnregisterEvent('LOOT_SLOT_CLEARED')
	self:UnregisterEvent('LOOT_CLOSED')
	self:UnregisterEvent("OPEN_MASTER_LOOT_LIST")
	self:UnregisterEvent("UPDATE_MASTER_LOOT_LIST")
end

function LootHandler:ToggleRollTracking()
	self.trackingRolls = not self.trackingRolls
	if self.trackingRolls then
		self:RegisterEvent("CHAT_MSG_SYSTEM")
	else
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
	end
end

--[[-----------------------------------------------------------------------------
    Comms
-------------------------------------------------------------------------------]]

function LootHandler:OnCommReceived(prefix, data, channel, source)
    if not source then
        return
    end
    local info = select(2, self:Deserialize(data))
end

--[[-----------------------------------------------------------------------------
    Events
-------------------------------------------------------------------------------]]

function LootHandler:CHAT_MSG_SYSTEM(_, msg)
	local author, rollResult, rollMin, rollMax = string.match(msg, "(.+) rolls (%d+) %((%d+)-(%d+)%)")
	print(author)
	print(rollResult)
	print(rollMin)
	print(rollMax)
end

function LootHandler:LOOT_OPENED(...)
    for i = 1, select('#', ...) do
		local msg = select(i, ...)
		print(msg)
    end
    
	local items = GetNumLootItems()
	if items <= 0 then
		return
	end

    for i = 1, items do
        local type = GetLootSlotType(i)
        if type == LOOT_SLOT_ITEM then
            local link = GetLootSlotLink(i)
            local source = select(i * 2 - 1, GetLootSourceInfo(i))
            local textureId, item, _, _, quality, _, isQuestItem, _, isActive = GetLootSlotInfo(i)
            local color = ITEM_QUALITY_COLORS[quality]
            local id = GetItemInfoInstant(item)

            if self.cache[source] == nil then
                self.cache[source] = {}
            end

            if link and self.cache[source][i] == nil then
                local itemInfo = {
                    source = source,
                    id = id,
                    texture = textureId,
                    name = item,
                    quality = quality,
                    color = color,
                    bindType = select(14, GetItemInfo(item)),
                    link = link
                }

                self.cache[source][i] = itemInfo
                local classId = select(12, GetItemInfo(link))
                local allowed = ALLOWED_ITEM_TYPES[classId] ~= nil and not (isQuestItem and not isActive)
                if allowed then
                    UI:GetLootRollFrame(itemInfo, RollManager:GetOrderedOptions(), GetTime())
                end
            end
        end

        -- TODO, send comm message, handle loot windows
	end
end

function LootHandler:LOOT_SLOT_CLEARED(...)
	Addon.utils.table.print_args(...)
end

function LootHandler:LOOT_CLOSED(...)
	Addon.utils.table.print_args(...)
end

function LootHandler:OPEN_MASTER_LOOT_LIST(...)
	Addon.utils.table.print_args(...)
end

function LootHandler:UPDATE_MASTER_LOOT_LIST(...)
	Addon.utils.table.print_args(...)
end