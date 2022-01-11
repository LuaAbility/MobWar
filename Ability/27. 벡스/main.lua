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

function fly(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_SWORD") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					event:getPlayer():setAllowFlight(true)
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_VEX_CHARGE, 0.25, 1)
					
					if game.getPlayer(event:getPlayer()):getVariable("MW027-taskIDList") == nil then 
						local tempTable = {}
						game.getPlayer(event:getPlayer()):setVariable("MW027-taskIDList", tempTable)
					end
					
					local taskID = util.runLater(function()
						local down = event:getPlayer():getLocation():getBlock():getRelative(import("$.block.BlockFace").DOWN):getType()
						local moreDown = event:getPlayer():getLocation():getBlock():getRelative(import("$.block.BlockFace").DOWN):getRelative(import("$.block.BlockFace").DOWN):getType()
						event:getPlayer():setAllowFlight(false)
						event:getPlayer():setFlying(false)
						game.sendMessage(event:getPlayer(), "§2[§a벡스§2] §a능력 시전 시간이 종료되었습니다.")
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_VEX_AMBIENT, 0.25, 1)
						
						if down:toString() == "AIR" and moreDown:toString() == "AIR" then 
							game.getPlayer(event:getPlayer()):setVariable("MW027-firstFallDamage", true) 
							local damageID = util.runLater(function() 
								game.getPlayer(event:getPlayer()):setVariable("MW027-firstFallDamage", false) 
								table.remove(game.getPlayer(event:getPlayer()):getVariable("MW027-taskIDList"), damageID)
							end, 200)
							table.insert(game.getPlayer(event:getPlayer()):getVariable("MW027-taskIDList"), damageID)
						end
						table.remove(game.getPlayer(event:getPlayer()):getVariable("MW027-taskIDList"), taskID)
					end, 600)
					table.insert(game.getPlayer(event:getPlayer()):getVariable("MW027-taskIDList"), taskID)
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

function Reset(player, ability)
	local IDTable = player:getVariable("MW027-taskIDList")
	if IDTable ~= nil then for i = 1, #IDTable do util.cancelRunLater(IDTable[i]) end end
	
	player:getPlayer():setAllowFlight(false)
	player:getPlayer():setFlying(false)
end