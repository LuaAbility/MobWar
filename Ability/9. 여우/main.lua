function Init(abilityData)
	plugin.registerEvent(abilityData, "MW009-steal", "EntityDamageEvent", 2000)
end

function onEvent(funcTable)
	if funcTable[1] == "MW009-steal" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then steal(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function steal(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		math.randomseed(os.time())
		local randomData = util.random(100)
		if randomData <= 15 then
			local item = { event:getEntity():getInventory():getItemInMainHand() }
			if item[1] ~= nil and item[1]:getType():toString() ~= "AIR" then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
					event:getEntity():getInventory():removeItem(item)
					event:getDamager():getInventory():addItem(item)
					game.sendMessage(event:getEntity(), "§a쇽!")
					event:getEntity():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getEntity():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
					event:getDamager():getWorld():spawnParticle(import("$.Particle").COMPOSTER, event:getDamager():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
					event:getDamager():getWorld():playSound(event:getDamager():getLocation(), import("$.Sound").ENTITY_FOX_BITE, 0.5, 1)
				end
			end
		end
	end
end