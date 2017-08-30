local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_blood"
	local desc = "[Xel][7.0.3] Death Knight: Blood"
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

# Common functions.
AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(mind_freeze) Spell(mind_freeze)
		if not target.Classification(worldboss)
		{
			if target.InRange(asphyxiate) Spell(asphyxiate)
			if target.Distance(less 8) Spell(arcane_torrent_runicpower)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction BloodDefaultShortCDActions
{
	# Spell(death_and_decay)
	# if CheckBoxOn(opt_melee_range) and not target.InRange(death_strike) Texture(misc_arrowlup help=L(not_in_melee_range))
	if not BuffPresent(rune_tap_buff) Spell(rune_tap)
	if RuneCount() < 6 Spell(blood_tap)
}

AddFunction BloodDefaultMainActions
{
	BloodHealMe()
	if not Talent(soulgorge_talent) and target.DebuffRemaining(blood_plague_debuff) < 8 Spell(blood_boil)
	Spell(consumption)
	if BuffStacks(bone_shield_buff) <= 1 Spell(marrowrend)
	if target.DebuffRemaining(blood_plague_debuff) < 8 Spell(deaths_caress)
	if Talent(ossuary_talent) and BuffStacks(bone_shield_buff) <5 Spell(marrowrend)
	if Talent(mark_of_blood_talent) and not target.DebuffPresent(mark_of_blood_debuff) Spell(mark_of_blood)
	if RunicPower() >= 80 Spell(death_strike)
	if not Talent(soulgorge_talent) Spell(blood_boil)
	# Spell(death_and_decay)
	if BuffStacks(bone_shield_buff) <= 7 Spell(marrowrend)
	Spell(heart_strike)
	Spell(blood_boil)
}

AddFunction BloodDefaultAoEActions
{
	BloodHealMe()
	if not Talent(soulgorge_talent) and target.DebuffRemaining(blood_plague_debuff) < 8 Spell(blood_boil)
	Spell(consumption)
	if BuffStacks(bone_shield_buff) <= 1 Spell(marrowrend)
	if target.DebuffRemaining(blood_plague_debuff) < 8 Spell(deaths_caress)
	if Talent(ossuary_talent) and BuffStacks(bone_shield_buff) < 5 and Enemies(tagged=1) < 3 Spell(marrowrend)
	if Talent(mark_of_blood_talent) and not target.DebuffPresent(mark_of_blood_debuff) Spell(mark_of_blood)
	if RunicPower() >= 80 Spell(bonestorm)
	if RunicPower() >= 80 Spell(death_strike)
	if not Talent(soulgorge_talent) Spell(blood_boil)
	# Spell(death_and_decay)
	if BuffStacks(bone_shield_buff) <= 7 and Enemies(tagged=1) < 3 Spell(marrowrend)
	Spell(heart_strike)
	Spell(blood_boil)
	Spell(death_strike)
}

AddFunction BloodHealMe
{
	if HealthPercent() <= 70 Spell(death_strike)
	if DamageTaken(5) * 0.2 > (Health() / 100 * 25) Spell(death_strike)
	if (BuffStacks(bone_shield_buff) * 3) > (100 - HealthPercent()) Spell(tombstone)
}

AddFunction BloodDefaultCdActions
{
	# BloodInterruptActions()
	# Item(legendary_ring_bonus_armor usable=1)
	Spell(vampiric_blood)
	if target.InRange(blood_mirror) Spell(blood_mirror)
	# if IncomingDamage(1.5 magic=1) > 0 spell(antimagic_shell)
	Spell(dancing_rune_weapon)
	if BuffStacks(bone_shield_buff) >= 5 Spell(tombstone)
}

]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end
