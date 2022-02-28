local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW012-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW012-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW012-passiveCount") == nil then player:setVariable("MW012-passiveCount", 0) end
	local count = player:getVariable("MW012-passiveCount")
	if count >= 200 then 
		count = 0
		freeze(player)
	end
	count = count + 2
	player:setVariable("MW012-passiveCount", count)
end

function freeze(player)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if players[i] ~= player and game.targetPlayer(player, players[i], false) then
			if player:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and
			(player:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 10) then
				players[i]:getPlayer():setFreezeTicks(300)
			end
		end
	end
	player:getPlayer():getWorld():spawnParticle(import("$.Particle").SNOWFLAKE, player:getPlayer():getLocation():add(0,1,0), 500, 5, 1, 5, 0.05)
	player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").BLOCK_POWDER_SNOW_FALL, 0.5, 1)
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "SNOW_GOLEM" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end