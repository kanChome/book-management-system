@ECHO OFF
SETLOCAL

set DIR=%~dp0
set WRAPPER_DIR=%DIR%gradle\wrapper
set WRAPPER_JAR=%WRAPPER_DIR%\gradle-wrapper.jar
set WRAPPER_VERSION=8.14.3

IF NOT EXIST "%WRAPPER_JAR%" (
  ECHO gradle-wrapper.jar が見つかりません。ダウンロードを試みます (%WRAPPER_VERSION%)...
  mkdir "%WRAPPER_DIR%" 2>NUL
  where powershell >NUL 2>&1
  IF %ERRORLEVEL% EQU 0 (
    powershell -NoProfile -Command "\
      $u1='https://repo.gradle.org/gradle/libs-releases-local/org/gradle/gradle-wrapper/'+$env:WRAPPER_VERSION+'/gradle-wrapper-'+$env:WRAPPER_VERSION+'.jar'; \
      $u2='https://repo1.maven.org/maven2/org/gradle/gradle-wrapper/'+$env:WRAPPER_VERSION+'/gradle-wrapper-'+$env:WRAPPER_VERSION+'.jar'; \
      $o=$env:WRAPPER_JAR; \
      try { Invoke-WebRequest -UseBasicParsing -Uri $u1 -OutFile $o } catch { try { Invoke-WebRequest -UseBasicParsing -Uri $u2 -OutFile $o } catch { exit 1 } }" || (
      ECHO gradle-wrapper.jar の取得に失敗しました & EXIT /B 1
    )
  ) ELSE (
    ECHO PowerShell が見つかりません。手動で入手してください。 & EXIT /B 1
  )
)

set JAVA_EXE=%JAVA_HOME%\bin\java.exe
IF NOT EXIST "%JAVA_EXE%" (
  for %%i in (java.exe) do set JAVA_EXE=%%~$PATH:i
)
IF NOT EXIST "%JAVA_EXE%" (
  ECHO Java が見つかりません。JAVA_HOME を設定するか Java をインストールしてください。
  EXIT /B 1
)

"%JAVA_EXE%" -Dorg.gradle.appname=gradlew -classpath "%WRAPPER_JAR%" org.gradle.wrapper.GradleWrapperMain %*

ENDLOCAL

