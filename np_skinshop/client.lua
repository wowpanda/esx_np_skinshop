

-- // ADDED ESX SUPPORT \\ --
ESX                         = nil
Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

-- Storing selected outfit
local outfit = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- Menu toggle
-----------------------------------------------------------------------------------------------------------------------------------------
local m, f = GetHashKey("mp_m_freemode_01"), GetHashKey("mp_f_freemode_01")
local cor = 0
local menuactive = false
RegisterNetEvent("skinshop:toggleMenu")
AddEventHandler("skinshop:toggleMenu", function()
	menuactive = not menuactive
	if menuactive then
		SetNuiFocus(true,true)
		outfit = {  }

		local ped = PlayerPedId()
		if IsPedModel(ped, m) then
			SendNUIMessage({ showMenu = true, masc = true })
		elseif IsPedModel(ped, f) then
			SendNUIMessage({ showMenu = true, masc = false })		
		end
	else
		cor = 0
		dados, tipo = nil
		SetNuiFocus(false)
		SendNUIMessage({ showMenu = false, masc = true })
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if menuactive then InvalidateIdleCam() end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- Retornos
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("exit", function()
	TriggerEvent("skinshop:toggleMenu")
	-- Added a validate purchase menu
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'validate_purchase', {
		title = 'Would you like to validate this purchase?',
		align = 'right',
		elements = {
			{ label = "Yes", value = "yes" },
			{ label = "No", value = "no" }
		}
	}, function(data, menu)
		menu.close()
		if data.current.value == 'yes' then
			ESX.TriggerServerCallback('esx_clotheshop:buyClothes', function(bought)
				if bought then
					TriggerEvent('skinchanger:getSkin', function(skin)
						-- loops through everything in outfits and checks their type and color
						for k,v in pairs(outfit) do
							if k == 1 then skin.mask_1 = v.type skin.mask_2 = v.color end
							if k == 7 then skin.chain_1 = v.type skin.chain_2 = v.color end
							if k == 5 then skin.bags_1 = v.type skin.bags_2 = v.color end
							if k == 3 then skin.arms_1 = v.type skin.arms_2 = v.color end
							if k == 4 then skin.pants_1 = v.type skin.pants_2 = v.color end
							if k == 8 then skin.tshirt_1 = v.type skin.tshirt_2 = v.color end
							if k == 6 then skin.shoes_1 = v.type skin.shoes_2 = v.color end
							if k == 11 then skin.torso_1 = v.type skin.torso_2 = v.color end
							if k == 100 then skin.helmet_1 = v.type skin.helmet_2 = v.color end
							if k == 101 then skin.glasses_1 = v.type skin.glasses_2 = v.color end
							if k == 102 then skin.ears_1 = v.type skin.ears_2 = v.color end
							if k == 9 then skin.bproof_1 = v.type skin.bproof_2 = v.color end
						end

						TriggerServerEvent('esx_skin:save', skin)
					end)
				else
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
						TriggerEvent('skinchanger:loadSkin', skin)
					end)
					ESX.ShowNotification("You don't have enough money!")
				end
			end)
		else
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end)

RegisterNUICallback("rotate", function(data, cb)
	local ped = PlayerPedId()
	local heading = GetEntityHeading(ped)
	if data == "left" then
		SetEntityHeading(ped, heading + 15)
	elseif data == "right" then
		SetEntityHeading(ped, heading - 15)
	end
end)

RegisterNUICallback("update", function(data, cb)
	dados = tonumber(json.encode(data[1]))
	tipo = tonumber(json.encode(data[2]))
	cor = 0
	setRoupa(dados, tipo, cor)
end)

RegisterNUICallback("color", function(data, cb)
	if data == "left" then
		if cor ~= 0 then cor = cor - 1 else cor = 20 end
	elseif data == "right" then
		if cor ~= 21 then cor = cor + 1 else cor = 0 end
	end
	if dados and tipo then setRoupa(dados, tipo, cor) end
end)

function setRoupa(dados, tipo, cor)
	-- registers the selected piece of clothing to the outfit with the type and color
	outfit[dados] = { type = tipo, color = cor }
	local ped = PlayerPedId()
	if dados < 100 then		
		SetPedComponentVariation(ped, dados, tipo, cor, 1)
	else
		SetPedPropIndex(ped, dados-100, tipo, cor, 1)
	end
end
