# RentaVoz 배포 가이드

---

## Android 배포 (Google Play)

### 1. 서명 키 생성 (최초 1회)
```bash
keytool -genkey -v -keystore ~/rentavoz-release-key.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias rentavoz
```
비밀번호와 개인정보 입력 후 키 파일을 안전한 곳에 보관.

### 2. key.properties 설정
`android/key.properties` 파일 생성 (git에 절대 커밋하지 말 것):
```
storePassword=<저장소 비밀번호>
keyPassword=<키 비밀번호>
keyAlias=rentavoz
storeFile=<키 파일 절대경로>/rentavoz-release-key.jks
```

### 3. build.gradle.kts 서명 설정 추가
`android/app/build.gradle.kts`에 아래 추가:
```kotlin
import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 4. AAB 빌드
```bash
flutter build appbundle --release
```
결과물: `build/app/outputs/bundle/release/app-release.aab`

### 5. Google Play Console 업로드
- [Google Play Console](https://play.google.com/console) 접속
- 앱 선택 → 프로덕션 → 새 버전 만들기
- AAB 파일 업로드
- 출시 노트 작성 (스페인어)

---

## iOS 배포 (App Store)

### 1. Xcode에서 Archive
```bash
flutter build ios --release
```
이후 Xcode 열기: `open ios/Runner.xcworkspace`
- Product → Archive → Distribute App → App Store Connect

### 2. 또는 Transporter 앱 사용
- Xcode에서 `.ipa` 내보내기
- [Transporter](https://apps.apple.com/app/transporter/id1450874784) 앱으로 업로드

### 3. App Store Connect 설정
- [App Store Connect](https://appstoreconnect.apple.com) 접속
- 빌드 선택 → 심사 제출

---

## 버전 관리 규칙
| 변경 유형 | 버전 예시 | versionCode |
|---|---|---|
| 주요 기능 추가 | 1.1.0+3 | 3 |
| 버그 수정 | 1.0.1+3 | 3 (동일) |
| 긴급 패치 | 1.0.2+4 | 4 |

`pubspec.yaml`의 `version: X.Y.Z+N`에서 N(versionCode)은 항상 증가해야 함.

---

## .gitignore 추가 항목
```
android/key.properties
*.jks
*.keystore
```
