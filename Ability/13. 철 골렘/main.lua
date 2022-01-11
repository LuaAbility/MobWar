local effect = import("$.potion.PotionEffectType")
local attribute = import("$.attribute.Attribute")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW013-throw", "EntityDamageEvent", 300)
	plugin.registerEvent(abilityData, "MW013-cancelTarget", "EntityTargetEvent", 0)
	plugin.registerEvent(abilityData, "MW013-heal", "PlayerInteractEvent", 600)
end

function onEvent(funcTable)
	if funcTable[1] == "MW013-throw" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then throw(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW013-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW013-heal" then heal(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function throw(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		if math.random() <= 0.2 then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
				event:getEntity():damage(event:getDamage(), event:getDamager())
				event:setCancelled(true)
				local vector = event:getDamager():getEyeLocation():getDirection()
				vector:setX(vector:getX() / 4)
				vector:setY(1.2)
				vector:setZ(vector:getZ() / 4)
				event:getEntity():setVelocity(vector)
				event:getEntity():getWorld():spawnParticle(import("$.Particle").ITEM_CRACK, event:getEntity():getLocation():add(0,1,0), 50, 0.5, 1, 0.5, 0.05, newInstance("$.inventory.ItemStack", {import("$.Material").IRON_BLOCK}))
				event:getDamager():getWorld():spawnParticle(import("$.Particle").ITEM_CRACK, event:getEntity():getLocation():add(0,1,0), 50, 0.5, 1, 0.5, 0.05, newInstance("$.inventory.ItemStack", {import("$.Material").IRON_BLOCK}))
				event:getDamager():getWorld():playSound(event:getDamager():getLocation(), import("$.Sound").ENTITY_IRON_GOLEM_ATTACK, 0.5, 1)

			end
		end
	end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "IRON_GOLEM" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function heal(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "IRON_INGOT") then
				local maxHealth = event:getPlayer():getAttribute(attribute.GENERIC_MAX_HEALTH):getValue()
				if event:getPlayer():getHealth() < maxHealth then
					if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
						event:setCancelled(true)
						local newHealth = event:getPlayer():getHealth() + 4
						if newHealth > maxHealth then newHealth = maxHealth end
						event:getPlayer():setHealth(newHealth)
						local itemStack = { newInstance("$.inventory.ItemStack", {event:getMaterial(), 1}) }
						event:getPlayer():getInventory():removeItem(itemStack)
						event:getPlayer():getWorld():spawnParticle(import("$.Particle").COMPOSTER, event:getPlayer():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
						event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_IRON_GOLEM_REPAIR, 0.5, 1)
					end
				end
			end
		end
	end
end