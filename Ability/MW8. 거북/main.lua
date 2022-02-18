local effect = import("$.potion.PotionEffectType")

function Init(abilityData) end

function onTimer(player, ability)
	addEffect(player)
end

function addEffect(player)
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.DOLPHINS_GRACE, 20, 0}))
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.SLOW, 20, 2}))
	player:getPlayer():addPotionEffect(newInstance("$.potion.PotionEffect", {effect.WATER_BREATHING, 20, 0}))
end