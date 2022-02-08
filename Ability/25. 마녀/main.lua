local effect = import("$.potion.PotionEffectType")
local attribute = import("$.attribute.Attribute")
	
function Init(abilityData)
	plugin.registerEvent(abilityData, "MW025-heal", "PlayerInteractEvent", 1800)
	plugin.registerEvent(abilityData, "MW025-harm", "EntityDamageEvent", 500)
	plugin.registerEvent(abilityData, "MW025-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW025-heal" then heal(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW025-harm" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then harm(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW025-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "WITCH" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function heal(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		local arrow = {newInstance("$.inventory.ItemStack", { import("$.Material").ARROW, 1 }) }
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "GLASS_BOTTLE") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					local maxHealth = event:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getValue()
					if (event:getPlayer():getHealth() + 8 >= maxHealth) then event:getPlayer():setHealth(maxHealth)
					else event:getPlayer():setHealth(event:getPlayer():getHealth() + 8) end
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").HEART, event:getPlayer():getEyeLocation(), 10, 0.5, 1, 0.5, 0.05)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_WITCH_DRINK, 0.25, 1)
				end
			end
		end
	end
end

function harm(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		local item = { event:getDamager():getInventory():getItemInMainHand() }
		if game.isAbilityItem(item[1], "GLASS_BOTTLE") then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
				local randomData = util.random(3)
				if randomData == 1 then event:getEntity():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SLOW, 300, 0})) end
				if randomData == 2 then event:getEntity():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.POISON, 300, 0})) end
				if randomData == 3 then event:getEntity():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.WEAKNESS, 300, 0})) end
				event:getEntity():getWorld():spawnParticle(import("$.Particle").SPELL_WITCH, event:getEntity():getEyeLocation(), 150, 0.5, 1, 0.5, 0.05)
				event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_WITCH_CELEBRATE, 0.25, 1)
			end
		end
	end
end