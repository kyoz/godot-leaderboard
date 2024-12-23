package vn.kyoz.godot.leaderboard;

import android.content.Intent;
import android.util.Log;
import android.app.Activity;
import androidx.annotation.NonNull;
import androidx.collection.ArraySet;
import androidx.core.app.ActivityCompat;

import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.games.AnnotatedData;
import com.google.android.gms.games.GamesSignInClient;
import com.google.android.gms.games.LeaderboardsClient;
import com.google.android.gms.games.PlayGames;
import com.google.android.gms.games.leaderboard.LeaderboardScore;
import com.google.android.gms.games.leaderboard.LeaderboardVariant;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;


import java.util.Set;

public class Leaderboard extends GodotPlugin {
    private static final String TAG = "GodotLeaderboard";
    private final GamesSignInClient gamesSignInClient;
    private final LeaderboardsClient leaderboardsClient;
    private Activity activity;
    private final int showLeaderboardRequestCode = 9003;


    public Leaderboard(Godot godot) {
        super(godot);
        activity = getActivity();
        this.gamesSignInClient = PlayGames.getGamesSignInClient(godot.getActivity());
        this.leaderboardsClient = PlayGames.getLeaderboardsClient(godot.getActivity());
    }

    @NonNull
    @Override
    public String getPluginName() {
        return getClass().getSimpleName();
    }


    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new ArraySet<>();

        signals.add(new SignalInfo("on_leaderboard_error", String. class));
        signals.add(new SignalInfo("on_leaderboard_event", String. class));
        signals.add(new SignalInfo("on_authenticated", Boolean. class));
        signals.add(new SignalInfo("on_high_score_fetched", Integer. class));

        return signals;
    }

    @UsedByGodot
    public void check_authenticated() {
        gamesSignInClient.isAuthenticated().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                emitSignal("on_authenticated", true);
            }
        });
    }

    @UsedByGodot
    public void signIn() {
        gamesSignInClient.signIn().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                emitSignal("on_authenticated", true);
            } else {
                emitSignal("on_authenticated", false);
            }
        });
    }

    @UsedByGodot
    public void fetchHighScore(String leaderboard_id) {
        leaderboardsClient
                .loadCurrentPlayerLeaderboardScore(
                        leaderboard_id,
                        LeaderboardVariant.TIME_SPAN_ALL_TIME,
                        LeaderboardVariant.COLLECTION_PUBLIC
                )
                .addOnCompleteListener(new OnCompleteListener<AnnotatedData<LeaderboardScore>>() {
                    @Override
                    public void onComplete(Task<AnnotatedData<LeaderboardScore>> task) {
                        if (task.isSuccessful() && task.getResult() != null) {
                            LeaderboardScore score = task.getResult().get();
                            if (score != null) {
                                // Convert score to a dictionary or handle it directly
                                Log.d("Leaderboard", "Player score: " + score.getRawScore());
                                Log.d("Leaderboard", "Formatted score: " + score.getDisplayScore());
                                int rawScore = (int) score.getRawScore();
                                emitSignal("on_high_score_fetched", rawScore);
                            } else {
                                Log.d("Leaderboard", "No score available for the player.");
                            }
                        } else {
                            Log.e("Leaderboard", "Error fetching score", task.getException());
                        }
                    }
                });
    }

    @UsedByGodot
    public void submitHighScore(String leaderboard_id, int high_score) {
        leaderboardsClient.submitScore(leaderboard_id, high_score);
    }

    @UsedByGodot
    public void show(String leaderboard_id) {
        leaderboardsClient
                .getLeaderboardIntent(leaderboard_id)
                .addOnSuccessListener(new OnSuccessListener<Intent>() {
                    @Override
                    public void onSuccess(Intent intent) {
                        if (intent != null) {
                            ActivityCompat.startActivityForResult(
                                    activity,
                                    intent,
                                    showLeaderboardRequestCode,
                                    null
                            );
                        } else {
                            Log.e("Leaderboard", "Intent is null");
                        }
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(Exception e) {
                        Log.e("Leaderboard", "Failed to get leaderboard intent", e);
                    }
                });
    }
}
