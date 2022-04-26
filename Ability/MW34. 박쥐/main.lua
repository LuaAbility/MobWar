local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW034-checkAbility", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW034-checkAbility" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then checkAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW034-passiveCount") == nil then 
		player:setVariable("MW034-passiveCount", 0) 
		player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(game.getMaxHealth() * 0.5)
		
		local types = newInstance("java.util.ArrayList", {})
		local players = util.getTableFromList(game.getPlayers())
		
		for i = 1, #players do
			local abilities = util.getTableFromList(game.getPlayerAbility(players[i]))
			if #abilities > 0 and not types:contains(abilities[1].abilityType) then
				types:add(abilities[1].abilityType)
			end
		end
		
		if types:size() <= 1 then
			game.sendMessage(player:getPlayer(), "§4[§c박쥐§4] §c모두가 같은 능력 타입을 가지고 있어 능력이 제거됩니다.")
			game.removeAbilityAsID(player, "LA-MW-034", false)
		end
		
		player:setVariable("MW034-allTypes", types)
	end
	
	local count = player:getVariable("MW034-passiveCount")

	if count >= 1200 then count = 0 end
	if count == 0 then changeType(player) end
	count = count + 1
	player:setVariable("MW034-passiveCount", count)
end

function checkAbility(LAPlayer, event, ability, id)
	local damagee = event:getEntity()
	local damager = util.getRealDamager(event:getDamager())
	
	
	if damager ~= nil and damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" and game.getPlayerAbility(game.getPlayer(damager)) ~= nil then
		local abilities = util.getTableFromList(game.getPlayerAbility(game.getPlayer(damager)))
		if #abilities > 0 and abilities[1].abilityType == game.getPlayer(damagee):getVariable("MW034-playerType") then
			if game.checkCooldown(LAPlayer, game.getPlayer(damagee), ability, id) then
				event:setCancelled(true)
			end
		else
			if game.checkCooldown(LAPlayer, game.getPlayer(damagee), ability, id) then
				damagee:getWorld():playSound(damagee:getLocation(), import("$.Sound").ENTITY_BAT_HURT, 0.25, 1)
			end
		end
	end
end

function changeType(player)
	local types = util.getTableFromList(player:getVariable("MW034-allTypes"))
	local randomIndex = util.random(1, #types)

	player:setVariable("MW034-playerType", types[randomIndex])
	game.sendMessage(player:getPlayer(), "§2[§a박쥐§2] §a능력 타입이 §2" .. types[randomIndex] .. "§a이(가) 되었습니다.")
	game.sendMessage(player:getPlayer(), "§2[§a박쥐§2] §2" .. types[randomIndex] .. "§a 능력자에게는 데미지를 입지 않습니다.")
	
	player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").ENTITY_BAT_AMBIENT, 1, 1)
end

function Reset(player, ability)
	player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getDefaultValue())
end


