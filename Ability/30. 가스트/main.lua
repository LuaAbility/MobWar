function Init(abilityData)
	plugin.registerEvent(abilityData, "MW030-shootFireball", "PlayerInteractEvent", 400)
	plugin.registerEvent(abilityData, "MW030-instantDeath", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MW030-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW030-shootFireball" then shootFireball(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW030-instantDeath" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then instantDeath(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW030-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[2], funcTable[4], funcTable[1]) end
end

function shootFireball(event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
					local playerEye = event:getPlayer():getEyeLocation():getDirection()
					local pos = event:getPlayer():getLocation()
					pos:setX(pos:getX() + (playerEye:getX() * 1.5))
					pos:setY(pos:getY() + 1)
					pos:setZ(pos:getZ() + (playerEye:getZ() * 1.5))
					local fireball = event:getPlayer():getWorld():spawnEntity(pos, import("$.entity.EntityType").FIREBALL)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_GHAST_SHOOT, 0.25, 1)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_GHAST_WARN, 0.5, 1)
					fireball:setShooter(event:getPlayer())
					util.runLater(function()
						if fireball:isValid() then fireball:remove() end
					end, 200)
				end
			end
		end
	end
end

function instantDeath(event, ability, id)
	if event:getDamager():getType():toString() == "FIREBALL" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(game.getPlayer(event:getEntity()), ability, id) then
			event:setDamage(100000)
			event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_GHAST_DEATH, 1, 1)
			event:getEntity():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getEntity():getLocation():add(0,1,0), 200, 0.5, 1, 0.5)
		end
	end
end

function cancelTarget(event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "GHAST" then
			if game.checkCooldown(game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end