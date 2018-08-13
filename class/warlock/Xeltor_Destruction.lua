local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_destruction"
	local desc = "[Xel][8.0] Warlock: Destruction"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)

AddIcon specialization=3 help=main
{
	if InCombat() and target.InRange(chaos_bolt) and HasFullControl()
    {
		# Cooldowns
		if Boss()
		{
			if Speed() == 0 or CanMove() > 0 DestructionDefaultCdActions()
		}
		
		# Short Cooldowns
		if Speed() == 0 or CanMove() > 0 DestructionDefaultShortCdActions()
		
		# Default rotation
		if Speed() == 0 or CanMove() > 0 DestructionDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

### actions.default

AddFunction DestructionDefaultMainActions
{
 #run_action_list,name=cata,if=spell_targets.infernal_awakening>=3&talent.cataclysm.enabled
 if Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) DestructionCataMainActions()

 unless Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) and DestructionCataMainPostConditions()
 {
  #run_action_list,name=fnb,if=spell_targets.infernal_awakening>=3&talent.fire_and_brimstone.enabled
  if Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) DestructionFnbMainActions()

  unless Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) and DestructionFnbMainPostConditions()
  {
   #run_action_list,name=inf,if=spell_targets.infernal_awakening>=3&talent.inferno.enabled
   if Enemies(tagged=1) >= 3 and Talent(inferno_talent) DestructionInfMainActions()

   unless Enemies(tagged=1) >= 3 and Talent(inferno_talent) and DestructionInfMainPostConditions()
   {
    #immolate,cycle_targets=1,if=!debuff.havoc.remains&(refreshable|talent.internal_combustion.enabled&action.chaos_bolt.in_flight&remains-action.chaos_bolt.travel_time-5<duration*0.3)
    if not target.DebuffPresent(havoc_debuff) and { target.Refreshable(immolate_debuff) or Talent(internal_combustion_talent) and InFlightToTarget(chaos_bolt) and target.DebuffRemaining(immolate_debuff) - TravelTime(chaos_bolt) - 5 < BaseDuration(immolate_debuff) * 0.3 } Spell(immolate)
    #call_action_list,name=cds
    DestructionCdsMainActions()

    unless DestructionCdsMainPostConditions()
    {
     #channel_demonfire
     Spell(channel_demonfire)
     #soul_fire,cycle_targets=1,if=!debuff.havoc.remains
     if not target.DebuffPresent(havoc_debuff) Spell(soul_fire)
     #chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(talent.internal_combustion.enabled|!talent.internal_combustion.enabled&soul_shard>=4|(talent.eradication.enabled&debuff.eradication.remains<=cast_time)|buff.dark_soul_instability.remains>cast_time|pet.infernal.active&talent.grimoire_of_supremacy.enabled)
     if not target.DebuffPresent(havoc_debuff) and ExecuteTime(chaos_bolt) + TravelTime(chaos_bolt) < target.TimeToDie() and { Talent(internal_combustion_talent) or not Talent(internal_combustion_talent) and SoulShards() >= 4 or Talent(eradication_talent) and target.DebuffRemaining(eradication_debuff) <= CastTime(chaos_bolt) or BuffRemaining(dark_soul_instability_buff) > CastTime(chaos_bolt) or DemonDuration(infernal) > 0 and Talent(grimoire_of_supremacy_talent) } Spell(chaos_bolt)
     #conflagrate,cycle_targets=1,if=!debuff.havoc.remains&((talent.flashover.enabled&buff.backdraft.stack<=2)|(!talent.flashover.enabled&buff.backdraft.stack<2))
     if not target.DebuffPresent(havoc_debuff) and { Talent(flashover_talent) and BuffStacks(backdraft_buff) <= 2 or not Talent(flashover_talent) and BuffStacks(backdraft_buff) < 2 } Spell(conflagrate)
     #shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
     if not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } Spell(shadowburn)
     #incinerate,cycle_targets=1,if=!debuff.havoc.remains
     if not target.DebuffPresent(havoc_debuff) Spell(incinerate)
    }
   }
  }
 }
}

AddFunction DestructionDefaultMainPostConditions
{
 Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) and DestructionCataMainPostConditions() or Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) and DestructionFnbMainPostConditions() or Enemies(tagged=1) >= 3 and Talent(inferno_talent) and DestructionInfMainPostConditions() or DestructionCdsMainPostConditions()
}

AddFunction DestructionDefaultShortCdActions
{
 #run_action_list,name=cata,if=spell_targets.infernal_awakening>=3&talent.cataclysm.enabled
 if Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) DestructionCataShortCdActions()

 unless Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) and DestructionCataShortCdPostConditions()
 {
  #run_action_list,name=fnb,if=spell_targets.infernal_awakening>=3&talent.fire_and_brimstone.enabled
  if Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) DestructionFnbShortCdActions()

  unless Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) and DestructionFnbShortCdPostConditions()
  {
   #run_action_list,name=inf,if=spell_targets.infernal_awakening>=3&talent.inferno.enabled
   if Enemies(tagged=1) >= 3 and Talent(inferno_talent) DestructionInfShortCdActions()

   unless Enemies(tagged=1) >= 3 and Talent(inferno_talent) and DestructionInfShortCdPostConditions() or not target.DebuffPresent(havoc_debuff) and { target.Refreshable(immolate_debuff) or Talent(internal_combustion_talent) and InFlightToTarget(chaos_bolt) and target.DebuffRemaining(immolate_debuff) - TravelTime(chaos_bolt) - 5 < BaseDuration(immolate_debuff) * 0.3 } and Spell(immolate)
   {
    #call_action_list,name=cds
    DestructionCdsShortCdActions()

    unless DestructionCdsShortCdPostConditions()
    {
     #havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10
     if not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) > 1 Spell(havoc)
     #havoc,if=active_enemies>1
     if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(havoc)

     unless Spell(channel_demonfire)
     {
      #cataclysm
      Spell(cataclysm)
     }
    }
   }
  }
 }
}

AddFunction DestructionDefaultShortCdPostConditions
{
 Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) and DestructionCataShortCdPostConditions() or Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) and DestructionFnbShortCdPostConditions() or Enemies(tagged=1) >= 3 and Talent(inferno_talent) and DestructionInfShortCdPostConditions() or not target.DebuffPresent(havoc_debuff) and { target.Refreshable(immolate_debuff) or Talent(internal_combustion_talent) and InFlightToTarget(chaos_bolt) and target.DebuffRemaining(immolate_debuff) - TravelTime(chaos_bolt) - 5 < BaseDuration(immolate_debuff) * 0.3 } and Spell(immolate) or DestructionCdsShortCdPostConditions() or Spell(channel_demonfire) or not target.DebuffPresent(havoc_debuff) and Spell(soul_fire) or not target.DebuffPresent(havoc_debuff) and ExecuteTime(chaos_bolt) + TravelTime(chaos_bolt) < target.TimeToDie() and { Talent(internal_combustion_talent) or not Talent(internal_combustion_talent) and SoulShards() >= 4 or Talent(eradication_talent) and target.DebuffRemaining(eradication_debuff) <= CastTime(chaos_bolt) or BuffRemaining(dark_soul_instability_buff) > CastTime(chaos_bolt) or DemonDuration(infernal) > 0 and Talent(grimoire_of_supremacy_talent) } and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and { Talent(flashover_talent) and BuffStacks(backdraft_buff) <= 2 or not Talent(flashover_talent) and BuffStacks(backdraft_buff) < 2 } and Spell(conflagrate) or not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } and Spell(shadowburn) or not target.DebuffPresent(havoc_debuff) and Spell(incinerate)
}

AddFunction DestructionDefaultCdActions
{
 #run_action_list,name=cata,if=spell_targets.infernal_awakening>=3&talent.cataclysm.enabled
 if Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) DestructionCataCdActions()

 unless Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) and DestructionCataCdPostConditions()
 {
  #run_action_list,name=fnb,if=spell_targets.infernal_awakening>=3&talent.fire_and_brimstone.enabled
  if Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) DestructionFnbCdActions()

  unless Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) and DestructionFnbCdPostConditions()
  {
   #run_action_list,name=inf,if=spell_targets.infernal_awakening>=3&talent.inferno.enabled
   if Enemies(tagged=1) >= 3 and Talent(inferno_talent) DestructionInfCdActions()

   unless Enemies(tagged=1) >= 3 and Talent(inferno_talent) and DestructionInfCdPostConditions() or not target.DebuffPresent(havoc_debuff) and { target.Refreshable(immolate_debuff) or Talent(internal_combustion_talent) and InFlightToTarget(chaos_bolt) and target.DebuffRemaining(immolate_debuff) - TravelTime(chaos_bolt) - 5 < BaseDuration(immolate_debuff) * 0.3 } and Spell(immolate)
   {
    #call_action_list,name=cds
    DestructionCdsCdActions()
   }
  }
 }
}

AddFunction DestructionDefaultCdPostConditions
{
 Enemies(tagged=1) >= 3 and Talent(cataclysm_talent) and DestructionCataCdPostConditions() or Enemies(tagged=1) >= 3 and Talent(fire_and_brimstone_talent) and DestructionFnbCdPostConditions() or Enemies(tagged=1) >= 3 and Talent(inferno_talent) and DestructionInfCdPostConditions() or not target.DebuffPresent(havoc_debuff) and { target.Refreshable(immolate_debuff) or Talent(internal_combustion_talent) and InFlightToTarget(chaos_bolt) and target.DebuffRemaining(immolate_debuff) - TravelTime(chaos_bolt) - 5 < BaseDuration(immolate_debuff) * 0.3 } and Spell(immolate) or DestructionCdsCdPostConditions() or not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) > 1 and Spell(havoc) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(havoc) or Spell(channel_demonfire) or Spell(cataclysm) or not target.DebuffPresent(havoc_debuff) and Spell(soul_fire) or not target.DebuffPresent(havoc_debuff) and ExecuteTime(chaos_bolt) + TravelTime(chaos_bolt) < target.TimeToDie() and { Talent(internal_combustion_talent) or not Talent(internal_combustion_talent) and SoulShards() >= 4 or Talent(eradication_talent) and target.DebuffRemaining(eradication_debuff) <= CastTime(chaos_bolt) or BuffRemaining(dark_soul_instability_buff) > CastTime(chaos_bolt) or DemonDuration(infernal) > 0 and Talent(grimoire_of_supremacy_talent) } and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and { Talent(flashover_talent) and BuffStacks(backdraft_buff) <= 2 or not Talent(flashover_talent) and BuffStacks(backdraft_buff) < 2 } and Spell(conflagrate) or not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } and Spell(shadowburn) or not target.DebuffPresent(havoc_debuff) and Spell(incinerate)
}

### actions.cata

AddFunction DestructionCataMainActions
{
 #call_action_list,name=cds
 DestructionCdsMainActions()

 unless DestructionCdsMainPostConditions()
 {
  #rain_of_fire,if=soul_shard>=4.5
  if SoulShards() >= 4.5 Spell(rain_of_fire)
  #immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
  if Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) Spell(immolate)
  #channel_demonfire
  Spell(channel_demonfire)
  #chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=8&((108*spell_targets.rain_of_fire%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
  if not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 8 and 108 * Enemies(tagged=1) / 3 < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } Spell(chaos_bolt)
  #chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4
  if not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 Spell(chaos_bolt)
  #immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable&remains<=cooldown.cataclysm.remains
  if not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) and target.DebuffRemaining(immolate_debuff) <= SpellCooldown(cataclysm) Spell(immolate)
  #rain_of_fire
  Spell(rain_of_fire)
  #soul_fire,cycle_targets=1,if=!debuff.havoc.remains
  if not target.DebuffPresent(havoc_debuff) Spell(soul_fire)
  #conflagrate,cycle_targets=1,if=!debuff.havoc.remains
  if not target.DebuffPresent(havoc_debuff) Spell(conflagrate)
  #shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
  if not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } Spell(shadowburn)
  #incinerate,cycle_targets=1,if=!debuff.havoc.remains
  if not target.DebuffPresent(havoc_debuff) Spell(incinerate)
 }
}

AddFunction DestructionCataMainPostConditions
{
 DestructionCdsMainPostConditions()
}

AddFunction DestructionCataShortCdActions
{
 #call_action_list,name=cds
 DestructionCdsShortCdActions()

 unless DestructionCdsShortCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire)
 {
  #cataclysm
  Spell(cataclysm)

  unless Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire)
  {
   #havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=8&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
   if not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 8 and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 Spell(havoc)
   #havoc,if=spell_targets.rain_of_fire<=8&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
   if Enemies(tagged=1) <= 8 and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 Spell(havoc)

   unless not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 8 and 108 * Enemies(tagged=1) / 3 < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt)
   {
    #havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4
    if not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 4 and Enemies(tagged=1) > 1 Spell(havoc)
    #havoc,if=spell_targets.rain_of_fire<=4
    if Enemies(tagged=1) <= 4 and Enemies(tagged=1) > 1 Spell(havoc)
   }
  }
 }
}

AddFunction DestructionCataShortCdPostConditions
{
 DestructionCdsShortCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire) or Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire) or not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 8 and 108 * Enemies(tagged=1) / 3 < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) and target.DebuffRemaining(immolate_debuff) <= SpellCooldown(cataclysm) and Spell(immolate) or Spell(rain_of_fire) or not target.DebuffPresent(havoc_debuff) and Spell(soul_fire) or not target.DebuffPresent(havoc_debuff) and Spell(conflagrate) or not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } and Spell(shadowburn) or not target.DebuffPresent(havoc_debuff) and Spell(incinerate)
}

AddFunction DestructionCataCdActions
{
 #call_action_list,name=cds
 DestructionCdsCdActions()
}

AddFunction DestructionCataCdPostConditions
{
 DestructionCdsCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire) or Spell(cataclysm) or Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire) or not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 8 and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 and Spell(havoc) or Enemies(tagged=1) <= 8 and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 and Spell(havoc) or not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 8 and 108 * Enemies(tagged=1) / 3 < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt) or not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 4 and Enemies(tagged=1) > 1 and Spell(havoc) or Enemies(tagged=1) <= 4 and Enemies(tagged=1) > 1 and Spell(havoc) or not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) and target.DebuffRemaining(immolate_debuff) <= SpellCooldown(cataclysm) and Spell(immolate) or Spell(rain_of_fire) or not target.DebuffPresent(havoc_debuff) and Spell(soul_fire) or not target.DebuffPresent(havoc_debuff) and Spell(conflagrate) or not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } and Spell(shadowburn) or not target.DebuffPresent(havoc_debuff) and Spell(incinerate)
}

### actions.cds

AddFunction DestructionCdsMainActions
{
}

AddFunction DestructionCdsMainPostConditions
{
}

AddFunction DestructionCdsShortCdActions
{
}

AddFunction DestructionCdsShortCdPostConditions
{
}

AddFunction DestructionCdsCdActions
{
 #summon_infernal,if=target.time_to_die>=210|!cooldown.dark_soul_instability.remains|target.time_to_die<=30+gcd|!talent.dark_soul_instability.enabled
 if target.TimeToDie() >= 210 or not SpellCooldown(dark_soul_instability) > 0 or target.TimeToDie() <= 30 + GCD() or not Talent(dark_soul_instability_talent) Spell(summon_infernal)
 #dark_soul_instability,if=target.time_to_die>=140|pet.infernal.active|target.time_to_die<=20+gcd
 if target.TimeToDie() >= 140 or DemonDuration(infernal) > 0 or target.TimeToDie() <= 20 + GCD() Spell(dark_soul_instability)
 #potion,if=pet.infernal.active|target.time_to_die<65
 # if { DemonDuration(infernal) > 0 or target.TimeToDie() < 65 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #berserking
 Spell(berserking)
 #blood_fury
 Spell(blood_fury_sp)
 #fireblood
 Spell(fireblood)
 #use_items
 # DestructionUseItemActions()
}

AddFunction DestructionCdsCdPostConditions
{
}

### actions.fnb

AddFunction DestructionFnbMainActions
{
 #call_action_list,name=cds
 DestructionCdsMainActions()

 unless DestructionCdsMainPostConditions()
 {
  #rain_of_fire,if=soul_shard>=4.5
  if SoulShards() >= 4.5 Spell(rain_of_fire)
  #immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
  if Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) Spell(immolate)
  #channel_demonfire
  Spell(channel_demonfire)
  #chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=4&((108*spell_targets.rain_of_fire%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
  if not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 and 108 * Enemies(tagged=1) / 3 < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } Spell(chaos_bolt)
  #chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4
  if not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 Spell(chaos_bolt)
  #immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable&spell_targets.incinerate<=8
  if not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) and Enemies(tagged=1) <= 8 Spell(immolate)
  #rain_of_fire
  Spell(rain_of_fire)
  #soul_fire,cycle_targets=1,if=!debuff.havoc.remains&spell_targets.incinerate=3
  if not target.DebuffPresent(havoc_debuff) and Enemies(tagged=1) == 3 Spell(soul_fire)
  #conflagrate,cycle_targets=1,if=!debuff.havoc.remains&(talent.flashover.enabled&buff.backdraft.stack<=2|spell_targets.incinerate<=7|talent.roaring_blaze.enabled&spell_targets.incinerate<=9)
  if not target.DebuffPresent(havoc_debuff) and { Talent(flashover_talent) and BuffStacks(backdraft_buff) <= 2 or Enemies(tagged=1) <= 7 or Talent(roaring_blaze_talent) and Enemies(tagged=1) <= 9 } Spell(conflagrate)
  #incinerate,cycle_targets=1,if=!debuff.havoc.remains
  if not target.DebuffPresent(havoc_debuff) Spell(incinerate)
 }
}

AddFunction DestructionFnbMainPostConditions
{
 DestructionCdsMainPostConditions()
}

AddFunction DestructionFnbShortCdActions
{
 #call_action_list,name=cds
 DestructionCdsShortCdActions()

 unless DestructionCdsShortCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire) or Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire)
 {
  #havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
  if not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 4 and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 Spell(havoc)
  #havoc,if=spell_targets.rain_of_fire<=4&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
  if Enemies(tagged=1) <= 4 and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 Spell(havoc)

  unless not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 and 108 * Enemies(tagged=1) / 3 < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt)
  {
   #havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4
   if not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 4 and Enemies(tagged=1) > 1 Spell(havoc)
   #havoc,if=spell_targets.rain_of_fire<=4
   if Enemies(tagged=1) <= 4 and Enemies(tagged=1) > 1 Spell(havoc)
  }
 }
}

AddFunction DestructionFnbShortCdPostConditions
{
 DestructionCdsShortCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire) or Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire) or not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 and 108 * Enemies(tagged=1) / 3 < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) and Enemies(tagged=1) <= 8 and Spell(immolate) or Spell(rain_of_fire) or not target.DebuffPresent(havoc_debuff) and Enemies(tagged=1) == 3 and Spell(soul_fire) or not target.DebuffPresent(havoc_debuff) and { Talent(flashover_talent) and BuffStacks(backdraft_buff) <= 2 or Enemies(tagged=1) <= 7 or Talent(roaring_blaze_talent) and Enemies(tagged=1) <= 9 } and Spell(conflagrate) or not target.DebuffPresent(havoc_debuff) and Spell(incinerate)
}

AddFunction DestructionFnbCdActions
{
 #call_action_list,name=cds
 DestructionCdsCdActions()
}

AddFunction DestructionFnbCdPostConditions
{
 DestructionCdsCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire) or Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire) or not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 4 and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 and Spell(havoc) or Enemies(tagged=1) <= 4 and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 and Spell(havoc) or not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 and 108 * Enemies(tagged=1) / 3 < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt) or not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 4 and Enemies(tagged=1) > 1 and Spell(havoc) or Enemies(tagged=1) <= 4 and Enemies(tagged=1) > 1 and Spell(havoc) or not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) and Enemies(tagged=1) <= 8 and Spell(immolate) or Spell(rain_of_fire) or not target.DebuffPresent(havoc_debuff) and Enemies(tagged=1) == 3 and Spell(soul_fire) or not target.DebuffPresent(havoc_debuff) and { Talent(flashover_talent) and BuffStacks(backdraft_buff) <= 2 or Enemies(tagged=1) <= 7 or Talent(roaring_blaze_talent) and Enemies(tagged=1) <= 9 } and Spell(conflagrate) or not target.DebuffPresent(havoc_debuff) and Spell(incinerate)
}

### actions.inf

AddFunction DestructionInfMainActions
{
 #call_action_list,name=cds
 DestructionCdsMainActions()

 unless DestructionCdsMainPostConditions()
 {
  #rain_of_fire,if=soul_shard>=4.5
  if SoulShards() >= 4.5 Spell(rain_of_fire)
  #immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
  if Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) Spell(immolate)
  #channel_demonfire
  Spell(channel_demonfire)
  #chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&((108*spell_targets.rain_of_fire%(3-0.16*spell_targets.rain_of_fire))<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
  if not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 + TalentPoints(internal_combustion_talent) and 108 * Enemies(tagged=1) / { 3 - 0.16 * Enemies(tagged=1) } < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } Spell(chaos_bolt)
  #chaos_bolt,cycle_targets=1,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
  if not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 3 and { Talent(eradication_talent) or Talent(internal_combustion_talent) } Spell(chaos_bolt)
  #immolate,cycle_targets=1,if=!debuff.havoc.remains&refreshable
  if not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) Spell(immolate)
  #rain_of_fire
  Spell(rain_of_fire)
  #soul_fire,cycle_targets=1,if=!debuff.havoc.remains
  if not target.DebuffPresent(havoc_debuff) Spell(soul_fire)
  #conflagrate,cycle_targets=1,if=!debuff.havoc.remains
  if not target.DebuffPresent(havoc_debuff) Spell(conflagrate)
  #shadowburn,cycle_targets=1,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
  if not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } Spell(shadowburn)
  #incinerate,cycle_targets=1,if=!debuff.havoc.remains
  if not target.DebuffPresent(havoc_debuff) Spell(incinerate)
 }
}

AddFunction DestructionInfMainPostConditions
{
 DestructionCdsMainPostConditions()
}

AddFunction DestructionInfShortCdActions
{
 #call_action_list,name=cds
 DestructionCdsShortCdActions()

 unless DestructionCdsShortCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire)
 {
  #cataclysm
  Spell(cataclysm)

  unless Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire)
  {
   #havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
   if not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 4 + TalentPoints(internal_combustion_talent) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 Spell(havoc)
   #havoc,if=spell_targets.rain_of_fire<=4+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
   if Enemies(tagged=1) <= 4 + TalentPoints(internal_combustion_talent) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 Spell(havoc)

   unless not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 + TalentPoints(internal_combustion_talent) and 108 * Enemies(tagged=1) / { 3 - 0.16 * Enemies(tagged=1) } < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt)
   {
    #havoc,cycle_targets=1,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 3 and { Talent(eradication_talent) or Talent(internal_combustion_talent) } and Enemies(tagged=1) > 1 Spell(havoc)
    #havoc,if=spell_targets.rain_of_fire<=3&(talent.eradication.enabled|talent.internal_combustion.enabled)
    if Enemies(tagged=1) <= 3 and { Talent(eradication_talent) or Talent(internal_combustion_talent) } and Enemies(tagged=1) > 1 Spell(havoc)
   }
  }
 }
}

AddFunction DestructionInfShortCdPostConditions
{
 DestructionCdsShortCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire) or Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire) or not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 + TalentPoints(internal_combustion_talent) and 108 * Enemies(tagged=1) / { 3 - 0.16 * Enemies(tagged=1) } < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 3 and { Talent(eradication_talent) or Talent(internal_combustion_talent) } and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) and Spell(immolate) or Spell(rain_of_fire) or not target.DebuffPresent(havoc_debuff) and Spell(soul_fire) or not target.DebuffPresent(havoc_debuff) and Spell(conflagrate) or not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } and Spell(shadowburn) or not target.DebuffPresent(havoc_debuff) and Spell(incinerate)
}

AddFunction DestructionInfCdActions
{
 #call_action_list,name=cds
 DestructionCdsCdActions()
}

AddFunction DestructionInfCdPostConditions
{
 DestructionCdsCdPostConditions() or SoulShards() >= 4.5 and Spell(rain_of_fire) or Spell(cataclysm) or Talent(channel_demonfire_talent) and not target.DebuffRemaining(immolate_debuff) and SpellCooldown(channel_demonfire) <= ExecuteTime(chaos_bolt) and Spell(immolate) or Spell(channel_demonfire) or not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 4 + TalentPoints(internal_combustion_talent) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 and Spell(havoc) or Enemies(tagged=1) <= 4 + TalentPoints(internal_combustion_talent) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > 0 and DemonDuration(infernal) <= 10 and Enemies(tagged=1) > 1 and Spell(havoc) or not target.DebuffPresent(havoc_debuff) and Talent(grimoire_of_supremacy_talent) and DemonDuration(infernal) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 4 + TalentPoints(internal_combustion_talent) and 108 * Enemies(tagged=1) / { 3 - 0.16 * Enemies(tagged=1) } < 240 * { 1 + 0.08 * BuffStacks(grimoire_of_supremacy_buff) } / 2 * { 1 + BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) } and Spell(chaos_bolt) or not True(target_is_sim_target) and target.TimeToDie() > 10 and Enemies(tagged=1) <= 3 and { Talent(eradication_talent) or Talent(internal_combustion_talent) } and Enemies(tagged=1) > 1 and Spell(havoc) or Enemies(tagged=1) <= 3 and { Talent(eradication_talent) or Talent(internal_combustion_talent) } and Enemies(tagged=1) > 1 and Spell(havoc) or not target.DebuffPresent(havoc_debuff) and BuffRemaining(active_havoc_buff) > ExecuteTime(chaos_bolt) and Enemies(tagged=1) <= 3 and { Talent(eradication_talent) or Talent(internal_combustion_talent) } and Spell(chaos_bolt) or not target.DebuffPresent(havoc_debuff) and target.Refreshable(immolate_debuff) and Spell(immolate) or Spell(rain_of_fire) or not target.DebuffPresent(havoc_debuff) and Spell(soul_fire) or not target.DebuffPresent(havoc_debuff) and Spell(conflagrate) or not target.DebuffPresent(havoc_debuff) and { Charges(shadowburn) == 2 or not BuffPresent(backdraft_buff) or BuffRemaining(backdraft_buff) > BuffStacks(backdraft_buff) * ExecuteTime(incinerate) } and Spell(shadowburn) or not target.DebuffPresent(havoc_debuff) and Spell(incinerate)
}

### actions.precombat

AddFunction DestructionPrecombatMainActions
{
 #grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
 if Talent(grimoire_of_sacrifice_talent) and pet.Present() Spell(grimoire_of_sacrifice)
 #soul_fire
 Spell(soul_fire)
 #incinerate,if=!talent.soul_fire.enabled
 if not Talent(soul_fire_talent) Spell(incinerate)
}

AddFunction DestructionPrecombatMainPostConditions
{
}

AddFunction DestructionPrecombatShortCdActions
{
 #flask
 #food
 #augmentation
 #summon_pet
 if not pet.Present() Spell(summon_imp)
}

AddFunction DestructionPrecombatShortCdPostConditions
{
 Spell(soul_fire) or not Talent(soul_fire_talent) and Spell(incinerate)
}

AddFunction DestructionPrecombatCdActions
{
 unless not pet.Present() and Spell(summon_imp)
 {
  #snapshot_stats
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 }
}

AddFunction DestructionPrecombatCdPostConditions
{
 not pet.Present() and Spell(summon_imp) or Spell(soul_fire) or not Talent(soul_fire_talent) and Spell(incinerate)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "destruction", name, desc, code, "script")
end
