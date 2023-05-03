Config = {}

Config.Locale = GetConvar('esx:locale', 'en')

-- How much Delay should there be?
-- Standard is 7 seconds
Config.Delays = {
	WeedProcessing = 1000 * 7
}

-- How much should they cost?
Config.DrugDealerItems = {
	marijuana = 91
}

Config.LicenseEnable = false -- enable processing licenses? The player will be required to buy a license in order to process drugs. Requires esx_license

Config.LicensePrices = {
	weed_processing = {label = TranslateCap('license_weed'), price = 15000}
}

Config.GiveBlack = true -- give black money? if disabled it'll give regular cash.

Config.CircleZones = {
	WeedField = {coords = vector3(2220.72, 5582.52, 53.81), name = TranslateCap('blip_weedfield'), color = 25, sprite = 496, radius = 100.0, showBlip = true},
	WeedProcessing = {coords = vector3(2329.02, 2571.29, 46.68), name = TranslateCap('blip_weedprocessing'), color = 25, sprite = 496, showBlip = true},

	DrugDealer = {coords = vector3(-1172.02, -1571.98, 4.66), name = TranslateCap('blip_drugdealer'), color = 6, sprite = 378, showBlip = true},
}

Config.Marker = {
	Distance = 100.0,
	Color = {r=60,g=230,b=60,a=255},
	Size = vector3(1.5,1.5,1.0),
	Type = 1,
}

-- min amount of Config.DrugDealerItems to sell
-- max amount of Config.DrugDealerItems to sell
Config.SellMenu = {
	Min = 1,
	Max = 50
}

-- Set if the Drug Effect should appear on smoke
Config.DrugEffect = true

-- Set how long the effect should be. (In MS)
-- Normaly 300000 ms = 5 Mins
Config.DrugEffectMS = 300000