local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW005-panelty", "PlayerItemConsumeEvent", 0)
	plugin.registerEvent(abilityData, "MW005-removeDamage", "EntityDamageEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW005-panelty" then panelty(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW005-removeDamage" then removeDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function panelty(LAPlayer, event, ability, id)
	if event:getItem():getType():toString() == "COOKED_CHICKEN" or event:getItem():getType():toString() == "CHICKEN" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
			event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 100, 0}))
		end
	end
end

function removeDamage(LAPlayer, event, ability, id)
	if event:getCause():toString() == "FALL" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			event:setCancelled(true)
			event:getEntity():getWorld():spawnParticle(import("$.Particle").ITEM_CRACK, event:getEntity():getLocation():add(0,1,0), 50, 0.5, 1, 0.5, 0.05, newInstance("$.inventory.ItemStack", {import("$.Material").FEATHER}))
			event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_CHICKEN_AMBIENT, 0.25, 1)
		end
	end
end