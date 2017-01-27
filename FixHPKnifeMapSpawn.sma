#include <amxmodx>
#include <hamsandwich>
#include <fun>

#define HP_TASK 30500592

new THE_HP
new cvar_delay_1hp, cvar_delay_35hp, cvar_delay_35hp2, cvar_delay_acer

public plugin_init() {
	register_plugin("Fix HP spawn", "0.0.1.9", "L4D2 aka LEISER")
	
	RegisterHam(Ham_Spawn, "player", "fw_player_spawn", 1)
	
	cvar_delay_1hp = register_cvar("amx_hp_delay_1hp", "1.0")
	cvar_delay_35hp = register_cvar("amx_hp_delay_35hp", "1.0")
	cvar_delay_35hp2 = register_cvar("amx_hp_delay_35hp2", "1.0")
	cvar_delay_acer = register_cvar("amx_hp_delay_acer", "1.0")
	
	static mapname[64];
	get_mapname(mapname,charsmax(mapname))

	if(containi(mapname,"35hp") != -1) THE_HP = 35
	else if(containi(mapname,"35hp_2") != -1) THE_HP = 35
	else if(containi(mapname,"1hp") != -1) THE_HP = 1
	else if(containi(mapname,"acer") != -1) THE_HP = 100
	else if(containi(mapname,"ka_") != -1) THE_HP = 35
	else THE_HP = 0
}
 
public fw_player_spawn(id) {
	if(THE_HP) {
		if(get_user_health(id) != THE_HP) {
			if(task_exists(id + HP_TASK)) remove_task(id + HP_TASK)

			if(THE_HP == 1)
				set_task(get_pcvar_float(cvar_delay_1hp), "Set_hp", id + HP_TASK)
			else if(THE_HP == 100)
				set_task(get_pcvar_float(cvar_delay_acer), "Set_hp", id + HP_TASK)
			else if(THE_HP == 35)
				set_task(get_pcvar_float(cvar_delay_35hp), "Set_hp", id + HP_TASK)
			else if(THE_HP == 35)
				set_task(get_pcvar_float(cvar_delay_35hp2), "Set_hp", id + HP_TASK)
		}
	}
	return PLUGIN_CONTINUE
}
 
public Set_hp(id) {
    id -= HP_TASK
    if(is_user_alive(id)) set_user_health(id, THE_HP)
}
