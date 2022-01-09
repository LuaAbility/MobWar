local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW039-ability", "PlayerInteractEvent", 3000)
	plugin.registerEvent(abilityData, "MW039-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW039-ability" then ability(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW039-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW039-passiveCount") == nil then 
		player:setVariable("MW039-passiveCount", 0) 
		createBossbar(player)
	end
	updateBossbar(player)
end

function cancelTarget(event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and string.find(event:getEntity():getType():toString(), "WITHER") then
			if game.checkCooldown(game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function ability(event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
					for i = 1, 2 do
						local entity = event:getPlayer():getWorld():spawnEntity(event:getPlayer():getLocation(), import("$.entity.EntityType").WITHER_SKELETON)
						util.runLater(function()
							if entity:isValid() then entity:remove() end
						end, 600)
					end
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 500, 0.5, 1, 0.5)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_WITHER_SPAWN, 1, 1)
				end
			end
		end
	end
	
	if event:getAction():toString() == "LEFT_CLICK_AIR" or event:getAction():toString() == "LEFT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
					local players = util.getTableFromList(game.getPlayers())
					for i = 1, #players do
						if players[i]:getPlayer() ~= event:getPlayer() then
							if (event:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 10) then
								local pos = event:getPlayer():getEyeLocation()
								pos:setY(pos:getY() + 2)
								
								local dPos = newInstance("$.util.Vector", { players[i]:getPlayer():getLocation():getX() - pos:getX(), players[i]:getPlayer():getLocation():getY() - pos:getY() + 1, players[i]:getPlayer():getLocation():getZ() - pos:getZ() })
								local pitch = (math.atan2(math.sqrt(dPos:getZ() * dPos:getZ() + dPos:getX() * dPos:getX()), dPos:getY()))
								local yaw = (math.atan2(dPos:getZ(), dPos:getX()))
								
								pos:setDirection(newInstance("$.util.Vector", { math.sin(pitch) * math.cos(yaw), math.cos(pitch), math.sin(pitch) * math.sin(yaw) }))
								
								local skull = event:getPlayer():getWorld():spawnEntity(pos, import("$.entity.EntityType").WITHER_SKULL)
								skull:setShooter(event:getPlayer())
								util.runLater(function()
									if skull:isValid() then skull:remove() end
								end, 100)
							end
						end
					end
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 500, 0.5, 1, 0.5)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_WITHER_SHOOT, 1, 1)
				end
			end
		end
	end
end

function cancelEffect(event, ability, id)
	if (event:getDamager():getType():toString() == "DRAGON_FIREBALL" or event:getDamager():getType():toString() == "AREA_EFFECT_CLOUD") and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(game.getPlayer(event:getEntity()), ability, id) then
			event:setCancelled(true)
		end
	end
end

function createBossbar(player)
	player:setVariable("MW039-witherKey", player:getPlayer():getUniqueId():toString() .. "DRAGON")
	local witherKey = newInstance("$.NamespacedKey", {plugin.getPlugin(), player:getVariable("MW039-witherKey") })
	
	plugin.getServer():createBossBar(witherKey, player:getPlayer():getName() .. "(위더)", import("$.boss.BarColor").BLUE, import("$.boss.BarStyle").SEGMENTED_20, { } )
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		plugin.getServer():getBossBar(witherKey):addPlayer(players[i]:getPlayer())
	end
end

function updateBossbar(player)
	local witherKey = newInstance("$.NamespacedKey", {plugin.getPlugin(), player:getVariable("MW039-witherKey") })
	if plugin.getServer():getBossBar(witherKey) ~= nil then
		local health = player:getPlayer():getHealth() / player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getValue()
		if health > 1 then health = 1 end
		plugin.getServer():getBossBar(witherKey):setProgress(health)
	end
end

function removeBossbar(player)
	local witherKey = newInstance("$.NamespacedKey", {plugin.getPlugin(), player:getVariable("MW039-witherKey") })
	if plugin.getServer():getBossBar(witherKey) ~= nil then
		plugin.getServer():getBossBar(witherKey):setVisible(false)
	end
end

function Reset(player, ability)
	removeBossbar(player)
end


