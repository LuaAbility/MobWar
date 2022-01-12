local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW024-giveWither", "EntityDamageEvent", 400)
	plugin.registerEvent(abilityData, "MW024-giveArrow", "PlayerInteractEvent", 0)
	plugin.registerEvent(abilityData, "MW024-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW024-giveWither" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then giveWither(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW024-giveArrow" then giveArrow(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW024-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "SKELETON" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function giveWither(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		math.randomseed(os.time())
		if math.random(10) <= 2 then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
				event:getEntity():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.WITHER, 200, 0}))
				event:getEntity():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getEntity():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
				event:getDamager():getWorld():playSound(event:getDamager():getLocation(), import("$.Sound").ENTITY_WITHER_SKELETON_AMBIENT, 0.25, 1)
			end
		end
	end
end

function giveArrow(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		local arrow = {newInstance("$.inventory.ItemStack", { import("$.Material").ARROW, 1 }) }
		if event:getItem() ~= nil then
			if event:getItem():getType():toString() == "BOW" and event:getPlayer():getInventory():containsAtLeast(arrow[1], 1) == false then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					event:getPlayer():getInventory():addItem(arrow)
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, event:getPlayer():getLocation():add(0,1,0), 100, 0.5, 1, 0.5)
				end
			end
		end
	end
end