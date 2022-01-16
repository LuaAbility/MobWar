local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW037-changeStat", "PlayerInteractEvent", 2000)
	plugin.registerEvent(abilityData, "MW037-respawn", "PlayerRespawnEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW037-changeStat" then changeStat(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW037-respawn" then respawn(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW037-passiveCount") == nil then 
		player:setVariable("MW037-passiveCount", 0) 
		rollStat(player:getPlayer())
	end
end

function respawn(LAPlayer, event, ability, id)
	if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
		rollStat(event:getPlayer())
	end
end

function changeStat(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "WHEAT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					rollStat(event:getPlayer())
				end
			end
		end
	end
end

function rollStat(player)
	math.randomseed(os.time())
	local healthStat = util.random(15, 30)
	local speedStat = util.random(2500, 5000)
	
	player:getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(healthStat)
	player:setWalkSpeed(speedStat / 10000.0)
	game.sendMessage(player, "§2[§a말§2] §a체력 : " .. healthStat .. " / 속도 : " .. speedStat / 10000.0 .. "로 재설정 되었습니다.")
	player:getWorld():playSound(player:getLocation(), import("$.Sound").ENTITY_HORSE_AMBIENT, 1, 1)
end

function Reset(player, ability)
	player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getDefaultValue())
	player:getPlayer():setWalkSpeed(0.2)
end