function Init(abilityData)
	plugin.registerEvent(abilityData, "MW033-shareAbility", "EntityDamageEvent", 1800)
	plugin.registerEvent(abilityData, "MW033-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW033-shareAbility" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then shareAbility(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW033-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW033-passiveCount") == nil then player:setVariable("MW033-passiveCount", 0) end
	local count = player:getVariable("MW033-passiveCount")
	if count >= 200 then 
		count = 0
		passiveAbility(player)
	end
	count = count + 2
	player:setVariable("MW033-passiveCount", count)
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PHANTOM" then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function shareAbility(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "PLAYER" and event:getEntity():getType():toString() == "PLAYER" then
		local item = { event:getDamager():getInventory():getItemInMainHand() }
		if game.isAbilityItem(item[1], "IRON_INGOT") then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getDamager()), ability, id) then
				game.getPlayer(event:getDamager()):setVariable("MW033-targetPlayer", game.getPlayer(event:getEntity()))
				game.sendMessage(event:getEntity(), "§c팬텀에게 능력이 공유되었습니다. 1분 간 팬텀의 능력에 영향을 받습니다.")
				event:getEntity():getWorld():spawnParticle(import("$.Particle").REDSTONE, event:getEntity():getLocation():add(0,1,0), 150, 0.5, 1, 0.5, 0.05, newInstance("$.Particle$DustOptions", {import("$.Color").RED, 1}))
				event:getEntity():getWorld():playSound(event:getEntity():getLocation(), import("$.Sound").ENTITY_PHANTOM_BITE, 0.25, 1)
				
				util.runLater(function() 
					game.sendMessage(event:getEntity(), "§7팬텀의 능력 공유가 해제되었습니다.")
					game.getPlayer(event:getDamager()):removeVariable("MW033-targetPlayer")
				end, 1200)
			end
		end
	end
end

function passiveAbility(player)
	local targetPlayer = player:getVariable("MW033-targetPlayer")
	if targetPlayer ~= nil then 
		phantom(player:getPlayer(), targetPlayer:getPlayer())
		phantom(targetPlayer:getPlayer(), player:getPlayer()) 
	else phantom(player:getPlayer()) end
end

function phantom(p, damager)
	local attribute = import("$.attribute.Attribute")
	
	if util.random(10) <= 2 then
		local currentTime = p:getWorld():getTime() % 24000
		local newHealth = p:getHealth() + 4
		if newHealth > p:getAttribute(attribute.GENERIC_MAX_HEALTH):getValue() then newHealth = p:getAttribute(attribute.GENERIC_MAX_HEALTH):getValue() end
		
		if (currentTime < 13500 or currentTime > 23500) then 
			if damager ~= nil then p:damage(4, damager)
			else p:damage(4) end
			game.sendMessage(p, "§4[§c팬텀§4] §c낮의 영향으로 데미지를 입습니다.")
			p:getWorld():playSound(p:getLocation(), import("$.Sound").ENTITY_PHANTOM_HURT, 0.25, 1)
		else 
			p:setHealth(newHealth) 
			game.sendMessage(p, "§1[§b팬텀§1] §b밤의 영향으로 체력을 회복합니다.")
		end
	end
end


