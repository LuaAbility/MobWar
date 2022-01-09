local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW018-isDead", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MW018-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW018-isDead" then isDead(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW018-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[2], funcTable[4], funcTable[1]) end
end

function Reset(player, ability)
	player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):setBaseValue(player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getDefaultValue())
end

function cancelTarget(event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "SLIME" then
			if game.checkCooldown(game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function isDead(event, ability, id)
	if event:getEntity():getType():toString() == "PLAYER" then
		if event:getEntity():getHealth() - event:getDamage() <= 0 then
			local maxHealth = event:getEntity():getAttribute(attribute.GENERIC_MAX_HEALTH)
			if maxHealth:getValue() < 2.0 then
				maxHealth:setBaseValue(20)
				game.sendMessage(event:getEntity(), "§2[§a슬라임§2] §a원래 체력으로 돌아갑니다.")
				event:getEntity():getWorld():spawnParticle(import("$.Particle").SLIME, event:getEntity():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
				event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_SLIME_DEATH_SMALL, 0.5, 1)
			else
				if game.checkCooldown(game.getPlayer(event:getEntity()), ability, id) then
					event:getEntity():setHealth(maxHealth:getValue() / 2.0)
					maxHealth:setBaseValue(maxHealth:getValue() / 2.0)
					game.sendMessage(event:getEntity(), "§2[§a슬라임§2] §a부활했습니다. 최대 체력이 " .. maxHealth:getValue() / 2.0 .. "칸이 됩니다.")
					event:setCancelled(true)
					event:getEntity():getWorld():spawnParticle(import("$.Particle").SLIME, event:getEntity():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
					event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_SLIME_SQUISH, 0.5, 1)
				end
			end
		end
	end
end