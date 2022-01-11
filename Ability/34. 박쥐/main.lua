local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW034-checkAbility", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW034-checkAbility" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then checkAbility(funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW034-passiveCount") == nil then 
		player:setVariable("MW034-passiveCount", 0) 
		player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(6)
	end
	
	local count = player:getVariable("MW034-passiveCount")

	if count >= 1800 then count = 0 end
	if count == 0 then changeType(player) end
	count = count + 2
	player:setVariable("MW034-passiveCount", count)
end

function checkAbility(event, ability, id)
	local damagee = event:getEntity()
	local damager = event:getDamager()
	if event:getCause():toString() == "PROJECTILE" then damager = event:getDamager():getShooter() end
	
	if damager:getType():toString() == "PLAYER" and damagee:getType():toString() == "PLAYER" and game.getPlayerAbility(game.getPlayer(damager)) ~= nil then
		local abilities = util.getTableFromList(game.getPlayerAbility(game.getPlayer(damager)))
		if #abilities > 0 and abilities[1].abilityType == game.getPlayer(damagee):getVariable("MW034-playerType") then
			if game.checkCooldown(game.getPlayer(damagee), ability, id) then
				event:setCancelled(true)
			end
		else
			if game.checkCooldown(game.getPlayer(damagee), ability, id) then
				damagee:getWorld():playSound(damagee:getLocation(), import("$.Sound").ENTITY_BAT_HURT, 0.25, 1)
			end
		end
	end
end

function changeType(player)
	if math.random(2) == 1 then
		player:setVariable("MW034-playerType", "동물")
		game.sendMessage(player:getPlayer(), "§2[§a박쥐§2] §a능력 타입이 §2동물§a이 되었습니다.")
		game.sendMessage(player:getPlayer(), "§2[§a박쥐§2] §a동물 능력자에게는 데미지를 입지 않습니다.")
	else
		player:setVariable("MW034-playerType", "몬스터")
		game.sendMessage(player:getPlayer(), "§2[§a박쥐§2] §a능력 타입이 §2몬스터§a가 되었습니다.")
		game.sendMessage(player:getPlayer(), "§2[§a박쥐§2] §a몬스터 능력자에게는 데미지를 입지 않습니다.")
	end
	player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").ENTITY_BAT_AMBIENT, 1, 1)
end

function Reset(player, ability)
	player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getDefaultValue())
end


