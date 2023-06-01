Config = {}

Config.Locale = 'en'

Config.Delays = {
	WeedProcessing = 500 * 5
}

Config.DrugDealerItems = {
	weed_pooch = 91
}

Config.LicenseEnable = false -- enable processing licenses? The player will be required to buy a license in order to process drugs. Requires esx_license

Config.LicensePrices = {
	weed_processing = {
		label = _U('license_weed'),
		price = 15000
	}
}

Config.GiveBlack = true -- give black money? if disabled it'll give regular cash.

Config.CircleZones = {
	WeedField = {coords = vector3(2527.7002, 4360.2100, 40.0217), name = _U('blip_weedfield'), color = 25, sprite = 496},
	WeedProcessing = {coords = vector3(-1320.2625, -1169.4888, -4.8492), name = _U('blip_weedprocessing'), color = 25, sprite = 496},
	DrugDealer = {coords = vector3(-1172.02, -1571.98, -4.66), name = _U('blip_drugdealer'), color = 6, sprite = 378}
}
