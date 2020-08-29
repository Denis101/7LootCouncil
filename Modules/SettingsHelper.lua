--[[-----------------------------------------------------------------------------
    Lua imports
-------------------------------------------------------------------------------]]

local unpack = unpack
local rgb = rgb

--[[-----------------------------------------------------------------------------
    WoW API imports
-------------------------------------------------------------------------------]]

local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
    Ace imports and initialization
    Imports from params:
    - Addon
    - ProfileDB
    - GlobalDB
-------------------------------------------------------------------------------]]

local Addon = unpack(select(2, ...))
local SettingsHelper = Addon:NewModule("SettingsHelper", "AceHook-3.0")

--[[-----------------------------------------------------------------------------
    Properties
-------------------------------------------------------------------------------]]

local LSM = Addon.Libs.LSM

--[[-----------------------------------------------------------------------------
    Private
-------------------------------------------------------------------------------]]

local function BuildFont(f, font, size, outline, color, shadow)
	f.font, f.size, f.outline, f.color, f.shadow = font, size, outline, color, shadow
	font = font or LSM:Fetch("font", Addon.profile.general.fontSettings.font)
	if not size or size <= 0 then size = Addon.profile.general.fontSettings.size end
	outline = outline or Addon.profile.general.fontSettings.outline
	color = color or Addon.profile.general.fontSettings.color
	shadow = shadow or Addon.profile.general.fontSettings.shadow

	f:SetFont(font, size, outline)
	f:SetTextColor(rgb(color))

	if outline == "NONE" then
		f:SetShadowColor(rgb(shadow.Color))
		f:SetShadowOffset(shadow.Offset.x,shadow.Offset.y)
	end

	Addon.fontStrings[f] = true
end

--[[-----------------------------------------------------------------------------
    Public
-------------------------------------------------------------------------------]]

function SettingsHelper:UpdateFonts()
    for fs in pairs(Addon.fontStrings) do
        fs:BuildFont(fs.font, fs.size, fs.outline, fs.color, fs.shadow)
    end
end

--[[-----------------------------------------------------------------------------
    Hacky Lua Bullshit
-------------------------------------------------------------------------------]]

--Attach to font objects--
do
	local dummy = CreateFrame("Frame")
	getmetatable(dummy:CreateFontString()).__index.BuildFont = BuildFont
	if not getmetatable(_G.GameFontNormal).__index.BuildFont then
		getmetatable(_G.GameFontNormal).__index.BuildFont = BuildFont
	end
end