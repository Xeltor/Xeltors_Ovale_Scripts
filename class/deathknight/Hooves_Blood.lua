local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "hooves_blood"
	local desc = "[Hooves][7.3] Death Knight: Blood"
	local code = [[
# Based on SimulationCraft profile "Death_Knight_Blood_T17M".
#	class=deathknight
#	spec=blood
#	talents=2012102

Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_deathknight_spells)

Define(path_of_frost 3714)
	SpellInfo(path_of_frost runes=1)
	SpellAddBuff(path_of_frost path_of_frost_buff=1)
Define(path_of_frost_buff 3714)
	SpellInfo(path_of_frost_buff duration=600)
Define(consumption 205223)
	SpellInfo(consumption cd=45)

# Blood
AddIcon specialization=1 help=main
{
	# Path o' Frost
	if BuffExpires(path_of_frost_buff) and { mounted() or wet() } and not InCombat() Spell(path_of_frost)
	
	if InCombat()
	{
		if DamageTaken(5) > (Health() * 0.70) BloodDefaultCdActions()
		
		# Short cooldowns
		BloodDefaultShortCDActions()
	}
		
	if InCombat() InterruptActions()
	
	if target.InRange(heart_strike) and HasFullControl()
    {
		if BuffStacks(dark_succor_buff) Spell(death_strike)
		
		if Enemies(tagged=1) <= 1 BloodDefaultMainActions()
		BloodDefaultAoEActions()
	}
}


AddFunction BloodDefaultShortCDActions
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(death_strike) Texture(misc_arrowlup help=L(not_in_melee_range))
	if not BuffPresent(rune_tap_buff) Spell(rune_tap)
	if Rune() <= 2 Spell(blood_tap)
}

AddFunction BloodDefaultMainActions
{
	BloodHealMe()
	if InCombat() and BuffExpires(bone_shield_buff 3) Spell(marrowrend)
	if target.DebuffRefreshable(blood_plague_debuff) Spell(blood_boil)
	if not BuffPresent(death_and_decay_buff) and BuffPresent(crimson_scourge_buff) and Talent(rapid_decomposition_talent) Spell(death_and_decay)
	if RunicPower() >= 100 and target.TimeToDie() >= 10 Spell(bonestorm)
	if RunicPowerDeficit() <= 20 Spell(death_strike)
	if BuffStacks(bone_shield_buff) <= 2+4*Talent(ossuary_talent) Spell(marrowrend)
	if not BuffPresent(death_and_decay_buff) and Rune() >= 3 and Talent(rapid_decomposition_talent) Spell(death_and_decay)
	if not target.DebuffPresent(mark_of_blood_debuff) Spell(mark_of_blood)
	if Rune() >= 3 or RunicPower() < 45 Spell(heart_strike)
	Spell(consumption)
	Spell(blood_boil)
}

AddFunction BloodDefaultAoEActions
{
	BloodHealMe()
	if RunicPower() >= 100 Spell(bonestorm)
	if InCombat() and BuffExpires(bone_shield_buff 3) Spell(marrowrend)
	if DebuffCountOnAny(blood_plague_debuff) < Enemies(tagged=1) Spell(blood_boil)
	if not BuffPresent(death_and_decay_buff) and BuffPresent(crimson_scourge_buff) Spell(death_and_decay)
	if RunicPowerDeficit() <= 20 Spell(death_strike)
	if BuffStacks(bone_shield_buff) <= 2+4*Talent(ossuary_talent) Spell(marrowrend)
	if not BuffPresent(death_and_decay_buff) and Enemies(tagged=1) >= 3 Spell(death_and_decay)
	if not target.DebuffPresent(mark_of_blood_debuff) Spell(mark_of_blood)
	if Rune() >= 3 or RunicPower() < 45 Spell(heart_strike)
	Spell(consumption)
	Spell(blood_boil)
}

AddFunction BloodHealMe
{
	if HealthPercent() <= 70 Spell(death_strike)
	if (DamageTaken(5) * 0.2) > (Health() / 100 * 25) Spell(death_strike)
	if (BuffStacks(bone_shield_buff) * 3) > (100 - HealthPercent()) Spell(tombstone)
	if HealthPercent() <= 70 Spell(consumption)
}

AddFunction BloodDefaultCdActions
{
	BloodInterruptActions()
	if IncomingDamage(1.5 magic=1) > 0 spell(antimagic_shell)
	#if (HasEquippedItem(shifting_cosmic_sliver)) Spell(icebound_fortitude)
	#Item(Trinket0Slot usable=1 text=13)
	#Item(Trinket1Slot usable=1 text=14)
	#Spell(vampiric_blood)
	#Spell(icebound_fortitude)
	if target.InRange(blood_mirror) Spell(blood_mirror)
	Spell(dancing_rune_weapon)
	if BuffStacks(bone_shield_buff) >= 5 Spell(tombstone)
	if CheckBoxOn(opt_use_consumables) Item(unbending_potion usable=1)
	UseRacialSurvivalActions()
}

AddFunction BloodInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(mind_freeze) and target.IsInterruptible() Spell(mind_freeze)
		if target.InRange(asphyxiate) and not target.Classification(worldboss) Spell(asphyxiate)
		if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_runicpower)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
}

AddCheckBox(opt_deathknight_blood_aoe L(AOE) default specialization=blood)

]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end
