/* NO Supported ZP 5.0 Patched */

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta_util>

//#define SUPPORT_ZP_43				// Поддердка ZP 4.3 Patched
//#define SUPPORT_BIO				// Поддердка Biohazerd v2.00 Beta 3b

#if defined SUPPORT_ZP_43
	#include <zombieplague>
#endif

#if defined SUPPORT_BIO
	#tryinclude <biohazard>
#endif

new g_hudmsg1

public plugin_init() {
	register_plugin("ZP Bullet Damager | Hud HP", "1.0.41.3b", "L4D2")
	
	RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", true)
	register_event("Damage", "DamageR", "b", "2!0", "3=0", "4!0")
	
	g_hudmsg1 = CreateHudSyncObj()
}

public Player_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type) {
	#if defined SUPPORT_ZP_43
	if(victim == attacker || !is_user_alive(attacker) || !is_user_connected(victim) || zp_get_user_zombie(attacker)) return HAM_IGNORED
	#endif
	
	#if defined SUPPORT_BIO
	if(victim == attacker || !is_user_alive(attacker) || !is_user_connected(victim) || is_user_zombie(attacker)) return HAM_IGNORED
	#endif
	
	new iVictimHealth = get_user_health(victim)
	if(iVictimHealth < 0) iVictimHealth = 0
	
	client_print(attacker, print_center, "HP: %d", iVictimHealth)
	
	return HAM_IGNORED
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
				ShowSyncHudMsg(attacker, g_hudmsg1, "%d^n", damage)
		}
	}
}
