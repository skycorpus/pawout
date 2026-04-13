# 🐾 PawOut

PawOut은 반려견 산책 서비스를 목표로 하는 Flutter 기반 앱 프로젝트입니다.
산책 활동(걸음수, 거리, 시간)을 기록하고, 반려견 프로필과 소셜 기능을 통해 사용자 간 소통을 제공합니다.

## 🛠 기술 스택

| 영역 | 기술 |
|------|------|
| 언어 | Dart |
| 프레임워크 | Flutter |
| 백엔드 | Supabase (Auth, DB, Storage) |
| DB | PostgreSQL (via Supabase) |
| 상태관리 | Provider |
| 위치 | geolocator |
| 만보기 | pedometer |
| 이미지 | image_picker |
| 개발 도구 | VS Code, Android Studio, GitHub |

## 🎨 UI Reference

- iOS cute UI reference: [docs/references/pawout_ios_ui_v3_cute.html](docs/references/pawout_ios_ui_v3_cute.html)
- 포함 화면: `Home`, `Dog Profile`
  <img width="1440" height="1684" alt="image" src="https://github.com/user-attachments/assets/4fc51e2e-816e-44f8-b77c-330425d156b4" />


## 📌 아키텍처

```text
[Flutter 모바일 앱]
        |
        v
[Provider 상태관리]
(AuthProvider / DogProvider / WalkProvider /
 RankingProvider / LikesProvider / FollowsProvider)
        |
        v
[Supabase 직접 연동]
├── Auth (이메일 로그인)
├── PostgreSQL (DB)
└── Storage (이미지 업로드)
```

현재 구조는 `Screen -> Provider -> Supabase` 흐름입니다.
별도 Repository / Service 계층은 아직 본격적으로 분리되지 않았고, 주요 비즈니스 로직은 Provider에 위치합니다.

## 📌 개발 계획

Phase 1 (MVP) ⏳
인증 / 반려견 등록 / 산책 기록
현재 핵심 흐름은 동작하지만 상세/수정 UX 보완 필요

Phase 2 (소셜) ⏳
랭킹 / 좋아요 / 팔로우
핵심 기능은 동작하지만 안정화 및 화면 polish 여지 있음

Phase 3 (위치 기반)
지도 / 주변 탐색 / 경로 추천

Phase 4 (폴리싱)
알림 / 통계 / 배포 준비

## ⚠️ 참고 사항

- Supabase 설정값은 현재 코드에 직접 포함되어 있으며, 추후 환경변수 또는 별도 설정 파일로 분리하는 것이 안전합니다.
- README의 DB 설계는 목표 스키마 기준이며, 실제 화면 구현 상태와 100% 일치하지 않을 수 있습니다.
- 프로젝트에는 기본 위젯 테스트만 포함되어 있어, 주요 Provider와 화면 흐름에 대한 테스트 보강이 필요합니다.

## 🚀 현재 구현 상태

### ✅ 구현 완료
- 회원가입 / 로그인 (Supabase Auth)
- 반려견 프로필 등록 / 삭제
- 프로필 이미지 업로드 (Supabase Storage)
- 산책 시작 / 종료
- 실시간 걸음수 측정 (pedometer)
- 실시간 거리 추적 (GPS)
- 산책 기록 저장 및 조회
- 일일 랭킹 조회
- 좋아요 (낙관적 업데이트)
- 팔로우 / 언팔로우 (낙관적 업데이트)
- 팔로워 / 팔로잉 수 표시

### ⚠️ 부분 구현 / 보완 필요
- 반려견 수정 기능: Provider 로직은 있으나 전용 편집 화면과 사용자 플로우는 미완성
- 반려견 상세 화면: 라우트는 있으나 화면 구현은 placeholder 수준
- 산책 경로 좌표 저장: DB 저장은 하지만 지도 시각화 UI는 아직 없음
- 서비스 계층 분리 및 테스트 코드 보강 필요

### 🔲 Phase 3 — 위치 기반 (예정)
- 산책 경로 지도 표시
- 주변 산책 중인 강아지 보기
- 산책 경로 추천

### 🔲 Phase 4 — 폴리싱 (예정)
- 푸시 알림 (좋아요 / 팔로우)
- 주간 / 월간 통계
- 소셜 피드
- 배포 준비

## 📊 DB 설계

### profiles
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | Supabase Auth user id |
| name | text | 사용자 이름 |
| created_at | timestamptz | 가입일 |

### dogs
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 강아지 ID |
| user_id | uuid (FK) | 소유자 (profiles.id) |
| name | text | 강아지 이름 |
| breed | text | 견종 |
| age | int | 나이 |
| weight | numeric | 체중 (kg) |
| chip_number | text | 마이크로칩 번호 |
| profile_image_url | text | 프로필 이미지 URL |
| birth_date | date | 생년월일 |
| i_date | timestamptz | 등록일 |
| i_user | text | 등록자 |
| u_date | timestamptz | 수정일 |
| u_user | text | 수정자 |

### walks
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 산책 ID |
| dog_id | int8 (FK) | 강아지 (dogs.id) |
| start_time | timestamptz | 산책 시작 시간 |
| end_time | timestamptz | 산책 종료 시간 |
| distance_km | numeric | 거리 (km) |
| steps | int | 걸음수 |
| route_points | jsonb | GPS 경로 좌표 배열 |
| created_at | timestamptz | 기록 생성일 |

### daily_rankings
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 랭킹 ID |
| dog_id | int8 (FK) | 강아지 (dogs.id) |
| date | date | 날짜 |
| total_steps | int | 당일 누적 걸음수 |
| total_distance_km | numeric | 당일 누적 거리 (km) |

### likes
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 좋아요 ID |
| user_id | uuid (FK) | 좋아요 누른 사용자 |
| dog_id | int8 (FK) | 좋아요 받은 강아지 |
| created_at | timestamptz | 좋아요 일시 |

### follows
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 팔로우 ID |
| follower_id | uuid (FK) | 팔로우 하는 사용자 |
| following_id | uuid (FK) | 팔로우 받는 사용자 |
| created_at | timestamptz | 팔로우 일시 |

## ⚙️ 실행 방법

```bash
flutter pub get
flutter run
```

