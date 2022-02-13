package com.example.revisitas

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}

    

  /*   private val CHANNEL = "simple_pos"
    lateinit var methodChannelResult: MethodChannel.Result
    lateinit var uri: Uri

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine){
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            if(call.method == "getExternalStoragePublicDirectory"){
                val type = call.argument<String>("type")
            }else if(call.method == "getAndroidDeviceId"){
                val android_id:String = Settings.Secure.getString(getContext().getContentResolver(),
                Settings.Secure.ANDROID_ID)
                Log.d("android id", android_id)

                result.success(android_id)
            
            }else if(call.method == "sendSms"){
                if (checkSelfPermission(
                    Manifest.permission.SEND_SMS)
                    != PackageManager.PERMISSION_GRANTED){
                        if(shouldShowRequestPermissionRationale(
                            Manifest.permission.SEND_SMS)){

                            }
                        
                    }
                ))
            }
        }
    } */



