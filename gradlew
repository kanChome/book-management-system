#!/usr/bin/env sh

# Minimal Gradle wrapper bootstrapper with auto-download of gradle-wrapper.jar

APP_HOME=$(cd "$(dirname "$0")"; pwd -P)
APP_BASE_NAME=${0##*/}

WRAPPER_DIR="$APP_HOME/gradle/wrapper"
WRAPPER_JAR="$WRAPPER_DIR/gradle-wrapper.jar"
WRAPPER_VERSION="8.14.3"

download_wrapper_jar() {
  JAR_URL="https://repo.gradle.org/gradle/libs-releases-local/org/gradle/gradle-wrapper/${WRAPPER_VERSION}/gradle-wrapper-${WRAPPER_VERSION}.jar"
  ALT_URL="https://repo1.maven.org/maven2/org/gradle/gradle-wrapper/${WRAPPER_VERSION}/gradle-wrapper-${WRAPPER_VERSION}.jar"
  mkdir -p "$WRAPPER_DIR"
  echo "gradle-wrapper.jar が見つかりません。ダウンロードを試みます (${WRAPPER_VERSION})..." 1>&2
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$JAR_URL" -o "$WRAPPER_JAR" || curl -fsSL "$ALT_URL" -o "$WRAPPER_JAR" || return 1
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$WRAPPER_JAR" "$JAR_URL" || wget -q -O "$WRAPPER_JAR" "$ALT_URL" || return 1
  else
    echo "curl / wget が見つかりません。手動で $ALT_URL を $WRAPPER_JAR に配置してください。" 1>&2
    return 1
  fi
}

if [ ! -f "$WRAPPER_JAR" ]; then
  download_wrapper_jar || { echo "gradle-wrapper.jar の取得に失敗しました" 1>&2; exit 1; }
fi

# Java detection
if [ -n "$JAVA_HOME" ] ; then
  JAVA_EXE="$JAVA_HOME/bin/java"
  if [ ! -x "$JAVA_EXE" ] ; then
    echo "ERROR: JAVA_HOME は無効です: $JAVA_HOME" 1>&2
    exit 1
  fi
else
  JAVA_EXE=$(command -v java)
  if [ -z "$JAVA_EXE" ] ; then
    echo "ERROR: Java が見つかりません。JAVA_HOME を設定するか Java をインストールしてください。" 1>&2
    exit 1
  fi
fi

CLASSPATH="$WRAPPER_JAR"
exec "$JAVA_EXE" -Dorg.gradle.appname="$APP_BASE_NAME" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"

