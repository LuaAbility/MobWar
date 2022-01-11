local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW004-panelty", "PlayerItemConsumeEvent", 0)
	plugin.registerEvent(abilityData, "MW004-changeAbility", "PlayerInteractEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW004-panelty" then panelty(funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW004-changeAbility" then changeAbility(funcTable[2], funcTable[4], funcTable[1]) end
end

function panelty(event, ability, id)
	if event:getItem():getType():toString() == "COOKED_BEEF" or event:getItem():getType():toString() == "BEEF"  or event:getItem():getType():toString() == "MUSHROOM_STEW" then
		if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
			event:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.BLINDNESS, 100, 0}))
		end
	end
end

function changeAbility(event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "SHEARS") then
				if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
					util.runLater(function() game.changeAbility(game.getPlayer(event:getPlayer()), ability, "LA-MW-003", false) end, 1)
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").ITEM_CRACK, event:getPlayer():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05, newInstance("$.inventory.ItemStack", {import("$.Material").RED_MUSHROOM}))
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_MOOSHROOM_SHEAR, 0.25, 1)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_COW_AMBIENT, 0.25, 1)
				end
			end
		end
	end
end