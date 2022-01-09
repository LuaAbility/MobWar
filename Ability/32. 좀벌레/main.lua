function Init(abilityData)
	plugin.registerEvent(abilityData, "MW031-summonSilverFish", "BlockBreakEvent", 300)
	plugin.registerEvent(abilityData, "MW031-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW031-summonSilverFish" then summonSilverFish(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW031-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[2], funcTable[4], funcTable[1]) end
end

function summonSilverFish(player, event, ability, id)
	local players = util.getTableFromList(game.getPlayers())
	
	if event:getPlayer() ~= player:getPlayer() then
		if (player:getPlayer():getLocation():distance(event:getPlayer():getLocation()) <= 25) then
			if math.random(3) == 1 then
				if game.checkCooldown(player, ability, id) then
					for i = 1, 4 do
						local loc = event:getBlock():getLocation()
						loc:setX(loc:getX() + 0.5)
						loc:setZ(loc:getZ() + 0.5)
						local silverfish = event:getPlayer():getWorld():spawnEntity(loc, import("$.entity.EntityType").SILVERFISH)
						silverfish:setTarget(event:getPlayer())
						
						util.runLater(function() 
							if silverfish:isValid() then silverfish:remove() end
						end, 600)
					end
					game.sendMessage(event:getPlayer(), "§7좀벌레가 나타났습니다.")
				end
			end
		end
	end
end

function cancelTarget(event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "SILVERFISH" then
			if game.checkCooldown(game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end