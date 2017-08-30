local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_destruction"
	local desc = "[Xel][7.0.3] Warlock: Destruction"
	local code = [[
# Based on SimulationCraft profile "Warlock_Destruction_T18M".
#	class=warlock
#	spec=destruction
#	talents=2301033
#	pet=felhunter

Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)

AddIcon specialization=3 help=main
{
	if not mounted()
    {
		if not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() Spell(summon_felhunter)
		if Talent(grimoire_of_sacrifice_talent) and not Talent(demonic_servitude_talent) and pet.Present() and not { pet.CreatureFamily(Voidwalker) or pet.CreatureFamily(Doomguard)} Spell(grimoire_of_sacrifice)
    }
	
	# Interrupt
	# if InCombat() and target.Casting(interrupt_list) InterruptActions()
	
	if InCombat() and target.InRange(chaos_bolt) and HasFullControl()
    {
		# Cooldowns
		if Boss()
		{
			if NotMoving() DestructionDefaultCdActions()
		}
		
		# Short Cooldowns
		if NotMoving() DestructionDefaultShortCdActions()
		
		# Default rotation
		if NotMoving() DestructionDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction NotMoving
{
	{ Speed() == 0 }
}

### actions.default

AddFunction DestructionDefaultMainActions
{
	#immolate,if=remains<=tick_time
	if target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) Spell(immolate)
	#immolate,if=talent.roaring_blaze.enabled&remains<=duration&!debuff.roaring_blaze.remains&(action.conflagrate.charges=2|(action.conflagrate.charges>=1&action.conflagrate.recharge_time<cast_time+gcd))
	if Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) and not target.DebuffPresent(roaring_blaze_debuff) and { Charges(conflagrate) == 2 or Charges(conflagrate) >= 1 and SpellChargeCooldown(conflagrate) < CastTime(immolate) + GCD() } Spell(immolate)
	#conflagrate,if=talent.roaring_blaze.enabled&(charges=2|(action.conflagrate.charges>=1&action.conflagrate.recharge_time<gcd))
	if Talent(roaring_blaze_talent) and { Charges(conflagrate) == 2 or Charges(conflagrate) >= 1 and SpellChargeCooldown(conflagrate) < GCD() } Spell(conflagrate)
	#conflagrate,if=talent.roaring_blaze.enabled&prev_gcd.conflagrate
	if Talent(roaring_blaze_talent) and PreviousGCDSpell(conflagrate) Spell(conflagrate)
	#conflagrate,if=talent.roaring_blaze.enabled&debuff.roaring_blaze.stack=2
	if Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) == 2 Spell(conflagrate)
	#conflagrate,if=talent.roaring_blaze.enabled&debuff.roaring_blaze.stack=3&buff.bloodlust.remains
	if Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) == 3 and BuffPresent(burst_haste_buff any=1) Spell(conflagrate)
	#conflagrate,if=!talent.roaring_blaze.enabled&buff.conflagration_of_chaos.remains<=action.chaos_bolt.cast_time
	if not Talent(roaring_blaze_talent) and BuffRemaining(conflagration_of_chaos_buff) <= CastTime(chaos_bolt) Spell(conflagrate)
	#conflagrate,if=!talent.roaring_blaze.enabled&(charges=1&recharge_time<action.chaos_bolt.cast_time|charges=2)&soul_shard<5
	if not Talent(roaring_blaze_talent) and { Charges(conflagrate) == 1 and SpellChargeCooldown(conflagrate) < CastTime(chaos_bolt) or Charges(conflagrate) == 2 } and SoulShards() < 5 Spell(conflagrate)
	#channel_demonfire,if=dot.immolate.remains>cast_time
	if target.DebuffRemaining(immolate_debuff) > CastTime(channel_demonfire) Spell(channel_demonfire)
	#chaos_bolt,if=soul_shard>3
	if SoulShards() > 3 Spell(chaos_bolt)
	#mana_tap,if=buff.mana_tap.remains<=buff.mana_tap.duration*0.3&target.time_to_die>buff.mana_tap.duration*0.3
	if BuffRemaining(mana_tap_buff) <= BaseDuration(mana_tap_buff) * 0.3 and target.TimeToDie() > BaseDuration(mana_tap_buff) * 0.3 Spell(mana_tap)
	#chaos_bolt
	Spell(chaos_bolt)
	#conflagrate,if=!talent.roaring_blaze.enabled
	if not Talent(roaring_blaze_talent) Spell(conflagrate)
	#immolate,if=!talent.roaring_blaze.enabled&remains<=duration*0.3
	if not Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) * 0.3 Spell(immolate)
	#life_tap,if=talent.mana_tap.enabled&mana.pct<=10
	if Talent(mana_tap_talent) and ManaPercent() <= 10 Spell(life_tap)
	#incinerate
	Spell(incinerate)
	#life_tap
	Spell(life_tap)
}

AddFunction DestructionDefaultShortCdActions
{
	unless target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and Spell(immolate) or Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) and not target.DebuffPresent(roaring_blaze_debuff) and { Charges(conflagrate) == 2 or Charges(conflagrate) >= 1 and SpellChargeCooldown(conflagrate) < CastTime(immolate) + GCD() } and Spell(immolate) or Talent(roaring_blaze_talent) and { Charges(conflagrate) == 2 or Charges(conflagrate) >= 1 and SpellChargeCooldown(conflagrate) < GCD() } and Spell(conflagrate) or Talent(roaring_blaze_talent) and PreviousGCDSpell(conflagrate) and Spell(conflagrate) or Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) == 2 and Spell(conflagrate) or Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) == 3 and BuffPresent(burst_haste_buff any=1) and Spell(conflagrate) or not Talent(roaring_blaze_talent) and BuffRemaining(conflagration_of_chaos_buff) <= CastTime(chaos_bolt) and Spell(conflagrate) or not Talent(roaring_blaze_talent) and { Charges(conflagrate) == 1 and SpellChargeCooldown(conflagrate) < CastTime(chaos_bolt) or Charges(conflagrate) == 2 } and SoulShards() < 5 and Spell(conflagrate)
	{
		#service_pet
		Spell(service_felhunter)

		unless target.DebuffRemaining(immolate_debuff) > CastTime(channel_demonfire) and Spell(channel_demonfire) or SoulShards() > 3 and Spell(chaos_bolt)
		{
			#dimensional_rift
			Spell(dimensional_rift)

			unless BuffRemaining(mana_tap_buff) <= BaseDuration(mana_tap_buff) * 0.3 and target.TimeToDie() > BaseDuration(mana_tap_buff) * 0.3 and Spell(mana_tap) or Spell(chaos_bolt)
			{
				#cataclysm
				Spell(cataclysm)
			}
		}
	}
}

AddFunction DestructionDefaultCdActions
{
	#use_item,name=nithramus_the_allseer
	# Item(legendary_ring_intellect usable=1)

	unless target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and Spell(immolate) or Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) and not target.DebuffPresent(roaring_blaze_debuff) and { Charges(conflagrate) == 2 or Charges(conflagrate) >= 1 and SpellChargeCooldown(conflagrate) < CastTime(immolate) + GCD() } and Spell(immolate)
	{
		#berserking
		Spell(berserking)
		#blood_fury
		Spell(blood_fury_sp)
		#arcane_torrent
		Spell(arcane_torrent_mana)
		#potion,name=draenic_intellect,if=buff.nithramus.remains
		# if BuffPresent(nithramus_buff) DestructionUsePotionIntellect()

		unless Talent(roaring_blaze_talent) and { Charges(conflagrate) == 2 or Charges(conflagrate) >= 1 and SpellChargeCooldown(conflagrate) < GCD() } and Spell(conflagrate) or Talent(roaring_blaze_talent) and PreviousGCDSpell(conflagrate) and Spell(conflagrate) or Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) == 2 and Spell(conflagrate) or Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) == 3 and BuffPresent(burst_haste_buff any=1) and Spell(conflagrate) or not Talent(roaring_blaze_talent) and BuffRemaining(conflagration_of_chaos_buff) <= CastTime(chaos_bolt) and Spell(conflagrate) or not Talent(roaring_blaze_talent) and { Charges(conflagrate) == 1 and SpellChargeCooldown(conflagrate) < CastTime(chaos_bolt) or Charges(conflagrate) == 2 } and SoulShards() < 5 and Spell(conflagrate) or Spell(service_felhunter)
		{
			#summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening<3
			if not Talent(grimoire_of_supremacy_talent) and CheckBoxOff(aoe) Spell(summon_doomguard)
			#summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening>=3
			# if not Talent(grimoire_of_supremacy_talent) and CheckBoxOn(aoe) Spell(summon_infernal)
			#soul_harvest
			Spell(soul_harvest)
		}
	}
}

### actions.precombat

AddFunction DestructionPrecombatMainActions
{
	#snapshot_stats
	#grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
	if Talent(grimoire_of_sacrifice_talent) and pet.Present() Spell(grimoire_of_sacrifice)
	#mana_tap,if=talent.mana_tap.enabled&!buff.mana_tap.remains
	if Talent(mana_tap_talent) and not BuffPresent(mana_tap_buff) Spell(mana_tap)
	#incinerate
	Spell(incinerate)
}

AddFunction DestructionPrecombatShortCdActions
{
	#flask,type=greater_draenic_intellect_flask
	#food,type=frosty_stew
	#summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
	if not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() Spell(summon_felhunter)
}

AddFunction DestructionPrecombatShortCdPostConditions
{
	Talent(mana_tap_talent) and not BuffPresent(mana_tap_buff) and Spell(mana_tap) or Spell(incinerate)
}

AddFunction DestructionPrecombatCdActions
{
	unless not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_felhunter)
	{
		#summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies<3
		if Talent(grimoire_of_supremacy_talent) and CheckBoxOff(aoe) Spell(summon_doomguard)
		#summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>=3
		# if Talent(grimoire_of_supremacy_talent) and CheckBoxOn(aoe) Spell(summon_infernal)
		#potion,name=draenic_intellect
		# DestructionUsePotionIntellect()
	}
}

AddFunction DestructionPrecombatCdPostConditions
{
	not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_felhunter) or Talent(mana_tap_talent) and not BuffPresent(mana_tap_buff) and Spell(mana_tap) or Spell(incinerate)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "destruction", name, desc, code, "script")
end
