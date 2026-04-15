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
- 라이브 미리보기(v13): [https://skycorpus.github.io/pawout/references/pawout_v13.html](https://skycorpus.github.io/pawout/references/pawout_v13.html)
- 현재 기준 소스(v13): [docs/references/pawout_v13.html](docs/references/pawout_v13.html)
- 포함 화면: `Splash`,`Home`, `Dog Profile`
- GitHub Pages 설정: `Settings > Pages > Build and deployment > Source` 에서 `Deploy from a branch`, 브랜치는 `main`, 폴더는 `/docs`
  <img width="1328" height="937" alt="pawout_preview" src="https://github.com/user-attachments/assets/e35a64df-aab3-4937-93cf-6e106b54e534" />

## 📌 아키텍처

```text
[Flutter 모바일 앱]
        |
        v
[Provider 상태관리]
(AuthProvider / DogProvider / WalkProvider /
 RankingProvider / LikesProvider / FollowsProvider / CommonCodeProvider)
        |
        v
[Repository 계층]
(각 feature별 Repository — Supabase 쿼리 캡슐화)
        |
        v
[Supabase 직접 연동]
├── Auth (이메일 로그인)
├── PostgreSQL (DB)
└── Storage (이미지 업로드)
```

구조는 `Screen → Provider → Repository → Supabase` 흐름입니다.
각 feature 폴더에 `models / providers / repositories / screens` 레이어가 분리되어 있습니다.

## 📌 개발 계획

Phase 1 (MVP) ✅
인증 / 반려견 등록 / 산책 기록 — 핵심 흐름 완료

Phase 2 (소셜) ✅
랭킹 / 좋아요 / 팔로우 — 낙관적 업데이트 포함 완료

Phase 3 (위치 기반) 🔲
지도 / 주변 탐색 / 경로 추천

Phase 4 (폴리싱) 🔲
알림 / 통계 / 배포 준비

## 📋 개발 진행 히스토리

### Phase 1 — MVP ✅
- 회원가입 / 로그인 / 로그아웃 (Supabase Auth)
- 반려견 프로필 등록 / 수정 / 삭제 + 이미지 업로드 (Supabase Storage)
- 산책 기록 저장 (걸음수, 거리, 시간, GPS 좌표)
- 산책 이력 조회 / 상세 화면
- 하루 목표 걸음수 설정 (SharedPreferences)
- Splash → Login → Home 기본 라우팅

### Phase 2 — 소셜 ✅
- 일간 / 주간 / 월간 랭킹 (daily_rankings 기반 집계, 내 순위 강조)
- 좋아요 / 팔로우 (낙관적 업데이트)
- 팔로워 / 팔로잉 수 표시
- 알림 탭 — 좋아요 / 팔로우 수신 목록
- 커뮤니티 피드 — 홈 탭에서 다른 유저 산책 카드 표시
- 멀티 강아지 산책 (여러 마리 선택, 마지막 선택 기억, 1마리 자동 선택)
- 연속 산책 streak 계산 및 결과 화면 / 홈 히어로 카드 표시
- 가족 계정 초대 코드 생성 / 공유 / 입력 (dog_members, dog_invites)

### Phase 3 — 인증 강화 ✅
- 이메일 인증 절차 (커스텀 SMTP 연동, 재발송 지원)
- 미인증 계정 차단 — Splash / Login 단 `emailConfirmedAt` 체크 후 `/email-verify` redirect
- 비밀번호 재설정 화면 (`/forgot-password`) — 링크 발송 → 완료 상태 전환
- 환경변수 분리 — Supabase URL / Anon Key / Naver Maps Client ID를 `.dart_defines.json`으로 관리 (gitignore)

### Phase 4 — 지도 연동 ✅
- Google Maps → Naver Maps 전환 (`flutter_naver_map`)
- 산책 진행 중 실시간 경로 지도 (GPS 포인트마다 polyline 업데이트, 카메라 자동 이동)
- 산책 결과 화면 경로 지도 (출발 / 도착 마커 + 전체 경로 fit)
- 산책 상세 화면 경로 지도 (저장된 route_points 시각화)
- API 키 보호 — AndroidManifest manifest placeholder + build.gradle.kts dart-defines 주입

### Phase 5 — 프로필 강화 ✅
- 동물등록번호 15자리 형식 검증 (등록 / 수정 화면 공통)
- 동물등록번호 마스킹 표시 (앞 4자리, `*******`, 뒤 4자리)
- 뱃지 시스템 9종 — 첫 산책 / 10·50회 / 10·50km / 만·십만 걸음 / 7·30일 연속
  - 기존 산책 데이터 기반 클라이언트 계산 (DB 추가 없음)
  - 강아지 상세 화면에서 획득 / 미획득 상태 시각화

### Phase 6 — 푸시 알림 🔲
- FCM 기반 좋아요 / 팔로우 알림 (Firebase + Supabase Edge Function)

## ⚠️ 참고 사항

- Supabase URL / Anon Key / Naver Maps Client ID는 `.dart_defines.json`으로 분리 관리하며 git에 포함되지 않습니다. `.dart_defines.json.example`을 참고해 로컬 파일을 생성하세요.
- 실행 시 반드시 `--dart-define-from-file=.dart_defines.json` 옵션을 사용해야 합니다. VS Code에서는 F5 실행 시 자동 적용됩니다.
- README의 DB 설계는 `supabase/migrations/001_schema.sql`, `002_rls.sql` 기준으로 정리합니다.
- 프로젝트에는 기본 위젯 테스트만 포함되어 있어, 주요 Provider와 화면 흐름에 대한 테스트 보강이 필요합니다.

## 🚀 현재 구현 상태

### 상세 기능 로드맵

#### 1단계. 산책 핵심 로직 보완
- 산책 진행 중 화면 강화: 실시간 걸음수, 실시간 거리, 실시간 산책 시간, 현재 상태(진행 중 / 일시정지) 표시
- 자동 일시정지: 일정 시간 이상 움직임이 없으면 자동 pause, 다시 움직이면 자동 resume
- 최소 기록 조건: 100m 이하 또는 1분 이하 산책은 저장 제외
- 백그라운드 산책 추적: 앱이 백그라운드로 가거나 화면이 꺼져도 시간/거리/걸음수 누적
- 산책 종료 결과 화면: 총 걸음수, 총 거리, 총 시간, 목표 달성 여부, 피드백 문구 제공

#### 2단계. 반려견 프로필 기능 강화
- 프로필 수정 화면 완성: 이름, 견종, 생년월일, 성별, 체중, 프로필 이미지, 칩번호 수정
- 프로필 통계 추가: 총 산책 횟수, 누적 걸음수, 누적 거리, 평균 산책 시간, 최근 7일 활동량
- 칩번호 검증: 15자리 형식 체크, 중복 등록 방지, 화면 표시 시 마스킹 처리 고려
- 건강 정보 추가: 중성화 여부, 예방접종 상태, 몸무게 기록, 마지막 병원 방문일

#### 3단계. 랭킹 기능 고도화
- 기간별 랭킹: 일간, 주간, 월간 랭킹
- 랭킹 기준 다양화: 걸음수, 거리, 산책 시간 랭킹
- 점수 기반 랭킹: 걸음수 + 거리 + 시간 가중치 기반 종합 점수 도입
- 내 순위 강조: 내 강아지 현재 순위, 전일 대비 상승/하락 표시

#### 4단계. 소셜 기능 보완
- 활동 피드 추가: 산책 인증 카드 형태의 활동 피드 구성
- 댓글 기능: 활동 피드에 1단 댓글 작성 지원
- 좋아요/팔로우 알림: 좋아요 수신, 신규 팔로우 발생 시 알림 제공
- 공개/비공개 범위 설정: 프로필, 활동 피드, 랭킹 노출 여부 제어

#### 5단계. 위치 기반 기능 추가
- 산책 경로 지도 표시: 저장된 `route_points`를 지도 polyline으로 표시
- 주변 산책 중인 강아지 보기: 거리 기준 필터와 함께 근처 사용자 표시
- 인기 산책 코스 추천: 자주 이용된 경로 기반 추천
- 현재 위치 기반 시작 추천: 주변 공원/코스와 함께 산책 시작 제안

#### 6단계. UX / 서비스 디테일 강화
- 목표 설정 기능: 하루 목표 걸음수, 하루 목표 거리
- 연속 산책 streak: 3일, 7일, 30일 연속 산책 추적
- 뱃지 시스템: 첫 산책, 누적 10km, 7일 연속 산책, 월간 랭킹 진입 등 보상 요소 추가
- 빈 화면 처리: 강아지 미등록, 산책 기록 없음, 좋아요/팔로우 없음 상태에 대한 안내 강화
- 에러/로딩 처리: 저장 중 로딩, 재시도 버튼, 네트워크 실패 안내 보완

#### 7단계. 보안 / 운영 보완
- Supabase RLS 적용: 본인 데이터만 수정 가능, 공개 데이터만 조회 가능하도록 정책 정리
- 이미지 업로드 제한: 파일 크기 제한, 확장자 제한, 기본 프로필 이미지 제공
- 환경설정 분리: Supabase URL / anon key 분리, 개발/배포 설정 구분
- 데이터 검증 강화: null 체크, 날짜/숫자 형식 체크, 잘못된 거리/걸음수 저장 방지
- 이메일 인증 절차: 회원가입 시 이메일 인증 링크 발송, 미인증 계정 기능 제한, 커스텀 SMTP 서버 연동 (Supabase SMTP 설정)

### 추천 개발 순서
- 우선순위 1: 산책 진행 중 화면, 자동 일시정지, 산책 종료 결과 화면
- 우선순위 2: 반려견 프로필 수정, 프로필 통계, 기간별 랭킹
- 우선순위 3: 활동 피드, 알림, 지도 기반 경로 표시
- 우선순위 4: streak, 뱃지, 추천 코스, 배포 준비

### ✅ 구현 완료
- 회원가입 / 로그인 / 이메일 인증 / 비밀번호 재설정 (Supabase Auth + 커스텀 SMTP)
- 반려견 프로필 등록 / 수정 / 삭제 + 이미지 업로드
- 동물등록번호 15자리 검증 및 마스킹 표시
- 가족 계정 초대 코드로 강아지 공동 관리
- 멀티 강아지 산책 (여러 마리 선택, 마지막 선택 기억)
- 산책 진행 중 실시간 걸음수 / 거리 / 시간 + 네이버 지도 실시간 경로
- 산책 종료 결과 화면 (걸음수 / 거리 / 시간 / streak / 경로 지도)
- 산책 기록 저장 및 이력 조회 (walk_dogs 링크 테이블)
- 일간 / 주간 / 월간 랭킹 (내 순위 강조)
- 좋아요 / 팔로우 (낙관적 업데이트)
- 알림 탭 (좋아요 / 팔로우 수신)
- 커뮤니티 피드 (홈 탭)
- 목표 걸음수 설정 (SharedPreferences)
- 연속 산책 streak
- 뱃지 시스템 9종

### 🔲 예정
- 푸시 알림 (FCM — Firebase + Supabase Edge Function)
- 백그라운드 산책 추적
- 배포 준비

## 📊 DB 설계

현재 DB는 단일 강아지 산책 구조에서 확장되어, 멀티 강아지 산책과 가족 계정 공유를 함께 지원하는 형태입니다.

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
| user_id | uuid (FK) | 기본 소유자 (`auth.users.id`) |
| name | text | 강아지 이름 |
| breed | text | 견종 코드 (common_codes.code) |
| birth_date | date | 생년월일 (나이는 앱에서 계산) |
| gender | text | 성별 ('male' / 'female') |
| weight | numeric | 체중 (kg) |
| is_neutered | boolean | 중성화 여부 |
| chip_number | text | 동물등록번호 (15자리) |
| profile_image_url | text | 프로필 이미지 URL |
| i_date | timestamptz | 등록일 |
| i_user | text | 등록자 |
| u_date | timestamptz | 수정일 |
| u_user | text | 수정자 |

제약/인덱스
- `gender in ('male', 'female')`
- `idx_dogs_user`

### common_codes
| 컬럼 | 타입 | 설명 |
|------|------|------|
| group_code | text | 코드 그룹 (예: 'BREED') |
| code | text | 코드값 (예: 'POODLE') |
| code_name | text | 표시명 (예: '푸들') |
| sort_order | int | 정렬 순서 |

제약
- PK: `(group_code, code)`

### walks
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 산책 ID |
| dog_id | int8 (FK) | 대표 강아지 (`dogs.id`) |
| start_time | timestamptz | 산책 시작 시간 |
| end_time | timestamptz | 산책 종료 시간 |
| distance_km | numeric | 거리 (km) |
| steps | int | 걸음수 |
| route_points | jsonb | GPS 경로 좌표 배열 |
| created_at | timestamptz | 기록 생성일 |

제약/인덱스
- `idx_walks_dog`
- 멀티 강아지 참여 정보는 `walk_dogs`에서 별도 관리

### walk_dogs
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 연결 ID |
| walk_id | int8 (FK) | 산책 세션 (`walks.id`) |
| dog_id | int8 (FK) | 참여 강아지 (`dogs.id`) |
| allocated_steps | int | 강아지별 배분 걸음 수 |
| allocated_distance_km | numeric | 강아지별 배분 거리 |
| display_order | int | 선택 순서 |
| created_at | timestamptz | 생성 시각 |

제약/인덱스
- Unique: `(walk_id, dog_id)`
- `idx_walk_dogs_walk`, `idx_walk_dogs_dog`

### daily_rankings
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 랭킹 ID |
| dog_id | int8 (FK) | 강아지 (dogs.id) |
| date | date | 날짜 |
| total_steps | int | 당일 누적 걸음수 |
| total_distance_km | numeric | 당일 누적 거리 (km) |

제약/인덱스
- Unique: `(dog_id, date)`
- `idx_daily_rankings_date`

### likes
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 좋아요 ID |
| user_id | uuid (FK) | 좋아요 누른 사용자 |
| dog_id | int8 (FK) | 좋아요 받은 강아지 |
| created_at | timestamptz | 좋아요 일시 |

제약/인덱스
- Unique: `(user_id, dog_id)`
- `idx_likes_dog`

### follows
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 팔로우 ID |
| follower_id | uuid (FK) | 팔로우 하는 사용자 |
| following_id | uuid (FK) | 팔로우 받는 사용자 |
| created_at | timestamptz | 팔로우 일시 |

제약/인덱스
- Unique: `(follower_id, following_id)`
- `follower_id <> following_id`
- `idx_follows_follower`, `idx_follows_following`

### dog_members
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 연결 ID |
| dog_id | int8 (FK) | 강아지 (`dogs.id`) |
| user_id | uuid (FK) | 사용자 (`auth.users.id`) |
| role | text | 권한 역할 (`owner`, `family`) |
| is_primary | boolean | 대표 멤버 여부 |
| joined_at | timestamptz | 참여 시각 |
| invited_by | uuid (FK) | 초대한 사용자 |

제약/인덱스
- Unique: `(dog_id, user_id)`
- `role in ('owner', 'family')`
- `idx_dog_members_dog`, `idx_dog_members_user`

### dog_invites
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | int8 (PK) | 초대 ID |
| dog_id | int8 (FK) | 초대 대상 강아지 (`dogs.id`) |
| invite_code | text | 가족 초대 코드 |
| created_by | uuid (FK) | 초대 생성 사용자 |
| expires_at | timestamptz | 만료 시각 |
| used_by | uuid (FK) | 코드 사용 사용자 |
| used_at | timestamptz | 사용 시각 |
| created_at | timestamptz | 생성 시각 |

제약/인덱스
- Unique: `invite_code`
- `expires_at` 기본값: `now() + interval '7 days'`
- `idx_dog_invites_code`, `idx_dog_invites_dog`

### RLS 요약
- `profiles`, `likes`, `follows`, `daily_rankings`는 인증 사용자 기준 읽기 허용 정책이 설정되어 있습니다.
- `walks`는 완료된 산책은 조회 가능하고, 진행 중 산책은 소유 강아지 기준으로만 조회됩니다.
- `dog_members`, `dog_invites`는 멤버십 기반 접근 정책을 사용합니다.
- 세부 정책은 [`supabase/migrations/002_rls.sql`](supabase/migrations/002_rls.sql) 기준입니다.

## ⚙️ 실행 방법

```bash
# 1. 환경 파일 준비
cp .dart_defines.json.example .dart_defines.json
# .dart_defines.json에 실제 키 입력 후 저장

# 2. 패키지 설치
flutter pub get

# 3. 실행
flutter run --dart-define-from-file=.dart_defines.json
```

