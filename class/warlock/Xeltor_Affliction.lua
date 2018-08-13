local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_affliction"
	local desc = "[Xel][8.0] Warlock: Affliction"
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
		
		#shadow_bolt,if=buff.movement.up&buff.nightfall.remains
		if Speed() > 0 and BuffPresent(nightfall_buff) Spell(shadow_bolt)
		#agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
		if Speed() > 0 and not { Talent(siphon_life_talent) and PreviousGCDSpell(agony) and PreviousGCDSpell(agony count=2) and PreviousGCDSpell(agony count=3) or PreviousGCDSpell(agony) } Spell(agony)
		#siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
		if Speed() > 0 and not { PreviousGCDSpell(siphon_life) and PreviousGCDSpell(siphon_life count=2) and PreviousGCDSpell(siphon_life count=3) } Spell(siphon_life)
		#corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
		if Speed() > 0 and not PreviousGCDSpell(corruption) and not Talent(absolute_corruption_talent) Spell(corruption)
	}
}

AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
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

AddFunction padding
{
 ExecuteTime(shadow_bolt) * HasAzeriteTrait(cascading_calamity_trait)
}

AddFunction spammable_seed
{
 Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 or Talent(siphon_life_talent) and Enemies(tagged=1) >= 5 or Enemies(tagged=1) >= 8
}

### actions.default

AddFunction AfflictionDefaultMainActions
{
 #drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd&soul_shard<5
 if target.TimeToDie() <= GCD() and SoulShards() < 5 Spell(drain_soul)
 #haunt
 Spell(haunt)
 #agony,cycle_targets=1,if=remains<=gcd
 if target.DebuffRemaining(agony_debuff) <= GCD() Spell(agony)
 #shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=execute_time*2+travel_time&!action.shadow_bolt.in_flight
 if Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt) * 2 + TravelTime(shadow_bolt) and not InFlightToTarget(shadow_bolt) Spell(shadow_bolt)
 #vile_taint,if=time>20
 if TimeInCombat() > 20 Spell(vile_taint)
 #seed_of_corruption,if=dot.corruption.remains<=action.seed_of_corruption.cast_time+time_to_shard+4.2*(1-talent.creeping_death.enabled*0.15)&spell_targets.seed_of_corruption_aoe>=3+talent.writhe_in_agony.enabled&!dot.seed_of_corruption.remains&!action.seed_of_corruption.in_flight
 if target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TimeToShard() + 4.2 * { 1 - TalentPoints(creeping_death_talent) * 0.15 } and Enemies(tagged=1) >= 3 + TalentPoints(writhe_in_agony_talent) and not target.DebuffRemaining(seed_of_corruption_debuff) and not InFlightToTarget(seed_of_corruption) Spell(seed_of_corruption)
 #agony,cycle_targets=1,max_cycle_targets=6,if=talent.creeping_death.enabled&target.time_to_die>10&refreshable
 if DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 6 and Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) Spell(agony)
 #agony,cycle_targets=1,max_cycle_targets=8,if=(!talent.creeping_death.enabled)&target.time_to_die>10&refreshable
 if DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 8 and not Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) Spell(agony)
 #siphon_life,cycle_targets=1,max_cycle_targets=1,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies>=8)|active_enemies=1)
 if DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 1 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) >= 8 or Enemies(tagged=1) == 1 } Spell(siphon_life)
 #siphon_life,cycle_targets=1,max_cycle_targets=2,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=7)|active_enemies=2)
 if DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 2 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 7 or Enemies(tagged=1) == 2 } Spell(siphon_life)
 #siphon_life,cycle_targets=1,max_cycle_targets=3,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=6)|active_enemies=3)
 if DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 3 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 6 or Enemies(tagged=1) == 3 } Spell(siphon_life)
 #siphon_life,cycle_targets=1,max_cycle_targets=4,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=5)|active_enemies=4)
 if DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 4 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 5 or Enemies(tagged=1) == 4 } Spell(siphon_life)
 #corruption,cycle_targets=1,if=active_enemies<3+talent.writhe_in_agony.enabled&refreshable&target.time_to_die>10
 if Enemies(tagged=1) < 3 + TalentPoints(writhe_in_agony_talent) and target.Refreshable(corruption_debuff) and target.TimeToDie() > 10 Spell(corruption)
 #vile_taint
 Spell(vile_taint)
 #unstable_affliction,if=soul_shard>=5
 if SoulShards() >= 5 Spell(unstable_affliction)
 #unstable_affliction,if=cooldown.summon_darkglare.remains<=soul_shard*execute_time
 if SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) Spell(unstable_affliction)
 #call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
 if { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) AfflictionFillersMainActions()

 unless { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersMainPostConditions()
 {
  #seed_of_corruption,if=variable.spammable_seed
  if spammable_seed() Spell(seed_of_corruption)
  #unstable_affliction,if=!prev_gcd.1.summon_darkglare&!variable.spammable_seed&(talent.deathbolt.enabled&cooldown.deathbolt.remains<=execute_time&!azerite.cascading_calamity.enabled|soul_shard>=2&target.time_to_die>4+execute_time&active_enemies=1|target.time_to_die<=8+execute_time*soul_shard)
  if not PreviousGCDSpell(summon_darkglare) and not spammable_seed() and { Talent(deathbolt_talent) and SpellCooldown(deathbolt) <= ExecuteTime(unstable_affliction) and not HasAzeriteTrait(cascading_calamity_trait) or SoulShards() >= 2 and target.TimeToDie() > 4 + ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 1 or target.TimeToDie() <= 8 + ExecuteTime(unstable_affliction) * SoulShards() } Spell(unstable_affliction)
  #unstable_affliction,if=!variable.spammable_seed&contagion<=cast_time+variable.padding
  if not spammable_seed() and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() Spell(unstable_affliction)
  #unstable_affliction,cycle_targets=1,if=!variable.spammable_seed&(!talent.deathbolt.enabled|cooldown.deathbolt.remains>time_to_shard|soul_shard>1)&contagion<=cast_time+variable.padding
  if not spammable_seed() and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) > TimeToShard() or SoulShards() > 1 } and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() Spell(unstable_affliction)
  #call_action_list,name=fillers
  AfflictionFillersMainActions()
 }
}

AddFunction AfflictionDefaultMainPostConditions
{
 { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersMainPostConditions() or AfflictionFillersMainPostConditions()
}

AddFunction AfflictionDefaultShortCdActions
{
 unless target.TimeToDie() <= GCD() and SoulShards() < 5 and Spell(drain_soul) or Spell(haunt) or target.DebuffRemaining(agony_debuff) <= GCD() and Spell(agony) or Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt) * 2 + TravelTime(shadow_bolt) and not InFlightToTarget(shadow_bolt) and Spell(shadow_bolt)
 {
  #phantom_singularity,if=time>40
  if TimeInCombat() > 40 Spell(phantom_singularity)

  unless TimeInCombat() > 20 and Spell(vile_taint) or target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TimeToShard() + 4.2 * { 1 - TalentPoints(creeping_death_talent) * 0.15 } and Enemies(tagged=1) >= 3 + TalentPoints(writhe_in_agony_talent) and not target.DebuffRemaining(seed_of_corruption_debuff) and not InFlightToTarget(seed_of_corruption) and Spell(seed_of_corruption) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 6 and Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 8 and not Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) and Spell(agony) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 1 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) >= 8 or Enemies(tagged=1) == 1 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 2 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 7 or Enemies(tagged=1) == 2 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 3 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 6 or Enemies(tagged=1) == 3 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 4 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 5 or Enemies(tagged=1) == 4 } and Spell(siphon_life) or Enemies(tagged=1) < 3 + TalentPoints(writhe_in_agony_talent) and target.Refreshable(corruption_debuff) and target.TimeToDie() > 10 and Spell(corruption) or Spell(vile_taint) or SoulShards() >= 5 and Spell(unstable_affliction) or SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Spell(unstable_affliction)
  {
   #phantom_singularity
   Spell(phantom_singularity)
   #call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
   if { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) AfflictionFillersShortCdActions()

   unless { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersShortCdPostConditions() or spammable_seed() and Spell(seed_of_corruption) or not PreviousGCDSpell(summon_darkglare) and not spammable_seed() and { Talent(deathbolt_talent) and SpellCooldown(deathbolt) <= ExecuteTime(unstable_affliction) and not HasAzeriteTrait(cascading_calamity_trait) or SoulShards() >= 2 and target.TimeToDie() > 4 + ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 1 or target.TimeToDie() <= 8 + ExecuteTime(unstable_affliction) * SoulShards() } and Spell(unstable_affliction) or not spammable_seed() and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction) or not spammable_seed() and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) > TimeToShard() or SoulShards() > 1 } and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction)
   {
    #call_action_list,name=fillers
    AfflictionFillersShortCdActions()
   }
  }
 }
}

AddFunction AfflictionDefaultShortCdPostConditions
{
 target.TimeToDie() <= GCD() and SoulShards() < 5 and Spell(drain_soul) or Spell(haunt) or target.DebuffRemaining(agony_debuff) <= GCD() and Spell(agony) or Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt) * 2 + TravelTime(shadow_bolt) and not InFlightToTarget(shadow_bolt) and Spell(shadow_bolt) or TimeInCombat() > 20 and Spell(vile_taint) or target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TimeToShard() + 4.2 * { 1 - TalentPoints(creeping_death_talent) * 0.15 } and Enemies(tagged=1) >= 3 + TalentPoints(writhe_in_agony_talent) and not target.DebuffRemaining(seed_of_corruption_debuff) and not InFlightToTarget(seed_of_corruption) and Spell(seed_of_corruption) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 6 and Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 8 and not Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) and Spell(agony) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 1 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) >= 8 or Enemies(tagged=1) == 1 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 2 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 7 or Enemies(tagged=1) == 2 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 3 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 6 or Enemies(tagged=1) == 3 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 4 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 5 or Enemies(tagged=1) == 4 } and Spell(siphon_life) or Enemies(tagged=1) < 3 + TalentPoints(writhe_in_agony_talent) and target.Refreshable(corruption_debuff) and target.TimeToDie() > 10 and Spell(corruption) or Spell(vile_taint) or SoulShards() >= 5 and Spell(unstable_affliction) or SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Spell(unstable_affliction) or { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersShortCdPostConditions() or spammable_seed() and Spell(seed_of_corruption) or not PreviousGCDSpell(summon_darkglare) and not spammable_seed() and { Talent(deathbolt_talent) and SpellCooldown(deathbolt) <= ExecuteTime(unstable_affliction) and not HasAzeriteTrait(cascading_calamity_trait) or SoulShards() >= 2 and target.TimeToDie() > 4 + ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 1 or target.TimeToDie() <= 8 + ExecuteTime(unstable_affliction) * SoulShards() } and Spell(unstable_affliction) or not spammable_seed() and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction) or not spammable_seed() and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) > TimeToShard() or SoulShards() > 1 } and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction) or AfflictionFillersShortCdPostConditions()
}

AddFunction AfflictionDefaultCdActions
{
 #variable,name=spammable_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5|spell_targets.seed_of_corruption>=8
 #variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
 #variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
 #potion,if=(talent.dark_soul_misery.enabled&cooldown.summon_darkglare.up&cooldown.dark_soul.up)|cooldown.summon_darkglare.up|target.time_to_die<30
 # if { Talent(dark_soul_misery_talent) and not SpellCooldown(summon_darkglare) > 0 and not SpellCooldown(dark_soul_misery) > 0 or not SpellCooldown(summon_darkglare) > 0 or target.TimeToDie() < 30 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #use_items,if=!cooldown.summon_darkglare.up
 # if not { not SpellCooldown(summon_darkglare) > 0 } AfflictionUseItemActions()
 #fireblood,if=!cooldown.summon_darkglare.up
 if not { not SpellCooldown(summon_darkglare) > 0 } Spell(fireblood)
 #blood_fury,if=!cooldown.summon_darkglare.up
 if not { not SpellCooldown(summon_darkglare) > 0 } Spell(blood_fury_sp)

 unless target.TimeToDie() <= GCD() and SoulShards() < 5 and Spell(drain_soul) or Spell(haunt)
 {
  #summon_darkglare,if=dot.agony.ticking&dot.corruption.ticking&(buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains)
  if target.DebuffPresent(agony_debuff) and target.DebuffPresent(corruption_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 5 or SoulShards() == 0 } and { not Talent(phantom_singularity_talent) or SpellCooldown(phantom_singularity) > 0 } Spell(summon_darkglare)

  unless target.DebuffRemaining(agony_debuff) <= GCD() and Spell(agony) or Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt) * 2 + TravelTime(shadow_bolt) and not InFlightToTarget(shadow_bolt) and Spell(shadow_bolt) or TimeInCombat() > 40 and Spell(phantom_singularity) or TimeInCombat() > 20 and Spell(vile_taint) or target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TimeToShard() + 4.2 * { 1 - TalentPoints(creeping_death_talent) * 0.15 } and Enemies(tagged=1) >= 3 + TalentPoints(writhe_in_agony_talent) and not target.DebuffRemaining(seed_of_corruption_debuff) and not InFlightToTarget(seed_of_corruption) and Spell(seed_of_corruption) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 6 and Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 8 and not Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) and Spell(agony) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 1 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) >= 8 or Enemies(tagged=1) == 1 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 2 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 7 or Enemies(tagged=1) == 2 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 3 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 6 or Enemies(tagged=1) == 3 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 4 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 5 or Enemies(tagged=1) == 4 } and Spell(siphon_life) or Enemies(tagged=1) < 3 + TalentPoints(writhe_in_agony_talent) and target.Refreshable(corruption_debuff) and target.TimeToDie() > 10 and Spell(corruption)
  {
   #dark_soul
   Spell(dark_soul_misery)

   unless Spell(vile_taint)
   {
    #berserking
    Spell(berserking)

    unless SoulShards() >= 5 and Spell(unstable_affliction) or SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Spell(unstable_affliction) or Spell(phantom_singularity)
    {
     #call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
     if { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) AfflictionFillersCdActions()

     unless { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersCdPostConditions() or spammable_seed() and Spell(seed_of_corruption) or not PreviousGCDSpell(summon_darkglare) and not spammable_seed() and { Talent(deathbolt_talent) and SpellCooldown(deathbolt) <= ExecuteTime(unstable_affliction) and not HasAzeriteTrait(cascading_calamity_trait) or SoulShards() >= 2 and target.TimeToDie() > 4 + ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 1 or target.TimeToDie() <= 8 + ExecuteTime(unstable_affliction) * SoulShards() } and Spell(unstable_affliction) or not spammable_seed() and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction) or not spammable_seed() and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) > TimeToShard() or SoulShards() > 1 } and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction)
     {
      #call_action_list,name=fillers
      AfflictionFillersCdActions()
     }
    }
   }
  }
 }
}

AddFunction AfflictionDefaultCdPostConditions
{
 target.TimeToDie() <= GCD() and SoulShards() < 5 and Spell(drain_soul) or Spell(haunt) or target.DebuffRemaining(agony_debuff) <= GCD() and Spell(agony) or Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt) * 2 + TravelTime(shadow_bolt) and not InFlightToTarget(shadow_bolt) and Spell(shadow_bolt) or TimeInCombat() > 40 and Spell(phantom_singularity) or TimeInCombat() > 20 and Spell(vile_taint) or target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TimeToShard() + 4.2 * { 1 - TalentPoints(creeping_death_talent) * 0.15 } and Enemies(tagged=1) >= 3 + TalentPoints(writhe_in_agony_talent) and not target.DebuffRemaining(seed_of_corruption_debuff) and not InFlightToTarget(seed_of_corruption) and Spell(seed_of_corruption) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 6 and Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) and Spell(agony) or DebuffCountOnAny(agony_debuff) < Enemies(tagged=1) and DebuffCountOnAny(agony_debuff) <= 8 and not Talent(creeping_death_talent) and target.TimeToDie() > 10 and target.Refreshable(agony_debuff) and Spell(agony) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 1 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) >= 8 or Enemies(tagged=1) == 1 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 2 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 7 or Enemies(tagged=1) == 2 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 3 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 6 or Enemies(tagged=1) == 3 } and Spell(siphon_life) or DebuffCountOnAny(siphon_life_debuff) < Enemies(tagged=1) and DebuffCountOnAny(siphon_life_debuff) <= 4 and target.Refreshable(siphon_life_debuff) and target.TimeToDie() > 10 and { not SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 5 or Enemies(tagged=1) == 4 } and Spell(siphon_life) or Enemies(tagged=1) < 3 + TalentPoints(writhe_in_agony_talent) and target.Refreshable(corruption_debuff) and target.TimeToDie() > 10 and Spell(corruption) or Spell(vile_taint) or SoulShards() >= 5 and Spell(unstable_affliction) or SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and Spell(unstable_affliction) or Spell(phantom_singularity) or { SpellCooldown(summon_darkglare) < TimeToShard() * { 5 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersCdPostConditions() or spammable_seed() and Spell(seed_of_corruption) or not PreviousGCDSpell(summon_darkglare) and not spammable_seed() and { Talent(deathbolt_talent) and SpellCooldown(deathbolt) <= ExecuteTime(unstable_affliction) and not HasAzeriteTrait(cascading_calamity_trait) or SoulShards() >= 2 and target.TimeToDie() > 4 + ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 1 or target.TimeToDie() <= 8 + ExecuteTime(unstable_affliction) * SoulShards() } and Spell(unstable_affliction) or not spammable_seed() and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction) or not spammable_seed() and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) > TimeToShard() or SoulShards() > 1 } and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction) or AfflictionFillersCdPostConditions()
}

### actions.fillers

AddFunction AfflictionFillersMainActions
{
 #shadow_bolt,if=buff.movement.up&buff.nightfall.remains
 if Speed() > 0 and BuffPresent(nightfall_buff) Spell(shadow_bolt)
 #agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
 if Speed() > 0 and not { Talent(siphon_life_talent) and PreviousGCDSpell(agony) and PreviousGCDSpell(agony count=2) and PreviousGCDSpell(agony count=3) or PreviousGCDSpell(agony) } Spell(agony)
 #siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
 if Speed() > 0 and not { PreviousGCDSpell(siphon_life) and PreviousGCDSpell(siphon_life count=2) and PreviousGCDSpell(siphon_life count=3) } Spell(siphon_life)
 #corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
 if Speed() > 0 and not PreviousGCDSpell(corruption) and not Talent(absolute_corruption_talent) Spell(corruption)
 #drain_life,if=(buff.inevitable_demise.stack>=90&(cooldown.deathbolt.remains>execute_time|!talent.deathbolt.enabled)&(cooldown.phantom_singularity.remains>execute_time|!talent.phantom_singularity.enabled)&(cooldown.dark_soul.remains>execute_time|!talent.dark_soul_misery.enabled)&(cooldown.vile_taint.remains>execute_time|!talent.vile_taint.enabled)&cooldown.summon_darkglare.remains>execute_time+10|buff.inevitable_demise.stack>30&target.time_to_die<=10)
 if BuffStacks(inevitable_demise_buff) >= 90 and { SpellCooldown(deathbolt) > ExecuteTime(drain_life) or not Talent(deathbolt_talent) } and { SpellCooldown(phantom_singularity) > ExecuteTime(drain_life) or not Talent(phantom_singularity_talent) } and { SpellCooldown(dark_soul_misery) > ExecuteTime(drain_life) or not Talent(dark_soul_misery_talent) } and { SpellCooldown(vile_taint) > ExecuteTime(drain_life) or not Talent(vile_taint_talent) } and SpellCooldown(summon_darkglare) > ExecuteTime(drain_life) + 10 or BuffStacks(inevitable_demise_buff) > 30 and target.TimeToDie() <= 10 Spell(drain_life)
 #drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd
 if target.TimeToDie() <= GCD() Spell(drain_soul)
 #drain_soul,interrupt_global=1,chain=1
 Spell(drain_soul)
 #shadow_bolt,cycle_targets=1,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2&!debuff.shadow_embrace.remains&!action.shadow_bolt.in_flight
 if Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and not target.DebuffPresent(shadow_embrace_debuff) and not InFlightToTarget(shadow_bolt) Spell(shadow_bolt)
 #shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2
 if Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 Spell(shadow_bolt)
 #shadow_bolt
 Spell(shadow_bolt)
}

AddFunction AfflictionFillersMainPostConditions
{
}

AddFunction AfflictionFillersShortCdActions
{
 #deathbolt
 Spell(deathbolt)
}

AddFunction AfflictionFillersShortCdPostConditions
{
 Speed() > 0 and BuffPresent(nightfall_buff) and Spell(shadow_bolt) or Speed() > 0 and not { Talent(siphon_life_talent) and PreviousGCDSpell(agony) and PreviousGCDSpell(agony count=2) and PreviousGCDSpell(agony count=3) or PreviousGCDSpell(agony) } and Spell(agony) or Speed() > 0 and not { PreviousGCDSpell(siphon_life) and PreviousGCDSpell(siphon_life count=2) and PreviousGCDSpell(siphon_life count=3) } and Spell(siphon_life) or Speed() > 0 and not PreviousGCDSpell(corruption) and not Talent(absolute_corruption_talent) and Spell(corruption) or { BuffStacks(inevitable_demise_buff) >= 90 and { SpellCooldown(deathbolt) > ExecuteTime(drain_life) or not Talent(deathbolt_talent) } and { SpellCooldown(phantom_singularity) > ExecuteTime(drain_life) or not Talent(phantom_singularity_talent) } and { SpellCooldown(dark_soul_misery) > ExecuteTime(drain_life) or not Talent(dark_soul_misery_talent) } and { SpellCooldown(vile_taint) > ExecuteTime(drain_life) or not Talent(vile_taint_talent) } and SpellCooldown(summon_darkglare) > ExecuteTime(drain_life) + 10 or BuffStacks(inevitable_demise_buff) > 30 and target.TimeToDie() <= 10 } and Spell(drain_life) or target.TimeToDie() <= GCD() and Spell(drain_soul) or Spell(drain_soul) or Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and not target.DebuffPresent(shadow_embrace_debuff) and not InFlightToTarget(shadow_bolt) and Spell(shadow_bolt) or Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and Spell(shadow_bolt) or Spell(shadow_bolt)
}

AddFunction AfflictionFillersCdActions
{
}

AddFunction AfflictionFillersCdPostConditions
{
 Spell(deathbolt) or Speed() > 0 and BuffPresent(nightfall_buff) and Spell(shadow_bolt) or Speed() > 0 and not { Talent(siphon_life_talent) and PreviousGCDSpell(agony) and PreviousGCDSpell(agony count=2) and PreviousGCDSpell(agony count=3) or PreviousGCDSpell(agony) } and Spell(agony) or Speed() > 0 and not { PreviousGCDSpell(siphon_life) and PreviousGCDSpell(siphon_life count=2) and PreviousGCDSpell(siphon_life count=3) } and Spell(siphon_life) or Speed() > 0 and not PreviousGCDSpell(corruption) and not Talent(absolute_corruption_talent) and Spell(corruption) or { BuffStacks(inevitable_demise_buff) >= 90 and { SpellCooldown(deathbolt) > ExecuteTime(drain_life) or not Talent(deathbolt_talent) } and { SpellCooldown(phantom_singularity) > ExecuteTime(drain_life) or not Talent(phantom_singularity_talent) } and { SpellCooldown(dark_soul_misery) > ExecuteTime(drain_life) or not Talent(dark_soul_misery_talent) } and { SpellCooldown(vile_taint) > ExecuteTime(drain_life) or not Talent(vile_taint_talent) } and SpellCooldown(summon_darkglare) > ExecuteTime(drain_life) + 10 or BuffStacks(inevitable_demise_buff) > 30 and target.TimeToDie() <= 10 } and Spell(drain_life) or target.TimeToDie() <= GCD() and Spell(drain_soul) or Spell(drain_soul) or Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and not target.DebuffPresent(shadow_embrace_debuff) and not InFlightToTarget(shadow_bolt) and Spell(shadow_bolt) or Talent(shadow_embrace_talent) and Talent(absolute_corruption_talent) and Enemies(tagged=1) == 2 and Spell(shadow_bolt) or Spell(shadow_bolt)
}

### actions.precombat

AddFunction AfflictionPrecombatMainActions
{
 #grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
 if Talent(grimoire_of_sacrifice_talent) and pet.Present() Spell(grimoire_of_sacrifice)
 #seed_of_corruption,if=spell_targets.seed_of_corruption_aoe>=3
 if Enemies(tagged=1) >= 3 Spell(seed_of_corruption)
 #haunt
 Spell(haunt)
 #shadow_bolt,if=!talent.haunt.enabled&spell_targets.seed_of_corruption_aoe<3
 if not Talent(haunt_talent) and Enemies(tagged=1) < 3 Spell(shadow_bolt)
}

AddFunction AfflictionPrecombatMainPostConditions
{
}

AddFunction AfflictionPrecombatShortCdActions
{
 #flask
 #food
 #augmentation
 #summon_pet
 if not pet.Present() Spell(summon_imp)
}

AddFunction AfflictionPrecombatShortCdPostConditions
{
 Enemies(tagged=1) >= 3 and Spell(seed_of_corruption) or Spell(haunt) or not Talent(haunt_talent) and Enemies(tagged=1) < 3 and Spell(shadow_bolt)
}

AddFunction AfflictionPrecombatCdActions
{
 unless not pet.Present() and Spell(summon_imp)
 {
  #snapshot_stats
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 }
}

AddFunction AfflictionPrecombatCdPostConditions
{
 not pet.Present() and Spell(summon_imp) or Enemies(tagged=1) >= 3 and Spell(seed_of_corruption) or Spell(haunt) or not Talent(haunt_talent) and Enemies(tagged=1) < 3 and Spell(shadow_bolt)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "affliction", name, desc, code, "script")
end
