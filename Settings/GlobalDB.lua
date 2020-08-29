local Engine = select(2, ...)
local GlobalDB = {}

--Global Settings
GlobalDB.general = {
	version = "0.0.1",
	cropIcon = 1.75,
	AceGUI = {
		width = 1200,
		height = 1000
	},
	maxFrames = 40,
	rangeFadeTime = 10,
	rangeFadeAmount = 0.5,
	blueShamans = true
}

-- Luv u juised man :)
GlobalDB.JuisedBlue = {
	r = 104,
	g = 31,
	b = 128,
	hex = "681f80",
	displayText = "|cFF681f80"
}

GlobalDB.PreviewItemIds = {
	19352,
	19360,
	19379,
	21622,
	21709,
	21888,
	21134,
	21839,
	21581,
	21814,
	21663,
	21126,
	21585,
	22798,
	22691,
}

Engine[3] = GlobalDB