local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW001-panelty", "PlayerItemConsumeEvent", 0)
	plugin.registerEvent(abilityData, "MW001-speed", "PlayerInteractEvent", 1200)
	plugin.registerEvent(abilityData, "MW001-changeAbility", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW001-panelty" then panelty(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW001-speed" then speed(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW001-changeAbility" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then changeAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function panelty(LAPlayer, event, ability, id)
	if event:getItem():getType():toString() == "COOKED_PORKCHOP" or event:getItem():getType():toString() == "PORKCHOP" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
			event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 100, 0}))
		end
	end
end

function speed(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "CARROT_ON_A_STICK") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SPEED, 800, 0}))
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").COMPOSTER, event:getPlayer():getLocation():add(0,1,0), 100, 0.5, 0.5, 0.5, 0.2)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_PIG_AMBIENT, 0.25, 1)
				end
			end
		end
	end
end

function changeAbility(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "LIGHTNING" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			util.runLater(function() game.changeAbility(game.getPlayer(event:getEntity()), ability, "LA-MW-014", false) end, 1)
			event:getEntity():getWorld():spawnParticle(import("$.Particle").VILLAGER_ANGRY, event:getEntity():getLocation():add(0,1,0), 20, 0.5, 1, 0.5, 0.05)
			event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_ZOMBIFIED_PIGLIN_ANGRY, 1, 1)
		end
	end
end