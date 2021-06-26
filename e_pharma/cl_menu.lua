
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	Citizen.Wait(0)
    end  
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
    Citizen.Wait(5000)
end)

------------------------- Blips --------------------------

local blips = {
    {title="Pharmacie", colour=25, id=85, x = -1886.52, y = 2062.68, z = 139.98},
}
	  
Citizen.CreateThread(function()    
	Citizen.Wait(0)    
  local bool = true     
  if bool then    
		 for _, info in pairs(blips) do      
			 info.blip = AddBlipForCoord(info.x, info.y, info.z)
						 SetBlipSprite(info.blip, info.id)
						 SetBlipDisplay(info.blip, 4)
						 SetBlipScale(info.blip, 1.1)
						 SetBlipColour(info.blip, info.colour)
						 SetBlipAsShortRange(info.blip, true)
						 BeginTextCommandSetBlipName("STRING")
						 AddTextComponentString(info.title)
						 EndTextCommandSetBlipName(info.blip)
		 end        
	 bool = false     
   end
end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- SCRIPT -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

function OpenBillingMenu()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'facture',
        {
            title = 'Donner une facture'
        },
        function(data, menu)

            local amount = tonumber(data.value)

            if amount == nil or amount <= 0 then
                ESX.ShowNotification('Montant invalide')
            else
                menu.close()

                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 3.0 then
                    ESX.ShowNotification('Pas de joueurs proche')
                else
                    local playerPed        = GetPlayerPed(-1)

                    Citizen.CreateThread(function()
                        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                        Citizen.Wait(5000)
                        ClearPedTasks(playerPed)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_pharmacie', 'Pharmacie', amount)
                        ESX.ShowNotification("~r~Vous avez bien envoyer la facture")
                    end)
                end
            end
        end,
        function(data, menu)
            menu.close()
    end)
end

------ Coffre

function OpenGetStockspharmaMenu()
	ESX.TriggerServerCallback('e_pharma:prendreitem', function(items)
		local elements = {}

		for i=1, #items, 1 do
            table.insert(elements, {
                label = 'x' .. items[i].count .. ' ' .. items[i].label,
                value = items[i].name
            })
        end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'police',
			title    = 'stockage',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
                css      = 'police',
				title = 'quantité'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantité invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('e_pharma:prendreitems', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksLSPDMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStockspharmaMenu()
	ESX.TriggerServerCallback('e_pharma:inventairejoueur', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
            css      = 'e_pharma',
			title    = 'inventaire',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
                css      = 'e_pharma',
				title = 'quantité'
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification('quantité invalide')
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('e_pharma:stockitem', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksLSPDMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Menu F6 ----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local menuf6 = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "MENU INTERACTION" },
    Data = { currentMenu = "Liste des actions :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Facturation" then   
                OpenBillingMenu()
            elseif btn.name == "Annonce" then
                OpenMenu("annonce")
            elseif btn.name == "Ouvert" then
                TriggerServerEvent("pharmaouvert")
            elseif btn.name == "Fermer" then
                TriggerServerEvent("pharmafermer")
            elseif btn.name == "Fermer le menu" then
                CloseMenu()
            end 
    end,
},
    Menu = {
        ["Liste des actions :"] = {
            b = {
                {name = "Facturation", ask = '>>', askX = true},
                {name = "Annonce", ask = '>>', askX = true},
            }
        },
        ["annonce"] = {
            b = {
                {name = "Ouvert", ask = '>>', askX = true},
                {name = "Fermer", ask = '>>', askX = true},
            }
        }
    }
} 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if IsControlJustPressed(0,167) and PlayerData.job and PlayerData.job.name == 'pharma' then
			CreateMenu(menuf6)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Coffre -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local coffre = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "Coffre entreprise" },
    Data = { currentMenu = "Coffre :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Stock" then   
                OpenMenu("stock")
            elseif btn.name == "Coffre" then
                OpenMenu("coffre")
            elseif btn.name == "Prendre" then
                OpenGetStockspharmaMenu()
                CloseMenu()
            elseif btn.name == "Deposer" then
                OpenPutStockspharmaMenu()
                CloseMenu()
            elseif btn.name == "Kit de premier soin" then
                TriggerServerEvent('prendre:kit')
                CloseMenu()
            elseif btn.name == "Bandage" then
                TriggerServerEvent("prendre:bandage")
                CloseMenu()
            elseif btn.name == "Fermer le menu" then
                CloseMenu()
            end 
    end,
},
    Menu = {
        ["Coffre :"] = {
            b = {
                {name = "Stock", ask = '>>', askX = true},
                {name = "Coffre", ask = '>>', askX = true},
            }
        },
        ["coffre"] = {
            b = {
                {name = "Prendre", ask = '>>', askX = true},
                {name = "Deposer", ask = '>>', askX = true},
            }
        },
        ["stock"] = {
            b = {
                {name = "Kit de premier soin", ask = '>>', askX = true},
                {name = "Bandage", ask = '>>', askX = true},
            }
        }
    }
} 

local stock = { 
    {x=364.13, y=-586.98, z=28.69} --Position coffre
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(stock) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, stock[k].x, stock[k].y, stock[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'pharma'  then
                DrawMarker(23, 364.13, -586.98, 28.69, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 0.9, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("~b~Appuyez sur ~INPUT_PICKUP~ pour accéder au armoire~s~")
                if IsControlJustPressed(1,38) then 			
                    CreateMenu(coffre)
         end end end end end)  

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- GARAGE -----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local voiture = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "GARAGE VIGNE" },
    Data = { currentMenu = "Liste des véhicules :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
         
            if btn.name == "Camionette" then   
                spawnCar("burrito2")
            elseif btn.name == "Pick-up" then
                spawnCar("bison3")
            elseif btn.name == "Berline" then
                spawnCar("cog55")
            end 
    end,
},
    Menu = {
        ["Liste des véhicules :"] = {
            b = {
                {name = "Camionette", ask = '>>', askX = true},
                {name = "Pick-up", ask = '>>', askX = true},
                {name = "Berline", ask = '>>', askX = true},
            }
        }
    }
} 


function spawnCar(car)
    local car = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(50)   
    end


    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, -1918.86, 2052.77, 140.74, 258.65, true, false)   ---- spawn du vehicule (position)
    ESX.ShowNotification('~g~Garage¦~s~\nVous avez sorti ~h~~b~un/une~s~ ~y~'..GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))..'')
    TriggerServerEvent('esx_vehiclelock:givekey', 'no', plate)
    SetEntityAsNoLongerNeeded(vehicle)
    SetVehicleNumberPlateText(vehicle, "VIGNE")





end 

local garagevigne = { 
    {x=-1923.64, y=2054.36, z=140.83} -- Point pour sortir le vehicule
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(garagevigne) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, garagevigne[k].x, garagevigne[k].y, garagevigne[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'vigne'  then
                DrawMarker(23, -1923.64, 2054.36, 139.83, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 0.9, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("~b~Appuyez sur ~INPUT_PICKUP~ pour accéder au garage~s~")
                if IsControlJustPressed(1,38) then 			
                    CreateMenu(voiture)
         end end end end end)   

-------------------------------------------------------- Suppression -------------------------------------------------------

local range = { 
    {x=-1921.82, y=2040.74, z=140.74} -- Suppression pos
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(range) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, range[k].x, range[k].y, range[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'vigne'  then
                DrawMarker(23, -1921.82, 2040.74, 139.74, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 0.9, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("~b~Appuyez sur ~INPUT_PICKUP~ pour ranger ton vehicule~s~")
                if IsControlJustPressed(1,38) then 			
                    TriggerEvent('esx:deleteVehicle')
         end end end end end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Menu BOSS --------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local boss = { 
    {x=364.76, y=-585.00, z=28.7}
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(boss) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, boss[k].x, boss[k].y, boss[k].z)
            if dist <= 1.5 and PlayerData.job and PlayerData.job.name == 'pharma' and PlayerData.job.grade_name == 'boss'   then
                DrawMarker(23, 364.76, -585.00, 28.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.9, 0.9, 255, 255, 0, 255, 0, 1, 2, 0, nil, nil, 0)
                ESX.ShowHelpNotification("~b~Appuyez sur ~INPUT_PICKUP~ pour acceder a l'ordinateur~s~")
                if IsControlJustPressed(1,38) then 			
                    TriggerEvent('esx_society:openBossMenu', 'pharmacie', function(data, menu)
                        menu.close()
                    end, {wash = true})
         end end end end end)  
