local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_blood"
	local desc = "[Xel][7.3.5] Death Knight: Blood"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_deathknight_spells)

Define(path_of_frost 3714)
	SpellInfo(path_of_frost runes=1)
	SpellAddBuff(path_of_frost path_of_frost_buff=1)
Define(path_of_frost_buff 3714)
	SpellInfo(path_of_frost_buff duration=600)

# Blood
AddIcon specialization=1 help=main
{
	# Path o' Frost
	if BuffExpires(path_of_frost_buff) and { mounted() or wet() } and not InCombat() Spell(path_of_frost)
	
	if InCombat() and HealthPercent() < 100
	{
		BloodDefaultCdActions()
		
		BloodDefaultShortCdActions()
	}
		
	if InCombat() InterruptActions()
	
	if target.InRange(heart_strike) and HasFullControl()
    {
		if BuffStacks(dark_succor_buff) Spell(death_strike)
		
		BloodDefaultMainActions()
	}
}

# Common functions.
AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
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

AddFunction BloodDefaultMainActions
{
 #tombstone,if=buff.bone_shield.stack>=7
 if BuffStacks(bone_shield_buff) >= 7 Spell(tombstone)
 #call_action_list,name=standard
 BloodStandardMainActions()
}

AddFunction BloodDefaultMainPostConditions
{
 BloodStandardMainPostConditions()
}

AddFunction BloodDefaultShortCdActions
{
 #auto_attack
 # BloodGetInMeleeRange()
 #dancing_rune_weapon,if=(!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready)&!cooldown.death_and_decay.ready
 if { not Talent(blooddrinker_talent) or not SpellCooldown(blooddrinker) == 0 } and not SpellCooldown(death_and_decay) == 0 Spell(dancing_rune_weapon)
 #vampiric_blood,if=!equipped.archimondes_hatred_reborn|cooldown.trinket.ready
 if not HasEquippedItem(archimondes_hatred_reborn) or ItemCooldown(archimondes_hatred_reborn) == 0 Spell(vampiric_blood)

 unless BuffStacks(bone_shield_buff) >= 7 and Spell(tombstone)
 {
  #call_action_list,name=standard
  BloodStandardShortCdActions()
 }
}

AddFunction BloodDefaultShortCdPostConditions
{
 BuffStacks(bone_shield_buff) >= 7 and Spell(tombstone) or BloodStandardShortCdPostConditions()
}

AddFunction BloodDefaultCdActions
{
 #mind_freeze
 # BloodInterruptActions()
 #arcane_torrent,if=runic_power.deficit>20
 if RunicPowerDeficit() > 20 Spell(arcane_torrent_runicpower)
 #blood_fury
 Spell(blood_fury_ap)
 #berserking,if=buff.dancing_rune_weapon.up
 if BuffPresent(dancing_rune_weapon_buff) Spell(berserking)
 #use_items
 # BloodUseItemActions()
 #use_item,name=archimondes_hatred_reborn,if=buff.vampiric_blood.up
 # if BuffPresent(vampiric_blood_buff) BloodUseItemActions()
 #potion,if=buff.dancing_rune_weapon.up
 # if BuffPresent(dancing_rune_weapon_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)

 unless BuffStacks(bone_shield_buff) >= 7 and Spell(tombstone)
 {
  #call_action_list,name=standard
  BloodStandardCdActions()
 }
}

AddFunction BloodDefaultCdPostConditions
{
 BuffStacks(bone_shield_buff) >= 7 and Spell(tombstone) or BloodStandardCdPostConditions()
}

### actions.precombat

AddFunction BloodPrecombatMainActions
{
}

AddFunction BloodPrecombatMainPostConditions
{
}

AddFunction BloodPrecombatShortCdActions
{
}

AddFunction BloodPrecombatShortCdPostConditions
{
}

AddFunction BloodPrecombatCdActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
}

AddFunction BloodPrecombatCdPostConditions
{
}

### actions.standard

AddFunction BloodStandardMainActions
{
 #death_strike,if=runic_power.deficit<10
 if RunicPowerDeficit() < 10 Spell(death_strike)
 #death_and_decay,if=talent.rapid_decomposition.enabled&!buff.dancing_rune_weapon.up
 if Talent(rapid_decomposition_talent) and not BuffPresent(dancing_rune_weapon_buff) Spell(death_and_decay)
 #marrowrend,if=buff.bone_shield.remains<=gcd*2
 if BuffRemaining(bone_shield_buff) <= GCD() * 2 Spell(marrowrend)
 #blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
 if Charges(blood_boil count=0) >= 1.8 and BuffStacks(haemostasis_buff) < 5 and { BuffStacks(haemostasis_buff) < 3 or not BuffPresent(dancing_rune_weapon_buff) } Spell(blood_boil)
 #marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
 if BuffStacks(bone_shield_buff) < 5 and Talent(ossuary_talent) or BuffRemaining(bone_shield_buff) < GCD() * 3 Spell(marrowrend)
 #bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
 if RunicPower() >= 100 and Enemies() >= 3 Spell(bonestorm)
 #death_strike,if=buff.blood_shield.up|(runic_power.deficit<15&(runic_power.deficit<25|!buff.dancing_rune_weapon.up))
 if BuffPresent(blood_shield_buff) or RunicPowerDeficit() < 15 and { RunicPowerDeficit() < 25 or not BuffPresent(dancing_rune_weapon_buff) } Spell(death_strike)
 #consumption
 Spell(consumption)
 #heart_strike,if=buff.dancing_rune_weapon.up
 if BuffPresent(dancing_rune_weapon_buff) Spell(heart_strike)
 #death_and_decay,if=buff.crimson_scourge.up
 if BuffPresent(crimson_scourge_buff) Spell(death_and_decay)
 #blood_boil,if=buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
 if BuffStacks(haemostasis_buff) < 5 and { BuffStacks(haemostasis_buff) < 3 or not BuffPresent(dancing_rune_weapon_buff) } Spell(blood_boil)
 #death_and_decay
 Spell(death_and_decay)
 #heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
 if TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 Spell(heart_strike)
}

AddFunction BloodStandardMainPostConditions
{
}

AddFunction BloodStandardShortCdActions
{
 unless RunicPowerDeficit() < 10 and Spell(death_strike) or Talent(rapid_decomposition_talent) and not BuffPresent(dancing_rune_weapon_buff) and Spell(death_and_decay)
 {
  #blooddrinker,if=!buff.dancing_rune_weapon.up
  if not BuffPresent(dancing_rune_weapon_buff) Spell(blooddrinker)
 }
}

AddFunction BloodStandardShortCdPostConditions
{
 RunicPowerDeficit() < 10 and Spell(death_strike) or Talent(rapid_decomposition_talent) and not BuffPresent(dancing_rune_weapon_buff) and Spell(death_and_decay) or BuffRemaining(bone_shield_buff) <= GCD() * 2 and Spell(marrowrend) or Charges(blood_boil count=0) >= 1.8 and BuffStacks(haemostasis_buff) < 5 and { BuffStacks(haemostasis_buff) < 3 or not BuffPresent(dancing_rune_weapon_buff) } and Spell(blood_boil) or { BuffStacks(bone_shield_buff) < 5 and Talent(ossuary_talent) or BuffRemaining(bone_shield_buff) < GCD() * 3 } and Spell(marrowrend) or RunicPower() >= 100 and Enemies() >= 3 and Spell(bonestorm) or { BuffPresent(blood_shield_buff) or RunicPowerDeficit() < 15 and { RunicPowerDeficit() < 25 or not BuffPresent(dancing_rune_weapon_buff) } } and Spell(death_strike) or Spell(consumption) or BuffPresent(dancing_rune_weapon_buff) and Spell(heart_strike) or BuffPresent(crimson_scourge_buff) and Spell(death_and_decay) or BuffStacks(haemostasis_buff) < 5 and { BuffStacks(haemostasis_buff) < 3 or not BuffPresent(dancing_rune_weapon_buff) } and Spell(blood_boil) or Spell(death_and_decay) or { TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 } and Spell(heart_strike)
}

AddFunction BloodStandardCdActions
{
}

AddFunction BloodStandardCdPostConditions
{
 RunicPowerDeficit() < 10 and Spell(death_strike) or Talent(rapid_decomposition_talent) and not BuffPresent(dancing_rune_weapon_buff) and Spell(death_and_decay) or not BuffPresent(dancing_rune_weapon_buff) and Spell(blooddrinker) or BuffRemaining(bone_shield_buff) <= GCD() * 2 and Spell(marrowrend) or Charges(blood_boil count=0) >= 1.8 and BuffStacks(haemostasis_buff) < 5 and { BuffStacks(haemostasis_buff) < 3 or not BuffPresent(dancing_rune_weapon_buff) } and Spell(blood_boil) or { BuffStacks(bone_shield_buff) < 5 and Talent(ossuary_talent) or BuffRemaining(bone_shield_buff) < GCD() * 3 } and Spell(marrowrend) or RunicPower() >= 100 and Enemies() >= 3 and Spell(bonestorm) or { BuffPresent(blood_shield_buff) or RunicPowerDeficit() < 15 and { RunicPowerDeficit() < 25 or not BuffPresent(dancing_rune_weapon_buff) } } and Spell(death_strike) or Spell(consumption) or BuffPresent(dancing_rune_weapon_buff) and Spell(heart_strike) or BuffPresent(crimson_scourge_buff) and Spell(death_and_decay) or BuffStacks(haemostasis_buff) < 5 and { BuffStacks(haemostasis_buff) < 3 or not BuffPresent(dancing_rune_weapon_buff) } and Spell(blood_boil) or Spell(death_and_decay) or { TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 } and Spell(heart_strike)
}

]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end
