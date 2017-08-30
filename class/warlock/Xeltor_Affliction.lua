local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_affliction"
	local desc = "[Xel][7.1] Warlock: Affliction"
	local code = [[
# Based on SimulationCraft profile "Warlock_Affliction_T18M".
#	class=warlock
#	spec=affliction
#	talents=2203011
#	pet=felhunter

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)


Define(health_funnel 755)
Define(spell_lock_fh 19647)
	SpellInfo(spell_lock_fh cd=24)

AddIcon specialization=1 help=main
{
	if not mounted() PetStuff()

	# Interrupt
	if InCombat() InterruptActions()
	
	if InCombat() and target.InRange(agony) and HasFullControl()
    {
		#life_tap
		if ManaPercent() < 25 Spell(life_tap)
		
		# Cooldowns
		if Boss()
		{
			if NotMoving() AfflictionDefaultCdActions()
		}
		
		# Short Cooldowns
		if NotMoving() AfflictionDefaultShortCdActions()
		
		# Default rotation
		if NotMoving() AfflictionDefaultMainActions()
		
		#agony,if=remains<=tick_time+gcd
		if target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() Spell(agony)
		#corruption,if=remains<=tick_time+gcd
		if target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() Spell(corruption)
		#siphon_life,if=remains<=tick_time+gcd
		if target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() Spell(siphon_life)
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(spell_lock_fh) Spell(spell_lock_fh)
	}
}

AddFunction PetStuff
{
	if HealthPercent() > 50 and pet.HealthPercent() < 50 and pet.Present() and pet.Exists() Spell(health_funnel)
}

AddFunction NotMoving
{
	{ Speed() == 0 }
}

### actions.default

AddFunction AfflictionDefaultMainActions
{
	#reap_souls,if=!buff.deadwind_harvester.remains&(buff.soul_harvest.remains>5+equipped.144364*1.5&!talent.malefic_grasp.enabled&buff.active_uas.stack>1|buff.tormented_souls.react>=8|target.time_to_die<=buff.tormented_souls.react*5+equipped.144364*1.5|!talent.malefic_grasp.enabled&(trinket.proc.any.react|trinket.stacking_proc.any.react))
	if not BuffPresent(deadwind_harvester_buff) and { BuffRemaining(soul_harvest_buff) > 5 + HasEquippedItem(144364) * 1.5 and not Talent(malefic_grasp_talent) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffStacks(tormented_souls_buff) >= 8 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * 5 + HasEquippedItem(144364) * 1.5 or not Talent(malefic_grasp_talent) and { BuffPresent(trinket_proc_any_buff) or BuffPresent(trinket_stacking_proc_any_buff) } } Spell(reap_souls)
	#soul_effigy,if=!pet.soul_effigy.active
	if not pet.Present() Spell(soul_effigy)
	#agony,cycle_targets=1,if=remains<=tick_time+gcd
	if target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() Spell(agony)
	#potion,name=prolonged_power,if=!talent.soul_harvest.enabled&(trinket.proc.any.react|trinket.stack_proc.any.react|target.time_to_die<=70|!cooldown.haunt.remains|buff.active_uas.stack>2)
	#potion,name=prolonged_power,if=talent.soul_harvest.enabled&buff.soul_harvest.remains&(trinket.proc.any.react|trinket.stack_proc.any.react|target.time_to_die<=70|!cooldown.haunt.remains|buff.active_uas.stack>2)
	#corruption,if=remains<=tick_time+gcd&(spell_targets.seed_of_corruption<3&talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<4)&(buff.active_uas.stack<2&soul_shard=0|!talent.malefic_grasp.enabled)
	if target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies() < 3 and Talent(sow_the_seeds_talent) or Enemies() < 4 } and { target.DebuffStacks(unstable_affliction_debuff) < 2 and SoulShards() == 0 or not Talent(malefic_grasp_talent) } Spell(corruption)
	#corruption,cycle_targets=1,if=(talent.absolute_corruption.enabled|!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&active_enemies>1&remains<=tick_time+gcd&(spell_targets.seed_of_corruption<3&talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<4)
	if { Talent(absolute_corruption_talent) or not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and Enemies() > 1 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies() < 3 and Talent(sow_the_seeds_talent) or Enemies() < 4 } Spell(corruption)
	#siphon_life,if=remains<=tick_time+gcd&(buff.active_uas.stack<2&soul_shard=0|!talent.malefic_grasp.enabled)
	if target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and { target.DebuffStacks(unstable_affliction_debuff) < 2 and SoulShards() == 0 or not Talent(malefic_grasp_talent) } Spell(siphon_life)
	#siphon_life,cycle_targets=1,if=(!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&active_enemies>1&remains<=tick_time+gcd
	if { not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and Enemies() > 1 and target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() Spell(siphon_life)
	#life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
	if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() Spell(life_tap)
	#haunt
	Spell(haunt)
	#agony,cycle_targets=1,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
	if not Talent(malefic_grasp_talent) and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) Spell(agony)
	#agony,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains&buff.active_uas.stack=0
	if target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 Spell(agony)
	#life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3|talent.malefic_grasp.enabled&target.time_to_die>15&mana.pct<10
	if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 Spell(life_tap)
	#seed_of_corruption,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3|spell_targets.seed_of_corruption>=4|spell_targets.seed_of_corruption=3&dot.corruption.remains<=cast_time+travel_time
	if Talent(sow_the_seeds_talent) and Enemies() >= 3 or Enemies() >= 4 or Enemies() == 3 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) Spell(seed_of_corruption)
	#corruption,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
	if not Talent(malefic_grasp_talent) and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) Spell(corruption)
	#corruption,if=remains<=duration*0.3&target.time_to_die>=remains&buff.active_uas.stack=0
	if target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 Spell(corruption)
	#corruption,cycle_targets=1,if=(talent.absolute_corruption.enabled|!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&remains<=duration*0.3&target.time_to_die>=remains
	if { Talent(absolute_corruption_talent) or not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) Spell(corruption)
	#siphon_life,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
	if not Talent(malefic_grasp_talent) and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) Spell(siphon_life)
	#siphon_life,if=remains<=duration*0.3&target.time_to_die>=remains&buff.active_uas.stack=0
	if target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 Spell(siphon_life)
	#siphon_life,cycle_targets=1,if=(!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&remains<=duration*0.3&target.time_to_die>=remains
	if { not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) Spell(siphon_life)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&talent.haunt.enabled&(soul_shard>=4|debuff.haunt.remains>6.5|target.time_to_die<30)
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Talent(haunt_talent) and { SoulShards() >= 4 or target.DebuffRemaining(haunt_debuff) > 6.5 or target.TimeToDie() < 30 } Spell(unstable_affliction)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.writhe_in_agony.enabled&talent.contagion.enabled&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(writhe_in_agony_talent) and Talent(contagion_talent) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) Spell(unstable_affliction)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.writhe_in_agony.enabled&(soul_shard>=4|trinket.proc.intellect.react|trinket.stacking_proc.mastery.react|trinket.proc.mastery.react|trinket.proc.crit.react|trinket.proc.versatility.react|buff.soul_harvest.remains|buff.deadwind_harvester.remains|buff.compounding_horror.react=5|target.time_to_die<=20)
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(writhe_in_agony_talent) and { SoulShards() >= 4 or BuffPresent(trinket_proc_intellect_buff) or BuffPresent(trinket_stacking_proc_mastery_buff) or BuffPresent(trinket_proc_mastery_buff) or BuffPresent(trinket_proc_crit_buff) or BuffPresent(trinket_proc_versatility_buff) or BuffPresent(soul_harvest_buff) or BuffPresent(deadwind_harvester_buff) or BuffStacks(compounding_horror_buff) == 5 or target.TimeToDie() <= 20 } Spell(unstable_affliction)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&(target.time_to_die<30|prev_gcd.1.unstable_affliction&soul_shard>=4)
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { target.TimeToDie() < 30 or PreviousGCDSpell(unstable_affliction) and SoulShards() >= 4 } Spell(unstable_affliction)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&(soul_shard=5|talent.contagion.enabled&soul_shard>=4)
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { SoulShards() == 5 or Talent(contagion_talent) and SoulShards() >= 4 } Spell(unstable_affliction)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&(talent.soul_effigy.enabled|equipped.132457)&!prev_gcd.3.unstable_affliction&prev_gcd.1.unstable_affliction
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { Talent(soul_effigy_talent) or HasEquippedItem(132457) } and not PreviousGCDSpell(unstable_affliction count=3) and PreviousGCDSpell(unstable_affliction) Spell(unstable_affliction)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&equipped.132457&buff.active_uas.stack=0
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and HasEquippedItem(132457) and target.DebuffStacks(unstable_affliction_debuff) == 0 Spell(unstable_affliction)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&talent.soul_effigy.enabled&!equipped.132457&buff.active_uas.stack=0&dot.agony.remains>cast_time*3+6.5&(!talent.soul_effigy.enabled|pet.soul_effigy.dot.agony.remains>cast_time*3+6.5)
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and Talent(soul_effigy_talent) and not HasEquippedItem(132457) and target.DebuffStacks(unstable_affliction_debuff) == 0 and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 and { not Talent(soul_effigy_talent) or pet.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 } Spell(unstable_affliction)
	#unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&!talent.soul_effigy.enabled&!equipped.132457&!prev_gcd.3.unstable_affliction&dot.agony.remains>cast_time*3+6.5&(dot.corruption.remains>cast_time+6.5|talent.absolute_corruption.enabled)
	if { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and not Talent(soul_effigy_talent) and not HasEquippedItem(132457) and not PreviousGCDSpell(unstable_affliction count=3) and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 and { target.DebuffRemaining(corruption_debuff) > CastTime(unstable_affliction) + 6.5 or Talent(absolute_corruption_talent) } Spell(unstable_affliction)
	#reap_souls,if=!buff.deadwind_harvester.remains&buff.active_uas.stack>1&((!trinket.has_stacking_stat.any&!trinket.has_stat.any)|talent.malefic_grasp.enabled)
	if not BuffPresent(deadwind_harvester_buff) and target.DebuffStacks(unstable_affliction_debuff) > 1 and { not True(trinket_has_stacking_stat_any) and not True(trinket_has_stat_any) or Talent(malefic_grasp_talent) } Spell(reap_souls)
	#reap_souls,if=!buff.deadwind_harvester.remains&prev_gcd.1.unstable_affliction&((!trinket.has_stacking_stat.any&!trinket.has_stat.any)|talent.malefic_grasp.enabled)&buff.tormented_souls.react>1
	if not BuffPresent(deadwind_harvester_buff) and PreviousGCDSpell(unstable_affliction) and { not True(trinket_has_stacking_stat_any) and not True(trinket_has_stat_any) or Talent(malefic_grasp_talent) } and BuffStacks(tormented_souls_buff) > 1 Spell(reap_souls)
	#life_tap,if=mana.pct<=10
	if ManaPercent() <= 10 Spell(life_tap)
	#drain_soul,chain=1,interrupt=1
	Spell(drain_soul)
	#life_tap
	Spell(life_tap)
}

AddFunction AfflictionDefaultMainPostConditions
{
}

AddFunction AfflictionDefaultShortCdActions
{
	unless not BuffPresent(deadwind_harvester_buff) and { BuffRemaining(soul_harvest_buff) > 5 + HasEquippedItem(144364) * 1.5 and not Talent(malefic_grasp_talent) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffStacks(tormented_souls_buff) >= 8 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * 5 + HasEquippedItem(144364) * 1.5 or not Talent(malefic_grasp_talent) and { BuffPresent(trinket_proc_any_buff) or BuffPresent(trinket_stacking_proc_any_buff) } } and Spell(reap_souls) or not pet.Present() and Spell(soul_effigy) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony)
	{
		#service_pet,if=dot.corruption.remains&dot.agony.remains
		if target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) Spell(service_felhunter)

		unless target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies() < 3 and Talent(sow_the_seeds_talent) or Enemies() < 4 } and { target.DebuffStacks(unstable_affliction_debuff) < 2 and SoulShards() == 0 or not Talent(malefic_grasp_talent) } and Spell(corruption) or { Talent(absolute_corruption_talent) or not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and Enemies() > 1 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies() < 3 and Talent(sow_the_seeds_talent) or Enemies() < 4 } and Spell(corruption) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and { target.DebuffStacks(unstable_affliction_debuff) < 2 and SoulShards() == 0 or not Talent(malefic_grasp_talent) } and Spell(siphon_life) or { not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and Enemies() > 1 and target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and Spell(siphon_life) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap)
		{
			#phantom_singularity
			Spell(phantom_singularity)
		}
	}
}

AddFunction AfflictionDefaultShortCdPostConditions
{
	not BuffPresent(deadwind_harvester_buff) and { BuffRemaining(soul_harvest_buff) > 5 + HasEquippedItem(144364) * 1.5 and not Talent(malefic_grasp_talent) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffStacks(tormented_souls_buff) >= 8 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * 5 + HasEquippedItem(144364) * 1.5 or not Talent(malefic_grasp_talent) and { BuffPresent(trinket_proc_any_buff) or BuffPresent(trinket_stacking_proc_any_buff) } } and Spell(reap_souls) or not pet.Present() and Spell(soul_effigy) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies() < 3 and Talent(sow_the_seeds_talent) or Enemies() < 4 } and { target.DebuffStacks(unstable_affliction_debuff) < 2 and SoulShards() == 0 or not Talent(malefic_grasp_talent) } and Spell(corruption) or { Talent(absolute_corruption_talent) or not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and Enemies() > 1 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies() < 3 and Talent(sow_the_seeds_talent) or Enemies() < 4 } and Spell(corruption) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and { target.DebuffStacks(unstable_affliction_debuff) < 2 and SoulShards() == 0 or not Talent(malefic_grasp_talent) } and Spell(siphon_life) or { not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and Enemies() > 1 and target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and Spell(siphon_life) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or Spell(haunt) or not Talent(malefic_grasp_talent) and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and Spell(agony) or target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 and Spell(agony) or { Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 } and Spell(life_tap) or { Talent(sow_the_seeds_talent) and Enemies() >= 3 or Enemies() >= 4 or Enemies() == 3 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) } and Spell(seed_of_corruption) or not Talent(malefic_grasp_talent) and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and Spell(corruption) or target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 and Spell(corruption) or { Talent(absolute_corruption_talent) or not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and Spell(corruption) or not Talent(malefic_grasp_talent) and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and Spell(siphon_life) or target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 and Spell(siphon_life) or { not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and Spell(siphon_life) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Talent(haunt_talent) and { SoulShards() >= 4 or target.DebuffRemaining(haunt_debuff) > 6.5 or target.TimeToDie() < 30 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(writhe_in_agony_talent) and Talent(contagion_talent) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(writhe_in_agony_talent) and { SoulShards() >= 4 or BuffPresent(trinket_proc_intellect_buff) or BuffPresent(trinket_stacking_proc_mastery_buff) or BuffPresent(trinket_proc_mastery_buff) or BuffPresent(trinket_proc_crit_buff) or BuffPresent(trinket_proc_versatility_buff) or BuffPresent(soul_harvest_buff) or BuffPresent(deadwind_harvester_buff) or BuffStacks(compounding_horror_buff) == 5 or target.TimeToDie() <= 20 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { target.TimeToDie() < 30 or PreviousGCDSpell(unstable_affliction) and SoulShards() >= 4 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { SoulShards() == 5 or Talent(contagion_talent) and SoulShards() >= 4 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { Talent(soul_effigy_talent) or HasEquippedItem(132457) } and not PreviousGCDSpell(unstable_affliction count=3) and PreviousGCDSpell(unstable_affliction) and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and HasEquippedItem(132457) and target.DebuffStacks(unstable_affliction_debuff) == 0 and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and Talent(soul_effigy_talent) and not HasEquippedItem(132457) and target.DebuffStacks(unstable_affliction_debuff) == 0 and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 and { not Talent(soul_effigy_talent) or pet.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and not Talent(soul_effigy_talent) and not HasEquippedItem(132457) and not PreviousGCDSpell(unstable_affliction count=3) and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 and { target.DebuffRemaining(corruption_debuff) > CastTime(unstable_affliction) + 6.5 or Talent(absolute_corruption_talent) } and Spell(unstable_affliction) or not BuffPresent(deadwind_harvester_buff) and target.DebuffStacks(unstable_affliction_debuff) > 1 and { not True(trinket_has_stacking_stat_any) and not True(trinket_has_stat_any) or Talent(malefic_grasp_talent) } and Spell(reap_souls) or not BuffPresent(deadwind_harvester_buff) and PreviousGCDSpell(unstable_affliction) and { not True(trinket_has_stacking_stat_any) and not True(trinket_has_stat_any) or Talent(malefic_grasp_talent) } and BuffStacks(tormented_souls_buff) > 1 and Spell(reap_souls) or ManaPercent() <= 10 and Spell(life_tap) or Spell(drain_soul) or Spell(life_tap)
}

AddFunction AfflictionDefaultCdActions
{
	unless not BuffPresent(deadwind_harvester_buff) and { BuffRemaining(soul_harvest_buff) > 5 + HasEquippedItem(144364) * 1.5 and not Talent(malefic_grasp_talent) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffStacks(tormented_souls_buff) >= 8 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * 5 + HasEquippedItem(144364) * 1.5 or not Talent(malefic_grasp_talent) and { BuffPresent(trinket_proc_any_buff) or BuffPresent(trinket_stacking_proc_any_buff) } } and Spell(reap_souls) or not pet.Present() and Spell(soul_effigy) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) and Spell(service_felhunter)
	{
		#summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
		if not Talent(grimoire_of_supremacy_talent) and Enemies() <= 2 and { target.TimeToDie() > 180 or target.HealthPercent() <= 20 or target.TimeToDie() < 30 } Spell(summon_doomguard)
		#summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>2
		if not Talent(grimoire_of_supremacy_talent) and Enemies() > 2 Spell(summon_infernal)
		#summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
		if Talent(grimoire_of_supremacy_talent) and Enemies() == 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_doomguard)
		#summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
		if Talent(grimoire_of_supremacy_talent) and Enemies() > 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_infernal)
		#berserking,if=prev_gcd.1.unstable_affliction|buff.soul_harvest.remains>=10
		if PreviousGCDSpell(unstable_affliction) or BuffRemaining(soul_harvest_buff) >= 10 Spell(berserking)
		#blood_fury
		Spell(blood_fury_sp)
		#arcane_torrent
		Spell(arcane_torrent_mana)
		#soul_harvest,if=buff.active_uas.stack>=3|!equipped.132394&!equipped.132457&(debuff.haunt.remains|talent.writhe_in_agony.enabled)
		if target.DebuffStacks(unstable_affliction_debuff) >= 3 or not HasEquippedItem(132394) and not HasEquippedItem(132457) and { target.DebuffPresent(haunt_debuff) or Talent(writhe_in_agony_talent) } Spell(soul_harvest)
	}
}

AddFunction AfflictionDefaultCdPostConditions
{
	not BuffPresent(deadwind_harvester_buff) and { BuffRemaining(soul_harvest_buff) > 5 + HasEquippedItem(144364) * 1.5 and not Talent(malefic_grasp_talent) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffStacks(tormented_souls_buff) >= 8 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * 5 + HasEquippedItem(144364) * 1.5 or not Talent(malefic_grasp_talent) and { BuffPresent(trinket_proc_any_buff) or BuffPresent(trinket_stacking_proc_any_buff) } } and Spell(reap_souls) or not pet.Present() and Spell(soul_effigy) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) and Spell(service_felhunter) or target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies() < 3 and Talent(sow_the_seeds_talent) or Enemies() < 4 } and { target.DebuffStacks(unstable_affliction_debuff) < 2 and SoulShards() == 0 or not Talent(malefic_grasp_talent) } and Spell(corruption) or { Talent(absolute_corruption_talent) or not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and Enemies() > 1 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies() < 3 and Talent(sow_the_seeds_talent) or Enemies() < 4 } and Spell(corruption) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and { target.DebuffStacks(unstable_affliction_debuff) < 2 and SoulShards() == 0 or not Talent(malefic_grasp_talent) } and Spell(siphon_life) or { not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and Enemies() > 1 and target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and Spell(siphon_life) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or Spell(phantom_singularity) or Spell(haunt) or not Talent(malefic_grasp_talent) and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and Spell(agony) or target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 and Spell(agony) or { Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 } and Spell(life_tap) or { Talent(sow_the_seeds_talent) and Enemies() >= 3 or Enemies() >= 4 or Enemies() == 3 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) } and Spell(seed_of_corruption) or not Talent(malefic_grasp_talent) and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and Spell(corruption) or target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 and Spell(corruption) or { Talent(absolute_corruption_talent) or not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and Spell(corruption) or not Talent(malefic_grasp_talent) and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and Spell(siphon_life) or target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and target.DebuffStacks(unstable_affliction_debuff) == 0 and Spell(siphon_life) or { not Talent(malefic_grasp_talent) or not Talent(soul_effigy_talent) } and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and Spell(siphon_life) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Talent(haunt_talent) and { SoulShards() >= 4 or target.DebuffRemaining(haunt_debuff) > 6.5 or target.TimeToDie() < 30 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(writhe_in_agony_talent) and Talent(contagion_talent) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(writhe_in_agony_talent) and { SoulShards() >= 4 or BuffPresent(trinket_proc_intellect_buff) or BuffPresent(trinket_stacking_proc_mastery_buff) or BuffPresent(trinket_proc_mastery_buff) or BuffPresent(trinket_proc_crit_buff) or BuffPresent(trinket_proc_versatility_buff) or BuffPresent(soul_harvest_buff) or BuffPresent(deadwind_harvester_buff) or BuffStacks(compounding_horror_buff) == 5 or target.TimeToDie() <= 20 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { target.TimeToDie() < 30 or PreviousGCDSpell(unstable_affliction) and SoulShards() >= 4 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { SoulShards() == 5 or Talent(contagion_talent) and SoulShards() >= 4 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and { Talent(soul_effigy_talent) or HasEquippedItem(132457) } and not PreviousGCDSpell(unstable_affliction count=3) and PreviousGCDSpell(unstable_affliction) and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and HasEquippedItem(132457) and target.DebuffStacks(unstable_affliction_debuff) == 0 and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and Talent(soul_effigy_talent) and not HasEquippedItem(132457) and target.DebuffStacks(unstable_affliction_debuff) == 0 and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 and { not Talent(soul_effigy_talent) or pet.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 } and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies() < 3 } and Enemies() < 4 and Talent(malefic_grasp_talent) and not Talent(soul_effigy_talent) and not HasEquippedItem(132457) and not PreviousGCDSpell(unstable_affliction count=3) and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) * 3 + 6.5 and { target.DebuffRemaining(corruption_debuff) > CastTime(unstable_affliction) + 6.5 or Talent(absolute_corruption_talent) } and Spell(unstable_affliction) or not BuffPresent(deadwind_harvester_buff) and target.DebuffStacks(unstable_affliction_debuff) > 1 and { not True(trinket_has_stacking_stat_any) and not True(trinket_has_stat_any) or Talent(malefic_grasp_talent) } and Spell(reap_souls) or not BuffPresent(deadwind_harvester_buff) and PreviousGCDSpell(unstable_affliction) and { not True(trinket_has_stacking_stat_any) and not True(trinket_has_stat_any) or Talent(malefic_grasp_talent) } and BuffStacks(tormented_souls_buff) > 1 and Spell(reap_souls) or ManaPercent() <= 10 and Spell(life_tap) or Spell(drain_soul) or Spell(life_tap)
}

### actions.precombat

AddFunction AfflictionPrecombatMainActions
{
	#augmentation,type=defiled
	Spell(augmentation)
	#snapshot_stats
	#grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
	if Talent(grimoire_of_sacrifice_talent) and pet.Present() Spell(grimoire_of_sacrifice)
	#life_tap,if=talent.empowered_life_tap.enabled&!buff.empowered_life_tap.remains
	if Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) Spell(life_tap)
}

AddFunction AfflictionPrecombatMainPostConditions
{
}

AddFunction AfflictionPrecombatShortCdActions
{
	#flask,type=whispered_pact
	#food,type=nightborne_delicacy_platter
	#summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
	if not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() Spell(summon_felhunter)
}

AddFunction AfflictionPrecombatShortCdPostConditions
{
	Spell(augmentation) or Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) and Spell(life_tap)
}

AddFunction AfflictionPrecombatCdActions
{
	unless not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_felhunter)
	{
		#summon_infernal,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0
		if Talent(grimoire_of_supremacy_talent) and ArtifactTraitRank(lord_of_flames) > 0 Spell(summon_infernal)
		#summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>1
		if Talent(grimoire_of_supremacy_talent) and Enemies() > 1 Spell(summon_infernal)
		#summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies=1&artifact.lord_of_flames.rank=0
		if Talent(grimoire_of_supremacy_talent) and Enemies() == 1 and ArtifactTraitRank(lord_of_flames) == 0 Spell(summon_doomguard)
	}
}

AddFunction AfflictionPrecombatCdPostConditions
{
	not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_felhunter) or Spell(augmentation) or Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) and Spell(life_tap)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "affliction", name, desc, code, "script")
end
