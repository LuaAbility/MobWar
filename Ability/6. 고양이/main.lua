local effect = import("$.potion.PotionEffectType")
local material = import("$.Material")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW006-getBedItem", "PlayerInteractEvent", 400)
end

function onEvent(funcTable)
	if funcTable[1] == "MW006-getBedItem" then getBedItem(funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	runAway(player)
end

function runAway(player)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if players[i] ~= player and players[i]:getPlayer():getWorld():getEnvironment() == player:getPlayer():getWorld():getEnvironment() then
			if player:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 10 then
				player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SPEED, 10, 1}))
			end
		end
	end
end

function getBedItem(event, ability, id)
	if event:getAction():toString() == "RIGHT_CLICK_AIR" or event:getAction():toString() == "RIGHT_CLICK_BLOCK" then
		if event:getItem() ~= nil then
			if game.isAbilityItem(event:getItem(), "BED") and event:getItem():toString() ~= "BEDROCK" then
				if game.checkCooldown(game.getPlayer(event:getPlayer()), ability, id) then
					event:setCancelled(true)
					
					local randomNumber = math.random(100)
					if randomNumber <= 1 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.ELYTRA, 1})
						event:getPlayer():getWorld():dropItemNaturally(event:getPlayer():getLocation(), itemStack)
					elseif randomNumber <= 10 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.ENDER_PEARL, math.random(10)})
						event:getPlayer():getWorld():dropItemNaturally(event:getPlayer():getLocation(), itemStack)
					elseif randomNumber <= 20 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.PHANTOM_MEMBRANE, math.random(5)})
						event:getPlayer():getWorld():dropItemNaturally(event:getPlayer():getLocation(), itemStack)
					elseif randomNumber <= 30 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.STRING, math.random(10)})
						event:getPlayer():getWorld():dropItemNaturally(event:getPlayer():getLocation(), itemStack)
					elseif randomNumber <= 50 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.WHITE_WOOL, math.random(5)})
						event:getPlayer():getWorld():dropItemNaturally(event:getPlayer():getLocation(), itemStack)
					elseif randomNumber <= 70 then
						local itemStack = newInstance("$.inventory.ItemStack", {material.RABBIT, math.random(5)})
						event:getPlayer():getWorld():dropItemNaturally(event:getPlayer():getLocation(), itemStack)
					else
						local itemStack = newInstance("$.inventory.ItemStack", {material.CHICKEN, math.random(3)})
						event:getPlayer():getWorld():dropItemNaturally(event:getPlayer():getLocation(), itemStack)
					end
					event:getPlayer():getWorld():spawnParticle(import("$.Particle").ITEM_CRACK, event:getPlayer():getLocation():add(0,1,0), 50, 0.5, 1, 0.5, 0.05, newInstance("$.inventory.ItemStack", {import("$.Material").WHITE_WOOL}))
					event:getPlayer():getWorld():playSound(event:getPlayer():getLocation(), import("$.Sound").ENTITY_CAT_AMBIENT, 0.25, 1)
				end
			end
		end
	end
end