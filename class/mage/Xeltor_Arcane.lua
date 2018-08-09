local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_arcane"
	local desc = "[Xel][8.0] Mage: Arcane"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

# Arcane
AddIcon specialization=1 help=main
{
	if not mounted() and not PlayerIsResting() and not IsDead()
	{
		#arcane_intellect
		if not BuffPresent(arcane_intellect_buff any=1) and not target.IsFriend() Spell(arcane_intellect)
		#summon_arcane_familiar
		if not BuffPresent(arcane_familiar_buff) Spell(summon_arcane_familiar)
	}
	
	if InCombat() InterruptActions()
	
	if InCombat() and target.InRange(arcane_blast) and HasFullControl()
	{
		if Speed() == 0 ArcaneDefaultCdActions()
		
		if Speed() == 0 ArcaneDefaultShortCdActions()
		
		if Speed() == 0 ArcaneDefaultMainActions()
		
		if Speed() > 0 and Talent(chrono_shift_talent) and BuffRemains(chrono_shift_buff) <= 1 Spell(arcane_barrage)
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
		if target.InRange(counterspell) and target.IsInterruptible() Spell(counterspell)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
	}
}

AddFunction NotMoving
{
	{ Speed() == 0 or Talent(slipstream_talent) }
}

AddFunction total_burns
{
 if not GetState(burn_phase) > 0 1
 # 0
}

AddFunction conserve_mana
{
 if not Talent(overpowered_talent) 45
 if Talent(overpowered_talent) 35
}

AddFunction average_burn_length
{
 { 0 * total_burns() - 0 + GetStateDuration(burn_phase) } / total_burns()
 # 4
}

### actions.default

AddFunction ArcaneDefaultMainActions
{
 #call_action_list,name=burn,if=burn_phase|target.time_to_die<variable.average_burn_length|(cooldown.arcane_power.remains=0&cooldown.evocation.remains<=variable.average_burn_length&(buff.arcane_charge.stack=buff.arcane_charge.max_stack|(talent.charged_up.enabled&cooldown.charged_up.remains=0)))
 if { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } ArcaneBurnMainActions()

 unless { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } and ArcaneBurnMainPostConditions()
 {
  #call_action_list,name=conserve,if=!burn_phase
  if not GetState(burn_phase) > 0 ArcaneConserveMainActions()

  unless not GetState(burn_phase) > 0 and ArcaneConserveMainPostConditions()
  {
   #call_action_list,name=movement
   # ArcaneMovementMainActions()
  }
 }
}

AddFunction ArcaneDefaultMainPostConditions
{
 { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } and ArcaneBurnMainPostConditions() or not GetState(burn_phase) > 0 and ArcaneConserveMainPostConditions()
}

AddFunction ArcaneDefaultShortCdActions
{
 #call_action_list,name=burn,if=burn_phase|target.time_to_die<variable.average_burn_length|(cooldown.arcane_power.remains=0&cooldown.evocation.remains<=variable.average_burn_length&(buff.arcane_charge.stack=buff.arcane_charge.max_stack|(talent.charged_up.enabled&cooldown.charged_up.remains=0)))
 if { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } ArcaneBurnShortCdActions()

 unless { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } and ArcaneBurnShortCdPostConditions()
 {
  #call_action_list,name=conserve,if=!burn_phase
  if not GetState(burn_phase) > 0 ArcaneConserveShortCdActions()

  unless not GetState(burn_phase) > 0 and ArcaneConserveShortCdPostConditions()
  {
   #call_action_list,name=movement
   # ArcaneMovementShortCdActions()
  }
 }
}

AddFunction ArcaneDefaultShortCdPostConditions
{
 { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } and ArcaneBurnShortCdPostConditions() or not GetState(burn_phase) > 0 and ArcaneConserveShortCdPostConditions()
}

AddFunction ArcaneDefaultCdActions
{
 #counterspell,if=target.debuff.casting.react
 # if target.IsInterruptible() ArcaneInterruptActions()
 #time_warp,if=time=0&buff.bloodlust.down
 # if TimeInCombat() == 0 and BuffExpires(burst_haste_buff any=1) and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
 #call_action_list,name=burn,if=burn_phase|target.time_to_die<variable.average_burn_length|(cooldown.arcane_power.remains=0&cooldown.evocation.remains<=variable.average_burn_length&(buff.arcane_charge.stack=buff.arcane_charge.max_stack|(talent.charged_up.enabled&cooldown.charged_up.remains=0)))
 if { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } ArcaneBurnCdActions()

 unless { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } and ArcaneBurnCdPostConditions()
 {
  #call_action_list,name=conserve,if=!burn_phase
  if not GetState(burn_phase) > 0 ArcaneConserveCdActions()

  unless not GetState(burn_phase) > 0 and ArcaneConserveCdPostConditions()
  {
   #call_action_list,name=movement
   # ArcaneMovementCdActions()
  }
 }
}

AddFunction ArcaneDefaultCdPostConditions
{
 { GetState(burn_phase) > 0 or target.TimeToDie() < average_burn_length() or not SpellCooldown(arcane_power) > 0 and SpellCooldown(evocation) <= average_burn_length() and { ArcaneCharges() == 4 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } } and ArcaneBurnCdPostConditions() or not GetState(burn_phase) > 0 and ArcaneConserveCdPostConditions()
}

### actions.burn

AddFunction ArcaneBurnMainActions
{
 #variable,name=total_burns,op=add,value=1,if=!burn_phase
 #start_burn_phase,if=!burn_phase
 if not GetState(burn_phase) > 0 SetState(burn_phase 1)
 #stop_burn_phase,if=burn_phase&(prev_gcd.1.evocation|(equipped.gravity_spiral&cooldown.evocation.charges=0&prev_gcd.1.evocation))&target.time_to_die>variable.average_burn_length&burn_phase_duration>0
 if GetState(burn_phase) > 0 and { PreviousGCDSpell(evocation) or HasEquippedItem(gravity_spiral_item) and SpellCharges(evocation) == 0 and PreviousGCDSpell(evocation) } and target.TimeToDie() > average_burn_length() and GetStateDuration(burn_phase) > 0 and GetState(burn_phase) > 0 SetState(burn_phase 0)
 #nether_tempest,if=(refreshable|!ticking)&buff.arcane_charge.stack=buff.arcane_charge.max_stack&buff.rune_of_power.down&buff.arcane_power.down
 if { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) Spell(nether_tempest)
 #arcane_blast,if=buff.presence_of_mind.up&set_bonus.tier20_2pc&talent.overpowered.enabled&buff.arcane_power.up
 if BuffPresent(presence_of_mind_buff) and 0 > 0 and Talent(overpowered_talent) and BuffPresent(arcane_power_buff) Spell(arcane_blast)
 #arcane_barrage,if=(active_enemies>=3|(active_enemies>=2&talent.resonance.enabled))&(buff.arcane_charge.stack=buff.arcane_charge.max_stack)
 if { Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 2 and Talent(resonance_talent) } and ArcaneCharges() == 4 Spell(arcane_barrage)
 #arcane_explosion,if=active_enemies>=3|(active_enemies>=2&talent.resonance.enabled)
 if { Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 2 and Talent(resonance_talent) } and target.Distance(less 10) Spell(arcane_explosion)
 #arcane_missiles,if=(buff.clearcasting.react&mana.pct<=95),chain=1
 if BuffPresent(clearcasting_buff) and ManaPercent() <= 95 Spell(arcane_missiles)
 #arcane_blast
 Spell(arcane_blast)
 #arcane_barrage
 Spell(arcane_barrage)
}

AddFunction ArcaneBurnMainPostConditions
{
}

AddFunction ArcaneBurnShortCdActions
{
 #variable,name=total_burns,op=add,value=1,if=!burn_phase
 #start_burn_phase,if=!burn_phase
 if not GetState(burn_phase) > 0 SetState(burn_phase 1)
 #stop_burn_phase,if=burn_phase&(prev_gcd.1.evocation|(equipped.gravity_spiral&cooldown.evocation.charges=0&prev_gcd.1.evocation))&target.time_to_die>variable.average_burn_length&burn_phase_duration>0
 if GetState(burn_phase) > 0 and { PreviousGCDSpell(evocation) or HasEquippedItem(gravity_spiral_item) and SpellCharges(evocation) == 0 and PreviousGCDSpell(evocation) } and target.TimeToDie() > average_burn_length() and GetStateDuration(burn_phase) > 0 and GetState(burn_phase) > 0 SetState(burn_phase 0)
 #charged_up,if=buff.arcane_charge.stack<=1&(!set_bonus.tier20_2pc|cooldown.presence_of_mind.remains>5)
 if ArcaneCharges() <= 1 and { not 0 > 0 or SpellCooldown(presence_of_mind) > 5 } Spell(charged_up)

 unless { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) and Spell(nether_tempest)
 {
  #rune_of_power,if=!buff.arcane_power.up&(mana.pct>=50|cooldown.arcane_power.remains=0)&(buff.arcane_charge.stack=buff.arcane_charge.max_stack)
  if not BuffPresent(arcane_power_buff) and { ManaPercent() >= 50 or not SpellCooldown(arcane_power) > 0 } and ArcaneCharges() == 4 Spell(rune_of_power)
  #presence_of_mind
  Spell(presence_of_mind)
  #arcane_orb,if=buff.arcane_charge.stack=0|(active_enemies<3|(active_enemies<2&talent.resonance.enabled))
  if ArcaneCharges() == 0 or Enemies(tagged=1) < 3 or Enemies(tagged=1) < 2 and Talent(resonance_talent) Spell(arcane_orb)

  unless BuffPresent(presence_of_mind_buff) and 0 > 0 and Talent(overpowered_talent) and BuffPresent(arcane_power_buff) and Spell(arcane_blast) or { Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 2 and Talent(resonance_talent) } and ArcaneCharges() == 4 and Spell(arcane_barrage) or { Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 2 and Talent(resonance_talent) } and Spell(arcane_explosion) or BuffPresent(clearcasting_buff) and ManaPercent() <= 95 and Spell(arcane_missiles) or Spell(arcane_blast)
  {
   #variable,name=average_burn_length,op=set,value=(variable.average_burn_length*variable.total_burns-variable.average_burn_length+(burn_phase_duration))%variable.total_burns
   #evocation,interrupt_if=mana.pct>=97|(buff.clearcasting.react&mana.pct>=92)
   Spell(evocation)
  }
 }
}

AddFunction ArcaneBurnShortCdPostConditions
{
 { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) and Spell(nether_tempest) or BuffPresent(presence_of_mind_buff) and 0 > 0 and Talent(overpowered_talent) and BuffPresent(arcane_power_buff) and Spell(arcane_blast) or { Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 2 and Talent(resonance_talent) } and ArcaneCharges() == 4 and Spell(arcane_barrage) or { Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 2 and Talent(resonance_talent) } and Spell(arcane_explosion) or BuffPresent(clearcasting_buff) and ManaPercent() <= 95 and Spell(arcane_missiles) or Spell(arcane_blast) or Spell(arcane_barrage)
}

AddFunction ArcaneBurnCdActions
{
 #variable,name=total_burns,op=add,value=1,if=!burn_phase
 #start_burn_phase,if=!burn_phase
 if not GetState(burn_phase) > 0 SetState(burn_phase 1)
 #stop_burn_phase,if=burn_phase&(prev_gcd.1.evocation|(equipped.gravity_spiral&cooldown.evocation.charges=0&prev_gcd.1.evocation))&target.time_to_die>variable.average_burn_length&burn_phase_duration>0
 if GetState(burn_phase) > 0 and { PreviousGCDSpell(evocation) or HasEquippedItem(gravity_spiral_item) and SpellCharges(evocation) == 0 and PreviousGCDSpell(evocation) } and target.TimeToDie() > average_burn_length() and GetStateDuration(burn_phase) > 0 and GetState(burn_phase) > 0 SetState(burn_phase 0)
 #mirror_image
 Spell(mirror_image)

 unless ArcaneCharges() <= 1 and { not 0 > 0 or SpellCooldown(presence_of_mind) > 5 } and Spell(charged_up) or { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) and Spell(nether_tempest)
 {
  #time_warp,if=buff.bloodlust.down&((buff.arcane_power.down&cooldown.arcane_power.remains=0)|(target.time_to_die<=buff.bloodlust.duration))
  # if BuffExpires(burst_haste_buff any=1) and { BuffExpires(arcane_power_buff) and not SpellCooldown(arcane_power) > 0 or target.TimeToDie() <= BaseDuration(burst_haste_buff) } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
  #lights_judgment,if=buff.arcane_power.down
  # if BuffExpires(arcane_power_buff) Spell(lights_judgment)

  unless not BuffPresent(arcane_power_buff) and { ManaPercent() >= 50 or not SpellCooldown(arcane_power) > 0 } and ArcaneCharges() == 4 and Spell(rune_of_power)
  {
   #arcane_power
   Spell(arcane_power)
   #use_items,if=buff.arcane_power.up|target.time_to_die<cooldown.arcane_power.remains
   # if BuffPresent(arcane_power_buff) or target.TimeToDie() < SpellCooldown(arcane_power) ArcaneUseItemActions()
   #blood_fury
   Spell(blood_fury_sp)
   #berserking
   Spell(berserking)
  }
 }
}

AddFunction ArcaneBurnCdPostConditions
{
 ArcaneCharges() <= 1 and { not 0 > 0 or SpellCooldown(presence_of_mind) > 5 } and Spell(charged_up) or { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) and Spell(nether_tempest) or not BuffPresent(arcane_power_buff) and { ManaPercent() >= 50 or not SpellCooldown(arcane_power) > 0 } and ArcaneCharges() == 4 and Spell(rune_of_power) or { ArcaneCharges() == 0 or Enemies(tagged=1) < 3 or Enemies(tagged=1) < 2 and Talent(resonance_talent) } and Spell(arcane_orb) or BuffPresent(presence_of_mind_buff) and 0 > 0 and Talent(overpowered_talent) and BuffPresent(arcane_power_buff) and Spell(arcane_blast) or { Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 2 and Talent(resonance_talent) } and ArcaneCharges() == 4 and Spell(arcane_barrage) or { Enemies(tagged=1) >= 3 or Enemies(tagged=1) >= 2 and Talent(resonance_talent) } and Spell(arcane_explosion) or BuffPresent(clearcasting_buff) and ManaPercent() <= 95 and Spell(arcane_missiles) or Spell(arcane_blast) or Spell(evocation) or Spell(arcane_barrage)
}

### actions.conserve

AddFunction ArcaneConserveMainActions
{
 #nether_tempest,if=(refreshable|!ticking)&buff.arcane_charge.stack=buff.arcane_charge.max_stack&buff.rune_of_power.down&buff.arcane_power.down
 if { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) Spell(nether_tempest)
 #arcane_blast,if=(buff.rule_of_threes.up|buff.rhonins_assaulting_armwraps.react)&buff.arcane_charge.stack>=3
 if { BuffPresent(rule_of_threes_buff) or BuffPresent(rhonins_assaulting_armwraps_buff) } and ArcaneCharges() >= 3 Spell(arcane_blast)
 #arcane_missiles,if=mana.pct<=95&buff.clearcasting.react,chain=1
 if ManaPercent() <= 95 and BuffPresent(clearcasting_buff) Spell(arcane_missiles)
 #arcane_blast,if=equipped.mystic_kilt_of_the_rune_master&buff.arcane_charge.stack=0
 if HasEquippedItem(mystic_kilt_of_the_rune_master_item) and ArcaneCharges() == 0 Spell(arcane_blast)
 #arcane_barrage,if=((buff.arcane_charge.stack=buff.arcane_charge.max_stack)&(mana.pct<=variable.conserve_mana)|(talent.arcane_orb.enabled&cooldown.arcane_orb.remains<=gcd))|mana.pct<=(variable.conserve_mana-10)
 if ArcaneCharges() == 4 and ManaPercent() <= conserve_mana() or Talent(arcane_orb_talent) and SpellCooldown(arcane_orb) <= GCD() or ManaPercent() <= conserve_mana() - 10 Spell(arcane_barrage)
 #supernova,if=mana.pct<=95
 if ManaPercent() <= 95 Spell(supernova)
 #arcane_explosion,if=active_enemies>=3&(mana.pct>=variable.conserve_mana|buff.arcane_charge.stack=3)
 if Enemies(tagged=1) >= 3 and { ManaPercent() >= conserve_mana() or ArcaneCharges() == 3 } and target.Distance(less 10) Spell(arcane_explosion)
 #arcane_blast
 Spell(arcane_blast)
 #arcane_barrage
 Spell(arcane_barrage)
}

AddFunction ArcaneConserveMainPostConditions
{
}

AddFunction ArcaneConserveShortCdActions
{
 #charged_up,if=buff.arcane_charge.stack=0
 if ArcaneCharges() == 0 Spell(charged_up)
 #presence_of_mind,if=set_bonus.tier20_2pc&buff.arcane_charge.stack=0
 if 0 > 0 and ArcaneCharges() == 0 Spell(presence_of_mind)

 unless { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) and Spell(nether_tempest) or { BuffPresent(rule_of_threes_buff) or BuffPresent(rhonins_assaulting_armwraps_buff) } and ArcaneCharges() >= 3 and Spell(arcane_blast)
 {
  #rune_of_power,if=buff.arcane_charge.stack=buff.arcane_charge.max_stack&(full_recharge_time<=execute_time|recharge_time<=cooldown.arcane_power.remains|target.time_to_die<=cooldown.arcane_power.remains)
  if ArcaneCharges() == 4 and { SpellFullRecharge(rune_of_power) <= ExecuteTime(rune_of_power) or SpellChargeCooldown(rune_of_power) <= SpellCooldown(arcane_power) or target.TimeToDie() <= SpellCooldown(arcane_power) } Spell(rune_of_power)
 }
}

AddFunction ArcaneConserveShortCdPostConditions
{
 { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) and Spell(nether_tempest) or { BuffPresent(rule_of_threes_buff) or BuffPresent(rhonins_assaulting_armwraps_buff) } and ArcaneCharges() >= 3 and Spell(arcane_blast) or ManaPercent() <= 95 and BuffPresent(clearcasting_buff) and Spell(arcane_missiles) or HasEquippedItem(mystic_kilt_of_the_rune_master_item) and ArcaneCharges() == 0 and Spell(arcane_blast) or { ArcaneCharges() == 4 and ManaPercent() <= conserve_mana() or Talent(arcane_orb_talent) and SpellCooldown(arcane_orb) <= GCD() or ManaPercent() <= conserve_mana() - 10 } and Spell(arcane_barrage) or ManaPercent() <= 95 and Spell(supernova) or Enemies(tagged=1) >= 3 and { ManaPercent() >= conserve_mana() or ArcaneCharges() == 3 } and Spell(arcane_explosion) or Spell(arcane_blast) or Spell(arcane_barrage)
}

AddFunction ArcaneConserveCdActions
{
 #mirror_image
 Spell(mirror_image)

 unless ArcaneCharges() == 0 and Spell(charged_up) or { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) and Spell(nether_tempest) or { BuffPresent(rule_of_threes_buff) or BuffPresent(rhonins_assaulting_armwraps_buff) } and ArcaneCharges() >= 3 and Spell(arcane_blast) or ArcaneCharges() == 4 and { SpellFullRecharge(rune_of_power) <= ExecuteTime(rune_of_power) or SpellChargeCooldown(rune_of_power) <= SpellCooldown(arcane_power) or target.TimeToDie() <= SpellCooldown(arcane_power) } and Spell(rune_of_power) or ManaPercent() <= 95 and BuffPresent(clearcasting_buff) and Spell(arcane_missiles) or HasEquippedItem(mystic_kilt_of_the_rune_master_item) and ArcaneCharges() == 0 and Spell(arcane_blast) or { ArcaneCharges() == 4 and ManaPercent() <= conserve_mana() or Talent(arcane_orb_talent) and SpellCooldown(arcane_orb) <= GCD() or ManaPercent() <= conserve_mana() - 10 } and Spell(arcane_barrage) or ManaPercent() <= 95 and Spell(supernova) or Enemies(tagged=1) >= 3 and { ManaPercent() >= conserve_mana() or ArcaneCharges() == 3 } and Spell(arcane_explosion)
 {
  #arcane_torrent
  Spell(arcane_torrent_mana)
 }
}

AddFunction ArcaneConserveCdPostConditions
{
 ArcaneCharges() == 0 and Spell(charged_up) or { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and ArcaneCharges() == 4 and BuffExpires(rune_of_power_buff) and BuffExpires(arcane_power_buff) and Spell(nether_tempest) or { BuffPresent(rule_of_threes_buff) or BuffPresent(rhonins_assaulting_armwraps_buff) } and ArcaneCharges() >= 3 and Spell(arcane_blast) or ArcaneCharges() == 4 and { SpellFullRecharge(rune_of_power) <= ExecuteTime(rune_of_power) or SpellChargeCooldown(rune_of_power) <= SpellCooldown(arcane_power) or target.TimeToDie() <= SpellCooldown(arcane_power) } and Spell(rune_of_power) or ManaPercent() <= 95 and BuffPresent(clearcasting_buff) and Spell(arcane_missiles) or HasEquippedItem(mystic_kilt_of_the_rune_master_item) and ArcaneCharges() == 0 and Spell(arcane_blast) or { ArcaneCharges() == 4 and ManaPercent() <= conserve_mana() or Talent(arcane_orb_talent) and SpellCooldown(arcane_orb) <= GCD() or ManaPercent() <= conserve_mana() - 10 } and Spell(arcane_barrage) or ManaPercent() <= 95 and Spell(supernova) or Enemies(tagged=1) >= 3 and { ManaPercent() >= conserve_mana() or ArcaneCharges() == 3 } and Spell(arcane_explosion) or Spell(arcane_blast) or Spell(arcane_barrage)
}

### actions.movement

AddFunction ArcaneMovementMainActions
{
 #shimmer,if=movement.distance>=10
 # if target.Distance() >= 10 Spell(shimmer)
 #arcane_missiles
 Spell(arcane_missiles)
 #supernova
 Spell(supernova)
}

AddFunction ArcaneMovementMainPostConditions
{
}

AddFunction ArcaneMovementShortCdActions
{
  #blink,if=movement.distance>=10
  # if target.Distance() >= 10 Spell(blink)
  #presence_of_mind
  Spell(presence_of_mind)

  unless Spell(arcane_missiles)
  {
   #arcane_orb
   Spell(arcane_orb)
  }
}

AddFunction ArcaneMovementShortCdPostConditions
{
 Spell(arcane_missiles) or Spell(supernova)
}

AddFunction ArcaneMovementCdActions
{
}

AddFunction ArcaneMovementCdPostConditions
{
 Spell(arcane_missiles) or Spell(arcane_orb) or Spell(supernova)
}

### actions.precombat

AddFunction ArcanePrecombatMainActions
{
 #flask
 #food
 #augmentation
 #arcane_intellect
 Spell(arcane_intellect)
 #summon_arcane_familiar
 Spell(summon_arcane_familiar)
 #arcane_blast
 Spell(arcane_blast)
}

AddFunction ArcanePrecombatMainPostConditions
{
}

AddFunction ArcanePrecombatShortCdActions
{
}

AddFunction ArcanePrecombatShortCdPostConditions
{
 Spell(arcane_intellect) or Spell(summon_arcane_familiar) or Spell(arcane_blast)
}

AddFunction ArcanePrecombatCdActions
{
 unless Spell(arcane_intellect) or Spell(summon_arcane_familiar)
 {
  #variable,name=conserve_mana,op=set,value=35,if=talent.overpowered.enabled
  #variable,name=conserve_mana,op=set,value=45,if=!talent.overpowered.enabled
  #snapshot_stats
  #mirror_image
  Spell(mirror_image)
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(deadly_grace_potion usable=1)
 }
}

AddFunction ArcanePrecombatCdPostConditions
{
 Spell(arcane_intellect) or Spell(summon_arcane_familiar) or Spell(arcane_blast)
}
]]

	OvaleScripts:RegisterScript("MAGE", "arcane", name, desc, code, "script")
end
