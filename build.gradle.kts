import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.9.25"
    id("org.springframework.boot") version "3.5.5"
    id("io.spring.dependency-management") version "1.1.6"
    kotlin("plugin.spring") version "1.9.25"
    id("nu.studer.jooq") version "9.0"
    id("org.flywaydb.flyway") version "10.21.0"
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

group = "com.example"
version = "0.0.1-SNAPSHOT"

tasks.withType<KotlinCompile> {
    kotlinOptions {
        jvmTarget = "21"
        freeCompilerArgs = freeCompilerArgs + listOf("-Xjsr305=strict")
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-jooq")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jooq:jooq-kotlin:3.19.17")
    implementation("org.jooq:jooq-kotlin-coroutines:3.19.17")

    // DB driver: PostgreSQL
    runtimeOnly("org.postgresql:postgresql")
    jooqGenerator("org.postgresql:postgresql")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
}

// JOOQ Configuration
jooq {
    version.set("3.19.17")
    configurations {
        create("main") {
            jooqConfiguration.apply {
                logging = org.jooq.meta.jaxb.Logging.WARN
                jdbc.apply {
                    driver = "org.postgresql.Driver"
                    url = "jdbc:postgresql://localhost:5432/book_management"
                    user = "postgres"
                    password = "password"
                }
                generator.apply {
                    name = "org.jooq.codegen.KotlinGenerator"
                    database.apply {
                        name = "org.jooq.meta.postgres.PostgresDatabase"
                        inputSchema = "public"
                        includes = ".*"
                        excludes = "flyway_schema_history"
                    }
                    generate.apply {
                        isDeprecated = false
                        isRecords = true
                        isImmutablePojos = true
                        isFluentSetters = true
                        isJavaTimeTypes = true
                        isKotlinNotNullPojoAttributes = true
                        isKotlinNotNullRecordAttributes = true
                        isKotlinNotNullInterfaceAttributes = true
                    }
                    target.apply {
                        packageName = "com.example.jooq.generated"
                        directory = "src/main/kotlin"
                    }
                    strategy.name = "org.jooq.codegen.DefaultGeneratorStrategy"
                }
            }
        }
    }
}

// Make JOOQ generation depend on Flyway migration
tasks.named("generateJooq").configure {
    dependsOn("flywayMigrate")
    inputs.files(fileTree("src/main/resources/db/migration"))
        .withPropertyName("migrations")
        .withPathSensitivity(PathSensitivity.RELATIVE)
    outputs.cacheIf { true }
}

// Flyway Configuration
flyway {
    url = "jdbc:postgresql://localhost:5432/book_management"
    user = "postgres"
    password = "password"
    schemas = arrayOf("public")
    locations = arrayOf("filesystem:src/main/resources/db/migration")
    baselineOnMigrate = true
    validateMigrationNaming = true
}

