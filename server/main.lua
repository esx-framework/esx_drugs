local playersProcessingCannabis = {}
local outofbound = true
local alive = true

local function ValidatePickupCannabis(src)
	local ECoords = Config.CircleZones.WeedField.coords
	local PCoords = GetEntityCoords(GetPlayerPed(src))
	local Dist = #(PCoords-ECoords)
	if Dist <= 90 then return true end
end

local function ValidateProcessCannabis(src)
	local ECoords = Config.CircleZones.WeedProcessing.coords
	local PCoords = GetEntityCoords(GetPlayerPed(src))
	local Dist = #(PCoords-ECoords)
	if Dist <= 5 then return true end
end

local function FoundExploiter(src,reason)
	-- ADD YOUR BAN EVENT HERE UNTIL THEN IT WILL ONLY KICK THE PLAYER --
	DropPlayer(src,reason)
end

RegisterServerEvent('esx_drugs:sellDrug')
AddEventHandler('esx_drugs:sellDrug', function(itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.DrugDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)

	-- If this fails its 99% a mod-menu, the variables client sided are setup to provide the exact right arguments
	if type(amount) ~= 'number' or type(itemName) ~= 'string' then
		print(('esx_drugs: %s attempted to sell with invalid input type!'):format(xPlayer.identifier))
		FoundExploiter(xPlayer.source,'SellDrugs Event Trigger')
		return
	end
	if not price then
		print(('esx_drugs: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
		return
	end
	if amount < 0 then
		print(('esx_drugs: %s attempted to sell an minus amount!'):format(xPlayer.identifier))
		return
	end
	if xItem == nil or xItem.count < amount then
		xPlayer.showNotification(TranslateCap('dealer_notenough'))
		return
	end

	price = ESX.Math.Round(price * amount)

	if Config.GiveBlack then
		xPlayer.addAccountMoney('black_money', price, "Drugs Sold")
	else
		xPlayer.addMoney(price, "Drugs Sold")
	end

	xPlayer.removeInventoryItem(xItem.name, amount)
	xPlayer.showNotification(TranslateCap('dealer_sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
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

RegisterServerEvent('esx_drugs:pickedUpCannabis')
AddEventHandler('esx_drugs:pickedUpCannabis', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local cime = math.random(5,10)
	if ValidatePickupCannabis(src) then
		if xPlayer.canCarryItem('cannabis', cime) then
			xPlayer.addInventoryItem('cannabis', cime)
		else
			xPlayer.showNotification(TranslateCap('weed_inventoryfull'))
		end
	else
		FoundExploiter(src,'Event Trigger')
	end
end)

ESX.RegisterServerCallback('esx_drugs:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('esx_drugs:outofbound')
AddEventHandler('esx_drugs:outofbound', function()
	outofbound = true
end)

ESX.RegisterServerCallback('esx_drugs:cannabis_count', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local xCannabis = xPlayer.getInventoryItem('cannabis').count
	cb(xCannabis)
end)

RegisterServerEvent('esx_drugs:processCannabis')
AddEventHandler('esx_drugs:processCannabis', function()
  	if not playersProcessingCannabis[source] then
		local source = source
		if ValidateProcessCannabis(source) then
			local xPlayer = ESX.GetPlayerFromId(source)
			local xCannabis = xPlayer.getInventoryItem('cannabis')
			local can = true
			outofbound = false
			if xCannabis.count >= 3 then
				while outofbound == false and can do
					if playersProcessingCannabis[source] == nil then
						playersProcessingCannabis[source] = ESX.SetTimeout(Config.Delays.WeedProcessing , function()
							if xCannabis.count >= 3 then
								if xPlayer.canSwapItem('cannabis', 3, 'marijuana', 1) then
									xPlayer.removeInventoryItem('cannabis', 3)
									xPlayer.addInventoryItem('marijuana', 1)
									xPlayer.showNotification(TranslateCap('weed_processed'))
								else
									can = false
									xPlayer.showNotification(TranslateCap('weed_processingfull'))
									TriggerEvent('esx_drugs:cancelProcessing')
								end
							else						
								can = false
								xPlayer.showNotification(TranslateCap('weed_processingenough'))
								TriggerEvent('esx_drugs:cancelProcessing')
							end
							playersProcessingCannabis[source] = nil
						end)
					else
						Wait(Config.Delays.WeedProcessing)
					end	
				end
			else
				xPlayer.showNotification(TranslateCap('weed_processingenough'))
				TriggerEvent('esx_drugs:cancelProcessing')
			end	
		else
			FoundExploiter(source,'Event Trigger')
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

RegisterServerEvent('esx_drugs:cancelProcessing')
AddEventHandler('esx_drugs:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
