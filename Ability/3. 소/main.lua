local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW003-panelty", "PlayerItemConsumeEvent", 0)
	plugin.registerEvent(abilityData, "MW003-removeEffect", "EntityPotionEffectEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW003-panelty" then panelty(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW003-removeEffect" then removeEffect(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW003-cowBlindness") == nil then player:setVariable("MW003-cowBlindness", 0) end
	local count = player:getVariable("MW003-cowBlindness")
	if count > 0 then count = count - 2 end
	player:setVariable("MW003-cowBlindness", count)
end

function panelty(LAPlayer, event, ability, id)
	if event:getItem():getType():toString() == "COOKED_BEEF" or event:getItem():getType():toString() == "BEEF" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
			game.getPlayer(event:getPlayer()):setVariable("MW003-cowBlindness", 100)
			event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 100, 0}))
		end
	end
end

function removeEffect(LAPlayer, event, ability, id)
	if event:getAction():toString() ~= "CLEARED" and event:getAction():toString() ~= "REMOVED" and event:getEntity():getType():toString() == "PLAYER" then 
		if isBadEffect(event:getNewEffect(), game.getPlayer(event:getEntity())) then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
				event:setCancelled(true)
			end
		end
	end
end

function isBadEffect(targetEffect, player)
	if (targetEffect:getType() == effect.BLINDNESS) and player:getVariable("MW003-cowBlindness") ~= nil and player:getVariable("MW003-cowBlindness") < 1 then return true end
	if (targetEffect:getType() == effect.CONFUSION) then return true end
	if (targetEffect:getType() == effect.HUNGER) then return true end
	if (targetEffect:getType() == effect.LEVITATION) then return true end
	if (targetEffect:getType() == effect.POISON) then return true end
	if (targetEffect:getType() == effect.SLOW) then return true end
	if (targetEffect:getType() == effect.SLOW_DIGGING) then return true end
	if (targetEffect:getType() == effect.UNLUCK) then return true end
	if (targetEffect:getType() == effect.WEAKNESS) then return true end
	if (targetEffect:getType() == effect.WITHER) then return true end
	return false
end