local spawnedWeeds = 0
local weedPlants = {}
local isPickingUp, isProcessing = false, false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)

		local coords = GetEntityCoords(PlayerPedId())

		if #(coords - Config.CircleZones.WeedField.coords) < 50 then
			SpawnWeedPlants()
		end
	end
end)

function ProcessWeed(xCannabis)
	isProcessing = true

	ESX.ShowNotification(_U('weed_processingstarted'))

	TriggerServerEvent('esx_drugs:processCannabis')

	if (xCannabis < 3) then
		xCannabis = 0
	end

	local timeLeft = (Config.Delays.WeedProcessing * xCannabis) / 1000
	local playerPed = PlayerPedId()

	while timeLeft > 0 do
		Citizen.Wait(1000)

		timeLeft = timeLeft - 1

		if #(GetEntityCoords(playerPed).xy - Config.CircleZones.WeedProcessing.coords.xy) > 4 then
			ESX.ShowNotification(_U('weed_processingtoofar'))

			TriggerServerEvent('esx_drugs:cancelProcessing')
			TriggerServerEvent('esx_drugs:outofbound')
			break
		end
	end

	isProcessing = false
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(weedPlants) do
			ESX.Game.DeleteObject(v)
		end
	end
end)

function SpawnWeedPlants()
	while spawnedWeeds < 15 do
		Citizen.Wait(0)

		local weedCoords = GenerateWeedCoords()

		ESX.Game.SpawnLocalObject('bkr_prop_weed_01_small_01a', weedCoords, function(obj)
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)

			table.insert(weedPlants, obj)

			spawnedWeeds = spawnedWeeds + 1
		end)
	end
end

function ValidateWeedCoord(plantCoord)
	if spawnedWeeds > 0 then
		local validate = true

		for k, v in pairs(weedPlants) do
			if #(plantCoord - GetEntityCoords(v)) < 4 then
				validate = false
			end
		end

		if #(plantCoord.xy - Config.CircleZones.WeedField.coords.xy) > 15 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateWeedCoords()
	while true do
		Citizen.Wait(0)

		local weedCoordX, weedCoordY

		math.randomseed(GetGameTimer())

		local modX = math.random(-90, 90)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())

		local modY = math.random(-90, 90)

		weedCoordX = Config.CircleZones.WeedField.coords.x + modX
		weedCoordY = Config.CircleZones.WeedField.coords.y + modY

		local coordZ = GetCoordZ(weedCoordX, weedCoordY)
		local coord = vector3(weedCoordX, weedCoordY, coordZ)

		if ValidateWeedCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = {48.0, 49.0, 50.0, 51.0, 52.0, 53.0, 54.0, 55.0, 56.0, 57.0, 58.0}

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 43.0
end

Citizen.CreateThread(function()
	while not Config.CircleZones do Wait(0) end

	exports.qtarget:AddTargetModel(GetHashKey('bkr_prop_weed_01_small_01a'), {
		options = {
			{
				event = "esx_drugs:canPickUp",
				icon = "fa-solid fa-cannabis",
				label = "Pluk wietplant",
				canInteract = function(entity, distance, coords, name, bone)
					activePlant = entity
					return true
				end
			},
		},
		distance = 1.5
	})
end)

RegisterNetEvent('esx_drugs:canPickUp')
AddEventHandler('esx_drugs:canPickUp', function(data)
	if not pickingUp then
		pickingUp = true

		local ped = PlayerPedId()

		TaskStartScenarioInPlace(ped, 'world_human_gardener_plant', 0, false)
		Citizen.Wait(2000)
		ClearPedTasks(ped)
		Citizen.Wait(2000)
		TriggerServerEvent('esx_drugs:pickedUpCannabis', xPlayer, cime)
		ESX.Game.DeleteObject(activePlant)

		pickingUp = false

		weedPlants[#weedPlants] = nil
	end
end)

exports.qtarget:AddBoxZone("verwerkwiet", vector3(1038.3906, -3205.8044, -38.4837), 0.45, 0.35, {
	name="verwerkwiet",
	heading=90.2562,
	debugPoly=false,
	minZ=-36.77834,
	maxZ=-37.1837,
	}, {
		options = {
			{
				event = "esx_drugs:processCannabis",
				icon = "fa-solid fa-cannabis",
				label = "Werwerk Wiet",
			},
		},
		distance = 3.5
})

RegisterNetEvent('esx_drugs:processCannabis')
AddEventHandler('esx_drugs:processCannabis', function(data)
	if not pickingUp then

		local ped = PlayerPedId()

		TaskStartScenarioInPlace(ped, 'PROP_HUMAN_BUM_BIN', 0, false)
		Citizen.Wait(2000)
		ClearPedTasks(ped)
		Citizen.Wait(2000)
		TriggerServerEvent('esx_drugs:processCannabis')
		Citizen.Wait(2000)
		TriggerServerEvent('esx_drugs:outofbound')
		
	end

end)

RegisterNetEvent('esx_drugs:outofbound', function()
	outofbound = true
end)






