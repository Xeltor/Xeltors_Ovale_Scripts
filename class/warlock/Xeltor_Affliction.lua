local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_affliction"
	local desc = "[Xel][7.3] Warlock: Affliction"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)

Define(health_funnel 755)
Define(spell_lock_fh 19647)
	SpellInfo(spell_lock_fh cd=24)
Define(shadow_lock_dg 171138)
	SpellInfo(shadow_lock_dg cd=24)

AddIcon specialization=1 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
	if InCombat() and target.InRange(agony) and HasFullControl()
    {
		#life_tap
		if ManaPercent() < 25 Spell(life_tap)
		if pet.CreatureFamily(Voidwalker) or pet.CreatureFamily(Voidlord) or pet.CreatureFamily(Infernal) PetStuff()
		
		# Cooldowns
		if Boss()
		{
			if Speed() == 0 or CanMove() > 0 AfflictionDefaultCdActions()
		}
		
		# Short Cooldowns
		if Speed() == 0 or CanMove() > 0 AfflictionDefaultShortCdActions()
		
		# Default rotation
		if Speed() == 0 or CanMove() > 0 AfflictionDefaultMainActions()
		
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
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		# Felhunter Spell Lock
		if target.Distance() - pet.Distance() <= 40 and pet.CreatureFamily(Felhunter) Spell(spell_lock_fh)
		# Doomguard Shadow Lock
		if target.Distance() - pet.Distance() <= 40 and pet.CreatureFamily(Doomguard) Spell(shadow_lock_dg)
	}
}

AddFunction PetStuff
{
	if pet.Health() < pet.MaxHealth() / 2 and pet.Present() and Speed() == 0 Spell(health_funnel)
}

### actions.default

AddFunction AfflictionDefaultMainActions
{
 #call_action_list,name=mg,if=talent.malefic_grasp.enabled
 if Talent(malefic_grasp_talent) AfflictionMgMainActions()

 unless Talent(malefic_grasp_talent) and AfflictionMgMainPostConditions()
 {
  #call_action_list,name=writhe,if=talent.writhe_in_agony.enabled
  if Talent(writhe_in_agony_talent) AfflictionWritheMainActions()

  unless Talent(writhe_in_agony_talent) and AfflictionWritheMainPostConditions()
  {
   #call_action_list,name=haunt,if=talent.haunt.enabled
   if Talent(haunt_talent) AfflictionHauntMainActions()
  }
 }
}

AddFunction AfflictionDefaultMainPostConditions
{
 Talent(malefic_grasp_talent) and AfflictionMgMainPostConditions() or Talent(writhe_in_agony_talent) and AfflictionWritheMainPostConditions() or Talent(haunt_talent) and AfflictionHauntMainPostConditions()
}

AddFunction AfflictionDefaultShortCdActions
{
 #call_action_list,name=mg,if=talent.malefic_grasp.enabled
 if Talent(malefic_grasp_talent) AfflictionMgShortCdActions()

 unless Talent(malefic_grasp_talent) and AfflictionMgShortCdPostConditions()
 {
  #call_action_list,name=writhe,if=talent.writhe_in_agony.enabled
  if Talent(writhe_in_agony_talent) AfflictionWritheShortCdActions()

  unless Talent(writhe_in_agony_talent) and AfflictionWritheShortCdPostConditions()
  {
   #call_action_list,name=haunt,if=talent.haunt.enabled
   if Talent(haunt_talent) AfflictionHauntShortCdActions()
  }
 }
}

AddFunction AfflictionDefaultShortCdPostConditions
{
 Talent(malefic_grasp_talent) and AfflictionMgShortCdPostConditions() or Talent(writhe_in_agony_talent) and AfflictionWritheShortCdPostConditions() or Talent(haunt_talent) and AfflictionHauntShortCdPostConditions()
}

AddFunction AfflictionDefaultCdActions
{
 #call_action_list,name=mg,if=talent.malefic_grasp.enabled
 if Talent(malefic_grasp_talent) AfflictionMgCdActions()

 unless Talent(malefic_grasp_talent) and AfflictionMgCdPostConditions()
 {
  #call_action_list,name=writhe,if=talent.writhe_in_agony.enabled
  if Talent(writhe_in_agony_talent) AfflictionWritheCdActions()

  unless Talent(writhe_in_agony_talent) and AfflictionWritheCdPostConditions()
  {
   #call_action_list,name=haunt,if=talent.haunt.enabled
   if Talent(haunt_talent) AfflictionHauntCdActions()
  }
 }
}

AddFunction AfflictionDefaultCdPostConditions
{
 Talent(malefic_grasp_talent) and AfflictionMgCdPostConditions() or Talent(writhe_in_agony_talent) and AfflictionWritheCdPostConditions() or Talent(haunt_talent) and AfflictionHauntCdPostConditions()
}

### actions.haunt

AddFunction AfflictionHauntMainActions
{
 #reap_souls,if=!buff.deadwind_harvester.remains&time>5&(buff.tormented_souls.react>=5|target.time_to_die<=buff.tormented_souls.react*(5+1.5*equipped.144364)+(buff.deadwind_harvester.remains*(5+1.5*equipped.144364)%12*(5+1.5*equipped.144364)))
 if not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } Spell(reap_souls)
 #reap_souls,if=debuff.haunt.remains&!buff.deadwind_harvester.remains
 if target.DebuffPresent(haunt_debuff) and not BuffPresent(deadwind_harvester_buff) Spell(reap_souls)
 #reap_souls,if=active_enemies>1&!buff.deadwind_harvester.remains&time>5&soul_shard>0&((talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3)|spell_targets.seed_of_corruption>=5)
 if Enemies(tagged=1) > 1 and not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and SoulShards() > 0 and { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 } Spell(reap_souls)
 #agony,cycle_targets=1,if=remains<=tick_time+gcd
 if target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() Spell(agony)
 #drain_soul,cycle_targets=1,if=target.time_to_die<=gcd*2&soul_shard<5
 if target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 Spell(drain_soul)
 #siphon_life,cycle_targets=1,if=remains<=tick_time+gcd
 if target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() Spell(siphon_life)
 #corruption,cycle_targets=1,if=remains<=tick_time+gcd&(spell_targets.seed_of_corruption<3&talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<5)
 if target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies(tagged=1) < 3 and Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 5 } Spell(corruption)
 #reap_souls,if=(buff.deadwind_harvester.remains+buff.tormented_souls.react*(5+equipped.144364))>=(12*(5+1.5*equipped.144364))
 if BuffRemaining(deadwind_harvester_buff) + BuffStacks(tormented_souls_buff) * { 5 + HasEquippedItem(144364) } >= 12 * { 5 + 1.5 * HasEquippedItem(144364) } Spell(reap_souls)
 #life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
 if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() Spell(life_tap)
 #haunt
 Spell(haunt)
 #agony,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains
 if target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) Spell(agony)
 #life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3|talent.malefic_grasp.enabled&target.time_to_die>15&mana.pct<10
 if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 Spell(life_tap)
 #siphon_life,if=remains<=duration*0.3&target.time_to_die>=remains
 if target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) Spell(siphon_life)
 #siphon_life,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*6&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*4
 if target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 6 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 4 Spell(siphon_life)
 #seed_of_corruption,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3|spell_targets.seed_of_corruption>=5|spell_targets.seed_of_corruption>=3&dot.corruption.remains<=cast_time+travel_time
 if Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 or Enemies(tagged=1) >= 3 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) Spell(seed_of_corruption)
 #corruption,if=remains<=duration*0.3&target.time_to_die>=remains
 if target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) Spell(corruption)
 #corruption,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*6&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*4
 if target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 6 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 4 Spell(corruption)
 #unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&((soul_shard>=4&!talent.contagion.enabled)|soul_shard>=5|target.time_to_die<30)
 if { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and { SoulShards() >= 4 and not Talent(contagion_talent) or SoulShards() >= 5 or target.TimeToDie() < 30 } Spell(unstable_affliction)
 #unstable_affliction,cycle_targets=1,if=active_enemies>1&(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&soul_shard>=4&talent.contagion.enabled&cooldown.haunt.remains<15&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
 if Enemies(tagged=1) > 1 and { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and SoulShards() >= 4 and Talent(contagion_talent) and SpellCooldown(haunt) < 15 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) Spell(unstable_affliction)
 #unstable_affliction,cycle_targets=1,if=active_enemies>1&(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&(equipped.132381|equipped.132457)&cooldown.haunt.remains<15&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
 if Enemies(tagged=1) > 1 and { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and { HasEquippedItem(132381) or HasEquippedItem(132457) } and SpellCooldown(haunt) < 15 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) Spell(unstable_affliction)
 #unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&talent.contagion.enabled&soul_shard>=4&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
 if { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and Talent(contagion_talent) and SoulShards() >= 4 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) Spell(unstable_affliction)
 #unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&debuff.haunt.remains>=action.unstable_affliction_1.tick_time*2
 if { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 2 Spell(unstable_affliction)
 #reap_souls,if=!buff.deadwind_harvester.remains&(buff.active_uas.stack>1|(prev_gcd.1.unstable_affliction&buff.tormented_souls.react>1))
 if not BuffPresent(deadwind_harvester_buff) and { target.DebuffStacks(unstable_affliction_debuff) > 1 or PreviousGCDSpell(unstable_affliction) and BuffStacks(tormented_souls_buff) > 1 } Spell(reap_souls)
 #life_tap,if=mana.pct<=10
 if ManaPercent() <= 10 Spell(life_tap)
 #life_tap,if=prev_gcd.1.life_tap&buff.active_uas.stack=0&mana.pct<50
 if PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 Spell(life_tap)
 #agony,safety
 if target.DebuffRemaining(agony_debuff) <= target.CastTime(drain_soul) + GCD() Spell(agony)
 #drain_soul,chain=1,interrupt=1
 Spell(drain_soul)
 #life_tap,moving=1,if=mana.pct<80
 if Speed() > 0 and ManaPercent() < 80 Spell(life_tap)
 #agony,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) Spell(agony)
 #siphon_life,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) Spell(siphon_life)
 #corruption,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) Spell(corruption)
 #life_tap,moving=0
 if not Speed() > 0 Spell(life_tap)
}

AddFunction AfflictionHauntMainPostConditions
{
}

AddFunction AfflictionHauntShortCdActions
{
 unless not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or target.DebuffPresent(haunt_debuff) and not BuffPresent(deadwind_harvester_buff) and Spell(reap_souls) or Enemies(tagged=1) > 1 and not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and SoulShards() > 0 and { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 } and Spell(reap_souls) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 and Spell(drain_soul)
 {
  #service_pet,if=dot.corruption.remains&dot.agony.remains
  if target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) Spell(service_felhunter)

  unless target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and Spell(siphon_life) or target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies(tagged=1) < 3 and Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 5 } and Spell(corruption) or BuffRemaining(deadwind_harvester_buff) + BuffStacks(tormented_souls_buff) * { 5 + HasEquippedItem(144364) } >= 12 * { 5 + 1.5 * HasEquippedItem(144364) } and Spell(reap_souls) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap)
  {
   #phantom_singularity
   Spell(phantom_singularity)
  }
 }
}

AddFunction AfflictionHauntShortCdPostConditions
{
 not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or target.DebuffPresent(haunt_debuff) and not BuffPresent(deadwind_harvester_buff) and Spell(reap_souls) or Enemies(tagged=1) > 1 and not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and SoulShards() > 0 and { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 } and Spell(reap_souls) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and Spell(siphon_life) or target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies(tagged=1) < 3 and Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 5 } and Spell(corruption) or BuffRemaining(deadwind_harvester_buff) + BuffStacks(tormented_souls_buff) * { 5 + HasEquippedItem(144364) } >= 12 * { 5 + 1.5 * HasEquippedItem(144364) } and Spell(reap_souls) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or Spell(haunt) or target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and Spell(agony) or { Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 } and Spell(life_tap) or target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and Spell(siphon_life) or target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 6 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 4 and Spell(siphon_life) or { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 or Enemies(tagged=1) >= 3 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) } and Spell(seed_of_corruption) or target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and Spell(corruption) or target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 6 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 4 and Spell(corruption) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and { SoulShards() >= 4 and not Talent(contagion_talent) or SoulShards() >= 5 or target.TimeToDie() < 30 } and Spell(unstable_affliction) or Enemies(tagged=1) > 1 and { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and SoulShards() >= 4 and Talent(contagion_talent) and SpellCooldown(haunt) < 15 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or Enemies(tagged=1) > 1 and { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and { HasEquippedItem(132381) or HasEquippedItem(132457) } and SpellCooldown(haunt) < 15 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and Talent(contagion_talent) and SoulShards() >= 4 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 2 and Spell(unstable_affliction) or not BuffPresent(deadwind_harvester_buff) and { target.DebuffStacks(unstable_affliction_debuff) > 1 or PreviousGCDSpell(unstable_affliction) and BuffStacks(tormented_souls_buff) > 1 } and Spell(reap_souls) or ManaPercent() <= 10 and Spell(life_tap) or PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 and Spell(life_tap) or Spell(drain_soul) or Speed() > 0 and ManaPercent() < 80 and Spell(life_tap) or Speed() > 0 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) and Spell(agony) or Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) and Spell(siphon_life) or Speed() > 0 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) and Spell(corruption) or not Speed() > 0 and Spell(life_tap)
}

AddFunction AfflictionHauntCdActions
{
 unless not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or target.DebuffPresent(haunt_debuff) and not BuffPresent(deadwind_harvester_buff) and Spell(reap_souls) or Enemies(tagged=1) > 1 and not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and SoulShards() > 0 and { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 } and Spell(reap_souls) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) and Spell(service_felhunter)
 {
  #summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
  if not Talent(grimoire_of_supremacy_talent) and not Talent(grimoire_of_sacrifice_talent) and Enemies(tagged=1) <= 2 and { target.TimeToDie() > 180 or target.HealthPercent() <= 20 or target.TimeToDie() < 30 } Spell(summon_doomguard)
  #summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>2
  if not Talent(grimoire_of_supremacy_talent) and not Talent(grimoire_of_sacrifice_talent) and Enemies(tagged=1) > 2 Spell(summon_infernal)
  #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
  # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_doomguard)
  #summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
  # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_infernal)
  #berserking,if=prev_gcd.1.unstable_affliction|buff.soul_harvest.remains>=10
  if PreviousGCDSpell(unstable_affliction) or BuffRemaining(soul_harvest_buff) >= 10 Spell(berserking)
  #blood_fury
  Spell(blood_fury_sp)
  #soul_harvest,if=buff.soul_harvest.remains<=8&buff.active_uas.stack>=1&(raid_event.adds.in>20|active_enemies>1|!raid_event.adds.exists)
  if BuffRemaining(soul_harvest_buff) <= 8 and target.DebuffStacks(unstable_affliction_debuff) >= 1 Spell(soul_harvest)
  #potion,if=!talent.soul_harvest.enabled&(trinket.proc.any.react|trinket.stack_proc.any.react|target.time_to_die<=70|buff.active_uas.stack>2)
  # if not Talent(soul_harvest_talent) and { BuffPresent(trinket_proc_any_buff) or BuffPresent(trinket_stack_proc_any_buff) or target.TimeToDie() <= 70 or target.DebuffStacks(unstable_affliction_debuff) > 2 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
  #potion,if=talent.soul_harvest.enabled&buff.soul_harvest.remains&(trinket.proc.any.react|trinket.stack_proc.any.react|target.time_to_die<=70|!cooldown.haunt.remains|buff.active_uas.stack>2)
  # if Talent(soul_harvest_talent) and BuffPresent(soul_harvest_buff) and { BuffPresent(trinket_proc_any_buff) or BuffPresent(trinket_stack_proc_any_buff) or target.TimeToDie() <= 70 or not SpellCooldown(haunt) > 0 or target.DebuffStacks(unstable_affliction_debuff) > 2 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 }
}

AddFunction AfflictionHauntCdPostConditions
{
 not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or target.DebuffPresent(haunt_debuff) and not BuffPresent(deadwind_harvester_buff) and Spell(reap_souls) or Enemies(tagged=1) > 1 and not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and SoulShards() > 0 and { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 } and Spell(reap_souls) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) and Spell(service_felhunter) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and Spell(siphon_life) or target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies(tagged=1) < 3 and Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 5 } and Spell(corruption) or BuffRemaining(deadwind_harvester_buff) + BuffStacks(tormented_souls_buff) * { 5 + HasEquippedItem(144364) } >= 12 * { 5 + 1.5 * HasEquippedItem(144364) } and Spell(reap_souls) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or Spell(phantom_singularity) or Spell(haunt) or target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and Spell(agony) or { Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 } and Spell(life_tap) or target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and Spell(siphon_life) or target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 6 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 4 and Spell(siphon_life) or { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 or Enemies(tagged=1) >= 3 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) } and Spell(seed_of_corruption) or target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and Spell(corruption) or target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 6 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 4 and Spell(corruption) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and { SoulShards() >= 4 and not Talent(contagion_talent) or SoulShards() >= 5 or target.TimeToDie() < 30 } and Spell(unstable_affliction) or Enemies(tagged=1) > 1 and { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and SoulShards() >= 4 and Talent(contagion_talent) and SpellCooldown(haunt) < 15 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or Enemies(tagged=1) > 1 and { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and { HasEquippedItem(132381) or HasEquippedItem(132457) } and SpellCooldown(haunt) < 15 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and Talent(contagion_talent) and SoulShards() >= 4 and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(haunt_debuff) >= target.TickTime(unstable_affliction_debuff) * 2 and Spell(unstable_affliction) or not BuffPresent(deadwind_harvester_buff) and { target.DebuffStacks(unstable_affliction_debuff) > 1 or PreviousGCDSpell(unstable_affliction) and BuffStacks(tormented_souls_buff) > 1 } and Spell(reap_souls) or ManaPercent() <= 10 and Spell(life_tap) or PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 and Spell(life_tap) or Spell(drain_soul) or Speed() > 0 and ManaPercent() < 80 and Spell(life_tap) or Speed() > 0 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) and Spell(agony) or Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) and Spell(siphon_life) or Speed() > 0 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) and Spell(corruption) or not Speed() > 0 and Spell(life_tap)
}

### actions.mg

AddFunction AfflictionMgMainActions
{
 #reap_souls,if=!buff.deadwind_harvester.remains&time>5&((buff.tormented_souls.react>=4+active_enemies|buff.tormented_souls.react>=9)|target.time_to_die<=buff.tormented_souls.react*(5+1.5*equipped.144364)+(buff.deadwind_harvester.remains*(5+1.5*equipped.144364)%12*(5+1.5*equipped.144364)))
 if not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 4 + Enemies(tagged=1) or BuffStacks(tormented_souls_buff) >= 9 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } Spell(reap_souls)
 #agony,cycle_targets=1,max_cycle_targets=5,target_if=sim.target!=target&talent.soul_harvest.enabled&cooldown.soul_harvest.remains<cast_time*6&remains<=duration*0.3&target.time_to_die>=remains&time_to_die>tick_time*3
 if DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 Spell(agony)
 #agony,cycle_targets=1,max_cycle_targets=4,if=remains<=(tick_time+gcd)
 if DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 4 and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() Spell(agony)
 #seed_of_corruption,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3&soul_shard=5
 if Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 Spell(seed_of_corruption)
 #unstable_affliction,if=target=sim.target&soul_shard=5
 if True(target_is_sim_target) and SoulShards() == 5 Spell(unstable_affliction)
 #drain_soul,cycle_targets=1,if=target.time_to_die<gcd*2&soul_shard<5
 if target.TimeToDie() < GCD() * 2 and SoulShards() < 5 Spell(drain_soul)
 #life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
 if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() Spell(life_tap)
 #siphon_life,cycle_targets=1,if=remains<=(tick_time+gcd)&target.time_to_die>tick_time*3
 if target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 3 Spell(siphon_life)
 #corruption,cycle_targets=1,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&remains<=(tick_time+gcd)&target.time_to_die>tick_time*3
 if { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and target.TimeToDie() > target.TickTime(corruption_debuff) * 3 Spell(corruption)
 #agony,cycle_targets=1,if=remains<=(duration*0.3)&target.time_to_die>=remains&(buff.active_uas.stack=0|prev_gcd.1.agony)
 if target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(agony) } Spell(agony)
 #siphon_life,cycle_targets=1,if=remains<=(duration*0.3)&target.time_to_die>=remains&(buff.active_uas.stack=0|prev_gcd.1.siphon_life)
 if target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(siphon_life) } Spell(siphon_life)
 #corruption,cycle_targets=1,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<5&remains<=(duration*0.3)&target.time_to_die>=remains&(buff.active_uas.stack=0|prev_gcd.1.corruption)
 if { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(corruption) } Spell(corruption)
 #life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3|talent.malefic_grasp.enabled&target.time_to_die>15&mana.pct<10
 if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 Spell(life_tap)
 #seed_of_corruption,if=(talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3)|(spell_targets.seed_of_corruption>=5&dot.corruption.remains<=cast_time+travel_time)
 if Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) Spell(seed_of_corruption)
 #unstable_affliction,if=target=sim.target&target.time_to_die<30
 if True(target_is_sim_target) and target.TimeToDie() < 30 Spell(unstable_affliction)
 #unstable_affliction,if=target=sim.target&active_enemies>1&soul_shard>=4
 if True(target_is_sim_target) and Enemies(tagged=1) > 1 and SoulShards() >= 4 Spell(unstable_affliction)
 #unstable_affliction,if=target=sim.target&(buff.active_uas.stack=0|(!prev_gcd.3.unstable_affliction&prev_gcd.1.unstable_affliction))&dot.agony.remains>cast_time+(6.5*spell_haste)
 if True(target_is_sim_target) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or not PreviousGCDSpell(unstable_affliction count=3) and PreviousGCDSpell(unstable_affliction) } and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) + 6.5 * { 100 / { 100 + SpellHaste() } } Spell(unstable_affliction)
 #reap_souls,if=buff.deadwind_harvester.remains<dot.unstable_affliction_1.remains|buff.deadwind_harvester.remains<dot.unstable_affliction_2.remains|buff.deadwind_harvester.remains<dot.unstable_affliction_3.remains|buff.deadwind_harvester.remains<dot.unstable_affliction_4.remains|buff.deadwind_harvester.remains<dot.unstable_affliction_5.remains&buff.active_uas.stack>1
 if BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 1 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 2 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 3 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 4 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 5 } and target.DebuffStacks(unstable_affliction_debuff) > 1 Spell(reap_souls)
 #life_tap,if=mana.pct<=10
 if ManaPercent() <= 10 Spell(life_tap)
 #life_tap,if=prev_gcd.1.life_tap&buff.active_uas.stack=0&mana.pct<50
 if PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 Spell(life_tap)
 #drain_soul,chain=1,interrupt=1
 Spell(drain_soul)
 #life_tap,moving=1,if=mana.pct<80
 if Speed() > 0 and ManaPercent() < 80 Spell(life_tap)
 #agony,moving=1,cycle_targets=1,if=remains<duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(agony_debuff) < BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) Spell(agony)
 #siphon_life,moving=1,cycle_targets=1,if=remains<duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) < BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) Spell(siphon_life)
 #corruption,moving=1,cycle_targets=1,if=remains<duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(corruption_debuff) < BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) Spell(corruption)
 #life_tap,moving=0
 if not Speed() > 0 Spell(life_tap)
}

AddFunction AfflictionMgMainPostConditions
{
}

AddFunction AfflictionMgShortCdActions
{
 unless not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 4 + Enemies(tagged=1) or BuffStacks(tormented_souls_buff) >= 9 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 4 and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 and Spell(seed_of_corruption) or True(target_is_sim_target) and SoulShards() == 5 and Spell(unstable_affliction) or target.TimeToDie() < GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap)
 {
  #service_pet,if=dot.corruption.remains&dot.agony.remains
  if target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) Spell(service_felhunter)

  unless target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 3 and Spell(siphon_life) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and target.TimeToDie() > target.TickTime(corruption_debuff) * 3 and Spell(corruption)
  {
   #phantom_singularity
   Spell(phantom_singularity)
  }
 }
}

AddFunction AfflictionMgShortCdPostConditions
{
 not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 4 + Enemies(tagged=1) or BuffStacks(tormented_souls_buff) >= 9 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 4 and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 and Spell(seed_of_corruption) or True(target_is_sim_target) and SoulShards() == 5 and Spell(unstable_affliction) or target.TimeToDie() < GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 3 and Spell(siphon_life) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and target.TimeToDie() > target.TickTime(corruption_debuff) * 3 and Spell(corruption) or target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(agony) } and Spell(agony) or target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(siphon_life) } and Spell(siphon_life) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(corruption) } and Spell(corruption) or { Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 } and Spell(life_tap) or { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) } and Spell(seed_of_corruption) or True(target_is_sim_target) and target.TimeToDie() < 30 and Spell(unstable_affliction) or True(target_is_sim_target) and Enemies(tagged=1) > 1 and SoulShards() >= 4 and Spell(unstable_affliction) or True(target_is_sim_target) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or not PreviousGCDSpell(unstable_affliction count=3) and PreviousGCDSpell(unstable_affliction) } and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) + 6.5 * { 100 / { 100 + SpellHaste() } } and Spell(unstable_affliction) or { BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 1 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 2 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 3 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 4 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 5 } and target.DebuffStacks(unstable_affliction_debuff) > 1 } and Spell(reap_souls) or ManaPercent() <= 10 and Spell(life_tap) or PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 and Spell(life_tap) or Spell(drain_soul) or Speed() > 0 and ManaPercent() < 80 and Spell(life_tap) or Speed() > 0 and target.DebuffRemaining(agony_debuff) < BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) and Spell(agony) or Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) < BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) and Spell(siphon_life) or Speed() > 0 and target.DebuffRemaining(corruption_debuff) < BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) and Spell(corruption) or not Speed() > 0 and Spell(life_tap)
}

AddFunction AfflictionMgCdActions
{
 unless not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 4 + Enemies(tagged=1) or BuffStacks(tormented_souls_buff) >= 9 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 4 and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 and Spell(seed_of_corruption) or True(target_is_sim_target) and SoulShards() == 5 and Spell(unstable_affliction) or target.TimeToDie() < GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) and Spell(service_felhunter)
 {
  #summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
  if not Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) <= 2 and { target.TimeToDie() > 180 or target.HealthPercent() <= 20 or target.TimeToDie() < 30 } Spell(summon_doomguard)
  #summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>2
  if not Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 2 Spell(summon_infernal)
  #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
  # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_doomguard)
  #summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
  # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_infernal)
  #berserking,if=prev_gcd.1.unstable_affliction|buff.soul_harvest.remains>=10
  if PreviousGCDSpell(unstable_affliction) or BuffRemaining(soul_harvest_buff) >= 10 Spell(berserking)
  #blood_fury
  Spell(blood_fury_sp)

  unless target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 3 and Spell(siphon_life) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and target.TimeToDie() > target.TickTime(corruption_debuff) * 3 and Spell(corruption) or Spell(phantom_singularity)
  {
   #soul_harvest,if=buff.active_uas.stack>1&buff.soul_harvest.remains<=8&sim.target=target&(!talent.deaths_embrace.enabled|target.time_to_die>=136|target.time_to_die<=40)
   if target.DebuffStacks(unstable_affliction_debuff) > 1 and BuffRemaining(soul_harvest_buff) <= 8 and True(target_is_sim_target) and { not Talent(deaths_embrace_talent) or target.TimeToDie() >= 136 or target.TimeToDie() <= 40 } Spell(soul_harvest)
   #potion,if=target.time_to_die<=70
   # if target.TimeToDie() <= 70 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
   #potion,if=(!talent.soul_harvest.enabled|buff.soul_harvest.remains>12)&buff.active_uas.stack>=2
   # if { not Talent(soul_harvest_talent) or BuffRemaining(soul_harvest_buff) > 12 } and target.DebuffStacks(unstable_affliction_debuff) >= 2 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
  }
 }
}

AddFunction AfflictionMgCdPostConditions
{
 not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 4 + Enemies(tagged=1) or BuffStacks(tormented_souls_buff) >= 9 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 4 and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 and Spell(seed_of_corruption) or True(target_is_sim_target) and SoulShards() == 5 and Spell(unstable_affliction) or target.TimeToDie() < GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) and Spell(service_felhunter) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 3 and Spell(siphon_life) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and target.TimeToDie() > target.TickTime(corruption_debuff) * 3 and Spell(corruption) or Spell(phantom_singularity) or target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(agony) } and Spell(agony) or target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(siphon_life) } and Spell(siphon_life) or { not Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 3 } and Enemies(tagged=1) < 5 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or PreviousGCDSpell(corruption) } and Spell(corruption) or { Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 or Talent(malefic_grasp_talent) and target.TimeToDie() > 15 and ManaPercent() < 10 } and Spell(life_tap) or { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 5 and target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TravelTime(seed_of_corruption) } and Spell(seed_of_corruption) or True(target_is_sim_target) and target.TimeToDie() < 30 and Spell(unstable_affliction) or True(target_is_sim_target) and Enemies(tagged=1) > 1 and SoulShards() >= 4 and Spell(unstable_affliction) or True(target_is_sim_target) and { target.DebuffStacks(unstable_affliction_debuff) == 0 or not PreviousGCDSpell(unstable_affliction count=3) and PreviousGCDSpell(unstable_affliction) } and target.DebuffRemaining(agony_debuff) > CastTime(unstable_affliction) + 6.5 * { 100 / { 100 + SpellHaste() } } and Spell(unstable_affliction) or { BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 1 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 2 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 3 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 4 } or BuffRemaining(deadwind_harvester_buff) < { target.DebuffStacks(unstable_affliction_debuff) >= 5 } and target.DebuffStacks(unstable_affliction_debuff) > 1 } and Spell(reap_souls) or ManaPercent() <= 10 and Spell(life_tap) or PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 and Spell(life_tap) or Spell(drain_soul) or Speed() > 0 and ManaPercent() < 80 and Spell(life_tap) or Speed() > 0 and target.DebuffRemaining(agony_debuff) < BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) and Spell(agony) or Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) < BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) and Spell(siphon_life) or Speed() > 0 and target.DebuffRemaining(corruption_debuff) < BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) and Spell(corruption) or not Speed() > 0 and Spell(life_tap)
}

### actions.precombat

AddFunction AfflictionPrecombatMainActions
{
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
 #flask
 #food
 #augmentation
 #summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
 if not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() Spell(summon_felhunter)
}

AddFunction AfflictionPrecombatShortCdPostConditions
{
 Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) and Spell(life_tap)
}

AddFunction AfflictionPrecombatCdActions
{
 unless not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_felhunter)
 {
  #summon_infernal,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0
  # if Talent(grimoire_of_supremacy_talent) and ArtifactTraitRank(lord_of_flames) > 0 Spell(summon_infernal)
  #summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>1
  # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 1 Spell(summon_infernal)
  #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies=1&artifact.lord_of_flames.rank=0
  # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and ArtifactTraitRank(lord_of_flames) == 0 Spell(summon_doomguard)

  unless Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) and Spell(life_tap)
  {
   #potion
   # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
  }
 }
}

AddFunction AfflictionPrecombatCdPostConditions
{
 not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_felhunter) or Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) and Spell(life_tap)
}

### actions.writhe

AddFunction AfflictionWritheMainActions
{
 #reap_souls,if=!buff.deadwind_harvester.remains&time>5&(buff.tormented_souls.react>=5|target.time_to_die<=buff.tormented_souls.react*(5+1.5*equipped.144364)+(buff.deadwind_harvester.remains*(5+1.5*equipped.144364)%12*(5+1.5*equipped.144364)))
 if not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } Spell(reap_souls)
 #reap_souls,if=!buff.deadwind_harvester.remains&time>5&(buff.soul_harvest.remains>=(5+1.5*equipped.144364)&buff.active_uas.stack>1|buff.concordance_of_the_legionfall.react|trinket.proc.intellect.react|trinket.stacking_proc.intellect.react|trinket.proc.mastery.react|trinket.stacking_proc.mastery.react|trinket.proc.crit.react|trinket.stacking_proc.crit.react|trinket.proc.versatility.react|trinket.stacking_proc.versatility.react|trinket.proc.spell_power.react|trinket.stacking_proc.spell_power.react)
 if not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffRemaining(soul_harvest_buff) >= 5 + 1.5 * HasEquippedItem(144364) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffPresent(concordance_of_the_legionfall_buff) or BuffPresent(trinket_proc_intellect_buff) or BuffPresent(trinket_stacking_proc_intellect_buff) or BuffPresent(trinket_proc_mastery_buff) or BuffPresent(trinket_stacking_proc_mastery_buff) or BuffPresent(trinket_proc_crit_buff) or BuffPresent(trinket_stacking_proc_crit_buff) or BuffPresent(trinket_proc_versatility_buff) or BuffPresent(trinket_stacking_proc_versatility_buff) or BuffPresent(trinket_proc_spell_power_buff) or BuffPresent(trinket_stacking_proc_spell_power_buff) } Spell(reap_souls)
 #agony,if=remains<=tick_time+gcd
 if target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() Spell(agony)
 #agony,cycle_targets=1,max_cycle_targets=5,target_if=sim.target!=target&talent.soul_harvest.enabled&cooldown.soul_harvest.remains<cast_time*6&remains<=duration*0.3&target.time_to_die>=remains&time_to_die>tick_time*3
 if DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 Spell(agony)
 #agony,cycle_targets=1,max_cycle_targets=3,target_if=sim.target!=target&remains<=tick_time+gcd&time_to_die>tick_time*3
 if DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 3 and False(target_is_sim_target) and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and target.TimeToDie() > target.TickTime(agony_debuff) * 3 Spell(agony)
 #seed_of_corruption,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3&soul_shard=5
 if Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 Spell(seed_of_corruption)
 #unstable_affliction,if=soul_shard=5|(time_to_die<=((duration+cast_time)*soul_shard))
 if SoulShards() == 5 or target.TimeToDie() <= { BaseDuration(unstable_affliction_debuff) + CastTime(unstable_affliction) } * SoulShards() Spell(unstable_affliction)
 #drain_soul,cycle_targets=1,if=target.time_to_die<=gcd*2&soul_shard<5
 if target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 Spell(drain_soul)
 #life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
 if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() Spell(life_tap)
 #siphon_life,cycle_targets=1,if=remains<=tick_time+gcd&time_to_die>tick_time*2
 if target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 2 Spell(siphon_life)
 #corruption,cycle_targets=1,if=remains<=tick_time+gcd&((spell_targets.seed_of_corruption<3&talent.sow_the_seeds.enabled)|spell_targets.seed_of_corruption<5)&time_to_die>tick_time*2
 if target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies(tagged=1) < 3 and Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 5 } and target.TimeToDie() > target.TickTime(corruption_debuff) * 2 Spell(corruption)
 #life_tap,if=mana.pct<40&(buff.active_uas.stack<1|!buff.deadwind_harvester.remains)
 if ManaPercent() < 40 and { target.DebuffStacks(unstable_affliction_debuff) < 1 or not BuffPresent(deadwind_harvester_buff) } Spell(life_tap)
 #reap_souls,if=(buff.deadwind_harvester.remains+buff.tormented_souls.react*(5+equipped.144364))>=(12*(5+1.5*equipped.144364))
 if BuffRemaining(deadwind_harvester_buff) + BuffStacks(tormented_souls_buff) * { 5 + HasEquippedItem(144364) } >= 12 * { 5 + 1.5 * HasEquippedItem(144364) } Spell(reap_souls)
 #seed_of_corruption,if=(talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3)|(spell_targets.seed_of_corruption>3&dot.corruption.refreshable)
 if Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) > 3 and target.DebuffRefreshable(corruption_debuff) Spell(seed_of_corruption)
 #unstable_affliction,if=talent.contagion.enabled&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
 if Talent(contagion_talent) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) Spell(unstable_affliction)
 #unstable_affliction,if=talent.absolute_corruption.enabled&set_bonus.tier21_4pc&debuff.tormented_agony.remains<=cast_time
 if Talent(absolute_corruption_talent) and ArmorSetBonus(T21 4) and target.DebuffRemaining(tormented_agony_debuff) <= CastTime(unstable_affliction) Spell(unstable_affliction)
 #unstable_affliction,cycle_targets=1,target_if=buff.deadwind_harvester.remains>=duration+cast_time&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
 if BuffRemaining(deadwind_harvester_buff) >= BaseDuration(unstable_affliction_debuff) + CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) Spell(unstable_affliction)
 #unstable_affliction,if=buff.deadwind_harvester.remains>tick_time*2&(!set_bonus.tier21_4pc|talent.contagion.enabled|soul_shard>1)&(!talent.contagion.enabled|soul_shard>1|buff.soul_harvest.remains)&(dot.unstable_affliction_1.ticking+dot.unstable_affliction_2.ticking+dot.unstable_affliction_3.ticking+dot.unstable_affliction_4.ticking+dot.unstable_affliction_5.ticking<5)
 if BuffRemaining(deadwind_harvester_buff) > target.TickTime(unstable_affliction_debuff) * 2 and { not ArmorSetBonus(T21 4) or Talent(contagion_talent) or SoulShards() > 1 } and { not Talent(contagion_talent) or SoulShards() > 1 or BuffPresent(soul_harvest_buff) } and target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) < 5 Spell(unstable_affliction)
 #reap_souls,if=!buff.deadwind_harvester.remains&buff.active_uas.stack>1
 if not BuffPresent(deadwind_harvester_buff) and target.DebuffStacks(unstable_affliction_debuff) > 1 Spell(reap_souls)
 #reap_souls,if=!buff.deadwind_harvester.remains&prev_gcd.1.unstable_affliction&buff.tormented_souls.react>1
 if not BuffPresent(deadwind_harvester_buff) and PreviousGCDSpell(unstable_affliction) and BuffStacks(tormented_souls_buff) > 1 Spell(reap_souls)
 #life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3&(!buff.deadwind_harvester.remains|buff.active_uas.stack<1)
 if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 and { not BuffPresent(deadwind_harvester_buff) or target.DebuffStacks(unstable_affliction_debuff) < 1 } Spell(life_tap)
 #agony,if=refreshable&time_to_die>=remains
 if target.Refreshable(agony_debuff) and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) Spell(agony)
 #siphon_life,if=refreshable&time_to_die>=remains
 if target.Refreshable(siphon_life_debuff) and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) Spell(siphon_life)
 #corruption,if=refreshable&time_to_die>=remains
 if target.Refreshable(corruption_debuff) and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) Spell(corruption)
 #agony,cycle_targets=1,target_if=sim.target!=target&time_to_die>tick_time*3&!buff.deadwind_harvester.remains&refreshable
 if False(target_is_sim_target) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(agony_debuff) Spell(agony)
 #siphon_life,cycle_targets=1,target_if=sim.target!=target&time_to_die>tick_time*3&!buff.deadwind_harvester.remains&refreshable
 if False(target_is_sim_target) and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(siphon_life_debuff) Spell(siphon_life)
 #corruption,cycle_targets=1,target_if=sim.target!=target&time_to_die>tick_time*3&!buff.deadwind_harvester.remains&refreshable
 if False(target_is_sim_target) and target.TimeToDie() > target.TickTime(corruption_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(corruption_debuff) Spell(corruption)
 #life_tap,if=mana.pct<=10
 if ManaPercent() <= 10 Spell(life_tap)
 #life_tap,if=prev_gcd.1.life_tap&buff.active_uas.stack=0&mana.pct<50
 if PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 Spell(life_tap)
 #drain_soul,chain=1,interrupt=1
 Spell(drain_soul)
 #life_tap,moving=1,if=mana.pct<80
 if Speed() > 0 and ManaPercent() < 80 Spell(life_tap)
 #agony,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) Spell(agony)
 #siphon_life,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) Spell(siphon_life)
 #corruption,moving=1,cycle_targets=1,if=remains<=duration-(3*tick_time)
 if Speed() > 0 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) Spell(corruption)
 #life_tap,moving=0
 if not Speed() > 0 Spell(life_tap)
}

AddFunction AfflictionWritheMainPostConditions
{
}

AddFunction AfflictionWritheShortCdActions
{
 unless not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffRemaining(soul_harvest_buff) >= 5 + 1.5 * HasEquippedItem(144364) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffPresent(concordance_of_the_legionfall_buff) or BuffPresent(trinket_proc_intellect_buff) or BuffPresent(trinket_stacking_proc_intellect_buff) or BuffPresent(trinket_proc_mastery_buff) or BuffPresent(trinket_stacking_proc_mastery_buff) or BuffPresent(trinket_proc_crit_buff) or BuffPresent(trinket_stacking_proc_crit_buff) or BuffPresent(trinket_proc_versatility_buff) or BuffPresent(trinket_stacking_proc_versatility_buff) or BuffPresent(trinket_proc_spell_power_buff) or BuffPresent(trinket_stacking_proc_spell_power_buff) } and Spell(reap_souls) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 3 and False(target_is_sim_target) and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 and Spell(seed_of_corruption) or { SoulShards() == 5 or target.TimeToDie() <= { BaseDuration(unstable_affliction_debuff) + CastTime(unstable_affliction) } * SoulShards() } and Spell(unstable_affliction) or target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap)
 {
  #service_pet,if=dot.corruption.remains&dot.agony.remains
  if target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) Spell(service_felhunter)

  unless target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 2 and Spell(siphon_life) or target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies(tagged=1) < 3 and Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 5 } and target.TimeToDie() > target.TickTime(corruption_debuff) * 2 and Spell(corruption) or ManaPercent() < 40 and { target.DebuffStacks(unstable_affliction_debuff) < 1 or not BuffPresent(deadwind_harvester_buff) } and Spell(life_tap) or BuffRemaining(deadwind_harvester_buff) + BuffStacks(tormented_souls_buff) * { 5 + HasEquippedItem(144364) } >= 12 * { 5 + 1.5 * HasEquippedItem(144364) } and Spell(reap_souls)
  {
   #phantom_singularity
   Spell(phantom_singularity)
  }
 }
}

AddFunction AfflictionWritheShortCdPostConditions
{
 not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffRemaining(soul_harvest_buff) >= 5 + 1.5 * HasEquippedItem(144364) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffPresent(concordance_of_the_legionfall_buff) or BuffPresent(trinket_proc_intellect_buff) or BuffPresent(trinket_stacking_proc_intellect_buff) or BuffPresent(trinket_proc_mastery_buff) or BuffPresent(trinket_stacking_proc_mastery_buff) or BuffPresent(trinket_proc_crit_buff) or BuffPresent(trinket_stacking_proc_crit_buff) or BuffPresent(trinket_proc_versatility_buff) or BuffPresent(trinket_stacking_proc_versatility_buff) or BuffPresent(trinket_proc_spell_power_buff) or BuffPresent(trinket_stacking_proc_spell_power_buff) } and Spell(reap_souls) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 3 and False(target_is_sim_target) and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 and Spell(seed_of_corruption) or { SoulShards() == 5 or target.TimeToDie() <= { BaseDuration(unstable_affliction_debuff) + CastTime(unstable_affliction) } * SoulShards() } and Spell(unstable_affliction) or target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 2 and Spell(siphon_life) or target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies(tagged=1) < 3 and Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 5 } and target.TimeToDie() > target.TickTime(corruption_debuff) * 2 and Spell(corruption) or ManaPercent() < 40 and { target.DebuffStacks(unstable_affliction_debuff) < 1 or not BuffPresent(deadwind_harvester_buff) } and Spell(life_tap) or BuffRemaining(deadwind_harvester_buff) + BuffStacks(tormented_souls_buff) * { 5 + HasEquippedItem(144364) } >= 12 * { 5 + 1.5 * HasEquippedItem(144364) } and Spell(reap_souls) or { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) > 3 and target.DebuffRefreshable(corruption_debuff) } and Spell(seed_of_corruption) or Talent(contagion_talent) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or Talent(absolute_corruption_talent) and ArmorSetBonus(T21 4) and target.DebuffRemaining(tormented_agony_debuff) <= CastTime(unstable_affliction) and Spell(unstable_affliction) or BuffRemaining(deadwind_harvester_buff) >= BaseDuration(unstable_affliction_debuff) + CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or BuffRemaining(deadwind_harvester_buff) > target.TickTime(unstable_affliction_debuff) * 2 and { not ArmorSetBonus(T21 4) or Talent(contagion_talent) or SoulShards() > 1 } and { not Talent(contagion_talent) or SoulShards() > 1 or BuffPresent(soul_harvest_buff) } and target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) < 5 and Spell(unstable_affliction) or not BuffPresent(deadwind_harvester_buff) and target.DebuffStacks(unstable_affliction_debuff) > 1 and Spell(reap_souls) or not BuffPresent(deadwind_harvester_buff) and PreviousGCDSpell(unstable_affliction) and BuffStacks(tormented_souls_buff) > 1 and Spell(reap_souls) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 and { not BuffPresent(deadwind_harvester_buff) or target.DebuffStacks(unstable_affliction_debuff) < 1 } and Spell(life_tap) or target.Refreshable(agony_debuff) and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and Spell(agony) or target.Refreshable(siphon_life_debuff) and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and Spell(siphon_life) or target.Refreshable(corruption_debuff) and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and Spell(corruption) or False(target_is_sim_target) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(agony_debuff) and Spell(agony) or False(target_is_sim_target) and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(siphon_life_debuff) and Spell(siphon_life) or False(target_is_sim_target) and target.TimeToDie() > target.TickTime(corruption_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(corruption_debuff) and Spell(corruption) or ManaPercent() <= 10 and Spell(life_tap) or PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 and Spell(life_tap) or Spell(drain_soul) or Speed() > 0 and ManaPercent() < 80 and Spell(life_tap) or Speed() > 0 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) and Spell(agony) or Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) and Spell(siphon_life) or Speed() > 0 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) and Spell(corruption) or not Speed() > 0 and Spell(life_tap)
}

AddFunction AfflictionWritheCdActions
{
 unless not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffRemaining(soul_harvest_buff) >= 5 + 1.5 * HasEquippedItem(144364) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffPresent(concordance_of_the_legionfall_buff) or BuffPresent(trinket_proc_intellect_buff) or BuffPresent(trinket_stacking_proc_intellect_buff) or BuffPresent(trinket_proc_mastery_buff) or BuffPresent(trinket_stacking_proc_mastery_buff) or BuffPresent(trinket_proc_crit_buff) or BuffPresent(trinket_stacking_proc_crit_buff) or BuffPresent(trinket_proc_versatility_buff) or BuffPresent(trinket_stacking_proc_versatility_buff) or BuffPresent(trinket_proc_spell_power_buff) or BuffPresent(trinket_stacking_proc_spell_power_buff) } and Spell(reap_souls) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 3 and False(target_is_sim_target) and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 and Spell(seed_of_corruption) or { SoulShards() == 5 or target.TimeToDie() <= { BaseDuration(unstable_affliction_debuff) + CastTime(unstable_affliction) } * SoulShards() } and Spell(unstable_affliction) or target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) and Spell(service_felhunter)
 {
  #summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
  if not Talent(grimoire_of_supremacy_talent) and not Talent(grimoire_of_sacrifice_talent) and Enemies(tagged=1) <= 2 and { target.TimeToDie() > 180 or target.HealthPercent() <= 20 or target.TimeToDie() < 30 } Spell(summon_doomguard)
  #summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>2
  if not Talent(grimoire_of_supremacy_talent) and not Talent(grimoire_of_sacrifice_talent) and Enemies(tagged=1) > 2 Spell(summon_infernal)
  #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
  # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_doomguard)
  #summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
  # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_infernal)
  #berserking,if=prev_gcd.1.unstable_affliction|buff.soul_harvest.remains>=10
  if PreviousGCDSpell(unstable_affliction) or BuffRemaining(soul_harvest_buff) >= 10 Spell(berserking)
  #blood_fury
  Spell(blood_fury_sp)
  #soul_harvest,if=sim.target=target&buff.soul_harvest.remains<=8&(raid_event.adds.in>20|active_enemies>1|!raid_event.adds.exists)&(buff.active_uas.stack>=2|active_enemies>3)&(!talent.deaths_embrace.enabled|time_to_die>120|time_to_die<30)
  if True(target_is_sim_target) and BuffRemaining(soul_harvest_buff) <= 8 and { 600 > 20 or Enemies(tagged=1) > 1 or not False(raid_event_adds_exists) } and { target.DebuffStacks(unstable_affliction_debuff) >= 2 or Enemies(tagged=1) > 3 } and { not Talent(deaths_embrace_talent) or target.TimeToDie() > 120 or target.TimeToDie() < 30 } Spell(soul_harvest)
  #potion,if=target.time_to_die<=70
  # if target.TimeToDie() <= 70 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
  #potion,if=(!talent.soul_harvest.enabled|buff.soul_harvest.remains>12)&(trinket.proc.any.react|trinket.stack_proc.any.react|buff.active_uas.stack>=2)
  # if { not Talent(soul_harvest_talent) or BuffRemaining(soul_harvest_buff) > 12 } and { BuffPresent(trinket_proc_any_buff) or BuffPresent(trinket_stack_proc_any_buff) or target.DebuffStacks(unstable_affliction_debuff) >= 2 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 }
}

AddFunction AfflictionWritheCdPostConditions
{
 not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffStacks(tormented_souls_buff) >= 5 or target.TimeToDie() <= BuffStacks(tormented_souls_buff) * { 5 + 1.5 * HasEquippedItem(144364) } + BuffRemaining(deadwind_harvester_buff) * { 5 + 1.5 * HasEquippedItem(144364) } / 12 * { 5 + 1.5 * HasEquippedItem(144364) } } and Spell(reap_souls) or not BuffPresent(deadwind_harvester_buff) and TimeInCombat() > 5 and { BuffRemaining(soul_harvest_buff) >= 5 + 1.5 * HasEquippedItem(144364) and target.DebuffStacks(unstable_affliction_debuff) > 1 or BuffPresent(concordance_of_the_legionfall_buff) or BuffPresent(trinket_proc_intellect_buff) or BuffPresent(trinket_stacking_proc_intellect_buff) or BuffPresent(trinket_proc_mastery_buff) or BuffPresent(trinket_stacking_proc_mastery_buff) or BuffPresent(trinket_proc_crit_buff) or BuffPresent(trinket_stacking_proc_crit_buff) or BuffPresent(trinket_proc_versatility_buff) or BuffPresent(trinket_stacking_proc_versatility_buff) or BuffPresent(trinket_proc_spell_power_buff) or BuffPresent(trinket_stacking_proc_spell_power_buff) } and Spell(reap_souls) or target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 5 and False(target_is_sim_target) and Talent(soul_harvest_talent) and SpellCooldown(soul_harvest) < CastTime(agony) * 6 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) * 0.3 and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 3 and False(target_is_sim_target) and target.DebuffRemaining(agony_debuff) <= target.TickTime(agony_debuff) + GCD() and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and Spell(agony) or Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 and SoulShards() == 5 and Spell(seed_of_corruption) or { SoulShards() == 5 or target.TimeToDie() <= { BaseDuration(unstable_affliction_debuff) + CastTime(unstable_affliction) } * SoulShards() } and Spell(unstable_affliction) or target.TimeToDie() <= GCD() * 2 and SoulShards() < 5 and Spell(drain_soul) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or target.DebuffRemaining(corruption_debuff) and target.DebuffRemaining(agony_debuff) and Spell(service_felhunter) or target.DebuffRemaining(siphon_life_debuff) <= target.TickTime(siphon_life_debuff) + GCD() and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 2 and Spell(siphon_life) or target.DebuffRemaining(corruption_debuff) <= target.TickTime(corruption_debuff) + GCD() and { Enemies(tagged=1) < 3 and Talent(sow_the_seeds_talent) or Enemies(tagged=1) < 5 } and target.TimeToDie() > target.TickTime(corruption_debuff) * 2 and Spell(corruption) or ManaPercent() < 40 and { target.DebuffStacks(unstable_affliction_debuff) < 1 or not BuffPresent(deadwind_harvester_buff) } and Spell(life_tap) or BuffRemaining(deadwind_harvester_buff) + BuffStacks(tormented_souls_buff) * { 5 + HasEquippedItem(144364) } >= 12 * { 5 + 1.5 * HasEquippedItem(144364) } and Spell(reap_souls) or Spell(phantom_singularity) or { Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Enemies(tagged=1) > 3 and target.DebuffRefreshable(corruption_debuff) } and Spell(seed_of_corruption) or Talent(contagion_talent) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or Talent(absolute_corruption_talent) and ArmorSetBonus(T21 4) and target.DebuffRemaining(tormented_agony_debuff) <= CastTime(unstable_affliction) and Spell(unstable_affliction) or BuffRemaining(deadwind_harvester_buff) >= BaseDuration(unstable_affliction_debuff) + CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 1 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 2 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 3 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 4 < CastTime(unstable_affliction) and target.DebuffStacks(unstable_affliction_debuff) >= 5 < CastTime(unstable_affliction) and Spell(unstable_affliction) or BuffRemaining(deadwind_harvester_buff) > target.TickTime(unstable_affliction_debuff) * 2 and { not ArmorSetBonus(T21 4) or Talent(contagion_talent) or SoulShards() > 1 } and { not Talent(contagion_talent) or SoulShards() > 1 or BuffPresent(soul_harvest_buff) } and target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) + target.DebuffPresent(unstable_affliction_debuff) < 5 and Spell(unstable_affliction) or not BuffPresent(deadwind_harvester_buff) and target.DebuffStacks(unstable_affliction_debuff) > 1 and Spell(reap_souls) or not BuffPresent(deadwind_harvester_buff) and PreviousGCDSpell(unstable_affliction) and BuffStacks(tormented_souls_buff) > 1 and Spell(reap_souls) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 and { not BuffPresent(deadwind_harvester_buff) or target.DebuffStacks(unstable_affliction_debuff) < 1 } and Spell(life_tap) or target.Refreshable(agony_debuff) and target.TimeToDie() >= target.DebuffRemaining(agony_debuff) and Spell(agony) or target.Refreshable(siphon_life_debuff) and target.TimeToDie() >= target.DebuffRemaining(siphon_life_debuff) and Spell(siphon_life) or target.Refreshable(corruption_debuff) and target.TimeToDie() >= target.DebuffRemaining(corruption_debuff) and Spell(corruption) or False(target_is_sim_target) and target.TimeToDie() > target.TickTime(agony_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(agony_debuff) and Spell(agony) or False(target_is_sim_target) and target.TimeToDie() > target.TickTime(siphon_life_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(siphon_life_debuff) and Spell(siphon_life) or False(target_is_sim_target) and target.TimeToDie() > target.TickTime(corruption_debuff) * 3 and not BuffPresent(deadwind_harvester_buff) and target.Refreshable(corruption_debuff) and Spell(corruption) or ManaPercent() <= 10 and Spell(life_tap) or PreviousGCDSpell(life_tap) and target.DebuffStacks(unstable_affliction_debuff) == 0 and ManaPercent() < 50 and Spell(life_tap) or Spell(drain_soul) or Speed() > 0 and ManaPercent() < 80 and Spell(life_tap) or Speed() > 0 and target.DebuffRemaining(agony_debuff) <= BaseDuration(agony_debuff) - 3 * target.TickTime(agony_debuff) and Spell(agony) or Speed() > 0 and target.DebuffRemaining(siphon_life_debuff) <= BaseDuration(siphon_life_debuff) - 3 * target.TickTime(siphon_life_debuff) and Spell(siphon_life) or Speed() > 0 and target.DebuffRemaining(corruption_debuff) <= BaseDuration(corruption_debuff) - 3 * target.TickTime(corruption_debuff) and Spell(corruption) or not Speed() > 0 and Spell(life_tap)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "affliction", name, desc, code, "script")
end
