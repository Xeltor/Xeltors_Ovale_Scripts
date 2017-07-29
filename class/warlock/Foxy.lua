local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "Foxylock"
	local desc = "[Foxy] Warlock: Demonology, Destruction"
	local code = [[
# Spells and Buffs
Define(agony 980)
Define(backdraft 117828)
Define(blood_fury 33702)
Define(command_demon 119898)
Define(chaos_bolt 116858)
Define(conflagrate 17962)
Define(corruption 172)
Define(corruption_aura 146739)
Define(curse_of_the_elements 1490)
Define(dark_intent 109773)
Define(dark_soul_knowledge 113861)
Define(dark_soul_misery 113860)
Define(dark_soul_instability 113858)
Define(doom 124913)
Define(doom_aura 603)
Define(drain_soul 1120)
Define(fel_flame 77799)
Define(felstorm 89751)
Define(fire_and_brimstone 108683)
Define(grimoire_of_sacrifice 108503)
Define(grimoire_felguard 111898)
Define(grimoire_felhunter 111897)
Define(grimoire_imp 111859)
Define(grimoire_succubus 111896)
Define(grimoire_voidwalker 111895)
Define(hand_of_guldan 105174)
Define(harvest_life 108371)
Define(haunt 48181)
Define(havoc 80240)
Define(hellfire 1949)
Define(immolate 348)
Define(immolate_fnb 108686)
SpellList(immolate_debuff 108686 348)
Define(immolation_aura 109797)
Define(immolation_aura_aura 104025)
Define(incinerate 29722)
Define(life_tap 1454)
Define(malefic_grasp 103103)
Define(melee 103988)
Define(metamorphosis 103958)
Define(meta_buff 103965)
Define(molten_core 122355)
Define(rain_of_fire 104232)
Define(seed_of_corruption 27243)
Define(shadow_bolt 686)
Define(shadowburn 17877)
Define(shadowflame 47960)
Define(soul_fire 6353)
Define(soul_swap 86121)
Define(soulburn 74434)
Define(soulburn_seed_of_corruption 86664)
Define(spell_lock 132409)
Define(summon_doomguard 18540)
Define(summon_felguard 30146)
Define(summon_felhunter 691)
Define(summon_imp 688)
Define(summon_infernal 1122)
Define(summon_succubus 712)
Define(summon_voidwalker 697)
Define(touch_of_chaos 112089)
Define(unstable_affliction 30108)
Define(void_ray 129343)
Define(wrathstorm 115831)
Define(kiljaedens_cunning_talent 17)
Define(grimoire_of_sacrifice_talent 15)
Define(grimoire_of_service_talent 14)
Define(harvest_life_talent 3)
Define(archimondes_darkness_talent 16)
SpellList(bloodlust 2825 80353 32182 90355)
SpellList(big_proc 139133 138963 138898)
SpellList(big_multi_proc 138786)
AddIcon specialization=1 help=main
{
	if TargetInRange(corruption) and HasFullControl() and not Casting(malefic_grasp) and not Casting(drain_soul) and InCombat()
    {
		if BuffStacks(soulburn)
		{
			if ManaPercent() <15 and not target.DeBuffStacks(haunt) and HealthPercent() >30 Spell(life_tap)
			Spell(soul_swap usable=1)
		}
		if not BuffStacks(soulburn)
		{
			if ManaPercent() <15 and not target.DeBuffStacks(haunt) and HealthPercent() >30 Spell(life_tap)
			if target.DebuffExpires(magic_vulnerability any=1) and TargetClassification(worldboss) Spell(curse_of_the_elements)
			if not BuffStacks(dark_soul_misery) and TimeInCombat() <10 and not target.DeBuffStacks(agony) and not target.DeBuffStacks(corruption) and not target.DeBuffStacks(unstable_affliction) and TargetClassification(worldboss)
			{
				if not target.DeBuffStacks(haunt) and SoulShards() >=3 and not InFlightToTarget(haunt) Spell(haunt usable=1)
				if PreviousSpell(haunt) and SoulShards() >=2 Spell(dark_soul_misery usable=1)
			}
			if TargetLifePercent() <=20 and SoulShards() >=1 and {not target.DeBuffStacks(agony) or not target.DeBuffStacks(corruption) or not target.DeBuffStacks(unstable_affliction) or target.DebuffRemains(agony) <CastTime(drain_soul) +2 or target.DebuffRemains(corruption) <CastTime(drain_soul) +2 or target.DebuffRemains(unstable_affliction) <CastTime(drain_soul) +1}
			{
				Spell(soulburn)
			}
			if BuffStacks(dark_soul_misery)
			{
				if PreviousSpell(dark_soul_misery) and SoulShards() >=1 Spell(soulburn)
				if BuffRemains(dark_soul_misery) <CastTime(malefic_grasp) +2 and SoulShards() >=1 and target.DebuffRemains(agony) <=20 Spell(soulburn)
				if target.DebuffRemains(agony) <CastTime(malefic_grasp) +2 or target.DebuffRemains(corruption) <CastTime(malefic_grasp) +2 or target.DebuffRemains(unstable_affliction) <CastTime(malefic_grasp) +2 Spell(soulburn)
				if SoulShards() >1 and not target.DeBuffStacks(haunt) and not InFlightToTarget(haunt) Spell(haunt)
				if TargetLifePercent() <=20 Spell(drain_soul)
				if TargetLifePercent() >20 Spell(malefic_grasp)
			}
			if not target.DeBuffStacks(agony) and not target.DeBuffStacks(corruption) and not target.DeBuffStacks(unstable_affliction) and TimeInCombat() <10
			{
				if SoulShards() >=1 Spell(soulburn)
			}
			if not target.DeBuffStacks(agony) or not target.DeBuffStacks(corruption) or not target.DeBuffStacks(unstable_affliction) or target.DebuffRemains(agony) -CastTime(malefic_grasp) <=12 or target.DebuffRemains(corruption) -CastTime(malefic_grasp) <=9 or target.DebuffRemains(unstable_affliction) -CastTime(malefic_grasp) <=7
			{
				if SoulShards() >3 Spell(soulburn)
				if not target.DeBuffStacks(agony) or target.DebuffRemains(agony) -CastTime(malefic_grasp) <=12 Spell(agony)
				if not target.DeBuffStacks(corruption) or target.DebuffRemains(corruption) -CastTime(malefic_grasp) <=9 Spell(corruption)
				if not target.DeBuffStacks(unstable_affliction) or target.DebuffRemains(unstable_affliction) -CastTime(malefic_grasp) <=7 Spell(unstable_affliction)
			}
			if SpellUsable(dark_soul_misery) and not target.DeBuffStacks(haunt) and TargetClassification(worldboss)
			{
				if ManaPercent() <35 and HealthPercent() >=30 Spell(life_tap)
				if ManaPercent() >=35 Spell(dark_soul_misery)
			}
			if SpellCooldown(dark_soul_misery) >30 and SoulShards() >=1 and not target.DeBuffStacks(haunt) and ManaPercent() >16 and target.DebuffRemains(agony) >8 +CastTime(haunt) and target.DebuffRemains(corruption) >8 +CastTime(haunt) and target.DebuffRemains(unstable_affliction) >8 +CastTime(haunt) and not InFlightToTarget(haunt) Spell(haunt)
			if SpellCooldown(dark_soul_misery) <=30 and SoulShards() >3 and not target.DeBuffStacks(haunt) and ManaPercent() >16 and target.DebuffRemains(agony) >8 +CastTime(haunt) and target.DebuffRemains(corruption) >8 +CastTime(haunt) and target.DebuffRemains(unstable_affliction) >8 +CastTime(haunt) and not InFlightToTarget(haunt) Spell(haunt)
			if not TargetClassification(worldboss) and SoulShards() >=1 and not target.DeBuffStacks(haunt) and ManaPercent() >16 and target.DebuffRemains(agony) >8 +CastTime(haunt) and target.DebuffRemains(corruption) >8 +CastTime(haunt) and target.DebuffRemains(unstable_affliction) >8 +CastTime(haunt) and not InFlightToTarget(haunt) Spell(haunt)
			if TargetLifePercent() <=20 Spell(drain_soul)
			if TargetLifePercent() >20 Spell(malefic_grasp)
			if HealthPercent() >=30 Spell(life_tap)
		}
	}
}
AddIcon specialization=2 help=main
{
    if not InCombat() 
    {
		if {not BuffPresent(spell_power_multiplier any=1) or not BuffPresent(stamina any=1)} and not mounted() Spell(dark_intent)
        if Stance(1) cancel.Texture(Spell_shadow_demonform)
		if not pet.Present() and not mounted() Spell(summon_felguard)
    }
	if InCombat() and TargetInRange(soul_fire) and HasFullControl()
    {
		if target.DebuffExpires(magic_vulnerability any=1) and not Stance(1) Spell(curse_of_the_elements)
		if DemonicFury() >=750 and SpellUsable(dark_soul_knowledge) Spell(dark_soul_knowledge)
		if TalentPoints(grimoire_of_service_talent) Spell(grimoire_felguard)
		if pet.Present() and pet.CreatureFamily(Felguard) Spell(felstorm)
		if CheckBoxOn(aoe)
		{
			if TargetClassification(worldboss) Spell(summon_infernal)
			if Stance(1)
			{
				if target.DebuffRemains(corruption_aura) >10 and DemonicFury() <=650 and not BuffPresent(dark_soul_knowledge) and not BuffPresent(immolation_aura_aura) cancel.Texture(Spell_shadow_demonform)
				if DemonicFury() <25 cancel.Texture(Spell_shadow_demonform)
				if target.Distance(less 8) and not BuffPresent(immolation_aura_aura) Spell(immolation_aura)
				if target.Distance(less 18) and target.DebuffRemains(corruption_aura) <10 Spell(void_ray)
				if not target.DebuffPresent(doom_aura) or target.DebuffRemains(doom_aura) <=30 Spell(doom)
				if target.Distance(less 18) Spell(void_ray)
			}
			if not Stance(1) and not BuffPresent(hellfire)
			{
				if not target.DebuffPresent(corruption_aura) or target.DebuffRemains(corruption_aura) <3 Spell(corruption)
				Spell(hand_of_guldan)
				if target.DebuffRemains(corruption_aura) <10 or DemonicFury() >=950 or BuffPresent(dark_soul_knowledge) Spell(metamorphosis)
				if target.Distance(less 8) Spell(hellfire)
			}
		}
		if CheckBoxOff(aoe)
		{
			if TargetClassification(worldboss) Spell(summon_doomguard)
			if Stance(1)
			{
				if target.DebuffRemains(corruption_aura) <3 Spell(touch_of_chaos)
				if not target.DebuffPresent(doom_aura) or target.DebuffRemains(doom_aura) <=30 Spell(doom)
				if DemonicFury() <=650 and not BuffPresent(dark_soul_knowledge) cancel.Texture(Spell_shadow_demonform)
				if DemonicFury() <40 cancel.Texture(Spell_shadow_demonform)
				if {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} and BuffStacks(molten_core) Spell(soul_fire)
				if {Speed() >0 or not BuffStacks(molten_core)} Spell(touch_of_chaos)
			}
			if not Stance(1)
			{
				if not target.DebuffPresent(corruption_aura) or target.DebuffRemains(corruption_aura) <3 Spell(corruption)
				if DemonicFury() >=950 or BuffPresent(dark_soul_knowledge) Spell(metamorphosis)
				if not InFlightToTarget(hand_of_guldan) and not PreviousSpell(hand_of_guldan) and {not target.DebuffPresent(shadowflame) or target.DebuffRemains(shadowflame) <1 +CastTime(shadow_bolt)} Spell(hand_of_guldan)
				if {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} and BuffStacks(molten_core) and {BuffStacks(molten_core) >9 or target.HealthPercent(less 28)} Spell(soul_fire)
				if ManaPercent() <60 Spell(life_tap)
				if {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} Spell(shadow_bolt)
				if Speed() >0 and not TalentPoints(kiljaedens_cunning_talent) Spell(fel_flame)
			}
		}
	}	
}
AddIcon specialization=3 help=main
{
	if not InCombat() 
    {
		if {not BuffPresent(spell_power_multiplier any=1) or not BuffPresent(stamina any=1)} and not mounted() Spell(dark_intent)
		if TalentPoints(grimoire_of_sacrifice_talent) and not pet.Present() and not BuffPresent(grimoire_of_sacrifice) Spell(summon_felhunter)
		if TalentPoints(grimoire_of_sacrifice_talent) and pet.Present() and not BuffPresent(grimoire_of_sacrifice) Spell(grimoire_of_sacrifice)
    }
	if InCombat() and TargetInRange(conflagrate) and HasFullControl()
	{
		if target.DebuffExpires(magic_vulnerability any=1) Spell(curse_of_the_elements)
		if BurningEmbers() >=30 and SpellUsable(dark_soul_instability) Spell(dark_soul_instability)
		if CheckBoxOn(fnb)
		{
			if TargetClassification(worldboss) Spell(summon_infernal)
			if not BuffPresent(rain_of_fire) Spell(rain_of_fire)
			if not BuffPresent(fire_and_brimstone) and BurningEmbers() >=10 Spell(fire_and_brimstone)
			if BuffPresent(fire_and_brimstone) and {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} and not PreviousSpell(immolate_fnb) and {not target.DebuffPresent(immolate_fnb) or target.DebuffRemains(immolate_fnb) <=3} Spell(immolate_fnb)
			if BuffPresent(fire_and_brimstone) and not BuffStacks(backdraft) >3 Spell(conflagrate)
			if BuffPresent(fire_and_brimstone) and {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} Spell(incinerate)
			if {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} Spell(incinerate)
		}
		if CheckBoxOff(fnb)
		{
			if TargetClassification(worldboss) Spell(summon_doomguard)
			if BuffPresent(fire_and_brimstone) cancel.Texture(ability_warlock_fireandbrimstone)
			if focus.Present() and not focus.DebuffPresent(havoc) and BurningEmbers() >=10 Spell(havoc usable=1)
			if target.HealthPercent() <=20 and BurningEmbers() >=10 and {BurningEmbers() >35 or BuffPresent(dark_soul_instability) or ManaPercent() <=20} Spell(shadowburn)
			if target.HealthPercent() <=20 and BurningEmbers() >=10 and BuffStacks(havoc) <=3 Spell(shadowburn)
			if {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} and not PreviousSpell(immolate) and {not target.DebuffPresent(immolate_debuff) or target.DebuffRemains(immolate_debuff) <=3} Spell(immolate)
			if SpellCharges(conflagrate) ==2 and not focus.Present() Spell(conflagrate)
			if SpellCharges(conflagrate) ==2 and focus.Present() and not focus.DebuffPresent(havoc) Spell(conflagrate)
			if {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} and target.HealthPercent() >20 and BurningEmbers() >=10 and {BurningEmbers() >35 or BuffPresent(dark_soul_instability) or BuffPresent(skull_banner)} Spell(chaos_bolt)
			if {Speed() ==0 or TalentPoints(kiljaedens_cunning_talent)} and target.HealthPercent() >20 and BurningEmbers() >=10 and BuffStacks(havoc) ==3 and not PreviousSpell(chaos_bolt) Spell(chaos_bolt)
			if not BuffStacks(backdraft) >3 Spell(conflagrate)
			if Speed() ==0 or TalentPoints(kiljaedens_cunning_talent) Spell(incinerate)
			if Speed() >0 and not TalentPoints(kiljaedens_cunning_talent) Spell(fel_flame)
		}
	}
}
AddCheckBox(aoe "AoE" specialization=2)
AddCheckBox(fnb "Disco Inferno" specialization=3)
]]

	OvaleScripts:RegisterScript("WARLOCK", nil, name, desc, code, "script")
end
