package com.sailinglogbook.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Anchor alarm: any system sound, at a volume of our own choosing.
 *
 * Two things the Flutter-side ringtone plugin cannot do, and both matter at
 * three in the morning:
 *
 *  * It plays three hardcoded system sounds. The skipper wants the one he
 *    recognises as "get up", which is whatever he set as his own alarm.
 *  * Its volume is a multiplier on top of the phone's alarm stream. With the
 *    phone turned down, "100 %" is still inaudible below deck — and the
 *    volume slider in settings was then a lie.
 *
 * So the alarm stream volume itself is raised for the duration of the alarm
 * and put back afterwards. That needs MODIFY_AUDIO_SETTINGS (a normal
 * permission, granted at install) and, while Do Not Disturb is on, notification
 * policy access — which only the user can grant, in system settings. Without
 * it the alarm still sounds, just at whatever volume the phone is set to.
 */
class AlarmChannel(
    private val activity: Activity,
    channel: MethodChannel,
) {
    companion object {
        const val CHANNEL = "hmb/alarm"
        private const val PICK_REQUEST = 7341
    }

    private var player: MediaPlayer? = null

    /** Alarm stream volume as we found it, restored when the alarm stops. */
    private var previousVolume: Int? = null

    /** Pending result of the ringtone picker, completed in [onActivityResult]. */
    private var pickResult: MethodChannel.Result? = null

    private val audio: AudioManager
        get() = activity.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    init {
        channel.setMethodCallHandler { call, result -> handle(call, result) }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickSound" -> pickSound(call.argument<String>("uri"), result)
            "soundTitle" -> result.success(titleOf(call.argument<String>("uri")))
            "defaultSoundUri" -> result.success(
                RingtoneManager
                    .getDefaultUri(RingtoneManager.TYPE_ALARM)
                    ?.toString(),
            )
            "play" -> {
                play(
                    call.argument<String>("uri"),
                    call.argument<Double>("volume") ?: 1.0,
                    call.argument<Boolean>("looping") ?: true,
                )
                result.success(null)
            }
            "stop" -> {
                stop()
                result.success(null)
            }
            "canOverrideDnd" -> result.success(hasPolicyAccess())
            "openDndSettings" -> {
                openDndSettings()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // ── Sound choice ──────────────────────────────────────────────

    /**
     * The system ringtone picker, showing every alarm and ringtone on the
     * phone. Alarms first: this is an alarm, and the list the skipper knows
     * is the one he picks his morning alarm from.
     */
    private fun pickSound(current: String?, result: MethodChannel.Result) {
        if (pickResult != null) {
            result.error("busy", "A sound picker is already open", null)
            return
        }
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_ALL)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(
                RingtoneManager.EXTRA_RINGTONE_DEFAULT_URI,
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM),
            )
            if (!current.isNullOrEmpty()) {
                putExtra(
                    RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                    Uri.parse(current),
                )
            }
        }
        // A phone without a picker is not a reason to fail the call — the
        // caller keeps whatever sound it had.
        if (intent.resolveActivity(activity.packageManager) == null) {
            result.success(null)
            return
        }
        pickResult = result
        activity.startActivityForResult(intent, PICK_REQUEST)
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_REQUEST) return false
        val result = pickResult ?: return true
        pickResult = null
        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return true
        }
        val uri = data
            ?.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
            ?.toString()
        if (uri == null) {
            result.success(null)
            return true
        }
        result.success(mapOf("uri" to uri, "title" to titleOf(uri)))
        return true
    }

    private fun titleOf(uri: String?): String? {
        if (uri.isNullOrEmpty()) return null
        return try {
            RingtoneManager.getRingtone(activity, Uri.parse(uri))?.getTitle(activity)
        } catch (_: Exception) {
            // A sound that was deleted, or lives on a card that is not in the
            // phone right now. The caller shows the alarm's default name.
            null
        }
    }

    // ── Playback ──────────────────────────────────────────────────

    private fun play(uri: String?, volume: Double, looping: Boolean) {
        stop()
        val sound = when {
            !uri.isNullOrEmpty() -> Uri.parse(uri)
            else -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        } ?: return

        raiseAlarmVolume(volume)

        try {
            player = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(activity, sound)
                isLooping = looping
                prepare()
                start()
            }
        } catch (_: Exception) {
            // A sound that cannot be opened must not swallow the alarm: fall
            // back to the system default, which is always present.
            restoreVolume()
            playDefaultFallback(looping)
        }
    }

    private fun playDefaultFallback(looping: Boolean) {
        val fallback = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM) ?: return
        try {
            player = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(activity, fallback)
                isLooping = looping
                prepare()
                start()
            }
        } catch (_: Exception) {
            player = null
        }
    }

    /**
     * Raises the alarm stream to the chosen share of its maximum.
     *
     * The previous value is remembered and put back in [stop] — the app is a
     * guest on this phone and must not leave its alarm volume changed.
     */
    private fun raiseAlarmVolume(volume: Double) {
        try {
            val max = audio.getStreamMaxVolume(AudioManager.STREAM_ALARM)
            val want = Math.max(1, Math.round(volume.coerceIn(0.05, 1.0) * max).toInt())
            val now = audio.getStreamVolume(AudioManager.STREAM_ALARM)
            if (previousVolume == null) previousVolume = now
            if (now != want) {
                audio.setStreamVolume(AudioManager.STREAM_ALARM, want, 0)
            }
        } catch (_: SecurityException) {
            // Do Not Disturb without notification policy access. The alarm
            // still plays, at whatever the phone is set to.
            previousVolume = null
        } catch (_: Exception) {
            previousVolume = null
        }
    }

    private fun restoreVolume() {
        val previous = previousVolume ?: return
        previousVolume = null
        try {
            audio.setStreamVolume(AudioManager.STREAM_ALARM, previous, 0)
        } catch (_: Exception) {
            // Nothing to do: leaving it louder is better than crashing.
        }
    }

    private fun stop() {
        try {
            player?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (_: Exception) {
            // Already gone.
        }
        player = null
        restoreVolume()
    }

    // ── Do Not Disturb ────────────────────────────────────────────

    private fun hasPolicyAccess(): Boolean = try {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            true
        } else {
            val nm = activity.getSystemService(Context.NOTIFICATION_SERVICE)
                as android.app.NotificationManager
            nm.isNotificationPolicyAccessGranted
        }
    } catch (_: Exception) {
        false
    }

    private fun openDndSettings() {
        try {
            activity.startActivity(
                Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        } catch (_: Exception) {
            // Some phones ship without that settings screen.
        }
    }

    /** Called when the activity goes away, so nothing keeps playing. */
    fun dispose() = stop()
}
