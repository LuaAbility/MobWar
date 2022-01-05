function main(abilityData)
	local effect = import("$.potion.PotionEffectType")
	
	plugin.registerEvent(abilityData, "BlockBreakEvent", 300, function(a, e)
		local players = util.getTableFromList(game.getPlayers())
		local player = { }
		for i = 1, #players do
			if players[i]:hasAbility("LA-EX-013") then table.insert(player, players[i]) end
		end
		
		if #player > 0 then
			for i = 1, #player do
				if e:getPlayer() ~= player[i]:getPlayer() then
					if (player[i]:getPlayer():getLocation():distance(e:getPlayer():getLocation()) <= 25) then
						if math.random(3) == 1 then
							if game.checkCooldown(player[i]:getPlayer(), a, 0) then
								for i = 1, 4 do
									local loc = e:getBlock():getLocation()
									loc:setX(loc:getX() + 0.5)
									loc:setZ(loc:getZ() + 0.5)
									local silverfish = e:getPlayer():getWorld():spawnEntity(loc, import("$.entity.EntityType").SILVERFISH)
									silverfish:setTarget(e:getPlayer())
									
									util.runLater(function() 
										if silverfish:isValid() then silverfish:remove() end
									end, 600)
								end
								game.sendMessage(e:getPlayer(), "§7좀벌레가 나타났습니다.")
							end
						end
					end
				end
			end
		end
	end)
	
	plugin.registerEvent(abilityData, "EntityTargetLivingEntityEvent", 0, function(a, e)
		if e:getTarget() ~= nil and e:getEntity() ~= nil then
			if e:getTarget():getType():toString() == "PLAYER" and e:getEntity():getType():toString() == "SILVERFISH" then
				if game.checkCooldown(e:getTarget(), a, 1) then
					e:setTarget(nil)
					e:setCancelled(true)
				end
			end
		end
	end)
end