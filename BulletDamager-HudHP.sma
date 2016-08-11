#include <amxmodx>
#include <hamsandwich>
#include <fakemeta_util>

#define SUPPORT_ZP
//#define SUPPORT_BIO

#if defined SUPPORT_ZP
	#include <zombieplague>
#endif

#if defined SUPPORT_BIO
	#tryinclude <biohazard>
#endif

new g_hudmsg1, g_hudmsg2

public plugin_init() {
	register_plugin("ZP Bullet Damager | Hud HP", "1.0.40.4f", "L4D2")
	
	register_event("Damage", "Damage", "b", "2!0", "3=0", "4!0")
	
	RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", true)
	
	g_hudmsg1 = CreateHudSyncObj()
	g_hudmsg2 = CreateHudSyncObj()
}

public Damage(id) {
	static attacker; attacker = get_user_attacker(id)
	static damage; damage = read_data(2)
	
	if(is_user_connected(attacker)) {
		switch(switch) {
			case 1: {
				set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
				ShowSyncHudMsg(attacker, g_hudmsg1, "%i^n", damage)
			}
			case 2: {
				if(fm_is_ent_visible(attacker, id)) {
					set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
					ShowSyncHudMsg(attacker, g_hudmsg2, "%i^n", damage)
				}
			}
		}
	}
}

public Player_TakeDamage(victim, inflictor, attacker, Float:damage) {
	#if defined SUPPORT_ZP
	if(!is_user_alive(attacker) || !zp_get_user_zombie(attacker)) return;
	#endif
	
	#if defined SUPPORT_BIO
	if(!is_user_alive(attacker) || !is_user_zombie(attacker)) return;
	#endif
	
	client_print(attacker, print_center, "Health Zombie: %d", get_user_health(victim))
}
