local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

func = Tunnel.getInterface("tikuida_rob")

local andamento = false
local segundos = 0
local blip = {}

CreateThread(function() 
    while true do
        local sleep = 2000
        local ped = PlayerPedId()
        local cds = GetEntityCoords(ped)
        for k, v in pairs(config.type) do
			for k2, v2 in pairs(v.cds) do
				local dis = #(cds - vector3(v2.x, v2.y, v2.z))
				if dis <= 1.5 and not andamento then
					sleep = 5
					drawTxt("PRESSIONE  ~r~G~w~  PARA INICIAR O ROUBO",4,0.5,0.93,0.50,255,255,255,180)
					if IsControlJustPressed(0,47) and not IsPedInAnyVehicle(ped) then
						func.checkRob(k, v2.id, v2.x, v2.y, v2.z, v2.h, json.encode(v))
					end
				end 
			end
		end

        if andamento then
            sleep = 5
			drawTxt("APERTE ~r~M~w~ PARA CANCELAR O ROUBO EM ANDAMENTO",4,0.5,0.91,0.36,255,255,255,30)
			drawTxt("RESTAM ~g~"..segundos.." SEGUNDOS ~w~PARA TERMINAR",4,0.5,0.93,0.50,255,255,255,180)
			if IsControlJustPressed(0,244) or GetEntityHealth(ped) <= 100 then
				andamento = false
				ClearPedTasks(ped)
				func.stopRob()
				TriggerEvent('cancelando',false)
			end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
	while true do
		Wait(1000)
		if andamento then
			segundos = segundos - 1
			if segundos <= 0 then
				andamento = false
				ClearPedTasks(PlayerPedId())
				TriggerEvent('cancelando',false)
			end
		end
	end
end)

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

RegisterNetEvent("iniciandoroubo")
AddEventHandler("iniciandoroubo",function(x,y,z,secs,head)

	segundos = secs
	andamento = true
	SetEntityHeading(PlayerPedId(),head)
	SetEntityCoords(PlayerPedId(),x,y,z-1,false,false,false,false)
	SetPedComponentVariation(PlayerPedId(),5,45,0,2)
	SetCurrentPedWeapon(PlayerPedId(),GetHashKey("WEAPON_UNARMED"),true)
	TriggerEvent('cancelando',true)

end)

RegisterNetEvent('blip:criar:assalto')
AddEventHandler('blip:criar:assalto',function(user_id, x,y,z, name)
	if not DoesBlipExist(blip[user_id]) then
		blip[user_id] = AddBlipForCoord(x,y,z)
		SetBlipScale(blip[user_id],0.9)
		SetBlipSprite(blip[user_id],272)
		SetBlipColour(blip[user_id],59)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Assaltante a "..name)
		EndTextCommandSetBlipName(blip[user_id])
		SetBlipAsShortRange(blip[user_id],false)
		SetBlipRoute(blip[user_id],true)
	end
end)

RegisterNetEvent('blip:remover:assalto')
AddEventHandler('blip:remover:assalto',function(user_id)
	if DoesBlipExist(blip[user_id]) then
		RemoveBlip(blip[user_id])
		blip[user_id] = nil
	end
end)
