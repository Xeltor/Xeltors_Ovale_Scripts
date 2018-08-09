local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "hooves_blood"
	local desc = "[Hooves][8.0] Death Knight: Blood"
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
		
		BloodDefaultMainActions()
		
	}
}
AddFunction BloodInterruptActions
{
 if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
 {
  if target.InRange(mind_freeze) and target.IsInterruptible() Spell(mind_freeze)
  if target.InRange(asphyxiate) and not target.Classification(worldboss) Spell(asphyxiate)
    if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
 }
}
AddFunction BloodHealMe
{
	if HealthPercent() <= 70 Spell(death_strike)
	if (DamageTaken(5) * 0.2) > (Health() / 100 * 25) Spell(death_strike)
	if (BuffStacks(bone_shield_buff) * 3) > (100 - HealthPercent()) Spell(tombstone)
	if HealthPercent() <= 70 Spell(consumption)
}


AddFunction BloodDefaultMainActions
{
 #potion,if=buff.dancing_rune_weapon.up
 if BuffPresent(dancing_rune_weapon_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war usable=1)
 #call_action_list,name=standard
 BloodHealMe()
 BloodStandardMainActions()
}

AddFunction BloodDefaultMainPostConditions
{
 BloodStandardMainPostConditions()
}

AddFunction BloodDefaultShortCdActions
{
 #auto_attack
 BloodGetInMeleeRange()

 unless BuffPresent(dancing_rune_weapon_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(old_war usable=1)
 {
  #tombstone,if=buff.bone_shield.stack>=7
  if BuffStacks(bone_shield_buff) >= 7 Spell(tombstone)
  #call_action_list,name=standard
  BloodStandardShortCdActions()
 }
}

AddFunction BloodDefaultShortCdPostConditions
{
 BuffPresent(dancing_rune_weapon_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(old_war usable=1) or BloodStandardShortCdPostConditions()
}

AddFunction BloodDefaultCdActions
{
 #mind_freeze
 BloodInterruptActions()
 #blood_fury,if=cooldown.dancing_rune_weapon.ready&(!cooldown.blooddrinker.ready|!talent.blooddrinker.enabled)
 if SpellCooldown(dancing_rune_weapon) == 0 and { not SpellCooldown(blooddrinker) == 0 or not Talent(blooddrinker_talent) } Spell(blood_fury_ap)
 #berserking
 Spell(berserking)
 #use_items
 BloodUseItemActions()

 unless BuffPresent(dancing_rune_weapon_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(old_war usable=1)
 {
  #dancing_rune_weapon,if=!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready
  #if not Talent(blooddrinker_talent) or not SpellCooldown(blooddrinker) == 0 Spell(dancing_rune_weapon)

  unless BuffStacks(bone_shield_buff) >= 7 and Spell(tombstone)
  {
   #call_action_list,name=standard
   BloodStandardCdActions()
  }
 }
}

AddFunction BloodDefaultCdPostConditions
{
 BuffPresent(dancing_rune_weapon_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(old_war usable=1) or BuffStacks(bone_shield_buff) >= 7 and Spell(tombstone) or BloodStandardCdPostConditions()
}

### actions.precombat

AddFunction BloodPrecombatMainActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #potion
 if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war usable=1)
}

AddFunction BloodPrecombatMainPostConditions
{
}

AddFunction BloodPrecombatShortCdActions
{
}

AddFunction BloodPrecombatShortCdPostConditions
{
 CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(old_war usable=1)
}

AddFunction BloodPrecombatCdActions
{
}

AddFunction BloodPrecombatCdPostConditions
{
 CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(old_war usable=1)
}

### actions.standard

AddFunction BloodStandardMainActions
{
 #death_strike,if=runic_power.deficit<=10
 if RunicPowerDeficit() <= 10 Spell(death_strike)
 #marrowrend,if=(buff.bone_shield.remains<=rune.time_to_3|buff.bone_shield.remains<=(gcd+cooldown.blooddrinker.ready*talent.blooddrinker.enabled*2)|buff.bone_shield.stack<3)&runic_power.deficit>=20
 if { BuffRemaining(bone_shield_buff) <= TimeToRunes(3) or BuffRemaining(bone_shield_buff) <= GCD() + { SpellCooldown(blooddrinker) == 0 } * TalentPoints(blooddrinker_talent) * 2 or BuffStacks(bone_shield_buff) < 3 } and RunicPowerDeficit() >= 20 Spell(marrowrend)
 #blood_boil,if=charges_fractional>=1.8&(buff.hemostasis.stack<=(5-spell_targets.blood_boil)|spell_targets.blood_boil>2)
 if Charges(blood_boil count=0) >= 1.8 and { BuffStacks(hemostasis_buff) <= 5 - Enemies() or Enemies() > 2 } Spell(blood_boil)
 #marrowrend,if=buff.bone_shield.stack<5&talent.ossuary.enabled&runic_power.deficit>=15
 if BuffStacks(bone_shield_buff) < 5 and Talent(ossuary_talent) and RunicPowerDeficit() >= 15 Spell(marrowrend)
 #death_strike,if=runic_power.deficit<=(15+buff.dancing_rune_weapon.up*5+spell_targets.heart_strike*talent.heartbreaker.enabled*2)|target.time_to_die<10
 if RunicPowerDeficit() <= 15 + BuffPresent(dancing_rune_weapon_buff) * 5 + Enemies() * TalentPoints(heartbreaker_talent) * 2 or target.TimeToDie() < 10 Spell(death_strike)
 #death_and_decay,if=spell_targets.death_and_decay>=3
 if Enemies() >= 3 Spell(death_and_decay)
 #heart_strike,if=buff.dancing_rune_weapon.up|rune.time_to_4<gcd
 if BuffPresent(dancing_rune_weapon_buff) or TimeToRunes(4) < GCD() Spell(heart_strike)
 #blood_boil,if=buff.dancing_rune_weapon.up
 if BuffPresent(dancing_rune_weapon_buff) Spell(blood_boil)
 #death_and_decay,if=buff.crimson_scourge.up|talent.rapid_decomposition.enabled|spell_targets.death_and_decay>=2
 if BuffPresent(crimson_scourge_buff) or Talent(rapid_decomposition_talent) or Enemies() >= 2 Spell(death_and_decay)
 #blood_boil
 Spell(blood_boil)
 #heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
 if TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 Spell(heart_strike)
}

AddFunction BloodStandardMainPostConditions
{
}

AddFunction BloodStandardShortCdActions
{
 unless RunicPowerDeficit() <= 10 and Spell(death_strike)
 {
  #blooddrinker,if=!buff.dancing_rune_weapon.up
  if not BuffPresent(dancing_rune_weapon_buff) Spell(blooddrinker)

  unless { BuffRemaining(bone_shield_buff) <= TimeToRunes(3) or BuffRemaining(bone_shield_buff) <= GCD() + { SpellCooldown(blooddrinker) == 0 } * TalentPoints(blooddrinker_talent) * 2 or BuffStacks(bone_shield_buff) < 3 } and RunicPowerDeficit() >= 20 and Spell(marrowrend) or Charges(blood_boil count=0) >= 1.8 and { BuffStacks(hemostasis_buff) <= 5 - Enemies() or Enemies() > 2 } and Spell(blood_boil) or BuffStacks(bone_shield_buff) < 5 and Talent(ossuary_talent) and RunicPowerDeficit() >= 15 and Spell(marrowrend)
  {
   #bonestorm,if=runic_power>=100&!buff.dancing_rune_weapon.up
   if RunicPower() >= 100 and not BuffPresent(dancing_rune_weapon_buff) Spell(bonestorm)

   unless { RunicPowerDeficit() <= 15 + BuffPresent(dancing_rune_weapon_buff) * 5 + Enemies() * TalentPoints(heartbreaker_talent) * 2 or target.TimeToDie() < 10 } and Spell(death_strike) or Enemies() >= 3 and Spell(death_and_decay)
   {
    #rune_strike,if=(charges_fractional>=1.8|buff.dancing_rune_weapon.up)&rune.time_to_3>=gcd
    if { Charges(rune_strike count=0) >= 1.8 or BuffPresent(dancing_rune_weapon_buff) } and TimeToRunes(3) >= GCD() Spell(rune_strike)

    unless { BuffPresent(dancing_rune_weapon_buff) or TimeToRunes(4) < GCD() } and Spell(heart_strike) or BuffPresent(dancing_rune_weapon_buff) and Spell(blood_boil) or { BuffPresent(crimson_scourge_buff) or Talent(rapid_decomposition_talent) or Enemies() >= 2 } and Spell(death_and_decay)
    {
     #consumption
     Spell(consumption)

     unless Spell(blood_boil) or { TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 } and Spell(heart_strike)
     {
      #rune_strike
      Spell(rune_strike)
     }
    }
   }
  }
 }
}

AddFunction BloodStandardShortCdPostConditions
{
 RunicPowerDeficit() <= 10 and Spell(death_strike) or { BuffRemaining(bone_shield_buff) <= TimeToRunes(3) or BuffRemaining(bone_shield_buff) <= GCD() + { SpellCooldown(blooddrinker) == 0 } * TalentPoints(blooddrinker_talent) * 2 or BuffStacks(bone_shield_buff) < 3 } and RunicPowerDeficit() >= 20 and Spell(marrowrend) or Charges(blood_boil count=0) >= 1.8 and { BuffStacks(hemostasis_buff) <= 5 - Enemies() or Enemies() > 2 } and Spell(blood_boil) or BuffStacks(bone_shield_buff) < 5 and Talent(ossuary_talent) and RunicPowerDeficit() >= 15 and Spell(marrowrend) or { RunicPowerDeficit() <= 15 + BuffPresent(dancing_rune_weapon_buff) * 5 + Enemies() * TalentPoints(heartbreaker_talent) * 2 or target.TimeToDie() < 10 } and Spell(death_strike) or Enemies() >= 3 and Spell(death_and_decay) or { BuffPresent(dancing_rune_weapon_buff) or TimeToRunes(4) < GCD() } and Spell(heart_strike) or BuffPresent(dancing_rune_weapon_buff) and Spell(blood_boil) or { BuffPresent(crimson_scourge_buff) or Talent(rapid_decomposition_talent) or Enemies() >= 2 } and Spell(death_and_decay) or Spell(blood_boil) or { TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 } and Spell(heart_strike)
}

AddFunction BloodStandardCdActions
{
 unless RunicPowerDeficit() <= 10 and Spell(death_strike) or not BuffPresent(dancing_rune_weapon_buff) and Spell(blooddrinker) or { BuffRemaining(bone_shield_buff) <= TimeToRunes(3) or BuffRemaining(bone_shield_buff) <= GCD() + { SpellCooldown(blooddrinker) == 0 } * TalentPoints(blooddrinker_talent) * 2 or BuffStacks(bone_shield_buff) < 3 } and RunicPowerDeficit() >= 20 and Spell(marrowrend) or Charges(blood_boil count=0) >= 1.8 and { BuffStacks(hemostasis_buff) <= 5 - Enemies() or Enemies() > 2 } and Spell(blood_boil) or BuffStacks(bone_shield_buff) < 5 and Talent(ossuary_talent) and RunicPowerDeficit() >= 15 and Spell(marrowrend) or RunicPower() >= 100 and not BuffPresent(dancing_rune_weapon_buff) and Spell(bonestorm) or { RunicPowerDeficit() <= 15 + BuffPresent(dancing_rune_weapon_buff) * 5 + Enemies() * TalentPoints(heartbreaker_talent) * 2 or target.TimeToDie() < 10 } and Spell(death_strike) or Enemies() >= 3 and Spell(death_and_decay) or { Charges(rune_strike count=0) >= 1.8 or BuffPresent(dancing_rune_weapon_buff) } and TimeToRunes(3) >= GCD() and Spell(rune_strike) or { BuffPresent(dancing_rune_weapon_buff) or TimeToRunes(4) < GCD() } and Spell(heart_strike) or BuffPresent(dancing_rune_weapon_buff) and Spell(blood_boil) or { BuffPresent(crimson_scourge_buff) or Talent(rapid_decomposition_talent) or Enemies() >= 2 } and Spell(death_and_decay) or Spell(consumption) or Spell(blood_boil) or { TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 } and Spell(heart_strike) or Spell(rune_strike)
 {
  #arcane_torrent,if=runic_power.deficit>20
  if RunicPowerDeficit() > 20 Spell(arcane_torrent_runicpower)
 }
}

AddFunction BloodStandardCdPostConditions
{
 RunicPowerDeficit() <= 10 and Spell(death_strike) or not BuffPresent(dancing_rune_weapon_buff) and Spell(blooddrinker) or { BuffRemaining(bone_shield_buff) <= TimeToRunes(3) or BuffRemaining(bone_shield_buff) <= GCD() + { SpellCooldown(blooddrinker) == 0 } * TalentPoints(blooddrinker_talent) * 2 or BuffStacks(bone_shield_buff) < 3 } and RunicPowerDeficit() >= 20 and Spell(marrowrend) or Charges(blood_boil count=0) >= 1.8 and { BuffStacks(hemostasis_buff) <= 5 - Enemies() or Enemies() > 2 } and Spell(blood_boil) or BuffStacks(bone_shield_buff) < 5 and Talent(ossuary_talent) and RunicPowerDeficit() >= 15 and Spell(marrowrend) or RunicPower() >= 100 and not BuffPresent(dancing_rune_weapon_buff) and Spell(bonestorm) or { RunicPowerDeficit() <= 15 + BuffPresent(dancing_rune_weapon_buff) * 5 + Enemies() * TalentPoints(heartbreaker_talent) * 2 or target.TimeToDie() < 10 } and Spell(death_strike) or Enemies() >= 3 and Spell(death_and_decay) or { Charges(rune_strike count=0) >= 1.8 or BuffPresent(dancing_rune_weapon_buff) } and TimeToRunes(3) >= GCD() and Spell(rune_strike) or { BuffPresent(dancing_rune_weapon_buff) or TimeToRunes(4) < GCD() } and Spell(heart_strike) or BuffPresent(dancing_rune_weapon_buff) and Spell(blood_boil) or { BuffPresent(crimson_scourge_buff) or Talent(rapid_decomposition_talent) or Enemies() >= 2 } and Spell(death_and_decay) or Spell(consumption) or Spell(blood_boil) or { TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 } and Spell(heart_strike) or Spell(rune_strike)
}



]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end