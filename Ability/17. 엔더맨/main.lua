function Init(abilityData)
	plugin.registerEvent(abilityData, "MW017-teleport", "PlayerInteractEvent", 600)
	plugin.registerEvent(abilityData, "MW017-cancelArrow", "EntityDamageEvent", 200)
	plugin.registerEvent(abilityData, "MW017-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW017-teleport" then teleportAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW017-cancelArrow" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then cancelArrow(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW017-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW017-passiveCount") == nil then player:setVariable("MW017-passiveCount", 0) end
	local count = player:getVariable("MW017-passiveCount")
	if count >= 20 then 
		count = 0
		addDamage(player)
	end
	count = count + 2
	player:setVariable("MW017-passiveCount", count)
end

function addDamage(player)
	if player:getPlayer():getLocation():getBlock():getType():toString() == "WATER" or player:getPlayer():getLocation():getBlock():getType():toString() == "WATER_CAULDRON" then
		player:getPlayer():damage(1)
		player:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, player:getPlayer():getLocation():add(0,1,0), 50, 0.5, 1, 0.5, 0.05)
		player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").ENTITY_ENDERMAN_HURT, 0.25, 1)
	end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "ENDERMAN" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function teleportAbility(LAPlayer, event, ability, id)
		if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					if event:getPlayer():getTargetBlock(nil, 30):getType():toString() ~= "AIR" then
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").PORTAL, event:getPlayer():getLocation():add(0,1,0), 1000, 0.1, 0.1, 0.1)
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_ENDERMAN_TELEPORT, 0.5, 1)
						teleport(event:getPlayer(), event:getPlayer():getTargetBlock(nil, 30))
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").REVERSE_PORTAL, event:getPlayer():getLocation():add(0,1,0), 1000, 0.1, 0.1, 0.1)
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_ENDERMAN_TELEPORT, 0.5, 1)
					else game.sendMessage(event:getPlayer(), "§4[§c엔더맨§4] §c허공엔 사용이 불가능합니다.") ability:resetCooldown(id) end
				end
			end
		end
	end
end

function cancelArrow(LAPlayer, event, ability, id)
	if event:getCause():toString() == "PROJECTILE" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			event:setCancelled(true)
		end
	end
end

function teleport(player, block)
	local playerLoc = player:getLocation()
	local blockLoc = block:getLocation()
	
	local targetVec = newInstance("$.util.Vector", {blockLoc:getX(), blockLoc:getY(), blockLoc:getZ()})
	if checkMat(player:getWorld():getBlockAt(blockLoc:add(0, 1, 0)):getType()) or checkMat(player:getWorld():getBlockAt(blockLoc:add(0, 2, 0)):getType()) then
		targetVec:setY(blockLoc:getWorld():getHighestBlockYAt(blockLoc:getX(), blockLoc:getZ()))
	end
	
	local playerVec = newInstance("$.util.Vector", {playerLoc:getX(), playerLoc:getY(), playerLoc:getZ()})
	if playerVec:distance(targetVec) > 30.0 and not (playerVec:getY() - targetVec:getY() > 30.0 or playerVec:getY() - targetVec:getY() < -30.0) then
		local moreDirection = playerVec:distance(targetVec) - 30
		local playerEye = player:getEyeLocation():getDirection()
		playerEye = newInstance("$.util.Vector", {playerEye:getX() * moreDirection * -1, 0, playerEye:getZ() * moreDirection * -1})
		
		targetVec:setX(targetVec:getX() + playerEye:getX())
		targetVec:setZ(targetVec:getZ() + playerEye:getZ())
	end
	
	blockLoc:setX(targetVec:getX() + 0.5)
	blockLoc:setY(targetVec:getY() + 1.0)
	blockLoc:setZ(targetVec:getZ() + 0.5)
	blockLoc:setPitch(playerLoc:getPitch())
	blockLoc:setYaw(playerLoc:getYaw())
end

function checkMat(mat)
	local name = mat:toString()
	if string.find(name, "SIGN") 			~= nil 	then return false end
	if string.find(name, "CARPET") 			~= nil 	then return false end
	if string.find(name, "PRESSURE_PLATE") 	~= nil 	then return false end
	if string.find(name, "BUTTON") 			~= nil 	then return false end
	if string.find(name, "TULIP") 			~= nil 	then return false end
	if string.find(name, "SAPLING") 		~= nil 	then return false end
	if string.find(name, "FAN") 			~= nil 	then return false end
	if string.find(name, "CORAL") 			~= nil 	then return false end
	if string.find(name, "SIGN") 			~= nil 	then return false end
	if string.find(name, "RAIL") 			~= nil 	then return false end
	if string.find(name, "_AIR") 			~= nil 	then return false end
	if string.find(name, "FLOWER") 			~= nil 	then return false end
	if string.find(name, "SLAB") 			~= nil 	then return false end
	if string.find(name, "STAIRS") 			~= nil 	then return false end
	if string.find(name, "FUNGUS") 			~= nil 	then return false end
	if string.find(name, "ROOTS") 			~= nil 	then return false end
	if string.find(name, "VINE") 			~= nil 	then return false end
	if string.find(name, "TORCH") 			~= nil 	then return false end
	if string.find(name, "SKULL") 			~= nil 	then return false end
	if string.find(name, "HEAD") 			~= nil 	then return false end
	if string.find(name, "BANNER") 			~= nil 	then return false end
	if string.find(name, "LANTERN") 		~= nil 	then return false end
	if string.find(name, "AMETHYST") 		~= nil 	then return false end
	if string.find(name, "CANDLE") 			~= nil 	then return false end
	if string.find(name, "CAMPFIRE") 		~= nil 	then return false end
	if string.find(name, "WIRE") 			~= nil 	then return false end
	if string.find(name, "DAILYLIGHT") 		~= nil 	then return false end
	if string.find(name, "DOOR") 			~= nil 	then return false end
	if name == "COBWEB" 							then return false end
	if name == "REPEATER" 							then return false end
	if name == "COMPARATOR" 						then return false end
	if name == "STONECUTTER" 						then return false end
	if name == "SCAFFOLDING" 						then return false end
	if name == "GLOW_LICHEN" 						then return false end
	if name == "NETHER_SPROUTS" 					then return false end
	if name == "LILY_OF_THE_VALLEY" 				then return false end
	if name == "SEA_PICKLE" 						then return false end
	if name == "AIR" 								then return false end
	if name == "DIRT_PATH" 							then return false end
	if name == "WATER"								then return false end
	if name == "LAVA" 								then return false end
	if name == "TALL_GRASS" 						then return false end
	if name == "LARGE_FERN" 						then return false end
	if name == "GRASS" 								then return false end
	if name == "DEAD_BUSH" 							then return false end
	if name == "FERN" 								then return false end
	if name == "SEAGRASS" 							then return false end
	if name == "TALL_SEAGRASS" 						then return false end
	if name == "LILY_PAD" 							then return false end
	if name == "DANDELION" 							then return false end
	if name == "POPPY" 								then return false end
	if name == "BLUE_ORCHID" 						then return false end
	if name == "ALLIUM" 							then return false end
	if name == "AZURE_BLUET" 						then return false end
	if name == "OXEYE_DAISY" 						then return false end
	if name == "LILAC" 								then return false end
	if name == "PEONY" 								then return false end
	if name == "ROSE_BUSH" 							then return false end
	if name == "BROWN_MUSHROOM" 					then return false end
	if name == "RED_MUSHROOM" 						then return false end
	if name == "FIRE" 								then return false end
	if name == "WHEAT" 								then return false end
	if name == "LADDER" 							then return false end
	if name == "LEVER" 								then return false end
	if name == "SNOW" 								then return false end
	if name == "SUGAR_CANE" 						then return false end
	if name == "NETHER_WART" 						then return false end
	return true
end