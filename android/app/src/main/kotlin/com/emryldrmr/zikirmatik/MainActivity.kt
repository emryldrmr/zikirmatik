package com.emryldrmr.zikirmatik

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    private companion object {
        const val SAVE_REQUEST = 18001
        const val OPEN_REQUEST = 18002

        // Spec 0018, G4: a larger file is refused without being read.
        const val MAX_BACKUP_BYTES = 5L * 1024 * 1024
    }

    private var pendingSave: Pair<MethodChannel.Result, ByteArray>? = null
    private var pendingOpen: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        // Spec 0010 (plan R1): keep the screen on while Zikirlerim is in front.
        // A window flag; needs no permission.
        MethodChannel(messenger, "zikirmatik/screen")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setKeepScreenOn" -> {
                        if (call.arguments == true) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        // Spec 0018 (plan R3): the system save and open dialogs (Storage Access
        // Framework). No permission: the system grants access to the one file
        // the user picks; nothing else is read or written.
        MethodChannel(messenger, "zikirmatik/backup")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "save" -> save(
                        call.argument<String>("name") ?: "zikirmatik-yedek.json",
                        call.argument<ByteArray>("bytes") ?: ByteArray(0),
                        result,
                    )
                    "open" -> open(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun save(name: String, bytes: ByteArray, result: MethodChannel.Result) {
        if (pendingSave != null || pendingOpen != null) {
            result.error("busy", null, null)
            return
        }
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
            putExtra(Intent.EXTRA_TITLE, name)
        }
        pendingSave = result to bytes
        try {
            startActivityForResult(intent, SAVE_REQUEST)
        } catch (e: ActivityNotFoundException) {
            pendingSave = null
            result.error("failed", null, null)
        }
    }

    private fun open(result: MethodChannel.Result) {
        if (pendingSave != null || pendingOpen != null) {
            result.error("busy", null, null)
            return
        }
        // Any type: a .json from Drive or e-mail often shows as
        // application/octet-stream; the app checks the content itself.
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
        }
        pendingOpen = result
        try {
            startActivityForResult(intent, OPEN_REQUEST)
        } catch (e: ActivityNotFoundException) {
            pendingOpen = null
            result.error("failed", null, null)
        }
    }

    @Deprecated("Flutter's FlutterActivity still delivers results here.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            SAVE_REQUEST -> {
                val (result, bytes) = pendingSave ?: return
                pendingSave = null
                val uri = data?.data
                if (resultCode != Activity.RESULT_OK || uri == null) {
                    result.success("cancelled")
                    return
                }
                Thread {
                    val ok = try {
                        contentResolver.openOutputStream(uri)?.use { it.write(bytes) } != null
                    } catch (e: Exception) {
                        false
                    }
                    runOnUiThread {
                        if (ok) result.success("saved") else result.error("failed", null, null)
                    }
                }.start()
            }
            OPEN_REQUEST -> {
                val result = pendingOpen ?: return
                pendingOpen = null
                val uri = data?.data
                if (resultCode != Activity.RESULT_OK || uri == null) {
                    result.success(mapOf("status" to "cancelled"))
                    return
                }
                Thread {
                    val outcome: Map<String, Any>? = try {
                        read(uri)
                    } catch (e: Exception) {
                        null
                    }
                    runOnUiThread {
                        if (outcome != null) result.success(outcome) else result.error("failed", null, null)
                    }
                }.start()
            }
        }
    }

    /** The file's bytes, or "tooLarge" when over the limit: by its stated size
     *  first, and by never reading more than the limit plus one byte. */
    private fun read(uri: Uri): Map<String, Any> {
        val size = contentResolver.query(uri, arrayOf(OpenableColumns.SIZE), null, null, null)
            ?.use { c -> if (c.moveToFirst() && !c.isNull(0)) c.getLong(0) else null }
        if (size != null && size > MAX_BACKUP_BYTES) return mapOf("status" to "tooLarge")
        val input = contentResolver.openInputStream(uri) ?: throw IOException("no stream")
        val out = ByteArrayOutputStream()
        input.use {
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val n = it.read(buffer)
                if (n < 0) break
                out.write(buffer, 0, n)
                if (out.size() > MAX_BACKUP_BYTES) return mapOf("status" to "tooLarge")
            }
        }
        return mapOf("status" to "opened", "bytes" to out.toByteArray())
    }
}
