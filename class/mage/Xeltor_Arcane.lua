local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_arcane"
	local desc = "[Xel][7.3.5] Mage: Arcane"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

Define(slipstream_talent 5)

# Arcane
AddIcon specialization=1 help=main
{
	if InCombat() InterruptActions()
	
	if InCombat() and target.InRange(arcane_blast) and HasFullControl()
	{
		ArcaneDefaultCdActions()
		
		ArcaneDefaultShortCdActions()
		
		ArcaneDefaultMainActions()
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
		if target.InRange(counterspell) Spell(counterspell)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_mana)
			if target.InRange(quaking_palm) Spell(quaking_palm)
		}
	}
}

AddFunction NotMoving
{
	{ Speed() == 0 or Talent(slipstream_talent) }
}

AddFunction time_until_burn_value
{
 if time_until_burn_value() < time_until_burn_max() time_until_burn_value()
 time_until_burn_max()
}

AddFunction time_until_burn
{
 if time_until_burn_value() < time_until_burn_max() time_until_burn_value()
 time_until_burn_max()
}

AddFunction average_burn_length
{
 { 0 * total_burns() - 0 + GetStateDuration(burn_phase) } / total_burns()
}

AddFunction time_until_burn_max
{
 if Talent(charged_up_talent) and ArmorSetBonus(T21 2) SpellCooldown(charged_up) > 0
 if Talent(rune_of_power_talent) SpellCooldown(rune_of_power)
 if ArmorSetBonus(T20 2) SpellCooldown(presence_of_mind) > 0
 SpellCooldown(evocation) - average_burn_length()
}

AddFunction total_burns
{
 if not GetState(burn_phase) > 0 1
}

AddFunction arcane_missiles_procs
{
 BuffPresent(arcane_missiles_buff)
}

### actions.default

AddFunction ArcaneDefaultMainActions
{
 #call_action_list,name=variables
 ArcaneVariablesMainActions()

 unless ArcaneVariablesMainPostConditions()
 {
  #call_action_list,name=build,if=buff.arcane_charge.stack<buff.arcane_charge.max_stack&!burn_phase
  if DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 ArcaneBuildMainActions()

  unless DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 and ArcaneBuildMainPostConditions()
  {
   #call_action_list,name=burn,if=(buff.arcane_charge.stack=buff.arcane_charge.max_stack&variable.time_until_burn=0)|burn_phase
   if { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) ArcaneBurnMainActions()

   unless { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) and ArcaneBurnMainPostConditions()
   {
    #call_action_list,name=conserve
    ArcaneConserveMainActions()
   }
  }
 }
}

AddFunction ArcaneDefaultMainPostConditions
{
 ArcaneVariablesMainPostConditions() or DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 and ArcaneBuildMainPostConditions() or { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) and ArcaneBurnMainPostConditions() or ArcaneConserveMainPostConditions()
}

AddFunction ArcaneDefaultShortCdActions
{
 #call_action_list,name=variables
 ArcaneVariablesShortCdActions()

 unless ArcaneVariablesShortCdPostConditions()
 {
  #cancel_buff,name=presence_of_mind,if=active_enemies>1&set_bonus.tier20_2pc
  if Enemies(tagged=1) > 1 and ArmorSetBonus(T20 2) and BuffPresent(presence_of_mind_buff) Texture(presence_of_mind)
  #call_action_list,name=build,if=buff.arcane_charge.stack<buff.arcane_charge.max_stack&!burn_phase
  if DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 ArcaneBuildShortCdActions()

  unless DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 and ArcaneBuildShortCdPostConditions()
  {
   #call_action_list,name=burn,if=(buff.arcane_charge.stack=buff.arcane_charge.max_stack&variable.time_until_burn=0)|burn_phase
   if { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) ArcaneBurnShortCdActions()

   unless { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) and ArcaneBurnShortCdPostConditions()
   {
    #call_action_list,name=conserve
    ArcaneConserveShortCdActions()
   }
  }
 }
}

AddFunction ArcaneDefaultShortCdPostConditions
{
 ArcaneVariablesShortCdPostConditions() or DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 and ArcaneBuildShortCdPostConditions() or { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) and ArcaneBurnShortCdPostConditions() or ArcaneConserveShortCdPostConditions()
}

AddFunction ArcaneDefaultCdActions
{
 #counterspell,if=target.debuff.casting.react
 # if target.IsInterruptible() ArcaneInterruptActions()
 #time_warp,if=buff.bloodlust.down&(time=0|(buff.arcane_power.up&(buff.potion.up|!action.potion.usable))|target.time_to_die<=buff.bloodlust.duration)
 # if BuffExpires(burst_haste_buff any=1) and { TimeInCombat() == 0 or BuffPresent(arcane_power_buff) and { BuffPresent(deadly_grace_potion_buff) or not CanCast(deadly_grace_potion) } or target.TimeToDie() <= BaseDuration(burst_haste_buff) } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
 #call_action_list,name=variables
 ArcaneVariablesCdActions()

 unless ArcaneVariablesCdPostConditions()
 {
  #call_action_list,name=build,if=buff.arcane_charge.stack<buff.arcane_charge.max_stack&!burn_phase
  if DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 ArcaneBuildCdActions()

  unless DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 and ArcaneBuildCdPostConditions()
  {
   #call_action_list,name=burn,if=(buff.arcane_charge.stack=buff.arcane_charge.max_stack&variable.time_until_burn=0)|burn_phase
   if { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) ArcaneBurnCdActions()

   unless { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) and ArcaneBurnCdPostConditions()
   {
    #call_action_list,name=conserve
    ArcaneConserveCdActions()
   }
  }
 }
}

AddFunction ArcaneDefaultCdPostConditions
{
 ArcaneVariablesCdPostConditions() or DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and not GetState(burn_phase) > 0 and ArcaneBuildCdPostConditions() or { DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and time_until_burn() == 0 or GetState(burn_phase) > 0 } and CheckBoxOn(opt_arcane_mage_burn_phase) and ArcaneBurnCdPostConditions() or ArcaneConserveCdPostConditions()
}

### actions.build

AddFunction ArcaneBuildMainActions
{
 #arcane_missiles,if=active_enemies<3&(variable.arcane_missiles_procs=buff.arcane_missiles.max_stack|(variable.arcane_missiles_procs&mana.pct<=50&buff.arcane_charge.stack=3)),chain=1
 if Enemies(tagged=1) < 3 and { arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) or arcane_missiles_procs() and ManaPercent() <= 50 and DebuffStacks(arcane_charge_debuff) == 3 } Spell(arcane_missiles)
 #arcane_explosion,if=active_enemies>1
 if Enemies(tagged=1) > 1 Spell(arcane_explosion)
 #arcane_blast
 Spell(arcane_blast)
}

AddFunction ArcaneBuildMainPostConditions
{
}

AddFunction ArcaneBuildShortCdActions
{
 #arcane_orb
 Spell(arcane_orb)
}

AddFunction ArcaneBuildShortCdPostConditions
{
 Enemies(tagged=1) < 3 and { arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) or arcane_missiles_procs() and ManaPercent() <= 50 and DebuffStacks(arcane_charge_debuff) == 3 } and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Spell(arcane_blast)
}

AddFunction ArcaneBuildCdActions
{
}

AddFunction ArcaneBuildCdPostConditions
{
 Spell(arcane_orb) or Enemies(tagged=1) < 3 and { arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) or arcane_missiles_procs() and ManaPercent() <= 50 and DebuffStacks(arcane_charge_debuff) == 3 } and Spell(arcane_missiles) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Spell(arcane_blast)
}

### actions.burn

AddFunction ArcaneBurnMainActions
{
 #variable,name=total_burns,op=add,value=1,if=!burn_phase
 #start_burn_phase,if=!burn_phase
 if not GetState(burn_phase) > 0 and not GetState(burn_phase) > 0 SetState(burn_phase 1)
 #stop_burn_phase,if=prev_gcd.1.evocation&cooldown.evocation.charges=0&burn_phase_duration>0
 if PreviousGCDSpell(evocation) and SpellCharges(evocation) == 0 and GetStateDuration(burn_phase) > 0 and GetState(burn_phase) > 0 SetState(burn_phase 0)
 #nether_tempest,if=refreshable|!ticking
 if target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) Spell(nether_tempest)
 #arcane_barrage,if=set_bonus.tier21_2pc&((set_bonus.tier20_2pc&cooldown.presence_of_mind.up)|(talent.charged_up.enabled&cooldown.charged_up.up))&buff.arcane_charge.stack=buff.arcane_charge.max_stack&buff.expanding_mind.down
 if ArmorSetBonus(T21 2) and { ArmorSetBonus(T20 2) and not SpellCooldown(presence_of_mind) > 0 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and BuffExpires(expanding_mind_buff) Spell(arcane_barrage)
 #charged_up,if=buff.arcane_charge.stack<buff.arcane_charge.max_stack
 if DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) Spell(charged_up)
 #arcane_barrage,if=active_enemies>4&equipped.mantle_of_the_first_kirin_tor&buff.arcane_charge.stack=buff.arcane_charge.max_stack
 if Enemies(tagged=1) > 4 and HasEquippedItem(mantle_of_the_first_kirin_tor) and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) Spell(arcane_barrage)
 #arcane_missiles,if=variable.arcane_missiles_procs=buff.arcane_missiles.max_stack&active_enemies<3,chain=1
 if arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) and Enemies(tagged=1) < 3 Spell(arcane_missiles)
 #arcane_blast,if=buff.presence_of_mind.up
 if BuffPresent(presence_of_mind_buff) Spell(arcane_blast)
 #arcane_explosion,if=active_enemies>1
 if Enemies(tagged=1) > 1 Spell(arcane_explosion)
 #arcane_missiles,if=variable.arcane_missiles_procs>1,chain=1
 if arcane_missiles_procs() > 1 Spell(arcane_missiles)
 #arcane_blast
 Spell(arcane_blast)
}

AddFunction ArcaneBurnMainPostConditions
{
}

AddFunction ArcaneBurnShortCdActions
{
 #variable,name=total_burns,op=add,value=1,if=!burn_phase
 #start_burn_phase,if=!burn_phase
 if not GetState(burn_phase) > 0 and not GetState(burn_phase) > 0 SetState(burn_phase 1)
 #stop_burn_phase,if=prev_gcd.1.evocation&cooldown.evocation.charges=0&burn_phase_duration>0
 if PreviousGCDSpell(evocation) and SpellCharges(evocation) == 0 and GetStateDuration(burn_phase) > 0 and GetState(burn_phase) > 0 SetState(burn_phase 0)

 unless { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest)
 {
  #mark_of_aluneth
  Spell(mark_of_aluneth)
  #rune_of_power,if=mana.pct>30|(buff.arcane_power.up|cooldown.arcane_power.up)
  if ManaPercent() > 30 or BuffPresent(arcane_power_buff) or not SpellCooldown(arcane_power) > 0 Spell(rune_of_power)

  unless ArmorSetBonus(T21 2) and { ArmorSetBonus(T20 2) and not SpellCooldown(presence_of_mind) > 0 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and BuffExpires(expanding_mind_buff) and Spell(arcane_barrage)
  {
   #presence_of_mind,if=((mana.pct>30|buff.arcane_power.up)&set_bonus.tier20_2pc)|buff.rune_of_power.remains<=buff.presence_of_mind.max_stack*action.arcane_blast.execute_time|buff.arcane_power.remains<=buff.presence_of_mind.max_stack*action.arcane_blast.execute_time
   if { ManaPercent() > 30 or BuffPresent(arcane_power_buff) } and ArmorSetBonus(T20 2) or TotemRemaining(rune_of_power) <= SpellData(presence_of_mind_buff max_stacks) * ExecuteTime(arcane_blast) or BuffRemaining(arcane_power_buff) <= SpellData(presence_of_mind_buff max_stacks) * ExecuteTime(arcane_blast) Spell(presence_of_mind)

   unless DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and Spell(charged_up)
   {
    #arcane_orb
    Spell(arcane_orb)
   }
  }
 }
}

AddFunction ArcaneBurnShortCdPostConditions
{
 { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or ArmorSetBonus(T21 2) and { ArmorSetBonus(T20 2) and not SpellCooldown(presence_of_mind) > 0 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and BuffExpires(expanding_mind_buff) and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and Spell(charged_up) or Enemies(tagged=1) > 4 and HasEquippedItem(mantle_of_the_first_kirin_tor) and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and Spell(arcane_barrage) or arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) and Enemies(tagged=1) < 3 and Spell(arcane_missiles) or BuffPresent(presence_of_mind_buff) and Spell(arcane_blast) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or arcane_missiles_procs() > 1 and Spell(arcane_missiles) or Spell(arcane_blast)
}

AddFunction ArcaneBurnCdActions
{
 #variable,name=total_burns,op=add,value=1,if=!burn_phase
 #start_burn_phase,if=!burn_phase
 if not GetState(burn_phase) > 0 and not GetState(burn_phase) > 0 SetState(burn_phase 1)
 #stop_burn_phase,if=prev_gcd.1.evocation&cooldown.evocation.charges=0&burn_phase_duration>0
 if PreviousGCDSpell(evocation) and SpellCharges(evocation) == 0 and GetStateDuration(burn_phase) > 0 and GetState(burn_phase) > 0 SetState(burn_phase 0)

 unless { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or Spell(mark_of_aluneth)
 {
  #mirror_image
  Spell(mirror_image)

  unless { ManaPercent() > 30 or BuffPresent(arcane_power_buff) or not SpellCooldown(arcane_power) > 0 } and Spell(rune_of_power)
  {
   #arcane_power
   Spell(arcane_power)
   #blood_fury
   Spell(blood_fury_sp)
   #berserking
   Spell(berserking)
   #arcane_torrent
   Spell(arcane_torrent_mana)
   #potion,if=buff.arcane_power.up&(buff.berserking.up|buff.blood_fury.up|!(race.troll|race.orc))
   # if BuffPresent(arcane_power_buff) and { BuffPresent(berserking_buff) or BuffPresent(blood_fury_sp_buff) or not { Race(Troll) or Race(Orc) } } Item(deadly_grace_potion)
   #use_items,if=buff.arcane_power.up|target.time_to_die<cooldown.arcane_power.remains
   # if BuffPresent(arcane_power_buff) or target.TimeToDie() < SpellCooldown(arcane_power) ArcaneUseItemActions()

   unless ArmorSetBonus(T21 2) and { ArmorSetBonus(T20 2) and not SpellCooldown(presence_of_mind) > 0 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and BuffExpires(expanding_mind_buff) and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and Spell(charged_up) or Spell(arcane_orb) or Enemies(tagged=1) > 4 and HasEquippedItem(mantle_of_the_first_kirin_tor) and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and Spell(arcane_barrage) or arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) and Enemies(tagged=1) < 3 and Spell(arcane_missiles) or BuffPresent(presence_of_mind_buff) and Spell(arcane_blast) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or arcane_missiles_procs() > 1 and Spell(arcane_missiles) or Spell(arcane_blast)
   {
    #variable,name=average_burn_length,op=set,value=(variable.average_burn_length*variable.total_burns-variable.average_burn_length+burn_phase_duration)%variable.total_burns
    #evocation,interrupt_if=ticks=2|mana.pct>=85,interrupt_immediate=1
    Spell(evocation)
   }
  }
 }
}

AddFunction ArcaneBurnCdPostConditions
{
 { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or Spell(mark_of_aluneth) or { ManaPercent() > 30 or BuffPresent(arcane_power_buff) or not SpellCooldown(arcane_power) > 0 } and Spell(rune_of_power) or ArmorSetBonus(T21 2) and { ArmorSetBonus(T20 2) and not SpellCooldown(presence_of_mind) > 0 or Talent(charged_up_talent) and not SpellCooldown(charged_up) > 0 } and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and BuffExpires(expanding_mind_buff) and Spell(arcane_barrage) or DebuffStacks(arcane_charge_debuff) < SpellData(arcane_charge_debuff max_stacks) and Spell(charged_up) or Spell(arcane_orb) or Enemies(tagged=1) > 4 and HasEquippedItem(mantle_of_the_first_kirin_tor) and DebuffStacks(arcane_charge_debuff) == SpellData(arcane_charge_debuff max_stacks) and Spell(arcane_barrage) or arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) and Enemies(tagged=1) < 3 and Spell(arcane_missiles) or BuffPresent(presence_of_mind_buff) and Spell(arcane_blast) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or arcane_missiles_procs() > 1 and Spell(arcane_missiles) or Spell(arcane_blast)
}

### actions.conserve

AddFunction ArcaneConserveMainActions
{
 #arcane_barrage,name=abarr_cu_combo,if=talent.charged_up.enabled&cooldown.charged_up.recharge_time<variable.time_until_burn
 # if Talent(charged_up_talent) and SpellChargeCooldown(charged_up) < time_until_burn() Spell(arcane_barrage)
 #arcane_missiles,if=variable.arcane_missiles_procs=buff.arcane_missiles.max_stack&active_enemies<3,chain=1
 if arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) and Enemies(tagged=1) < 3 Spell(arcane_missiles)
 #supernova
 Spell(supernova)
 #nether_tempest,if=refreshable|!ticking
 if target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) Spell(nether_tempest)
 #arcane_explosion,if=active_enemies>1&(mana.pct>=70-(10*equipped.mystic_kilt_of_the_rune_master))
 if Enemies(tagged=1) > 1 and ManaPercent() >= 70 - 10 * HasEquippedItem(mystic_kilt_of_the_rune_master) Spell(arcane_explosion)
 #arcane_blast,if=mana.pct>=90|buff.rhonins_assaulting_armwraps.up|(buff.rune_of_power.remains>=cast_time&equipped.mystic_kilt_of_the_rune_master)
 if ManaPercent() >= 90 or BuffPresent(rhonins_assaulting_armwraps_buff) or TotemRemaining(rune_of_power) >= CastTime(arcane_blast) and HasEquippedItem(mystic_kilt_of_the_rune_master) Spell(arcane_blast)
 #arcane_missiles,if=variable.arcane_missiles_procs,chain=1
 if arcane_missiles_procs() Spell(arcane_missiles)
 #arcane_barrage
 Spell(arcane_barrage)
 #arcane_explosion,if=active_enemies>1
 if Enemies(tagged=1) > 1 Spell(arcane_explosion)
 #arcane_blast
 Spell(arcane_blast)
}

AddFunction ArcaneConserveMainPostConditions
{
}

AddFunction ArcaneConserveShortCdActions
{
 #mark_of_aluneth,if=mana.pct<85
 if ManaPercent() < 85 Spell(mark_of_aluneth)
 #rune_of_power,if=full_recharge_time<=execute_time|prev_gcd.1.mark_of_aluneth
 if SpellFullRecharge(rune_of_power) <= ExecuteTime(rune_of_power) or PreviousGCDSpell(mark_of_aluneth) Spell(rune_of_power)
}

AddFunction ArcaneConserveShortCdPostConditions
{
 Talent(charged_up_talent) and SpellChargeCooldown(charged_up) < time_until_burn() and Spell(arcane_barrage) or arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) and Enemies(tagged=1) < 3 and Spell(arcane_missiles) or Spell(supernova) or { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or Enemies(tagged=1) > 1 and ManaPercent() >= 70 - 10 * HasEquippedItem(mystic_kilt_of_the_rune_master) and Spell(arcane_explosion) or { ManaPercent() >= 90 or BuffPresent(rhonins_assaulting_armwraps_buff) or TotemRemaining(rune_of_power) >= CastTime(arcane_blast) and HasEquippedItem(mystic_kilt_of_the_rune_master) } and Spell(arcane_blast) or arcane_missiles_procs() and Spell(arcane_missiles) or Spell(arcane_barrage) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Spell(arcane_blast)
}

AddFunction ArcaneConserveCdActions
{
 #mirror_image,if=variable.time_until_burn>recharge_time|variable.time_until_burn>target.time_to_die
 if time_until_burn() > SpellChargeCooldown(mirror_image) or time_until_burn() > target.TimeToDie() Spell(mirror_image)
}

AddFunction ArcaneConserveCdPostConditions
{
 ManaPercent() < 85 and Spell(mark_of_aluneth) or Talent(rune_of_power_talent) and ArmorSetBonus(T20 4) and time_until_burn() > 30 and Spell(rune_of_power) or { SpellFullRecharge(rune_of_power) <= ExecuteTime(rune_of_power) or PreviousGCDSpell(mark_of_aluneth) } and Spell(rune_of_power) or Talent(charged_up_talent) and SpellChargeCooldown(charged_up) < time_until_burn() and Spell(arcane_barrage) or arcane_missiles_procs() == SpellData(arcane_missiles_buff max_stacks) and Enemies(tagged=1) < 3 and Spell(arcane_missiles) or Spell(supernova) or { target.Refreshable(nether_tempest_debuff) or not target.DebuffPresent(nether_tempest_debuff) } and Spell(nether_tempest) or Enemies(tagged=1) > 1 and ManaPercent() >= 70 - 10 * HasEquippedItem(mystic_kilt_of_the_rune_master) and Spell(arcane_explosion) or { ManaPercent() >= 90 or BuffPresent(rhonins_assaulting_armwraps_buff) or TotemRemaining(rune_of_power) >= CastTime(arcane_blast) and HasEquippedItem(mystic_kilt_of_the_rune_master) } and Spell(arcane_blast) or arcane_missiles_procs() and Spell(arcane_missiles) or Spell(arcane_barrage) or Enemies(tagged=1) > 1 and Spell(arcane_explosion) or Spell(arcane_blast)
}

### actions.precombat

AddFunction ArcanePrecombatMainActions
{
 #flask
 #food
 #augmentation
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
 Spell(summon_arcane_familiar) or Spell(arcane_blast)
}

AddFunction ArcanePrecombatCdActions
{
 unless Spell(summon_arcane_familiar)
 {
  #snapshot_stats
  #mirror_image
  Spell(mirror_image)
  #potion
  Item(deadly_grace_potion)
 }
}

AddFunction ArcanePrecombatCdPostConditions
{
 Spell(summon_arcane_familiar) or Spell(arcane_blast)
}

### actions.variables

AddFunction ArcaneVariablesMainActions
{
}

AddFunction ArcaneVariablesMainPostConditions
{
}

AddFunction ArcaneVariablesShortCdActions
{
}

AddFunction ArcaneVariablesShortCdPostConditions
{
}

AddFunction ArcaneVariablesCdActions
{
}

AddFunction ArcaneVariablesCdPostConditions
{
}
]]

	OvaleScripts:RegisterScript("MAGE", "arcane", name, desc, code, "script")
end
