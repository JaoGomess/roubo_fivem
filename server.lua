local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

vRPclient = Tunnel.getInterface("vRP")

func = {}
Tunnel.bindInterface("tikuida_rob", func)

vRP._prepare('vRP/rob', "SELECT * FROM vrp_roubos WHERE id = @id")
vRP._prepare('vRP/updatev1', "UPDATE vrp_roubos SET time = @time, user_id = @user_id, type = @type WHERE id = @id")
vRP._prepare("vRP/updatev2","INSERT INTO vrp_roubos(id,time,user_id,type) VALUES(@id,@time,@user_id,@type)")

function checkTime(id, user_id, type)
	local row = vRP.query("vRP/rob", {id = id})
	if row and row[1] then
		local future = parseInt(row[1].time) + config.tempo
		if future >= os.time(os.date("!*t")) then

			return false
		end
		vRP.execute("vRP/updatev1", {id = id, time = os.time(os.date("!*t")), user_id = user_id, type = type})
		return true
	else
		vRP.execute("vRP/updatev2", {id = id, time = os.time(os.date("!*t")), user_id = user_id, type = type})
		return true
	end
end

function checkRestante(id, source)
	local row = vRP.query("vRP/rob", {id = id})
	if row and row[1] then
		local F = parseInt(os.time(os.date("!*t"))) - parseInt(row[1].time)
		local cd = config.tempo
		local a = (cd - F) + 1

		if a > 0 then
			TriggerClientEvent("Notify", source, "negado", "Espere "..a.." segundos para roubar novamente")	
		end	
	end
end

function func.checkRob(type, id, x, y, z, h, setup)
    local source = source
    local user_id = vRP.getUserId(source)
	local policia = vRP.getUsersByPermission(config.permissao)
    if user_id then
		local c = json.decode(setup)
		for k, v in pairs(config.type) do
			if k == type then
				if #policia < c.ptr then 
					TriggerClientEvent("Notify", source, "negado", "Número insuficiente de policiais (" ..c.ptr.. ") no momento para iniciar o roubo.")
				elseif checkTime(id, user_id, type) then
					if chanceSucesso(type, c.chanceRoubo) then
						darItem(c, user_id)

						TriggerClientEvent("Notify", source, "sucesso", "Roubando")
						TriggerClientEvent("iniciandoroubo", source, x, y, z, c.tempoRoubo, h)
						vRPclient._playAnim(source,false,{{"anim@heists@ornate_bank@grab_cash_heels","grab"}},true)
						avisarPolicia(user_id, "Roubo em Andamento", "Assalto a "..type.." em andamento, verifique o ocorrido.", x, y, z, type)

					else
						TriggerClientEvent("Notify", source, "negado", "Voce tentou roubar a "..type.." porem n obteve sucesso")
					end
				else
					checkRestante(id, source)
				end
			end
		end
    end
end

function darItem(c, user_id)
	for k, v in pairs(c.item) do
		SetTimeout(5000, function()
			vRP.giveInventoryItem(user_id, k, parseInt(math.random(v.min,v.max) / v.div))	
		end)	
	end
end

function chanceSucesso(type, chance)
    if chance then
        if chance < 100 then
            local r = math.random(0, 100)
            if r <= chance then
                return true
            else
                return false
            end
        end
        return true
    end
    return true
end

function func.stopRob()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local policia = vRP.getUsersByPermission(config.permissao)
        for l,w in pairs(policia) do
			local player = vRP.getUserSource(parseInt(w))
            if player then
				async(function()
					TriggerClientEvent('blip:remover:assalto', player, user_id)
					TriggerClientEvent("Notify", player, "sucesso", "O assaltante saiu correndo.")
				end)
			end
		end
	end


end

function avisarPolicia(user_id, titulo, msg, x, y, z, name)
	local policias = vRP.getUsersByPermission(config.permissao)
    for k, v in pairs(policias) do
        local player = vRP.getUserSource(parseInt(v))
        if player then
            async(
                function()
                    TriggerClientEvent("blip:criar:assalto", player, user_id, x, y, z, name)
                    vRPclient.playSound(player, "Oneshot_Final", "MP_MISSION_COUNTDOWN_SOUNDSET")
                    TriggerClientEvent("Notify", player, "sucesso", msg)
                end
            )
        end
    end
end
