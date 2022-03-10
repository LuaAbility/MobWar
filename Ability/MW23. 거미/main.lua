local blockFace = import("$.block.BlockFace")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW023-climb", "PlayerMoveEvent", 0)
	plugin.registerEvent(abilityData, "MW023-enable", "PlayerInteractEvent", 0)
	plugin.registerEvent(abilityData, "MW023-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW023-climb" then climb(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW023-enable" then enable(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW023-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "SPIDER" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function climb(LAPlayer, event, ability, id)
	local face = nil
	
	local targetLoc = event:getPlayer():getLocation()
	targetLoc:setY(math.floor(targetLoc:getY() + 0.5))
	local dir = targetLoc:getYaw()
	
	if dir >= -135 and dir <= -45 then face = blockFace.EAST
	elseif dir >= -45 and dir <= 45 then face = blockFace.SOUTH
	elseif dir >= 45 and dir <= 135 then face = blockFace.WEST
	else face = blockFace.NORTH end
	
	local block = checkMat(event:getPlayer():getLocation():getBlock():getRelative(face):getType())
	local up = checkMat(event:getPlayer():getLocation():add(0, 2, 0):getBlock():getType())
	
	if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
		if block and not up and game.getPlayer(event:getPlayer()):getVariable("MW023-useSpiderAbility") == true then
			local velocity = event:getPlayer():getVelocity()
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

function enable(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
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