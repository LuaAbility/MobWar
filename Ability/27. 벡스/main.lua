function Init(abilityData)
	plugin.registerEvent(abilityData, "MW027-fly", "PlayerInteractEvent", 1600)
	plugin.registerEvent(abilityData, "MW027-cancelFallDamage", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MW027-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW027-fly" then fly(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW027-cancelFallDamage" then cancelFallDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW027-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW027-useAbility") == nil then 
		player:setVariable("MW027-useAbility", 0)
	end
	
	local count = player:getVariable("MW027-useAbility")
	if count > 0 then 
		seeCheck(player) 
		count = count - 2
		if count <= 0 then unlockAbility(player) end
	end
	player:setVariable("MW027-useAbility", count)
end

function Reset(player, ability)
	if player:getVariable("MW027-useAbility") > 0 then unlockAbility(player) end
end

function unlockAbility(player)
	local down = player:getPlayer():getLocation():getBlock():getRelative(import("$.block.BlockFace").DOWN):getType()
	local moreDown = player:getPlayer():getLocation():getBlock():getRelative(import("$.block.BlockFace").DOWN):getRelative(import("$.block.BlockFace").DOWN):getType()
	player:getPlayer():setAllowFlight(false)
	player:getPlayer():setFlying(false)
	game.sendMessage(player:getPlayer(), "§2[§a벡스§2] §a능력 시전 시간이 종료되었습니다.")
	player:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, player:getPlayer():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
	player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").ENTITY_VEX_AMBIENT, 0.25, 1)
	
	if down:toString() == "AIR" and moreDown:toString() == "AIR" then game.getPlayer(player:getPlayer()):setVariable("MW027-firstFallDamage", true) end
end
function fly(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_SWORD") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					event:getPlayer():setAllowFlight(true)
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_VEX_CHARGE, 0.25, 1)
					
					player:setVariable("MW027-useAbility", 600)
				end
			end
		end
	end
end

function cancelFallDamage(LAPlayer, event, ability, id)
	if event:getCause():toString() == "FALL" and event:getEntity():getType():toString() == "PLAYER" and game.getPlayer(event:getEntity()):getVariable("MW027-firstFallDamage") == true then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			event:setCancelled(true)
			game.getPlayer(event:getEntity()):setVariable("MW027-firstFallDamage", false)
		end
	end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "VEX" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end