local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_affliction"
	local desc = "[Xel][8.1] Warlock: Affliction"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)

Define(spell_lock_fh 19647)
	SpellInfo(spell_lock_fh cd=24)
Define(shadow_lock_dg 171138)
	SpellInfo(shadow_lock_dg cd=24)

AddIcon specialization=1 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
	# Save ass
	SaveActions()
	
	if wet() and not mounted() Spell(unending_breath)
	
	if InCombat() and target.InRange(agony) and HasFullControl()
    {
		if pet.CreatureFamily(Voidwalker) or pet.CreatureFamily(Voidlord) or pet.CreatureFamily(Infernal) PetStuff()
		
		# Cooldowns
		if Boss() and { Speed() == 0 or CanMove() > 0 } AfflictionDefaultCdActions()
		
		# Short Cooldowns
		if Speed() == 0 or CanMove() > 0 AfflictionDefaultShortCdActions()
		
		# Default rotation
		if Speed() == 0 or CanMove() > 0 AfflictionDefaultMainActions()
		
		#shadow_bolt,if=buff.movement.up&buff.nightfall.remains
		if Speed() > 0 and BuffPresent(nightfall_buff) Spell(shadow_bolt_affliction)
		#agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
		if Speed() > 0 and not { Talent(siphon_life_talent) and PreviousGCDSpell(agony) and PreviousGCDSpell(agony count=2) and PreviousGCDSpell(agony count=3) or PreviousGCDSpell(agony) } Spell(agony)
		#siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
		if Speed() > 0 and not { PreviousGCDSpell(siphon_life) and PreviousGCDSpell(siphon_life count=2) and PreviousGCDSpell(siphon_life count=3) } Spell(siphon_life)
		#corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
		if Speed() > 0 and not PreviousGCDSpell(corruption) and not Talent(absolute_corruption_talent) Spell(corruption)
	}
	
	if not InCombat() and not mounted() OutOfCombatActions()
}

AddFunction InterruptActions
{
	if { target.HasManagedInterrupts() and target.MustBeInterrupted() } or { not target.HasManagedInterrupts() and target.IsInterruptible() }
	{
		if target.Distance() - pet.Distance() <= 40 and pet.CreatureFamily(Felhunter) Spell(spell_lock_fh)
		if target.Distance() - pet.Distance() <= 40 and pet.CreatureFamily(Doomguard) Spell(shadow_lock_dg)
	}
}

AddFunction PetStuff
{
	if pet.Health() < pet.HealthMissing() and pet.Present() and Speed() == 0 and SpellUsable(health_funnel) Texture(ability_deathwing_bloodcorruption_death)
}

AddFunction SaveActions
{
	if HealthPercent() < 30 and InCombat() Spell(unending_resolve)
	if HealthPercent() < 50 and ItemCharges(healthstone) > 0 and Item(healthstone usable=1) Texture(inv_stone_04)
}

AddFunction OutOfCombatActions
{
	if not ItemCharges(healthstone) > 0 and Speed() == 0 and SpellUsable(create_healthstone) and not PreviousGCDSpell(create_healthstone) Texture(inv_misc_gem_bloodstone_01)
}

AddFunction AfflictionUseItemActions
{
	if Item(Trinket0Slot usable=1) Texture(inv_jewelry_talisman_12)
	if Item(Trinket1Slot usable=1) Texture(inv_jewelry_talisman_12)
}

AddFunction maintain_se
{
 Enemies(tagged=1) <= 1 + TalentPoints(writhe_in_agony_talent) + TalentPoints(absolute_corruption_talent) * 2 + { Talent(writhe_in_agony_talent) and Talent(sow_the_seeds_talent) and Enemies(tagged=1) > 2 } + { Talent(siphon_life_talent) and not Talent(creeping_death_talent) and not Talent(drain_soul_talent) } + False(raid_events_invulnerable_up)
}

AddFunction use_seed
{
 Talent(sow_the_seeds_talent) and Enemies(tagged=1) >= 3 + False(raid_events_invulnerable_up) or Talent(siphon_life_talent) and Enemies(tagged=1) >= 5 + False(raid_events_invulnerable_up) or Enemies(tagged=1) >= 8 + False(raid_events_invulnerable_up)
}

AddFunction padding
{
 ExecuteTime(shadow_bolt_affliction) * HasAzeriteTrait(cascading_calamity_trait)
}

### actions.default

AddFunction AfflictionDefaultMainActions
{
 #variable,name=use_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3+raid_event.invulnerable.up|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5+raid_event.invulnerable.up|spell_targets.seed_of_corruption>=8+raid_event.invulnerable.up
 #variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
 #variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
 #variable,name=maintain_se,value=spell_targets.seed_of_corruption_aoe<=1+talent.writhe_in_agony.enabled+talent.absolute_corruption.enabled*2+(talent.writhe_in_agony.enabled&talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>2)+(talent.siphon_life.enabled&!talent.creeping_death.enabled&!talent.drain_soul.enabled)+raid_event.invulnerable.up
 #call_action_list,name=cooldowns
 AfflictionCooldownsMainActions()

 unless AfflictionCooldownsMainPostConditions()
 {
  #drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd&soul_shard<5
  if target.TimeToDie() <= GCD() and SoulShards() < 5 Spell(drain_soul)
  #haunt,if=spell_targets.seed_of_corruption_aoe<=2+raid_event.invulnerable.up
  if Enemies(tagged=1) <= 2 + False(raid_events_invulnerable_up) Spell(haunt)
  #agony,target_if=min:dot.agony.remains,if=remains<=gcd+action.shadow_bolt.execute_time&target.time_to_die>8
  if target.DebuffRemaining(agony_debuff) <= GCD() + ExecuteTime(shadow_bolt_affliction) + 1 and target.TimeToDie() > 8 Spell(agony)
  #unstable_affliction,target_if=!contagion&target.time_to_die<=8
  if not BuffRemaining(unstable_affliction_buff) and target.TimeToDie() <= 8 Spell(unstable_affliction)
  #drain_soul,target_if=min:debuff.shadow_embrace.remains,cancel_if=ticks_remain<5,if=talent.shadow_embrace.enabled&variable.maintain_se&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=gcd*2
  if Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= GCD() * 2 Spell(drain_soul)
  #shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&variable.maintain_se&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=execute_time*2+travel_time&!action.shadow_bolt.in_flight
  if Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt_affliction) * 2 + TravelTime(shadow_bolt_affliction) and not InFlightToTarget(shadow_bolt_affliction) Spell(shadow_bolt_affliction)
  #vile_taint,target_if=max:target.time_to_die,if=time>15&target.time_to_die>=10
  if TimeInCombat() > 15 and target.TimeToDie() >= 10 Spell(vile_taint)
  #unstable_affliction,target_if=min:contagion,if=!variable.use_seed&soul_shard=5
  if not use_seed() and SoulShards() == 5 Spell(unstable_affliction)
  #seed_of_corruption,if=variable.use_seed&soul_shard=5
  if use_seed() and SoulShards() == 5 Spell(seed_of_corruption)
  #call_action_list,name=dots
  AfflictionDotsMainActions()

  unless AfflictionDotsMainPostConditions()
  {
   #vile_taint,if=time<15
   if TimeInCombat() < 15 Spell(vile_taint)
   #call_action_list,name=spenders
   AfflictionSpendersMainActions()

   unless AfflictionSpendersMainPostConditions()
   {
    #call_action_list,name=fillers
    AfflictionFillersMainActions()
   }
  }
 }
}

AddFunction AfflictionDefaultMainPostConditions
{
 AfflictionCooldownsMainPostConditions() or AfflictionDotsMainPostConditions() or AfflictionSpendersMainPostConditions() or AfflictionFillersMainPostConditions()
}

AddFunction AfflictionDefaultShortCdActions
{
 #variable,name=use_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3+raid_event.invulnerable.up|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5+raid_event.invulnerable.up|spell_targets.seed_of_corruption>=8+raid_event.invulnerable.up
 #variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
 #variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
 #variable,name=maintain_se,value=spell_targets.seed_of_corruption_aoe<=1+talent.writhe_in_agony.enabled+talent.absolute_corruption.enabled*2+(talent.writhe_in_agony.enabled&talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>2)+(talent.siphon_life.enabled&!talent.creeping_death.enabled&!talent.drain_soul.enabled)+raid_event.invulnerable.up
 #call_action_list,name=cooldowns
 AfflictionCooldownsShortCdActions()

 unless AfflictionCooldownsShortCdPostConditions() or target.TimeToDie() <= GCD() and SoulShards() < 5 and Spell(drain_soul) or Enemies(tagged=1) <= 2 + False(raid_events_invulnerable_up) and Spell(haunt)
 {
  #deathbolt,if=cooldown.summon_darkglare.remains&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up
  if SpellCooldown(summon_darkglare) > 0 and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) Spell(deathbolt)

  unless target.DebuffRemaining(agony_debuff) <= GCD() + ExecuteTime(shadow_bolt_affliction) and target.TimeToDie() > 8 and Spell(agony) or not BuffRemaining(unstable_affliction_buff) and target.TimeToDie() <= 8 and Spell(unstable_affliction) or Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= GCD() * 2 and Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt_affliction) * 2 + TravelTime(shadow_bolt_affliction) and not InFlightToTarget(shadow_bolt_affliction) and Spell(shadow_bolt_affliction)
  {
   #phantom_singularity,target_if=max:target.time_to_die,if=time>35&target.time_to_die>16*spell_haste
   if TimeInCombat() > 35 and target.TimeToDie() > 16 * { 100 / { 100 + SpellCastSpeedPercent() } } Spell(phantom_singularity)

   unless TimeInCombat() > 15 and target.TimeToDie() >= 10 and Spell(vile_taint) or not use_seed() and SoulShards() == 5 and Spell(unstable_affliction) or use_seed() and SoulShards() == 5 and Spell(seed_of_corruption)
   {
    #call_action_list,name=dots
    AfflictionDotsShortCdActions()

    unless AfflictionDotsShortCdPostConditions()
    {
     #phantom_singularity,if=time<=35
     if TimeInCombat() <= 35 Spell(phantom_singularity)

     unless TimeInCombat() < 15 and Spell(vile_taint)
     {
      #call_action_list,name=spenders
      AfflictionSpendersShortCdActions()

      unless AfflictionSpendersShortCdPostConditions()
      {
       #call_action_list,name=fillers
       AfflictionFillersShortCdActions()
      }
     }
    }
   }
  }
 }
}

AddFunction AfflictionDefaultShortCdPostConditions
{
 AfflictionCooldownsShortCdPostConditions() or target.TimeToDie() <= GCD() and SoulShards() < 5 and Spell(drain_soul) or Enemies(tagged=1) <= 2 + False(raid_events_invulnerable_up) and Spell(haunt) or target.DebuffRemaining(agony_debuff) <= GCD() + ExecuteTime(shadow_bolt_affliction) and target.TimeToDie() > 8 and Spell(agony) or not BuffRemaining(unstable_affliction_buff) and target.TimeToDie() <= 8 and Spell(unstable_affliction) or Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= GCD() * 2 and Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt_affliction) * 2 + TravelTime(shadow_bolt_affliction) and not InFlightToTarget(shadow_bolt_affliction) and Spell(shadow_bolt_affliction) or TimeInCombat() > 15 and target.TimeToDie() >= 10 and Spell(vile_taint) or not use_seed() and SoulShards() == 5 and Spell(unstable_affliction) or use_seed() and SoulShards() == 5 and Spell(seed_of_corruption) or AfflictionDotsShortCdPostConditions() or TimeInCombat() < 15 and Spell(vile_taint) or AfflictionSpendersShortCdPostConditions() or AfflictionFillersShortCdPostConditions()
}

AddFunction AfflictionDefaultCdActions
{
 #variable,name=use_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3+raid_event.invulnerable.up|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5+raid_event.invulnerable.up|spell_targets.seed_of_corruption>=8+raid_event.invulnerable.up
 #variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
 #variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
 #variable,name=maintain_se,value=spell_targets.seed_of_corruption_aoe<=1+talent.writhe_in_agony.enabled+talent.absolute_corruption.enabled*2+(talent.writhe_in_agony.enabled&talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>2)+(talent.siphon_life.enabled&!talent.creeping_death.enabled&!talent.drain_soul.enabled)+raid_event.invulnerable.up
 #call_action_list,name=cooldowns
 AfflictionCooldownsCdActions()

 unless AfflictionCooldownsCdPostConditions() or target.TimeToDie() <= GCD() and SoulShards() < 5 and Spell(drain_soul) or Enemies(tagged=1) <= 2 + False(raid_events_invulnerable_up) and Spell(haunt)
 {
  #summon_darkglare,if=dot.agony.ticking&dot.corruption.ticking&(buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|dot.phantom_singularity.remains)&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=gcd|!cooldown.deathbolt.remains|spell_targets.seed_of_corruption_aoe>1+raid_event.invulnerable.up)
  if target.DebuffPresent(agony_debuff) and target.DebuffPresent(corruption_debuff) and { target.DebuffStacks(unstable_affliction_debuff) == 5 or SoulShards() == 0 } and { not Talent(phantom_singularity_talent) or target.DebuffRemaining(phantom_singularity) } and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) <= GCD() or not SpellCooldown(deathbolt) > 0 or Enemies(tagged=1) > 1 + False(raid_events_invulnerable_up) } Spell(summon_darkglare)

  unless SpellCooldown(summon_darkglare) > 0 and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and Spell(deathbolt) or target.DebuffRemaining(agony_debuff) <= GCD() + ExecuteTime(shadow_bolt_affliction) and target.TimeToDie() > 8 and Spell(agony) or not BuffRemaining(unstable_affliction_buff) and target.TimeToDie() <= 8 and Spell(unstable_affliction) or Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= GCD() * 2 and Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt_affliction) * 2 + TravelTime(shadow_bolt_affliction) and not InFlightToTarget(shadow_bolt_affliction) and Spell(shadow_bolt_affliction) or TimeInCombat() > 35 and target.TimeToDie() > 16 * { 100 / { 100 + SpellCastSpeedPercent() } } and Spell(phantom_singularity) or TimeInCombat() > 15 and target.TimeToDie() >= 10 and Spell(vile_taint) or not use_seed() and SoulShards() == 5 and Spell(unstable_affliction) or use_seed() and SoulShards() == 5 and Spell(seed_of_corruption)
  {
   #call_action_list,name=dots
   AfflictionDotsCdActions()

   unless AfflictionDotsCdPostConditions() or TimeInCombat() <= 35 and Spell(phantom_singularity) or TimeInCombat() < 15 and Spell(vile_taint)
   {
    #dark_soul,if=cooldown.summon_darkglare.remains<10&dot.phantom_singularity.remains|target.time_to_die<20+gcd|spell_targets.seed_of_corruption_aoe>1+raid_event.invulnerable.up
    if SpellCooldown(summon_darkglare) < 10 and target.DebuffRemaining(phantom_singularity) or target.TimeToDie() < 20 + GCD() or Enemies(tagged=1) > 1 + False(raid_events_invulnerable_up) Spell(dark_soul_misery)
    #berserking
    Spell(berserking)
    #call_action_list,name=spenders
    AfflictionSpendersCdActions()

    unless AfflictionSpendersCdPostConditions()
    {
     #call_action_list,name=fillers
     AfflictionFillersCdActions()
    }
   }
  }
 }
}

AddFunction AfflictionDefaultCdPostConditions
{
 AfflictionCooldownsCdPostConditions() or target.TimeToDie() <= GCD() and SoulShards() < 5 and Spell(drain_soul) or Enemies(tagged=1) <= 2 + False(raid_events_invulnerable_up) and Spell(haunt) or SpellCooldown(summon_darkglare) > 0 and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and Spell(deathbolt) or target.DebuffRemaining(agony_debuff) <= GCD() + ExecuteTime(shadow_bolt_affliction) and target.TimeToDie() > 8 and Spell(agony) or not BuffRemaining(unstable_affliction_buff) and target.TimeToDie() <= 8 and Spell(unstable_affliction) or Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= GCD() * 2 and Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and target.DebuffPresent(shadow_embrace_debuff) and target.DebuffRemaining(shadow_embrace_debuff) <= ExecuteTime(shadow_bolt_affliction) * 2 + TravelTime(shadow_bolt_affliction) and not InFlightToTarget(shadow_bolt_affliction) and Spell(shadow_bolt_affliction) or TimeInCombat() > 35 and target.TimeToDie() > 16 * { 100 / { 100 + SpellCastSpeedPercent() } } and Spell(phantom_singularity) or TimeInCombat() > 15 and target.TimeToDie() >= 10 and Spell(vile_taint) or not use_seed() and SoulShards() == 5 and Spell(unstable_affliction) or use_seed() and SoulShards() == 5 and Spell(seed_of_corruption) or AfflictionDotsCdPostConditions() or TimeInCombat() <= 35 and Spell(phantom_singularity) or TimeInCombat() < 15 and Spell(vile_taint) or AfflictionSpendersCdPostConditions() or AfflictionFillersCdPostConditions()
}

### actions.cooldowns

AddFunction AfflictionCooldownsMainActions
{
}

AddFunction AfflictionCooldownsMainPostConditions
{
}

AddFunction AfflictionCooldownsShortCdActions
{
}

AddFunction AfflictionCooldownsShortCdPostConditions
{
}

AddFunction AfflictionCooldownsCdActions
{
 #potion,if=(talent.dark_soul_misery.enabled&cooldown.summon_darkglare.up&cooldown.dark_soul.up)|cooldown.summon_darkglare.up|target.time_to_die<30
 # if { Talent(dark_soul_misery_talent) and not SpellCooldown(summon_darkglare) > 0 and not SpellCooldown(dark_soul_misery) > 0 or not SpellCooldown(summon_darkglare) > 0 or target.TimeToDie() < 30 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
 #use_items,if=!cooldown.summon_darkglare.up,if=cooldown.summon_darkglare.remains>70|time_to_die<20|((buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains)&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=gcd|!cooldown.deathbolt.remains)&!cooldown.summon_darkglare.remains)
 if SpellCooldown(summon_darkglare) > 70 or target.TimeToDie() < 20 or { target.DebuffStacks(unstable_affliction_debuff) == 5 or SoulShards() == 0 } and { not Talent(phantom_singularity_talent) or SpellCooldown(phantom_singularity) > 0 } and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) <= GCD() or not SpellCooldown(deathbolt) > 0 } and not SpellCooldown(summon_darkglare) > 0 AfflictionUseItemActions()
 #fireblood,if=!cooldown.summon_darkglare.up
 if not { not SpellCooldown(summon_darkglare) > 0 } Spell(fireblood)
 #blood_fury,if=!cooldown.summon_darkglare.up
 if not { not SpellCooldown(summon_darkglare) > 0 } Spell(blood_fury_sp)
}

AddFunction AfflictionCooldownsCdPostConditions
{
}

### actions.db_refresh

AddFunction AfflictionDbRefreshMainActions
{
 #siphon_life,line_cd=15,if=(dot.siphon_life.remains%dot.siphon_life.duration)<=(dot.agony.remains%dot.agony.duration)&(dot.siphon_life.remains%dot.siphon_life.duration)<=(dot.corruption.remains%dot.corruption.duration)&dot.siphon_life.remains<dot.siphon_life.duration*1.3
 if target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) <= target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) and target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) <= target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) and target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1.3 and TimeSincePreviousSpell(siphon_life) > 15 Spell(siphon_life)
 #agony,line_cd=15,if=(dot.agony.remains%dot.agony.duration)<=(dot.corruption.remains%dot.corruption.duration)&(dot.agony.remains%dot.agony.duration)<=(dot.siphon_life.remains%dot.siphon_life.duration)&dot.agony.remains<dot.agony.duration*1.3
 if target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) <= target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) and target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) <= target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) and target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1.3 and TimeSincePreviousSpell(agony) > 15 Spell(agony)
 #corruption,line_cd=15,if=(dot.corruption.remains%dot.corruption.duration)<=(dot.agony.remains%dot.agony.duration)&(dot.corruption.remains%dot.corruption.duration)<=(dot.siphon_life.remains%dot.siphon_life.duration)&dot.corruption.remains<dot.corruption.duration*1.3
 if target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) <= target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) and target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) <= target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) and target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1.3 and TimeSincePreviousSpell(corruption) > 15 Spell(corruption)
}

AddFunction AfflictionDbRefreshMainPostConditions
{
}

AddFunction AfflictionDbRefreshShortCdActions
{
}

AddFunction AfflictionDbRefreshShortCdPostConditions
{
 target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) <= target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) and target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) <= target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) and target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1.3 and TimeSincePreviousSpell(siphon_life) > 15 and Spell(siphon_life) or target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) <= target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) and target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) <= target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) and target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1.3 and TimeSincePreviousSpell(agony) > 15 and Spell(agony) or target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) <= target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) and target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) <= target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) and target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1.3 and TimeSincePreviousSpell(corruption) > 15 and Spell(corruption)
}

AddFunction AfflictionDbRefreshCdActions
{
}

AddFunction AfflictionDbRefreshCdPostConditions
{
 target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) <= target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) and target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) <= target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) and target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1.3 and TimeSincePreviousSpell(siphon_life) > 15 and Spell(siphon_life) or target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) <= target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) and target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) <= target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) and target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1.3 and TimeSincePreviousSpell(agony) > 15 and Spell(agony) or target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) <= target.DebuffRemaining(agony_debuff) / target.DebuffDuration(agony_debuff) and target.DebuffRemaining(corruption_debuff) / target.DebuffDuration(corruption_debuff) <= target.DebuffRemaining(siphon_life_debuff) / target.DebuffDuration(siphon_life_debuff) and target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1.3 and TimeSincePreviousSpell(corruption) > 15 and Spell(corruption)
}

### actions.dots

AddFunction AfflictionDotsMainActions
{
 #seed_of_corruption,if=dot.corruption.remains<=action.seed_of_corruption.cast_time+time_to_shard+4.2*(1-talent.creeping_death.enabled*0.15)&spell_targets.seed_of_corruption_aoe>=3+raid_event.invulnerable.up+talent.writhe_in_agony.enabled&!dot.seed_of_corruption.remains&!action.seed_of_corruption.in_flight
 if target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TimeToShard() + 4.2 * { 1 - TalentPoints(creeping_death_talent) * 0.15 } and Enemies(tagged=1) >= 3 + False(raid_events_invulnerable_up) + TalentPoints(writhe_in_agony_talent) and not target.DebuffRemaining(seed_of_corruption_debuff) and not InFlightToTarget(seed_of_corruption) Spell(seed_of_corruption)
 #agony,target_if=min:remains,if=talent.creeping_death.enabled&active_dot.agony<6&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&(remains<5|!azerite.pandemic_invocation.rank&refreshable))
 if Talent(creeping_death_talent) and DebuffCountOnAny(agony_debuff) < 6 and target.TimeToDie() > 10 and { target.DebuffRemaining(agony_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and { target.DebuffRemaining(agony_debuff) < 5 or not AzeriteTraitRank(pandemic_invocation_trait) and target.Refreshable(agony_debuff) } } Spell(agony)
 #agony,target_if=min:remains,if=!talent.creeping_death.enabled&active_dot.agony<8&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&(remains<5|!azerite.pandemic_invocation.rank&refreshable))
 if not Talent(creeping_death_talent) and DebuffCountOnAny(agony_debuff) < 8 and target.TimeToDie() > 10 and { target.DebuffRemaining(agony_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and { target.DebuffRemaining(agony_debuff) < 5 or not AzeriteTraitRank(pandemic_invocation_trait) and target.Refreshable(agony_debuff) } } Spell(agony)
 #siphon_life,target_if=min:remains,if=(active_dot.siphon_life<8-talent.creeping_death.enabled-spell_targets.sow_the_seeds_aoe)&target.time_to_die>10&refreshable&(!remains&spell_targets.seed_of_corruption_aoe=1|cooldown.summon_darkglare.remains>soul_shard*action.unstable_affliction.execute_time)
 if DebuffCountOnAny(siphon_life_debuff) < 8 - TalentPoints(creeping_death_talent) - Enemies(tagged=1) and target.TimeToDie() > 10 and target.Refreshable(siphon_life_debuff) and { not target.DebuffRemaining(siphon_life_debuff) and Enemies(tagged=1) == 1 or SpellCooldown(summon_darkglare) > SoulShards() * ExecuteTime(unstable_affliction) } Spell(siphon_life)
 #corruption,cycle_targets=1,if=spell_targets.seed_of_corruption_aoe<3+raid_event.invulnerable.up+talent.writhe_in_agony.enabled&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)&target.time_to_die>10
 if Enemies(tagged=1) < 3 + False(raid_events_invulnerable_up) + TalentPoints(writhe_in_agony_talent) and { target.DebuffRemaining(corruption_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and target.Refreshable(corruption_debuff) } and target.TimeToDie() > 10 Spell(corruption)
}

AddFunction AfflictionDotsMainPostConditions
{
}

AddFunction AfflictionDotsShortCdActions
{
}

AddFunction AfflictionDotsShortCdPostConditions
{
 target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TimeToShard() + 4.2 * { 1 - TalentPoints(creeping_death_talent) * 0.15 } and Enemies(tagged=1) >= 3 + False(raid_events_invulnerable_up) + TalentPoints(writhe_in_agony_talent) and not target.DebuffRemaining(seed_of_corruption_debuff) and not InFlightToTarget(seed_of_corruption) and Spell(seed_of_corruption) or Talent(creeping_death_talent) and DebuffCountOnAny(agony_debuff) < 6 and target.TimeToDie() > 10 and { target.DebuffRemaining(agony_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and { target.DebuffRemaining(agony_debuff) < 5 or not AzeriteTraitRank(pandemic_invocation_trait) and target.Refreshable(agony_debuff) } } and Spell(agony) or not Talent(creeping_death_talent) and DebuffCountOnAny(agony_debuff) < 8 and target.TimeToDie() > 10 and { target.DebuffRemaining(agony_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and { target.DebuffRemaining(agony_debuff) < 5 or not AzeriteTraitRank(pandemic_invocation_trait) and target.Refreshable(agony_debuff) } } and Spell(agony) or DebuffCountOnAny(siphon_life_debuff) < 8 - TalentPoints(creeping_death_talent) - Enemies(tagged=1) and target.TimeToDie() > 10 and target.Refreshable(siphon_life_debuff) and { not target.DebuffRemaining(siphon_life_debuff) and Enemies(tagged=1) == 1 or SpellCooldown(summon_darkglare) > SoulShards() * ExecuteTime(unstable_affliction) } and Spell(siphon_life) or Enemies(tagged=1) < 3 + False(raid_events_invulnerable_up) + TalentPoints(writhe_in_agony_talent) and { target.DebuffRemaining(corruption_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and target.Refreshable(corruption_debuff) } and target.TimeToDie() > 10 and Spell(corruption)
}

AddFunction AfflictionDotsCdActions
{
}

AddFunction AfflictionDotsCdPostConditions
{
 target.DebuffRemaining(corruption_debuff) <= CastTime(seed_of_corruption) + TimeToShard() + 4.2 * { 1 - TalentPoints(creeping_death_talent) * 0.15 } and Enemies(tagged=1) >= 3 + False(raid_events_invulnerable_up) + TalentPoints(writhe_in_agony_talent) and not target.DebuffRemaining(seed_of_corruption_debuff) and not InFlightToTarget(seed_of_corruption) and Spell(seed_of_corruption) or Talent(creeping_death_talent) and DebuffCountOnAny(agony_debuff) < 6 and target.TimeToDie() > 10 and { target.DebuffRemaining(agony_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and { target.DebuffRemaining(agony_debuff) < 5 or not AzeriteTraitRank(pandemic_invocation_trait) and target.Refreshable(agony_debuff) } } and Spell(agony) or not Talent(creeping_death_talent) and DebuffCountOnAny(agony_debuff) < 8 and target.TimeToDie() > 10 and { target.DebuffRemaining(agony_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and { target.DebuffRemaining(agony_debuff) < 5 or not AzeriteTraitRank(pandemic_invocation_trait) and target.Refreshable(agony_debuff) } } and Spell(agony) or DebuffCountOnAny(siphon_life_debuff) < 8 - TalentPoints(creeping_death_talent) - Enemies(tagged=1) and target.TimeToDie() > 10 and target.Refreshable(siphon_life_debuff) and { not target.DebuffRemaining(siphon_life_debuff) and Enemies(tagged=1) == 1 or SpellCooldown(summon_darkglare) > SoulShards() * ExecuteTime(unstable_affliction) } and Spell(siphon_life) or Enemies(tagged=1) < 3 + False(raid_events_invulnerable_up) + TalentPoints(writhe_in_agony_talent) and { target.DebuffRemaining(corruption_debuff) <= GCD() or SpellCooldown(summon_darkglare) > 10 and target.Refreshable(corruption_debuff) } and target.TimeToDie() > 10 and Spell(corruption)
}

### actions.fillers

AddFunction AfflictionFillersMainActions
{
 #unstable_affliction,line_cd=15,if=cooldown.deathbolt.remains<=gcd*2&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&cooldown.summon_darkglare.remains>20
 if SpellCooldown(deathbolt) <= GCD() * 2 and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) > 20 and TimeSincePreviousSpell(unstable_affliction) > 15 Spell(unstable_affliction)
 #call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&(dot.agony.remains<dot.agony.duration*0.75|dot.corruption.remains<dot.corruption.duration*0.75|dot.siphon_life.remains<dot.siphon_life.duration*0.75)&cooldown.deathbolt.remains<=action.agony.gcd*4&cooldown.summon_darkglare.remains>20
 if Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 AfflictionDbRefreshMainActions()

 unless Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 and AfflictionDbRefreshMainPostConditions()
 {
  #call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&cooldown.summon_darkglare.remains<=soul_shard*action.agony.gcd+action.agony.gcd*3&(dot.agony.remains<dot.agony.duration*1|dot.corruption.remains<dot.corruption.duration*1|dot.siphon_life.remains<dot.siphon_life.duration*1)
  if Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) <= SoulShards() * GCD() + GCD() * 3 and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1 } AfflictionDbRefreshMainActions()

  unless Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) <= SoulShards() * GCD() + GCD() * 3 and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1 } and AfflictionDbRefreshMainPostConditions()
  {
   #shadow_bolt,if=buff.movement.up&buff.nightfall.remains
   if Speed() > 0 and BuffPresent(nightfall_buff) Spell(shadow_bolt_affliction)
   #agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
   if Speed() > 0 and not { Talent(siphon_life_talent) and PreviousGCDSpell(agony) and PreviousGCDSpell(agony count=2) and PreviousGCDSpell(agony count=3) or PreviousGCDSpell(agony) } Spell(agony)
   #siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
   if Speed() > 0 and not { PreviousGCDSpell(siphon_life) and PreviousGCDSpell(siphon_life count=2) and PreviousGCDSpell(siphon_life count=3) } Spell(siphon_life)
   #corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
   if Speed() > 0 and not PreviousGCDSpell(corruption) and not Talent(absolute_corruption_talent) Spell(corruption)
   #drain_life,if=(buff.inevitable_demise.stack>=40-(spell_targets.seed_of_corruption_aoe-raid_event.invulnerable.up>2)*20&(cooldown.deathbolt.remains>execute_time|!talent.deathbolt.enabled)&(cooldown.phantom_singularity.remains>execute_time|!talent.phantom_singularity.enabled)&(cooldown.dark_soul.remains>execute_time|!talent.dark_soul_misery.enabled)&(cooldown.vile_taint.remains>execute_time|!talent.vile_taint.enabled)&cooldown.summon_darkglare.remains>execute_time+10|buff.inevitable_demise.stack>10&target.time_to_die<=10)
   if BuffStacks(inevitable_demise_buff) >= 40 - { Enemies(tagged=1) - False(raid_events_invulnerable_up) > 2 } * 20 and { SpellCooldown(deathbolt) > ExecuteTime(drain_life) or not Talent(deathbolt_talent) } and { SpellCooldown(phantom_singularity) > ExecuteTime(drain_life) or not Talent(phantom_singularity_talent) } and { SpellCooldown(dark_soul_misery) > ExecuteTime(drain_life) or not Talent(dark_soul_misery_talent) } and { SpellCooldown(vile_taint) > ExecuteTime(drain_life) or not Talent(vile_taint_talent) } and SpellCooldown(summon_darkglare) > ExecuteTime(drain_life) + 10 or BuffStacks(inevitable_demise_buff) > 10 and target.TimeToDie() <= 10 Spell(drain_life)
   #haunt
   Spell(haunt)
   #drain_soul,interrupt_global=1,chain=1,interrupt=1,cycle_targets=1,if=target.time_to_die<=gcd
   if target.TimeToDie() <= GCD() Spell(drain_soul)
   #drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&variable.maintain_se&!debuff.shadow_embrace.remains
   if Talent(shadow_embrace_talent) and maintain_se() and not target.DebuffPresent(shadow_embrace_debuff) Spell(drain_soul)
   #drain_soul,target_if=min:debuff.shadow_embrace.remains,chain=1,interrupt_if=ticks_remain<5,interrupt_global=1,if=talent.shadow_embrace.enabled&variable.maintain_se
   if Talent(shadow_embrace_talent) and maintain_se() Spell(drain_soul)
   #drain_soul,interrupt_global=1,chain=1,interrupt=1
   Spell(drain_soul)
   #shadow_bolt,cycle_targets=1,if=talent.shadow_embrace.enabled&variable.maintain_se&!debuff.shadow_embrace.remains&!action.shadow_bolt.in_flight
   if Talent(shadow_embrace_talent) and maintain_se() and not target.DebuffPresent(shadow_embrace_debuff) and not InFlightToTarget(shadow_bolt_affliction) Spell(shadow_bolt_affliction)
   #shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&variable.maintain_se
   if Talent(shadow_embrace_talent) and maintain_se() Spell(shadow_bolt_affliction)
   #shadow_bolt
   Spell(shadow_bolt_affliction)
  }
 }
}

AddFunction AfflictionFillersMainPostConditions
{
 Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 and AfflictionDbRefreshMainPostConditions() or Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) <= SoulShards() * GCD() + GCD() * 3 and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1 } and AfflictionDbRefreshMainPostConditions()
}

AddFunction AfflictionFillersShortCdActions
{
 unless SpellCooldown(deathbolt) <= GCD() * 2 and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) > 20 and TimeSincePreviousSpell(unstable_affliction) > 15 and Spell(unstable_affliction)
 {
  #call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&(dot.agony.remains<dot.agony.duration*0.75|dot.corruption.remains<dot.corruption.duration*0.75|dot.siphon_life.remains<dot.siphon_life.duration*0.75)&cooldown.deathbolt.remains<=action.agony.gcd*4&cooldown.summon_darkglare.remains>20
  if Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 AfflictionDbRefreshShortCdActions()

  unless Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 and AfflictionDbRefreshShortCdPostConditions()
  {
   #call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&cooldown.summon_darkglare.remains<=soul_shard*action.agony.gcd+action.agony.gcd*3&(dot.agony.remains<dot.agony.duration*1|dot.corruption.remains<dot.corruption.duration*1|dot.siphon_life.remains<dot.siphon_life.duration*1)
   if Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) <= SoulShards() * GCD() + GCD() * 3 and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1 } AfflictionDbRefreshShortCdActions()

   unless Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) <= SoulShards() * GCD() + GCD() * 3 and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1 } and AfflictionDbRefreshShortCdPostConditions()
   {
    #deathbolt,if=cooldown.summon_darkglare.remains>=30+gcd|cooldown.summon_darkglare.remains>140
    if SpellCooldown(summon_darkglare) >= 30 + GCD() or SpellCooldown(summon_darkglare) > 140 Spell(deathbolt)
   }
  }
 }
}

AddFunction AfflictionFillersShortCdPostConditions
{
 SpellCooldown(deathbolt) <= GCD() * 2 and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) > 20 and TimeSincePreviousSpell(unstable_affliction) > 15 and Spell(unstable_affliction) or Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 and AfflictionDbRefreshShortCdPostConditions() or Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) <= SoulShards() * GCD() + GCD() * 3 and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1 } and AfflictionDbRefreshShortCdPostConditions() or Speed() > 0 and BuffPresent(nightfall_buff) and Spell(shadow_bolt_affliction) or Speed() > 0 and not { Talent(siphon_life_talent) and PreviousGCDSpell(agony) and PreviousGCDSpell(agony count=2) and PreviousGCDSpell(agony count=3) or PreviousGCDSpell(agony) } and Spell(agony) or Speed() > 0 and not { PreviousGCDSpell(siphon_life) and PreviousGCDSpell(siphon_life count=2) and PreviousGCDSpell(siphon_life count=3) } and Spell(siphon_life) or Speed() > 0 and not PreviousGCDSpell(corruption) and not Talent(absolute_corruption_talent) and Spell(corruption) or { BuffStacks(inevitable_demise_buff) >= 40 - { Enemies(tagged=1) - False(raid_events_invulnerable_up) > 2 } * 20 and { SpellCooldown(deathbolt) > ExecuteTime(drain_life) or not Talent(deathbolt_talent) } and { SpellCooldown(phantom_singularity) > ExecuteTime(drain_life) or not Talent(phantom_singularity_talent) } and { SpellCooldown(dark_soul_misery) > ExecuteTime(drain_life) or not Talent(dark_soul_misery_talent) } and { SpellCooldown(vile_taint) > ExecuteTime(drain_life) or not Talent(vile_taint_talent) } and SpellCooldown(summon_darkglare) > ExecuteTime(drain_life) + 10 or BuffStacks(inevitable_demise_buff) > 10 and target.TimeToDie() <= 10 } and Spell(drain_life) or Spell(haunt) or target.TimeToDie() <= GCD() and Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and not target.DebuffPresent(shadow_embrace_debuff) and Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and Spell(drain_soul) or Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and not target.DebuffPresent(shadow_embrace_debuff) and not InFlightToTarget(shadow_bolt_affliction) and Spell(shadow_bolt_affliction) or Talent(shadow_embrace_talent) and maintain_se() and Spell(shadow_bolt_affliction) or Spell(shadow_bolt_affliction)
}

AddFunction AfflictionFillersCdActions
{
 unless SpellCooldown(deathbolt) <= GCD() * 2 and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) > 20 and TimeSincePreviousSpell(unstable_affliction) > 15 and Spell(unstable_affliction)
 {
  #call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&(dot.agony.remains<dot.agony.duration*0.75|dot.corruption.remains<dot.corruption.duration*0.75|dot.siphon_life.remains<dot.siphon_life.duration*0.75)&cooldown.deathbolt.remains<=action.agony.gcd*4&cooldown.summon_darkglare.remains>20
  if Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 AfflictionDbRefreshCdActions()

  unless Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 and AfflictionDbRefreshCdPostConditions()
  {
   #call_action_list,name=db_refresh,if=talent.deathbolt.enabled&spell_targets.seed_of_corruption_aoe=1+raid_event.invulnerable.up&cooldown.summon_darkglare.remains<=soul_shard*action.agony.gcd+action.agony.gcd*3&(dot.agony.remains<dot.agony.duration*1|dot.corruption.remains<dot.corruption.duration*1|dot.siphon_life.remains<dot.siphon_life.duration*1)
   if Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) <= SoulShards() * GCD() + GCD() * 3 and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1 } AfflictionDbRefreshCdActions()
  }
 }
}

AddFunction AfflictionFillersCdPostConditions
{
 SpellCooldown(deathbolt) <= GCD() * 2 and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) > 20 and TimeSincePreviousSpell(unstable_affliction) > 15 and Spell(unstable_affliction) or Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 0.75 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 0.75 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 0.75 } and SpellCooldown(deathbolt) <= GCD() * 4 and SpellCooldown(summon_darkglare) > 20 and AfflictionDbRefreshCdPostConditions() or Talent(deathbolt_talent) and Enemies(tagged=1) == 1 + False(raid_events_invulnerable_up) and SpellCooldown(summon_darkglare) <= SoulShards() * GCD() + GCD() * 3 and { target.DebuffRemaining(agony_debuff) < target.DebuffDuration(agony_debuff) * 1 or target.DebuffRemaining(corruption_debuff) < target.DebuffDuration(corruption_debuff) * 1 or target.DebuffRemaining(siphon_life_debuff) < target.DebuffDuration(siphon_life_debuff) * 1 } and AfflictionDbRefreshCdPostConditions() or { SpellCooldown(summon_darkglare) >= 30 + GCD() or SpellCooldown(summon_darkglare) > 140 } and Spell(deathbolt) or Speed() > 0 and BuffPresent(nightfall_buff) and Spell(shadow_bolt_affliction) or Speed() > 0 and not { Talent(siphon_life_talent) and PreviousGCDSpell(agony) and PreviousGCDSpell(agony count=2) and PreviousGCDSpell(agony count=3) or PreviousGCDSpell(agony) } and Spell(agony) or Speed() > 0 and not { PreviousGCDSpell(siphon_life) and PreviousGCDSpell(siphon_life count=2) and PreviousGCDSpell(siphon_life count=3) } and Spell(siphon_life) or Speed() > 0 and not PreviousGCDSpell(corruption) and not Talent(absolute_corruption_talent) and Spell(corruption) or { BuffStacks(inevitable_demise_buff) >= 40 - { Enemies(tagged=1) - False(raid_events_invulnerable_up) > 2 } * 20 and { SpellCooldown(deathbolt) > ExecuteTime(drain_life) or not Talent(deathbolt_talent) } and { SpellCooldown(phantom_singularity) > ExecuteTime(drain_life) or not Talent(phantom_singularity_talent) } and { SpellCooldown(dark_soul_misery) > ExecuteTime(drain_life) or not Talent(dark_soul_misery_talent) } and { SpellCooldown(vile_taint) > ExecuteTime(drain_life) or not Talent(vile_taint_talent) } and SpellCooldown(summon_darkglare) > ExecuteTime(drain_life) + 10 or BuffStacks(inevitable_demise_buff) > 10 and target.TimeToDie() <= 10 } and Spell(drain_life) or Spell(haunt) or target.TimeToDie() <= GCD() and Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and not target.DebuffPresent(shadow_embrace_debuff) and Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and Spell(drain_soul) or Spell(drain_soul) or Talent(shadow_embrace_talent) and maintain_se() and not target.DebuffPresent(shadow_embrace_debuff) and not InFlightToTarget(shadow_bolt_affliction) and Spell(shadow_bolt_affliction) or Talent(shadow_embrace_talent) and maintain_se() and Spell(shadow_bolt_affliction) or Spell(shadow_bolt_affliction)
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
 if not Talent(haunt_talent) and Enemies(tagged=1) < 3 Spell(shadow_bolt_affliction)
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
 Enemies(tagged=1) >= 3 and Spell(seed_of_corruption) or Spell(haunt) or not Talent(haunt_talent) and Enemies(tagged=1) < 3 and Spell(shadow_bolt_affliction)
}

AddFunction AfflictionPrecombatCdActions
{
 unless not pet.Present() and Spell(summon_imp)
 {
  #snapshot_stats
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
 }
}

AddFunction AfflictionPrecombatCdPostConditions
{
 not pet.Present() and Spell(summon_imp) or Enemies(tagged=1) >= 3 and Spell(seed_of_corruption) or Spell(haunt) or not Talent(haunt_talent) and Enemies(tagged=1) < 3 and Spell(shadow_bolt_affliction)
}

### actions.spenders

AddFunction AfflictionSpendersMainActions
{
 #unstable_affliction,if=cooldown.summon_darkglare.remains<=soul_shard*execute_time&(!talent.deathbolt.enabled|cooldown.deathbolt.remains<=soul_shard*execute_time)
 if SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) <= SoulShards() * ExecuteTime(unstable_affliction) } Spell(unstable_affliction)
 #call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(6-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
 if { SpellCooldown(summon_darkglare) < TimeToShard() * { 6 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) AfflictionFillersMainActions()

 unless { SpellCooldown(summon_darkglare) < TimeToShard() * { 6 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersMainPostConditions()
 {
  #seed_of_corruption,if=variable.use_seed
  if use_seed() Spell(seed_of_corruption)
  #unstable_affliction,if=!variable.use_seed&!prev_gcd.1.summon_darkglare&(talent.deathbolt.enabled&cooldown.deathbolt.remains<=execute_time&!azerite.cascading_calamity.enabled|(soul_shard>=5&spell_targets.seed_of_corruption_aoe<2|soul_shard>=2&spell_targets.seed_of_corruption_aoe>=2)&target.time_to_die>4+execute_time&spell_targets.seed_of_corruption_aoe=1|target.time_to_die<=8+execute_time*soul_shard)
  if not use_seed() and not PreviousGCDSpell(summon_darkglare) and { Talent(deathbolt_talent) and SpellCooldown(deathbolt) <= ExecuteTime(unstable_affliction) and not HasAzeriteTrait(cascading_calamity_trait) or { SoulShards() >= 5 and Enemies(tagged=1) < 2 or SoulShards() >= 2 and Enemies(tagged=1) >= 2 } and target.TimeToDie() > 4 + ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 1 or target.TimeToDie() <= 8 + ExecuteTime(unstable_affliction) * SoulShards() } Spell(unstable_affliction)
  #unstable_affliction,if=!variable.use_seed&contagion<=cast_time+variable.padding
  if not use_seed() and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() Spell(unstable_affliction)
  #unstable_affliction,cycle_targets=1,if=!variable.use_seed&(!talent.deathbolt.enabled|cooldown.deathbolt.remains>time_to_shard|soul_shard>1)&(!talent.vile_taint.enabled|soul_shard>1)&contagion<=cast_time+variable.padding&(!azerite.cascading_calamity.enabled|buff.cascading_calamity.remains>time_to_shard)
  if not use_seed() and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) > TimeToShard() or SoulShards() > 1 } and { not Talent(vile_taint_talent) or SoulShards() > 1 } and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and { not HasAzeriteTrait(cascading_calamity_trait) or BuffRemaining(cascading_calamity_buff) > TimeToShard() } Spell(unstable_affliction)
 }
}

AddFunction AfflictionSpendersMainPostConditions
{
 { SpellCooldown(summon_darkglare) < TimeToShard() * { 6 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersMainPostConditions()
}

AddFunction AfflictionSpendersShortCdActions
{
 unless SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) <= SoulShards() * ExecuteTime(unstable_affliction) } and Spell(unstable_affliction)
 {
  #call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(6-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
  if { SpellCooldown(summon_darkglare) < TimeToShard() * { 6 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) AfflictionFillersShortCdActions()
 }
}

AddFunction AfflictionSpendersShortCdPostConditions
{
 SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) <= SoulShards() * ExecuteTime(unstable_affliction) } and Spell(unstable_affliction) or { SpellCooldown(summon_darkglare) < TimeToShard() * { 6 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersShortCdPostConditions() or use_seed() and Spell(seed_of_corruption) or not use_seed() and not PreviousGCDSpell(summon_darkglare) and { Talent(deathbolt_talent) and SpellCooldown(deathbolt) <= ExecuteTime(unstable_affliction) and not HasAzeriteTrait(cascading_calamity_trait) or { SoulShards() >= 5 and Enemies(tagged=1) < 2 or SoulShards() >= 2 and Enemies(tagged=1) >= 2 } and target.TimeToDie() > 4 + ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 1 or target.TimeToDie() <= 8 + ExecuteTime(unstable_affliction) * SoulShards() } and Spell(unstable_affliction) or not use_seed() and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction) or not use_seed() and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) > TimeToShard() or SoulShards() > 1 } and { not Talent(vile_taint_talent) or SoulShards() > 1 } and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and { not HasAzeriteTrait(cascading_calamity_trait) or BuffRemaining(cascading_calamity_buff) > TimeToShard() } and Spell(unstable_affliction)
}

AddFunction AfflictionSpendersCdActions
{
 unless SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) <= SoulShards() * ExecuteTime(unstable_affliction) } and Spell(unstable_affliction)
 {
  #call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<time_to_shard*(6-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
  if { SpellCooldown(summon_darkglare) < TimeToShard() * { 6 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) AfflictionFillersCdActions()
 }
}

AddFunction AfflictionSpendersCdPostConditions
{
 SpellCooldown(summon_darkglare) <= SoulShards() * ExecuteTime(unstable_affliction) and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) <= SoulShards() * ExecuteTime(unstable_affliction) } and Spell(unstable_affliction) or { SpellCooldown(summon_darkglare) < TimeToShard() * { 6 - SoulShards() } or not SpellCooldown(summon_darkglare) > 0 } and target.TimeToDie() > SpellCooldown(summon_darkglare) and AfflictionFillersCdPostConditions() or use_seed() and Spell(seed_of_corruption) or not use_seed() and not PreviousGCDSpell(summon_darkglare) and { Talent(deathbolt_talent) and SpellCooldown(deathbolt) <= ExecuteTime(unstable_affliction) and not HasAzeriteTrait(cascading_calamity_trait) or { SoulShards() >= 5 and Enemies(tagged=1) < 2 or SoulShards() >= 2 and Enemies(tagged=1) >= 2 } and target.TimeToDie() > 4 + ExecuteTime(unstable_affliction) and Enemies(tagged=1) == 1 or target.TimeToDie() <= 8 + ExecuteTime(unstable_affliction) * SoulShards() } and Spell(unstable_affliction) or not use_seed() and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and Spell(unstable_affliction) or not use_seed() and { not Talent(deathbolt_talent) or SpellCooldown(deathbolt) > TimeToShard() or SoulShards() > 1 } and { not Talent(vile_taint_talent) or SoulShards() > 1 } and BuffRemaining(unstable_affliction_buff) <= CastTime(unstable_affliction) + padding() and { not HasAzeriteTrait(cascading_calamity_trait) or BuffRemaining(cascading_calamity_buff) > TimeToShard() } and Spell(unstable_affliction)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "affliction", name, desc, code, "script")
end
