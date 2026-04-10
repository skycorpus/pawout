# 🐾 PawOut

PawOut은 반려견 산책 서비스를 목표로 하는 Flutter 기반 앱 프로젝트입니다.
산책 활동(걸음수, 거리, 시간)을 기록하고, 반려견 프로필과 소셜 기능을 통해 사용자 간 소통을 제공합니다.

- 회원가입 및 로그인
- 반려견 프로필 관리
- 산책 시작, 진행, 기록 확인
- 랭킹 및 커뮤니티 확장 기반

## 📌 아키텍처

```text
[Flutter 모바일 앱]
        |
        v
[Provider 상태관리]
        |
        v
[Service Layer (API / Location / Storage)]
        |
        v
[Backend (추후 확장)]
```

## 🛠 기술 스택

| 영역 | 기술 |
|------|------|
| 언어 | Dart |
| 프론트엔드 | Flutter, Dart Flutter, Android studio, visual studio code |
| 백엔드 | Supabase |
| DB | PostgreSQL |
| Development Tools | VS Code, Android Studio, GitHub |
| Storage | Supabase Storage |
| 상태관리 | Provider |
| 네트워크 | Dio / HTTP |

## 🚀 주요 기능

### ✔ MVP 기능
- 회원가입 / 로그인
- 반려견 프로필 등록
- 산책 시작 / 종료
- 걸음수 측정
- 산책 거리 및 시간 기록

### ✔ 확장 기능 (예정)
- 랭킹 (걸음수 기반 TOP 10)
- 좋아요 / 팔로우
- 산책 인증 피드
- 근처 산책 중인 강아지 보기
- 산책 경로 추천
- 푸시 알림 및 통계

## 📊 DB 설계

### users
- user_id
- email
- password
- created_at

### dogs
- dog_id
- user_id (FK)
- name
- breed
- chip_number
- photo_url
- birth_date

### walks
- walk_id
- dog_id (FK)
- start_time
- end_time
- distance_km
- steps
- route_json

## ⚙️ 실행 방법

```bash
flutter pub get
flutter run
```

## 📌 개발 단계

Phase 1 (MVP)
인증 / 반려견 등록 / 산책 기록

Phase 2 (소셜)
랭킹 / 좋아요 / 팔로우

Phase 3 (위치 기반)
지도 / 주변 탐색 / 경로 추천

Phase 4 (폴리싱)
알림 / 통계 / 배포 준비

