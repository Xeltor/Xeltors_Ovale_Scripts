local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_protection"
	local desc = "[Xel][7.2.5] Warrior: Protection"
	local code = [[
# Based on SimulationCraft profile "Warrior_Protection_T19P".
#    class=warrior
#    spec=protection
#    talents=0111201

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warrior_spells)

AddIcon specialization=3 help=main
{
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
	if target.InRange(shield_slam) and HasFullControl()
	{
		if PreviousGCDSpell(intercept) Spell(thunder_clap)
		
		# Cooldowns
		ProtectionDefaultCdActions()
		
		# Short Cooldowns
		ProtectionDefaultShortCDActions()
		# Default rotation
		ProtectionDefaultMainActions()
	}
	# Move to the target!
	if target.InRange(heroic_throw) and not PreviousGCDSpell(intercept) and target.InRange(intercept) and InCombat() and HasFullControl() Spell(intercept)
	if target.InRange(heroic_throw) and InCombat() and HasFullControl() Spell(heroic_throw usable=1)
}
AddFunction ProtectionHealMe
{
	if HealthPercent() < 70 Spell(victory_rush)
	if HealthPercent() < 85 Spell(impending_victory)
}

AddFunction ProtectionGetInMeleeRange
{
	if InFlightToTarget(intercept) and not InFlightToTarget(heroic_leap)
	{
		if target.InRange(intercept) Spell(intercept)
		# if SpellCharges(intercept) == 0 and target.Distance(atLeast 8) and target.Distance(atMost 40) Spell(heroic_leap)
		# if not target.InRange(pummel) Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.Casting()
	{
		if target.InRange(pummel) and target.IsInterruptible() Spell(pummel)
		if target.InRange(storm_bolt) and not target.Classification(worldboss) Spell(storm_bolt)
		if target.InRange(intercept) and not target.Classification(worldboss) and Talent(warbringer_talent) Spell(intercept)
		if target.Distance(less 10) and not target.Classification(worldboss) Spell(shockwave)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_rage)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
		if target.InRange(intimidating_shout) and not target.Classification(worldboss) Spell(intimidating_shout)
	}
}

AddFunction ProtectionOffensiveCooldowns
{
	Spell(avatar)
	Spell(battle_cry)
}

#
# Short
#

AddFunction ProtectionDefaultShortCDActions
{
	ProtectionHealMe()
	if IncomingDamage(5 physical=1) 
	{
		if not BuffPresent(neltharions_fury_buff) Spell(shield_block)
		if not BuffPresent(shield_block_buff) Spell(neltharions_fury)
	}
	if (not BuffPresent(renewed_fury_buff) or FuryDeficit() <= 30) Spell(ignore_pain)
	
	# range check
	ProtectionGetInMeleeRange()
}

#
# Single-Target
#

AddFunction ProtectionDefaultMainActions
{
	Spell(shield_slam)
	if Talent(devastatator_talent) and BuffPresent(revenge_buff) Spell(revenge)
	if BuffPresent(vengeance_revenge_buff) Spell(revenge)
	Spell(thunder_clap)
	if BuffPresent(revenge_buff) Spell(revenge)
	Spell(storm_bolt)
	Spell(ravager)
	Spell(devastate)
}

#
# AOE
#

AddFunction ProtectionDefaultAoEActions
{
	Spell(ravager)
	Spell(revenge)
	Spell(thunder_clap)
	Spell(shield_slam)
	if Enemies(tagged=1) >= 3 Spell(shockwave)
	Spell(devastate)
}

#
# Cooldowns
#

AddFunction ProtectionDefaultCdActions 
{
	InterruptActions()
	ProtectionOffensiveCooldowns()
	if IncomingDamage(1.5 magic=1) > 0 Spell(spell_reflection)
	if (HasEquippedItem(shifting_cosmic_sliver)) Spell(shield_wall)
	Spell(demoralizing_shout)
	Spell(shield_wall)
	Spell(last_stand)
	
}
]]

	OvaleScripts:RegisterScript("WARRIOR", "protection", name, desc, code, "script")
end
