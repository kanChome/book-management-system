package com.example.demo

import org.jooq.DSLContext
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class HelloController(private val dsl: DSLContext) {
    @GetMapping("/health")
    fun health(): Map<String, Any> = mapOf(
        "status" to "OK",
        "dbConnected" to try {
            // 単純な接続確認（例: SELECT 1）
            dsl.fetch("select 1 as ok").isNotEmpty
        } catch (ex: Exception) {
            false
        }
    )
}

