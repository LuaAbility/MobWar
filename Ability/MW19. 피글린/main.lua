local effect = import("$.potion.PotionEffectType")
local material = import("$.Material")
local color = import("$.Color")

function Init(abilityData)
	plugin.registerEvent(abilityData, "아이템 거래", "PlayerInteractEvent", 400)
	plugin.registerEvent(abilityData, "MW019-goldDamage", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MW019-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "아이템 거래" then giveItem(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW019-goldDamage" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then goldDamage(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW019-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PIGLIN" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function goldDamage(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" then
		local item = event:getDamager():getInventory():getItemInMainHand()
		if string.find(item:getType():toString(), "GOLD") then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
				event:setDamage(event:getDamage() * 1.5)
			end
		end
	end
end

function giveItem(LAPlayer, event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "GOLD_INGOT") then
				if game.checkCooldown(LAPlayer, game.getPlayer(event:getPlayer()), ability, id) then
					event:setCancelled(true)
					local itemStack = { newInstance("$.inventory.ItemStack", {event:getMaterial(), 1}) }
					event:getPlayer():getInventory():removeItem(itemStack)
					
					
					local randomNumber = util.random(100)
					if randomNumber <= 1 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.END_CRYSTAL, 1})
						event:getPlayer():getInventory():addItem( { itemStack } )
					elseif randomNumber <= 10 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.GOLDEN_SWORD, 1})
						local itemMeta = itemStack:getItemMeta()
						itemMeta:setUnbreakable(true)
						itemStack:setItemMeta(itemMeta)
						event:getPlayer():getInventory():addItem( { itemStack } )
					elseif randomNumber <= 20 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.DIAMOND, util.random(5)})
						event:getPlayer():getInventory():addItem( { itemStack } )
					elseif randomNumber <= 30 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.POTION, 1})
						local itemMeta = itemStack:getItemMeta()
						itemMeta:addCustomEffect(newInstance("$.potion.PotionEffect", {effect.FIRE_RESISTANCE, 6000, 0}, true))
						itemMeta:setDisplayName("§r§b화염 저항 포션")
						itemMeta:setColor(color.ORANGE)
						itemStack:setItemMeta(itemMeta)
						event:getPlayer():getInventory():addItem( { itemStack } )
					elseif randomNumber <= 50 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.ENDER_PEARL, util.random(5)})
						event:getPlayer():getInventory():addItem( { itemStack } )
					elseif randomNumber <= 70 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.ARROW, util.random(6, 12)})
						event:getPlayer():getInventory():addItem( { itemStack } )
					else
						local itemStack = newInstance("$.inventory.ItemStack", {material.IRON_INGOT, util.random(3, 15)})
						event:getPlayer():getInventory():addItem( { itemStack } )
					end
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL,getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05)
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_PIGLIN_CELEBRATE, 0.5, 1)
				end
			end
		end
	end
end