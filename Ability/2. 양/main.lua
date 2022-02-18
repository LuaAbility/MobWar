local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW002-panelty", "PlayerItemConsumeEvent", 0)
	plugin.registerEvent(abilityData, "MW002-heal", "PlayerInteractEvent", 400)
end

function onEvent(funcTable)
	if funcTable[1] == "MW002-panelty" then panelty(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW002-heal" then heal(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function panelty(LAPlayer, event, ability, id)
	if event:getItem():getType():toString() == "COOKED_MUTTON" or event:getItem():getType():toString() == "MUTTON" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
			event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 100, 0}))
		end
	end
end

function heal(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "GRASS") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					event:setCancelled(true)
					event:getPlayer():setFoodLevel(event:getPlayer():getFoodLevel() + 4)
					if (event:getPlayer():getFoodLevel() >= 20) then event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.REGENERATION, 100, 2}))
					else event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.REGENERATION, 100, 1})) end
					local itemStack = { newInstance("$.inventory.ItemStack", {event:getMaterial(), 1}) }
					event:getPlayer():getInventory():removeItem(itemStack)
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").ITEM_CRACK, event:getPlayer():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05, newInstance("$.inventory.ItemStack", {import("$.Material").KELP}))
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_SHEEP_AMBIENT, 0.25, 1)
				end
			end
		end
	end
end