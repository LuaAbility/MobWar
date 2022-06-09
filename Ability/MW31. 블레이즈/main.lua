function Init(abilityData)
	plugin.registerEvent(abilityData, "화염구 발사", "PlayerInteractEvent", 600)
	plugin.registerEvent(abilityData, "MW031-cancelDamage", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MW031-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "화염구 발사" then shootFireball(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW031-cancelDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then cancelDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW031-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function shootFireball(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					fireball(event)
					util.runLater(function() fireball(event) end, 6)
					util.runLater(function() fireball(event) end, 12)
				end
			end
		end
	end
end

function cancelDamage(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "SMALL_FIREBALL" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			event:setCancelled(true)
		end
	end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "BLAZE" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function fireball(e)
	local playerEye = e:getPlayer():getEyeLocation():getDirection()
	local pos = e:getPlayer():getLocation()
	pos:setX(pos:getX() + (playerEye:getX() * 1.5))
	pos:setY(pos:getY() + 1)
	pos:setZ(pos:getZ() + (playerEye:getZ() * 1.5))
	local fireball = e:getPlayer():getWorld():spawnEntity(pos, import("$.entity.EntityType").SMALL_FIREBALL)
	fireball:setShooter(e:getPlayer())
	fireball:setVelocity(fireball:getVelocity():multiply(4))
	e:getPlayer():getWorld():playSound(e:getPlayer():getLocation(), import("$.Sound").ENTITY_BLAZE_SHOOT, 0.25, 1)
	util.runLater(function() 
		if fireball:isValid() then fireball:remove() end
	end, 200)
end