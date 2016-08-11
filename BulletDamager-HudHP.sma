#include <amxmodx>
#include <hamsandwich>
#include <fakemeta_util>

#define SUPPORT_ZP_43				// Поддердка ZP 4.3 Patched
//#define SUPPORT_BIO				// Поддердка Biohazerd v2.00 Beta 3b
//#define SUPPORT_ZP_50				// Поддердка ZP 5.0 Patched 

#if defined SUPPORT_ZP_43
	#include <zombieplague>
#endif

#if defined SUPPORT_BIO
	#tryinclude <biohazard>
#endif

#if defined SUPPORT_ZP_50
	#tryinclude <biohazard>
#endif

new g_hudmsg1, g_hudmsg2

public plugin_init() {
	register_plugin("ZP Bullet Damager | Hud HP", "1.0.41.0", "L4D2")
	
	RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", true)
	register_event("Damage", "DamageR", "b", "2!0", "3=0", "4!0")
	
	g_hudmsg1 = CreateHudSyncObj()
	g_hudmsg2 = CreateHudSyncObj()
}

public DamageR(id) {
	static attacker; attacker = get_user_attacker(id)
	static damage; damage = read_data(2)
	
	if(!is_user_connected(attacker)) return
	
	set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
	
	switch(id) {
		case 1: ShowSyncHudMsg(attacker, g_hudmsg1, "%d^n", damage)
		case 2: {
			if(fm_is_ent_visible(attacker, id))
				ShowSyncHudMsg(attacker, g_hudmsg2, "%d^n", damage)
		}
	}
}

public Player_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type) {
	#if defined SUPPORT_ZP_43
	if(victim == attacker || !is_user_alive(attacker) || !is_user_connected(victim) || zp_get_user_zombie(attacker)) return HAM_IGNORED
	#endif
	
	#if defined SUPPORT_BIO
	if(victim == attacker || !is_user_alive(attacker) || !is_user_connected(victim) || is_user_zombie(attacker)) return HAM_IGNORED
	#endif
	
	#if defined SUPPORT_ZP_50
	if(victim == attacker || !is_user_alive(attacker) || !is_user_connected(victim) || zp_core_is_zombie(attacker)) return HAM_IGNORED
	#endif
	
	new iVictimHealth = get_user_health(victim)
	if(iVictimHealth < 0) iVictimHealth = 0
	
	client_print(attacker, print_center, "HP: %d", iVictimHealth)
	
	return HAM_IGNORED
}
