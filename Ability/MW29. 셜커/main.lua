local effect = import("$.potion.PotionEffectType")

function Init(abilityData)
	plugin.registerEvent(abilityData, "MW029-cancelBullet", "EntityDamageEvent", 0)
	plugin.registerEvent(abilityData, "MW029-cancelTarget", "EntityTargetEvent", 0)
end

function onEvent(funcTable)
	if funcTable[1] == "MW028-cancelBullet" and funcTable[2]:getEventName() == "EntityDamageByEntityEvent" then cancelBullet(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
	if funcTable[1] == "MW028-cancelTarget" and funcTable[2]:getEventName() == "EntityTargetLivingEntityEvent" then cancelTarget(funcTable[3], funcTable[2], funcTable[4], funcTable[1]) end
end

function onTimer(player, ability)
	if player:getVariable("MW028-passiveCount") == nil then player:setVariable("MW028-passiveCount", 0) end
	local count = player:getVariable("MW028-passiveCount")
	Resistance(player)
	if count >= 200 then 
		count = 0
		Shoot(player)
	end
	count = count + 2
	player:setVariable("MW028-passiveCount", count)
end

function cancelBullet(LAPlayer, event, ability, id)
	if event:getDamager():getType():toString() == "SHULKER_BULLET" and event:getEntity():getType():toString() == "PLAYER" then
		if game.checkCooldown(LAPlayer, game.getPlayer(event:getEntity()), ability, id) then
			event:setCancelled(true)
		end
	end
end

function cancelTarget(LAPlayer, event, ability, id)
	if event:getTarget() ~= nil and event:getEntity() ~= nil then
		if event:getTarget():getType():toString() == "PLAYER" and (event:getEntity():getType():toString() == "SHULKER" or event:getEntity():getType():toString() == "SHULKER_BULLET") then
			if game.checkCooldown(LAPlayer, game.getPlayer(event:getTarget()), ability, id) then
				event:setTarget(nil)
				event:setCancelled(true)
			end
		end
	end
end

function Resistance(player)
	if player:getPlayer():isSneaking() then
		player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.DAMAGE_RESISTANCE, 4, 0}))
		player:getPlayer():setWalkSpeed(0)
		player:getPlayer():setVelocity(newInstance("$.util.Vector", {}))
	else 
		player:getPlayer():setWalkSpeed(0.2) 
	end
end

function Shoot(player)
	local players = util.getTableFromList(game.getPlayers())
	for i = 1, #players do
		if players[i] ~= player and game.targetPlayer(player, players[i], false) then
			if player:getPlayer():getWorld():getEnvironment() == players[i]:getPlayer():getWorld():getEnvironment() and
			(player:getPlayer():getLocation():distance(players[i]:getPlayer():getLocation()) <= 10) then
				local pos = player:getPlayer():getLocation()
				pos:setY(pos:getY() + 1)
				local bullet = player:getPlayer():getWorld():spawnEntity(pos, import("$.entity.EntityType").SHULKER_BULLET)
				bullet:setTarget(players[i]:getPlayer())
				bullet:setShooter(player:getPlayer())
				player:getPlayer():getWorld():spawnParticle(import("$.Particle").SMOKE_NORMAL, player:getPlayer():getLocation():add(0,1,0), 100, 0.5, 1, 0.5, 0.05)
				player:getPlayer():getWorld():playSound(player:getPlayer():getLocation(), import("$.Sound").ENTITY_SHULKER_SHOOT, 0.25, 1)
			end
		end
	end
end

function Reset(player, ability)
	player:getPlayer():setWalkSpeed(0.2)
end