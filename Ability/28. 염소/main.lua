function Init(abilityData)
	plugin.registerEvent(abilityData, "MW028-rush", "PlayerInteractEvent", 400)
	plugin.registerEvent(abilityData, "MW028-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW028-rush" then rush(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW028-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW028-abilityTime") == true then rushPassive(player) end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "GOAT" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function rush(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") and event:getPlayer():getLocation():getBlock():getRelative(import("$.block.BlockFace").DOWN):getType():toString() ~= "AIR" then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local vector = event:getPlayer():getEyeLocation():getDirection()
					vector:setX(vector:getX() * 6.0)
					vector:setY(0.15)
					vector:setZ(vector:getZ() * 6.0)
					event:getPlayer():setVelocity(vector)
					game.getPlayer(event:getPlayer()):setVariable("MW028-abilityTime", true)
					util.runLater(function() game.getPlayer(event:getPlayer()):setVariable("MW028-abilityTime", false) end, 12)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_GOAT_SCREAMING_PREPARE_RAM, 1, 1)
				end
			end
		end
	end
end

function rushPassive(player)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if players[i]:getPlayer() ~= player:getPlayer() then
			if player:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and
			(player:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 3) then
				local vector = player:getPlayer():getEyeLocation():getDirection()
				vector:setX(vector:getX() * 6.0)
				vector:setY(0.3)
				vector:setZ(vector:getZ() * 6.0)
				players[i]:getPlayer():setVelocity(vector)
				players[i]:getPlayer():damage(4, player:getPlayer())
				
				local vector = player:getPlayer():getEyeLocation():getDirection()
				vector:setX(vector:getX() * 0.75)
				vector:setZ(vector:getZ() * 0.75)
				player:getPlayer():setVelocity(vector)
				player:setVariable("MW028-abilityTime", "false")
				players[i]:getPlayer():getWorld():playSound(players[i]:getPlayer():getLocation(), import("$.Sound").ENTITY_GOAT_SCREAMING_RAM_IMPACT, 1, 1)
			end
		end
	end
	
	player:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, player:getPlayer():getLocation():add(0,1,0), 30, 0.5, 1, 0.5, 0.05)
end