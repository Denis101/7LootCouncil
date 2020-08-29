local Engine = select(2, ...)
local ProfileDB = {}

ProfileDB = {
	general = {
		unitFrames = {
			barTexture = "Solid",
		},
		buttonFrames = {
			backgroundTexture = "Solid",
			borderTexture = "None",
			color = { r = 1, g = .5, b = .5 },
		},
		fontSettings = {
			font = "2002",
			size = 14,
			outline = "OUTLINE",
			justifyV = "MIDDLE",
			justifyH = "LEFT",
			spacing = 0.0,
			color = {
				r = 1,
				g = 1,
				b = 1,
				a = 1,
			},
			shadow = {
				Color = {
					r = 0,
					g = 0,
					b = 0,
					a = 1,
				},
				Offset = {
					x = 1,
					y = -1,
				},
			},
		},
	},
	module = {
		['**'] = {
			locked = false,
			defaultOptions = true,
		},
		council = {
			myCouncil = {},
			councils = {},
		},
		roll = {
			newOption = {},
			myOptions = {},
			options = {},
			myTimer = 60,
			timers = {},
		},
	},
}

Engine[2] = ProfileDB