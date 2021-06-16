ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
TriggerEvent('esx_society:registerSociety', 'pharmacie', 'Pharmacie', 'society_pharmacie', 'society_pharmacie', 'society_pharmacie', {type = 'public'})

RegisterServerEvent('pharmaouvert')
AddEventHandler('pharmaouvert', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Pharmacie', '~b~Annonce', 'La pharmacie est ouverte !', 'CHAR_MP_MORS_MUTUAL', 8)
	end
end)

RegisterServerEvent('pharmafermer')
AddEventHandler('pharmafermer', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local xPlayers	= ESX.GetPlayers()
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Pharmacie', '~b~Annonce', 'Pharmacie fermer revener plus tard !', 'CHAR_MP_MORS_MUTUAL', 8)
	end
end)


-------------------- Coffre
RegisterServerEvent('e_pharma:prendreitems')
AddEventHandler('e_pharma:prendreitems', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pharmacie', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then

			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, "quantité invalide")
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', _source, 'Objet retiré', count, inventoryItem.label)
			end
		else
			TriggerClientEvent('esx:showNotification', _source, "quantité invalide")
		end
	end)
end)


RegisterNetEvent('e_pharma:stockitem')
AddEventHandler('e_pharma:stockitem', function(itemName, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pharmacie', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', _source, "Objet déposé "..count..""..inventoryItem.label.."")
		else
			TriggerClientEvent('esx:showNotification', _source, "quantité invalide")
		end
	end)
end)


ESX.RegisterServerCallback('e_pharma:inventairejoueur', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

ESX.RegisterServerCallback('e_pharma:prendreitem', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_pharmacie', function(inventory)
		cb(inventory.items)
	end)
end)

-------------------- Stock

RegisterNetEvent('prendre:kit')
AddEventHandler('prendre:kit', function()

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = 0
    local xMoney = xPlayer.getMoney()

    if xMoney >= price then

        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem('soda', 3)
    else
    end
end)

RegisterNetEvent('prendre:bandage')
AddEventHandler('prendre:bandage', function()

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = 0
    local xMoney = xPlayer.getMoney()

    if xMoney >= price then

        xPlayer.removeMoney(price)
        xPlayer.addInventoryItem('bandage', 3)
    else
    end
end)