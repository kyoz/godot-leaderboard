//
//  leaderboard.h
//  leaderboard
//
//  Created by Kyoz on 23/12/2024.
//

#ifndef LEADERBOARD_H
#define LEADERBOARD_H

#ifdef VERSION_4_0
#include "core/object/object.h"
#endif

#ifdef VERSION_3_X
#include "core/object.h"
#endif

class Leaderboard : public Object {

    GDCLASS(Leaderboard, Object);

    static Leaderboard *instance;

public:
    BOOL isAuthenticated();
    void signIn();
    void fetchHighScore(const String &leaderboard_id);
    void submitHighScore(const String &leaderboard_id, const int &score);
    void show(const String &leaderboard_id);

    
    void game_center_closed();

    
    static Leaderboard *get_singleton();
    
    Leaderboard();
    ~Leaderboard();

protected:
    static void _bind_methods();
};

#endif
