# PawOut

PawOut은 반려견 산책 서비스를 목표로 하는 Flutter 기반 앱 프로젝트입니다.
현재는 앱 구조, 라우팅, 기본 화면, 상태 관리용 스캐폴딩이 잡혀 있는 초기 단계입니다.

## 프로젝트 개요

이 프로젝트는 반려견 산책 앱의 핵심 사용자 흐름을 기준으로 구성되어 있습니다.

- 회원가입 및 로그인
- 반려견 프로필 관리
- 산책 시작, 진행, 기록 확인
- 랭킹 및 커뮤니티 확장 기반

현재 대부분의 화면은 라우트로 연결된 뼈대 수준이며, 백엔드 연동과 실제 비즈니스 로직은 최소한만 준비된 상태입니다.

## 기술 스택

- Flutter
- Dart
- Provider
- Dio / HTTP
- Shared Preferences
- Geolocator
- Google Maps Flutter
- Pedometer
- Image Picker

## 현재 구현 범위

- 앱 진입점 및 테마 설정
- 이름 기반 라우트 관리
- 홈 화면과 주요 기능 이동 버튼
- 로그인 및 회원가입 화면
- 반려견 목록, 상세, 등록 화면 스캐폴딩
- 산책 시작, 진행, 기록 화면 스캐폴딩
- 랭킹 화면 스캐폴딩
- 공통 위젯과 상수 분리
- API, 위치 기능용 서비스 레이어 기본 틀

## 프로젝트 구조

```text
lib/
  core/
    constants/
    utils/
    widgets/
  features/
    auth/
    dog_profile/
    home/
    ranking/
    walk/
  services/
  main.dart
```

## 실행 방법

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. 앱 실행

```bash
flutter run
```

### 3. 테스트 실행

```bash
flutter test
```

## 주요 라우트

현재 앱에 정의된 주요 라우트는 아래와 같습니다.

- `/`
- `/login`
- `/signup`
- `/dogs`
- `/dogs/detail`
- `/walk/start`
- `/walk/active`
- `/walk/history`
- `/ranking`

## 개발 메모

- `ApiService`, `LocationService`는 아직 플레이스홀더 수준이며 실제 구현이 필요합니다.
- `lib/main.dart`에는 임시 화면 흐름이 일부 남아 있습니다.
- 지도, 걸음 수, 이미지 처리, 네트워크 관련 패키지는 추가되어 있지만 대부분 실제 기능 연결은 아직 진행 중입니다.
- 위치 권한, 활동 권한 등 플랫폼별 설정은 Android와 iOS에서 추가 작업이 필요할 수 있습니다.

## 다음 작업 제안

- `Provider` 기반 인증 상태 연결
- `main.dart`의 임시 네비게이션을 공통 라우트 구조로 통합
- API 클라이언트 및 로컬 저장소 구현
- 반려견 프로필 CRUD 흐름 구현
- 위치, 걸음 수, 산책 추적 로직 연결
- 위젯 테스트 및 통합 테스트 추가

## 현재 상태

이 저장소는 프로덕션 준비가 끝난 앱이 아니라, 기능 확장을 위한 기반 구조를 만드는 단계의 프로젝트입니다.
