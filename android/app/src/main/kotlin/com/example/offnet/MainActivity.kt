package com.example.offnet

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.p2p.*
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.offnet/wifiDirect"

    private lateinit var wifiP2pManager: WifiP2pManager
    private lateinit var channel: WifiP2pManager.Channel
    private var peerListListener: WifiP2pManager.PeerListListener? = null
    private lateinit var receiver: BroadcastReceiver
    private lateinit var intentFilter: IntentFilter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        wifiP2pManager = getSystemService(WIFI_P2P_SERVICE) as WifiP2pManager
        channel = wifiP2pManager.initialize(this, mainLooper, null)

        intentFilter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        }

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                        wifiP2pManager.requestPeers(channel, peerListListener)
                    }
                }
            }
        }

        peerListListener = WifiP2pManager.PeerListListener { peerList ->
            val deviceNames = peerList.deviceList.map { it.deviceName }
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("updateDeviceList", deviceNames)
        }

        registerReceiver(receiver, intentFilter)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "listDevices") {
                discoverPeers(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun discoverPeers(result: MethodChannel.Result) {
        wifiP2pManager.discoverPeers(channel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                result.success("Discovery started successfully")
            }

            override fun onFailure(reason: Int) {
                result.error("DISCOVERY_FAILED", "Failed to start discovery", null)
            }
        })
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(receiver)
    }
}
