//
//  leaderboard_module.m
//  leaderboard
//
//  Created by Kyoz on 23/12/2024.
//


#ifdef VERSION_4_0
#include "core/config/engine.h"
#else
#include "core/engine.h"
#endif


#include "leaderboard_module.h"

Leaderboard * leaderboard;

void register_leaderboard_types() {
    leaderboard = memnew(Leaderboard);
    Engine::get_singleton()->add_singleton(Engine::Singleton("Leaderboard", leaderboard));
};

void unregister_leaderboard_types() {
    if (leaderboard) {
        memdelete(leaderboard);
    }
}
