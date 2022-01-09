local blockFace = import("$.block.BlockFace")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW023-climb", "PlayerMoveEvent", 0)
	plugin.registerEvent(abilityData, "MW023-enable", "PlayerInteractEvent", 0)
	plugin.registerEvent(abilityData, "MW023-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW023-climb" then climb(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW023-enable" then enable(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW023-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[2], funcTable[4], funcTable[1]) end
end

function cancelTarget(event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "SPIDER" then
			if game.checkCooldown(game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function climb(event, ability, id)
	local north = event:getPlayer():getLocation():getBlock():getRelative(blockFace.NORTH):getType()
	local east = event:getPlayer():getLocation():getBlock():getRelative(blockFace.EAST):getType()
	local west = event:getPlayer():getLocation():getBlock():getRelative(blockFace.WEST):getType()
	local south = event:getPlayer():getLocation():getBlock():getRelative(blockFace.SOUTH):getType()
	local up = event:getPlayer():getLocation():getBlock():getRelative(blockFace.UP):getRelative(blockFace.UP):getType()

	if (north:toString() ~= "AIR" or east:toString() ~= "AIR" or west:toString() ~= "AIR" or south:toString() ~= "AIR") and up:toString() == "AIR" and game.getPlayer(event:getPlayer()):getVariable("MW023-useSpiderAbility") == true then
		local velocity = event:getPlayer():getVelocity()
		if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
			if event:getPlayer():isSneaking() then
				velocity:setY(-0.25)
				event:getPlayer():setVelocity(velocity)
				event:getPlayer():setFallDistance(0)
			else
				velocity:setY(0.25)
				event:getPlayer():setVelocity(velocity)
			end
		end
	end
end

function enable(event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
					if game.getPlayer(event:getPlayer()):getVariable("MW023-useSpiderAbility") == true then
						game.getPlayer(event:getPlayer()):setVariable("MW023-useSpiderAbility", false)
						game.sendMessage(event:getPlayer(), "§2[§a거미§2] §a능력을 비활성화했습니다.")
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_SPIDER_DEATH, 0.25, 1)
					else
						game.getPlayer(event:getPlayer()):setVariable("MW023-useSpiderAbility", true)
						game.sendMessage(event:getPlayer(), "§2[§a거미§2] §a능력을 활성화했습니다.")
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_SPIDER_AMBIENT, 0.25, 1)
					end
				end
			end
		end
	end
end