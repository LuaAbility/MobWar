local effect = import("$.potion.PotionEffectType")
local cause = import("$.event.entity.EntityDamageEvent")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW016-boom", "PlayerInteractEvent", 1200)
	plugin.registerEvent(abilityData, "MW016-cancelExpDamage", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MW016-increaseExp", "EntityDamageEvent", 100)
	plugin.registerEvent(abilityData, "MW016-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW016-boom" then boom(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW016-cancelExpDamage" and funcTable[2]:getEventName() == "EntityDamageByBlockEvent" then cancelExpDamage(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW016-increaseExp" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then increaseExp(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW016-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW016-lightningStack") == nil then player:setVariable("MW016-lightningStack", 1) end
end

function cancelTarget(event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "CREEPER" then
			if game.checkCooldown(game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function cancelExpDamage(event, ability, id)
	if event:getCause() == cause.DamageCause.BLOCK_EXPLOSION then
		if event:getEntity():getType():toString() == "PLAYER" then
			if game.checkCooldown(game.getPlayer(event:getEntity()), ability, id) then
				if event:getEntity():getName() == game.getPlayer(event:getEntity()):getVariable("MW016-playerName") then
					game.getPlayer(event:getEntity()):removeVariable("MW016-playerName")
					event:setCancelled(true)
				end
			end
		end
	end
end

function increaseExp(event, ability, id)
	if event:getDamager():getType():toString() == "LIGHTNING" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(game.getPlayer(event:getEntity()), ability, id, false) then
			local lightningStack = game.getPlayer(event:getEntity()):getVariable("MW016-lightningStack") + 0.5
			
			if lightningStack > 3 then 
				lightningStack = 3
			else 
				game.sendMessage(event:getEntity(), "§2[§a크리퍼§2] §a폭발 강도가 강해졌습니다.")
				game.sendMessage(event:getEntity(), "§2[§a크리퍼§2] §a현재 폭발 강도 : " .. lightningStack)
				event:getEntity():getWorld():spawnParticle(import("$.Particle").SMOKE_LARGE, event:getEntity():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
				event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_CREEPER_HURT, 0.5, 1)
			end
			
			game.getPlayer(event:getEntity()):setVariable("MW016-lightningStack", lightningStack)
		end
	end
end

function boom(event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "GUNPOWDER") then
				if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
					game.getPlayer(event:getPlayer()):setVariable("MW016-playerName", event:getPlayer():getName())
					event:getPlayer():getLocation():getWorld():createExplosion(event:getPlayer():getLocation(), 10.0 * game.getPlayer(event:getPlayer()):getVariable("MW016-lightningStack"))
					local itemStack = { newInstance("$.inventory.ItemStack", {event:getMaterial(), 1}) }
					event:getPlayer():getInventory():removeItem(itemStack)
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").EXPLOSION_HUGE, event:getPlayer():getLocation():add(0,1,0), 10, 4, 1, 4, 0.05)
				end
			end
		end
	end
end