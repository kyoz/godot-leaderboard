//
//  leaderboard.m
//  leaderboard
//
//  Created by Kyoz on 23/12/2024.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#ifdef VERSION_4_0
#include "core/object/class_db.h"
#else
#include "core/class_db.h"
#endif

#include "leaderboard.h"
#import <GameKit/GameKit.h>
#import "game_center_delegate.h"

Leaderboard *Leaderboard::instance = NULL;
GodotGameCenterDelegate *gameCenterDelegate = nil;

Leaderboard::Leaderboard() {
    instance = this;
    gameCenterDelegate = [[GodotGameCenterDelegate alloc] init];

    NSLog(@"initialize leaderboard");
}

Leaderboard::~Leaderboard() {
    if (instance == this) {
        instance = NULL;
    }
    
    if (gameCenterDelegate) {
        gameCenterDelegate = nil;
    }
    
    NSLog(@"deinitialize leaderboard");
}

Leaderboard *Leaderboard::get_singleton() {
    return instance;
};


void Leaderboard::_bind_methods() {
    ADD_SIGNAL(MethodInfo("on_leaderboard_error", PropertyInfo(Variant::STRING, "error_code")));
    ADD_SIGNAL(MethodInfo("on_leaderboard_event", PropertyInfo(Variant::STRING, "event_code")));
    ADD_SIGNAL(MethodInfo("on_authenticated", PropertyInfo(Variant::BOOL, "is_authenticated")));
    ADD_SIGNAL(MethodInfo("on_high_score_fetched", PropertyInfo(Variant::INT, "highscore")));

    
    ClassDB::bind_method("isAuthenticated", &Leaderboard::isAuthenticated);
    ClassDB::bind_method("signIn", &Leaderboard::signIn);
    ClassDB::bind_method("fetchHighScore", &Leaderboard::fetchHighScore);
    ClassDB::bind_method("submitHighScore", &Leaderboard::submitHighScore);
    ClassDB::bind_method("show", &Leaderboard::show);

}


BOOL Leaderboard::isAuthenticated() {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    return localPlayer.isAuthenticated;
}


void Leaderboard::signIn() {
    //if this class isn't available, game center isn't implemented
    if ((NSClassFromString(@"GKLocalPlayer")) == nil) {
        emit_signal("on_leaderboard_error", "ERROR_INIT");
        return;
    }

    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    if (![player respondsToSelector:@selector(authenticateHandler)]) {
        emit_signal("on_leaderboard_error", "ERROR_INIT");
        return;
    }

    UIViewController *root_controller = [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    if (!root_controller) {
        emit_signal("on_leaderboard_error", "ERROR_INIT");
        return;
    }

    // This handler is called several times.  First when the view needs to be shown, then again
    // after the view is cancelled or the user logs in.  Or if the user's already logged in, it's
    // called just once to confirm they're authenticated.  This is why no result needs to be specified
    // in the presentViewController phase. In this case, more calls to this function will follow.
    _weakify(root_controller);
    _weakify(player);
    player.authenticateHandler = (^(UIViewController *controller, NSError *error) {
        _strongify(root_controller);
        _strongify(player);

        if (controller) {
            [root_controller presentViewController:controller animated:YES completion:nil];
        } else {
            if (player.isAuthenticated) {
                emit_signal("on_authenticated", true);
            } else {
                emit_signal("on_authenticated", false);
            };
        };
    });

}

void Leaderboard::fetchHighScore(const String &leaderboard_id) {
    GKLeaderboard *leaderboard = [[GKLeaderboard alloc] init];
    leaderboard.identifier = [[NSString alloc] initWithUTF8String:leaderboard_id.utf8().get_data()];
    leaderboard.playerScope = GKLeaderboardPlayerScopeGlobal;
    leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderboard.range = NSMakeRange(1, 1);

    [leaderboard loadScoresWithCompletionHandler:^(NSArray<GKScore *> * _Nullable scores, NSError * _Nullable error) {
        if (!error && scores && scores.count > 0) {
            GKScore *topScore = scores.firstObject;
            emit_signal("on_high_score_fetched", topScore.value);
        } else {
            // Handle error or no scores case
            emit_signal("on_leaderboard_error", "ERROR_FETCH_HIGHSCORE_FAILED");
        }
    }];
}

void Leaderboard::submitHighScore(const String &leaderboard_id, const int &score) {
    NSString *cat_str = [[NSString alloc] initWithUTF8String:leaderboard_id.utf8().get_data()];
    GKScore *reporter = [[GKScore alloc] initWithLeaderboardIdentifier:cat_str];
    reporter.value = score;

    if ([GKScore respondsToSelector:@selector(reportScores)]) {
        emit_signal("on_leaderboard_error", "ERROR_UNAVAILABLE");
        return;
    }

    [GKScore reportScores:@[ reporter ]
        withCompletionHandler:^(NSError *error) {
            if (error == nil) {
                emit_signal("on_leaderboard_event", "EVENT_SUBMIT_SCORE_OK");
            } else {
                emit_signal("on_leaderboard_event", "EVENT_SUBMIT_SCORE_ERROR");
            };
        }];
}


void Leaderboard::show(const String &leaderboard_id) {
    if (!NSProtocolFromString(@"GKGameCenterControllerDelegate")) {
        emit_signal("on_leaderboard_error", "ERROR_NO_CENTER_CONTROLLER");
        return;
    }

    GKGameCenterViewControllerState view_state = GKGameCenterViewControllerStateDefault;
    view_state = GKGameCenterViewControllerStateLeaderboards;

    GKGameCenterViewController *controller = [[GKGameCenterViewController alloc] init];
    
    if (!controller) {
        emit_signal("on_leaderboard_error", "ERROR_CANT_SHOW_LEADERBOARD");
        return;
    }

    controller.leaderboardIdentifier = [NSString stringWithUTF8String:leaderboard_id.ascii().get_data()];
    controller.leaderboardTimeScope = GKLeaderboardTimeScopeAllTime;

    
    UIViewController *root_controller = [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    if (!root_controller) {
        emit_signal("on_leaderboard_error", "ERROR_CANT_SHOW_LEADERBOARD");
        return;
    }
    
    controller.gameCenterDelegate = gameCenterDelegate;
    controller.viewState = view_state;

    [root_controller presentViewController:controller animated:YES completion:nil];
}


void Leaderboard::game_center_closed() {
    
}
