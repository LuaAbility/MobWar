local types = import("$.entity.EntityType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "친구 소환", "EntityDamageEvent", 1200)
	plugin.registerEvent(abilityData, "MW021-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "친구 소환" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then summonWolf(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW021-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "WOLF" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function Reset(player, ability)
	if player:getVariable("MW021-wolf") then
		for i = 1, #player:getVariable("MW021-wolf") do
			if player:getVariable("MW021-wolf")[i]:isValid() then player:getVariable("MW021-wolf")[i]:remove() end
		end
	end
end

function summonWolf(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		local item = event:getDamager():getInventory():getItemInMainHand()
		if game.isAbilityItem(item, "BONE") then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
				if game.targetPlayer(LAPlayer, game.getPlayer(event:getEntity())) then
					LAPlayer:setVariable("MW021-wolf", {})
					for i = 1, 3 do
						local entity = event:getDamager():getWorld():spawnEntity(event:getEntity():getLocation(), types.WOLF)
						entity:setTarget(event:getEntity())
						entity:setOwner(event:getDamager())
						
						table.insert(LAPlayer:getVariable("MW021-wolf"), entity)
						util.runLater(function()
							if entity:isValid() then entity:remove() end
						end, 600)
					end
					
					event:getEntity():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getEntity():getEyeLocation(), 150, 0.5, 1, 0.5, 0.05)
					event:getDamager():getWorld():playSound(event:getDamager():getLocation(), import("$.Sound").ENTITY_WOLF_HOWL, 1, 1)
				else
					ability:resetCooldown(id)
				end
			end
		end
	end
end