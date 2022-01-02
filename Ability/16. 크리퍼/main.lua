function main(abilityData)
	local effect = import("$.potion.PotionEffectType")
	local cause = import("$.event.entity.EntityDamageEvent")
	
	plugin.addPassiveScript(abilityData, 0, function(p)
		game.getPlayer(p):addVariable("MW016-lightningStack", "1")
	end)
	
	plugin.registerEvent(abilityData, "PlayerInteractEvent", 1200, function(a, e)
		if e:getAction():toString() == "RIGHT_CLICK_AIR" or e:getAction():toString() == "RIGHT_CLICK_BLOCK" then
			if e:getItem() ~= nil then
				if game.isAbilityItem(e:getItem(), "GUNPOWDER") then
					if game.checkCooldown(e:getPlayer(), a, 0) then
						game.getPlayer(e:getPlayer()):setVariable("MW016-playerName", e:getPlayer():getName())
						e:getPlayer():getLocation():getWorld():createExplosion(e:getPlayer():getLocation(), 10.0 * tonumber(game.getPlayer(e:getPlayer()):getVariable("MW016-lightningStack")))
						local itemStack = { newInstance("$.inventory.ItemStack", {e:getMaterial(), 1}) }
						e:getPlayer():getInventory():removeItem(itemStack)
						e:getPlayer():getWorld():spawnParticle(import("$.Particle").EXPLOSION_HUGE, e:getPlayer():getLocation():add(0,1,0), 10, 4, 1, 4, 0.05)
					end
				end
			end
		end
	end)
	
	plugin.registerEvent(abilityData, "EntityDamageByBlockEvent", 0, function(a, e)
		if e:getCause() == cause.DamageCause.BLOCK_EXPLOSION then
			if e:getEntity():getType():toString() == "PLAYER" then
				if game.checkCooldown(e:getEntity(), a, 1) then
					if e:getEntity():getName() == game.getPlayer(e:getEntity()):getVariable("MW016-playerName") then
						game.getPlayer(e:getEntity()):removeVariable("MW016-playerName")
						e:setCancelled(true)
					end
				end
			end
		end
	end)
	
	
	plugin.registerEvent(abilityData, "EntityDamageByEntityEvent", 100, function(a, e)
		if e:getDamager():getType():toString() == "LIGHTNING" and e:getEntity():getType():toString() == "PLAYER" then
			if game.checkCooldown(e:getEntity(), a, 2) then
				local lightningStack = tonumber(game.getPlayer(e:getEntity()):getVariable("MW016-lightningStack")) + 0.5
				
				if lightningStack > 3 then 
					lightningStack = 3
				else 
					game.sendMessage(e:getEntity(), "§2[§a크리퍼§2] §a폭발 강도가 강해졌습니다.")
					game.sendMessage(e:getEntity(), "§2[§a크리퍼§2] §a현재 폭발 강도 : " .. lightningStack)
					e:getEntity():getWorld():spawnParticle(import("$.Particle").SMOKE_LARGE, e:getEntity():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
					e:getEntity():getWorld():playSound(e:getEntity():getLocation(), import("$.Sound").ENTITY_CREEPER_HURT, 0.5, 1)
				end
				
				game.getPlayer(e:getEntity()):setVariable("MW016-lightningStack", tostring(lightningStack))
			end
		end
	end)
	
		
	plugin.registerEvent(abilityData, "EntityTargetLivingEntityEvent", 0, function(a, e)
		if e:getTarget() ~= nil and e:getEntity() ~= nil then
			if e:getTarget():getType():toString() == "PLAYER" and e:getEntity():getType():toString() == "CREEPER" then
				if game.checkCooldown(e:getTarget(), a, 3) then
					e:setTarget(nil)
					e:setCancelled(true)
				end
			end
		end
	end)
end