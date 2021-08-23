package com.example.ant_1

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.os.Environment
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.*
import org.opencv.imgproc.Imgproc
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        OpenCVLoader.initDebug()

        fun toPerspectiveTransformationImg(srcpath: String): Mat{
            val options = BitmapFactory.Options()
            options.inPreferredConfig = Bitmap.Config.ARGB_8888
            val bitmap = BitmapFactory.decodeFile(srcpath, options)
            var matSource = Mat()
            Utils.bitmapToMat(bitmap, matSource)
            var matDest = Mat()

            Imgproc.cvtColor(matSource, matDest, Imgproc.COLOR_BGR2GRAY)
            Imgproc.threshold(matDest, matDest, 0.0, 255.0, Imgproc.THRESH_OTSU)
            return matDest
        }

        MethodChannel(flutterEngine.getDartExecutor(),"api.opencv.dev/opencv")
                .setMethodCallHandler { call, result ->
            when(call.method) {
                "toPerspectiveTransformationImg" -> {
                    val srcpath : String? = call.argument("srcPath")
                    if (srcpath == null) {
                        result.error("error", "illigal arguments", null)
                    }
                    else {
                        result.success(toPerspectiveTransformationImg(srcpath))
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

}
}

