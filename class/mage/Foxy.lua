local _, FoxyOvaleScripts = ...
local Ovale = FoxyOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "foxylegionmage"
	local desc = "[Foxy] Mage: Arcane, Fire and Frost"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

AddCheckBox(opt_interrupt L(interrupt) default)
# AddCheckBox(opt_potion_intellect ItemName(draenic_intellect_potion) default)
# AddCheckBox(opt_legendary_ring_intellect ItemName(legendary_ring_intellect) default)
# AddCheckBox(opt_time_warp SpellName(time_warp) default)
# AddCheckBox(opt_cds L(CDs) default)
AddCheckBox(opt_aoe L(AOE) default)

AddFunction UsePotionIntellect
{
	# if CheckBoxOn(opt_potion_intellect) and target.Classification(worldboss) Item(draenic_intellect_potion usable=1)
}

AddFunction InterruptActions
{
	if InCombat() and target.InRange(counterspell) and HasFullControl()
	{
		if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.IsInterruptible()
		{
			Spell(counterspell)
			if not target.Classification(worldboss)
			{
				if target.Distance(less 8) Spell(arcane_torrent_mana)
				if target.InRange(quaking_palm) Spell(quaking_palm)
			}
		}
	}
}

AddFunction StandingStill
{
	{Speed() == 0 or BuffPresent(ice_floes_buff)}
}

### FIRE

AddFunction FirePrecombatActions
{
	# if CheckBoxOn(opt_cds) Spell(mirror_image)
	# UsePotionIntellect()
	Spell(pyroblast)
}

AddFunction FireDefaultActions
{
	if InCombat() and target.InRange(fire_blast) and HasFullControl()
	{
		if target.IsInterruptible() InterruptActions()
		# if { target.HealthPercent() < 25 or TimeInCombat() > 2 } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
		if { target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1) } and not SpellCooldown(combustion) > 0 and not SpellCooldown(flame_on) > 1 and BuffPresent(hot_streak_buff) or BuffPresent(combustion_buff) FireCombustionPhaseActions()
		if { target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1) } and SpellCooldown(combustion) < 6 and SpellCooldown(flame_on) < 6 FireCombPrepActions()
		if Speed() == 0 and { SpellCooldown(combustion) > 45 or Charges(rune_of_power) == 2 } Spell(rune_of_power)
		if CheckBoxOn(opt_aoe) and Enemies() >= 4 FireAoeActions()
		FireSingleTargetActions()
	}
}

AddFunction FireCombPrepActions
{
	if BuffPresent(heating_up_buff) Spell(fire_blast)
	if Speed() >0 and not BuffPresent(ice_floes_buff) Spell(ice_floes)
	if StandingStill() Spell(fireball)
	Spell(scorch)
}

AddFunction FireCombustionPhaseActions
{
	if not BuffPresent(rune_of_power_buff) Spell(rune_of_power)
	Spell(combustion)
	Spell(mirror_image)
	# if CheckBoxOn(opt_legendary_ring_intellect) Item(legendary_ring_intellect usable=1)
	Spell(blood_fury_sp)
	Spell(berserking)
	if BuffPresent(hot_streak_buff) Spell(pyroblast)
	if Charges(fire_blast) == 0 Spell(flame_on)
	if BuffPresent(heating_up_buff) Spell(fire_blast)
	if target.HealthPercent() <= 25 and HasEquippedItem(132454) Spell(scorch)
	Spell(fireball)
}

AddFunction FireAoeActions
{
	if BuffPresent(hot_streak_buff) Spell(flamestrike)
	if not target.DebuffPresent(living_bomb_debuff) and target.TimeToDie() > 8 Spell(living_bomb)
	if Charges(fire_blast) == 0 and SpellCooldown(combustion) > 50 Spell(flame_on)
	if BuffExpires(hot_streak_buff) and BuffPresent(heating_up_buff) Spell(fire_blast)
	if target.HealthPercent() <= 25 and HasEquippedItem(132454) Spell(scorch)
	if Speed() >0 and not BuffPresent(ice_floes_buff) Spell(ice_floes)
	if StandingStill() Spell(fireball)
	Spell(scorch)
}

AddFunction FireSingleTargetActions
{
	if BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) Spell(pyroblast)
	if BuffPresent(hot_streak_buff) and PreviousSpell(fireball) Spell(pyroblast)
	if Charges(fire_blast) == 0 and SpellCooldown(combustion) > 50 Spell(flame_on)
	if BuffExpires(hot_streak_buff) and BuffPresent(heating_up_buff) Spell(fire_blast)
	if target.HealthPercent() <= 25 and HasEquippedItem(132454) Spell(scorch)
	if Speed() >0 and not BuffPresent(ice_floes_buff) Spell(ice_floes)
	if StandingStill() Spell(fireball)
	if Speed() >0 and not BuffPresent(ice_floes_buff) and BuffPresent(hot_streak_buff) Spell(pyroblast)
	Spell(scorch)
}

### Required symbols
# arcane_torrent_mana
# berserking
# blood_fury_sp
# combustion
# counterspell
# draenic_intellect_potion
# fire_blast
# fireball
# flame_on
# flamestrike
# ice_floes
# legendary_ring_intellect
# living_bomb
# mirror_image
# pyroblast
# quaking_palm
# rune_of_power
# scorch
# time_warp
# blast_wave
# ring_of_frost


AddIcon specialization=arcane help=main
{
	if not InCombat() ArcanePrecombatActions()
	ArcaneDefaultActions()
}

AddIcon specialization=fire help=main
{
	# if not InCombat() FirePrecombatActions()
	FireDefaultActions()
}

AddIcon specialization=frost help=main
{
	if not InCombat() FrostPrecombatActions()
	FrostDefaultActions()
}
]]
	OvaleScripts:RegisterScript("MAGE", nil, name, desc, code, "script")
end
