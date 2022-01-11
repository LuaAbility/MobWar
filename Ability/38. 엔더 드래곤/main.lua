local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW038-ability", "PlayerInteractEvent", 4000)
	plugin.registerEvent(abilityData, "MW038-cancelEffect", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW038-ability" then ability(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW038-cancelEffect" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then cancelEffect(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW038-passiveCount") == nil then 
		player:setVariable("MW038-passiveCount", 0) 
		createBossbar(player)
	end
	updateBossbar(player)
end

function ability(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local players = util.getTableFromList(game.getPlayers())
					for i = 1, #players do
						if players[i]:getPlayer() ~= event:getPlayer() then
							if (event:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 5) then
								players[i]:getPlayer():damage(7, event:getPlayer())
								local velocity = event:getPlayer():getLocation()
								local dPos = newInstance("$.util.Vector", { velocity:getX() - players[i]:getPlayer():getLocation():getX(), velocity:getY() - players[i]:getPlayer():getLocation():getY(), velocity:getZ() - players[i]:getPlayer():getLocation():getZ() })
								local pitch = (math.atan2(math.sqrt(dPos:getZ() * dPos:getZ() + dPos:getX() * dPos:getX()), dPos:getY()))
								local yaw = (math.atan2(dPos:getZ(), dPos:getX()))
								
								velocity = newInstance("$.util.Vector", { math.sin(pitch) * math.cos(yaw), math.cos(pitch), math.sin(pitch) * math.sin(yaw) })
								velocity:setX(velocity:getX() * -10)
								velocity:setY(1.5)
								velocity:setZ(velocity:getZ() * -10)
								
								players[i]:getPlayer():setVelocity(velocity)
							end
						end
					end
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 500, 0.5, 1, 0.5)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_ENDER_DRAGON_GROWL, 1, 1)
				end
			end
		end
	end
	
	if event:getAction():toString() == "LEFT_CLICK_AIR" or event:getAction():toString() == "LEFT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local playerEye = event:getPlayer():getEyeLocation():getDirection()
					local pos = event:getPlayer():getLocation()
					pos:setX(pos:getX() + (playerEye:getX() * 1.5))
					pos:setY(pos:getY() + 1)
					pos:setZ(pos:getZ() + (playerEye:getZ() * 1.5))
					local fireball = event:getPlayer():getWorld():spawnEntity(pos, import("$.entity.EntityType").DRAGON_FIREBALL)
					fireball:setShooter(event:getPlayer())
					util.runLater(function()
						if fireball:isValid() then fireball:remove() end
					end, 100)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_ENDER_DRAGON_SHOOT, 1, 1)
				end
			end
		end
	end
end

function cancelEffect(LAPlayer, event, ability, id)
	if (event:getDamager():getType():toString() == "DRAGON_FIREBALL" or event:getDamager():getType():toString() == "AREA_EFFECT_CLOUD") and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			event:setCancelled(true)
		end
	end
end

function createBossbar(player)
	player:setVariable("MW038-dragonKey", player:getPlayer():getUniqueId():toString() .. "DRAGON")
	local dragonKey = newInstance("$.NamespacedKey", {plugin.getPlugin(), player:getVariable("MW038-dragonKey") })
	
	plugin.getServer():createBossBar(dragonKey, player:getPlayer():getName() .. "(엔더 드래곤)", import("$.boss.BarColor").PURPLE, import("$.boss.BarStyle").SEGMENTED_20, { } )
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		plugin.getServer():getBossBar(dragonKey):addPlayer(players[i]:getPlayer())
	end
end

function updateBossbar(player)
	local dragonKey = newInstance("$.NamespacedKey", {plugin.getPlugin(), player:getVariable("MW038-dragonKey") })
	if plugin.getServer():getBossBar(dragonKey) ~= nil then
		local health = player:getPlayer():getHealth() / player:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getValue()
		if health > 1 then health = 1 end
		plugin.getServer():getBossBar(dragonKey):setProgress(health)
	end
end

function removeBossbar(player)
	local dragonKey = newInstance("$.NamespacedKey", {plugin.getPlugin(), player:getVariable("MW038-dragonKey") })
	if plugin.getServer():getBossBar(dragonKey) ~= nil then
		plugin.getServer():getBossBar(dragonKey):setVisible(false)
	end
end

function Reset(player, ability)
	removeBossbar(player)
end


