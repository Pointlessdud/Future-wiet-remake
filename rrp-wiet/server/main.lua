local playersProcessingCannabis = {}
local outofbound = true
local alive = true
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

RegisterNetEvent('esx_drugs:sellDrug', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.DrugDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	if not price then
		print(('esx_drugs: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
		return
	end

	if xItem.count < amount then
		xPlayer.showNotification(_U('dealer_notenough'))
		return
	end

	price = ESX.Math.Round(price * amount)

	if Config.GiveBlack then
		xPlayer.addAccountMoney('black_money', price)
	else
		xPlayer.addMoney(price)
	end

	xPlayer.removeInventoryItem(xItem.name, amount)
	xPlayer.showNotification(_U('dealer_sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
end)

ESX.RegisterServerCallback('esx_drugs:buyLicense', function(source, cb, licenseName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local license = Config.LicensePrices[licenseName]

	if license then
		if xPlayer.getMoney() >= license.price then
			xPlayer.removeMoney(license.price)

			TriggerEvent('esx_license:addLicense', source, licenseName, function()
				cb(true)
			end)
		else
			cb(false)
		end
	else
		print(('esx_drugs: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end
end)

RegisterNetEvent('esx_drugs:pickedUpCannabis', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local cime = math.random(1,3)

	if exports.ox_inventory:CanCarryItem(source, 'weed', 1) then
		xPlayer.addInventoryItem('weed', cime)
	else
		xPlayer.showNotification(_U('weed_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('esx_drugs:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterNetEvent('esx_drugs:outofbound', function()
	outofbound = true
end)

RegisterNetEvent('esx_drugs:quitprocess', function()
	can = false
end)

ESX.RegisterServerCallback('esx_drugs:cannabis_count', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xCannabis = xPlayer.getInventoryItem('weed').count

	cb(xCannabis)
end)

RegisterNetEvent('esx_drugs:processCannabis', function()
	if not playersProcessingCannabis[source] then
		local _source = source
		local xPlayer = ESX.GetPlayerFromId(_source)
		local xCannabis = xPlayer.getInventoryItem('weed')

		TriggerClientEvent('esx_drugs:getPlayer',xCannabis.count,_source)

		local can = true

		outofbound = false

		if xCannabis.count >=3 then
			while outofbound == false and can and GetEntityHealth(GetPlayerPed(_source))>0 do
				if playersProcessingCannabis[_source] == nil then
					playersProcessingCannabis[_source] = ESX.SetTimeout(Config.Delays.WeedProcessing , function()
						if xCannabis.count >= 3 then
							if xPlayer.canSwapItem('weed', 3, 'weed_packed', 1) then
								xPlayer.removeInventoryItem('weed', 3)
								xPlayer.addInventoryItem('weed_packed', 1)
								xPlayer.showNotification(_U('weed_processed'))
							else
								can = false

								xPlayer.showNotification(_U('weed_processingfull'))

								TriggerEvent('esx_drugs:cancelProcessing')
							end
						else
							can = false

							xPlayer.showNotification(_U('weed_processingenough'))

							TriggerEvent('esx_drugs:cancelProcessing')
						end

						playersProcessingCannabis[_source] = nil
					end)
				else
					Citizen.Wait(Config.Delays.WeedProcessing)
				end
			end
		else
			xPlayer.showNotification(_U('weed_processingenough'))

			TriggerEvent('esx_drugs:cancelProcessing')
		end
	else
		print(('esx_drugs: %s attempted to exploit weed processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerId)
	if playersProcessingCannabis[playerId] then
		ESX.ClearTimeout(playersProcessingCannabis[playerId])

		playersProcessingCannabis[playerId] = nil
	end
end

RegisterNetEvent('esx_drugs:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterNetEvent('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)


