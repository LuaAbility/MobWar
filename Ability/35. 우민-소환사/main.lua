function Init(abilityData)
	plugin.registerEvent(abilityData, "MW035-shootFang", "PlayerInteractEvent", 500)
	plugin.registerEvent(abilityData, "MW035-cancelDamage", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MW035-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW035-shootFang" then shootFang(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW035-cancelDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then cancelDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW035-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function shootFang(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					evoker(event:getPlayer())
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_EVOKER_CAST_SPELL, 1, 1)
				end
			end
		end
	end
end

function cancelDamage(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "EVOKER_FANGS" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			event:setCancelled(true)
		end
	end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "EVOKER" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end


function evoker(player)
	local firstLoc = newInstance("org.bukkit.util.Vector", {player:getLocation():getX(), player:getLocation():getY(), player:getLocation():getZ()})
	local dir = player:getLocation():getDirection()
	
	for i = 1, 20 do
		util.runLater(function()
			local loc1 = newInstance("org.bukkit.util.Vector", {firstLoc:getX() + (dir:getX() * i), firstLoc:getY(), firstLoc:getZ() + (dir:getZ() * i)})
			local fangs1 = player:getWorld():spawnEntity(newInstance("org.bukkit.Location", {player:getWorld(), loc1:getX(), loc1:getY(), loc1:getZ()}), import("$.entity.EntityType").EVOKER_FANGS)
			fangs1:setOwner(player)
			
			local loc2 = newInstance("org.bukkit.util.Vector", {loc1:getX() + -dir:getZ(), loc1:getY(), loc1:getZ() + dir:getX()})
			local fangs2 = player:getWorld():spawnEntity(newInstance("org.bukkit.Location", {player:getWorld(), loc2:getX(), loc2:getY(), loc2:getZ()}), import("$.entity.EntityType").EVOKER_FANGS)
			fangs2:setOwner(player)
			
			local loc3 = newInstance("org.bukkit.util.Vector", {loc1:getX() + dir:getZ(), loc1:getY(), loc1:getZ() + -dir:getX()})
			local fangs3 = player:getWorld():spawnEntity(newInstance("org.bukkit.Location", {player:getWorld(), loc3:getX(), loc3:getY(), loc3:getZ()}), import("$.entity.EntityType").EVOKER_FANGS)
			fangs3:setOwner(player)
		end, (i - 1) * 1)
	end
end


