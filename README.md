## 개요

몰락실은 ‘몰입오락실’의 줄임말으로, 몰입캠프 사람들과 다양한 게임들을 즐기고 순위를 매기며 최고 점수를 경쟁할 수 있는 앱입니다. 

## 팀원

- **한종국**

[jkookhan03 - Overview](https://github.com/jkookhan03)

- **정다영**

[Dayoung331 - Overview](https://github.com/Dayoung331)

## Tech Stack

**Front-end** : Flutter

**IDE** : Android Studio

**Server** : KCloud

**Back-end** : Nodejs

**DB** : MySQL

**SDK** : 네이버 로그인

## About

## 앱 첫 실행 시 로그인

**네이버 로그인 기능**

`LoginState` 클래스는 네이버 로그인 기능을 제공하며, 로그인 상태를 관리합니다. `flutter_naver_login` 패키지를 사용하여 네이버 계정으로 로그인을 수행합니다. 사용자가 로그인에 성공하면, `NaverAccessToken`과 `NaverAccountResult`를 통해 액세스 토큰과 사용자 정보를 가져옵니다. 로그인 성공 시, 사용자 정보를 서버에 전달하여 인증을 수행하고, `SharedPreferences`에 사용자 정보를 저장하여 자동 로그인을 지원합니다.

## Tab 1: 게임 플레이

### 방 목록
<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/b95abeb9-90ca-45f6-8953-8db349a7dfca" width="300px">

- + 버튼을 눌러 방을 추가할 수 있습니다.

<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/972d5c70-edc9-4274-9dca-5ac6d868101e" width="300px">

- 방장이 게임 종류와 시간을 선택하고 참가자들이 전부 준비되면 ‘게임 시작’ 버튼이 활성화됩니다.
- 3초 카운트다운 후 모든 참가자들의 화면에서 동시에 게임이 시작됩니다.

<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/22cd2861-a11f-4bf6-b3b2-bfa00fc60b68" width="300px">

- 방장이 참가자 옆의 아이콘을 선택하면 방장 권한을 넘겨줄 수 있고, ‘게임 시작’ 버튼 대신 ‘준비’와 ‘준비 해제’ 버튼이 나타납니다.

### Game 1 : YaOng



제한 시간 내에 클릭을 더 많이 하자

### Game 2 : Balloon Game

<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/f8d74771-e6a0-46bd-ba05-f6fbdae50ab9" width="300px">


글자 색깔에 속지 말고 글자가 의미하는 올바른 색깔의 풍선을 터뜨리자

### Game 3 : Star Game

<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/8dd41e7e-cc37-4009-b3ad-4efac6b6866a" width="300px">


폭탄을 피해 별을 먹자

### 게임 종료
<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/6ebb09c8-2e4f-4849-bf76-d0620caa74bb" width="300px">

<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/77eb6699-9493-42d3-86c7-b7ba7f2cf4ac" width="300px">

<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/987df374-fa1a-4e0e-b678-3c572347cc94" width="300px">


- 제한 시간 후에 같은 방 참가자들의 점수가 오름차순으로 정렬됩니다.
- ‘로비로 나가기’ 버튼을 누르면 방을 나가 방 목록 화면으로 돌아가고, ‘게임 다시하기’ 버튼을 누르면 원래 있던 대기방으로 돌아가 같이 게임을 했던 참가자들과 다시 게임을 할 수 있습니다.

## Tab 2: 유저 화면

### **유저 스크린**

<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/83e86588-ea06-48ce-8e5f-48184d8466cd" width="300px">

`User_Screen`은 사용자의 프로필 정보를 보여주고, 사용자의 게임 최고 점수를 확인할 수 있는 화면입니다. 이 화면은 사용자의 로그인 상태, 프로필 이미지, 이름, 최고 점수를 포함하며, 게임 시간에 따라 최고 점수를 필터링하여 보여줍니다. 또한, 로그아웃 기능도 제공합니다.

사용자가 네이버 계정으로 로그인하면, 사용자의 `userId`, `userName`, `profileImageUrl`과 같은 정보를 가져오고, 이를 서버로 전송하여 로그인 상태를 확인합니다. 서버에서 로그인 성공 응답을 받으면, `SharedPreferences`에 사용자 정보를 저장하고, 상태를 업데이트하여 사용자 인터페이스에 반영합니다.

`logout` 메서드는 사용자가 로그아웃할 때 호출되며, 네이버 로그인 상태를 해제하고  `SharedPreferences`에 저장된 사용자 정보를 제거하여 완전히 로그아웃 상태로 만듭니다.

**개인 최고기록 불러오기 : fetchHighScores**

`fetchHighScores` 메서드는 사용자의 최고 점수를 서버로부터 가져와서 `_highScores` 리스트에 저장하는 기능을 합니다. 이 메서드는 HTTP GET 요청을 통해 데이터를 받아오고, 상태 변화를 알리기 위해 `notifyListeners()`를 호출합니다.

## Tab 3: 랭킹 화면

- 게임과 게임 시간을 선택하면 모든 참가자들의 최고 기록을 집계해서 랭킹을 표시해줍니다.
- 
    <img src="https://github.com/jkookhan03/mad_week2/assets/110375535/2e9903b6-490e-4c53-a73d-c37ad3ee80ff" width="300px">

    

**랭킹 데이터 불러오기: fetchRankings**

`fetchRankings` 메서드는 서버로부터 전체 랭킹 데이터를 가져와 `_rankings` 리스트에 저장하는 기능을 합니다. 이 메서드는 HTTP GET 요청을 통해 데이터를 받아오고, 상태 변화를 알리기 위해 `notifyListeners()`를 호출합니다.

## API 명세서

### 서버 기본 정보

- 기본 URL: `http://172.10.7.88`
- 포트: 80

### 공통 응답 코드

- **200**: 성공
- **201**: 생성됨
- **400**: 잘못된 요청
- **403**: 접근 금지
- **404**: 찾을 수 없음
- **500**: 서버 오류

### 몰락실 API 명세서
| 기능 | HTTP method | API path | Request | Response |
| --- | --- | --- | --- | --- |
| 로그인 | POST | /login | { "userId": "string", "userName": "string" } | { "status": "loggedIn" \| "registered", "userId": "string", "userName": "string" } |
| 방 생성 | POST | /api/rooms | { "roomName": "string", "userId": "string", "userName": "string", "password": "string" (optional) } | { "status": "Room created", "roomId": "integer", "roomName": "string" } |
| 방 참가 | POST | /api/rooms/:id/join | { "userId": "string", "userName": "string", "password": "string" (optional) } | { "status": "User joined", "roomId": "integer", "userId": "string", "userName": "string", "isLeader": "boolean" } |
| 준비 상태 업데이트 | POST | /api/rooms/:id/ready | { "userId": "string", "isReady": "boolean" } | { "status": "Ready state updated", "userId": "string", "isReady": "boolean" } |
| 방장 권한 넘기기 | POST | /api/rooms/:id/transfer-leadership | { "currentLeaderId": "string", "newLeaderId": "string" } | { "status": "Leadership transferred", "newLeaderId": "string" } |
| 방 목록 조회 | GET | /api/rooms |  | [ { "id": "integer", "roomName": "string", "password": "string" } ] |
| 방 삭제 | DELETE | /api/rooms/:id |  | { "status": "Room deleted" } |
| 방 참가자 목록 조회 | GET | /api/rooms/:id/participants |  | [ { "userId": "string", "userName": "string", "isLeader": "boolean", "isReady": "boolean" } ] |
| 방 나가기 | POST | /api/rooms/:id/leave | { "userId": "string" } | { "status": "Participant left", "roomId": "integer", "userId": "string" } |
| 게임 시작 | POST | /api/rooms/:id/start-game |  | { "status": "Game started" } |
| 점수 저장 | POST | /api/rooms/:id/score | { "userId": "string", "score": "integer", "gameName": "string", "duration": "integer" } | { "status": "Score and high score updated" \| "Score updated, high score remains the same" \| "Score and new high score inserted" } |
| 점수 조회 | GET | /api/rooms/:id/scores |  | [ { "userName": "string", "score": "integer", "gameName": "string", "duration": "integer" } ] |
| 최고 점수 조회 | GET | /users/:userId/high-scores |  | [ { "gameName": "string", "duration": "integer", "highScore": "integer" } ] |
| 게임 설정 저장 | POST | /api/rooms/:id/settings | { "game": "string", "duration": "integer" } | { "status": "Game settings updated", "game": "string", "duration": "integer" } |
| 게임 설정 조회 | GET | /api/rooms/:id/settings |  | { "game": "string", "duration": "integer" } |

## DB 구조 설명
<img src="https://github.com/jkookhan03/mad_week2/assets/110375535/f679a2e1-2557-4de6-94bf-4373a78c84eb" width="300px">

### 1. `users` 테이블

- 사용자 정보를 저장합니다.
    - `id`: 자동 증가하는 고유 번호 (Primary Key).
    - `userId`: 사용자의 고유 ID (유일함).
    - `userName`: 사용자의 이름.
    - `createdAt`: 사용자가 생성된 날짜와 시간.

### 2. `rooms` 테이블

- 게임 방 정보를 저장합니다.
    - `id`: 자동 증가하는 고유 번호 (Primary Key).
    - `roomName`: 방의 이름.
    - `password`: 방의 비밀번호 (선택 사항).
    - `createdAt`: 방이 생성된 날짜와 시간.
    - `game`: 게임의 종류, 기본값은 'tab_game'.
    - `duration`: 게임 시간, 기본값은 20분.

### 3. `participants` 테이블

- 방에 참가한 사용자 정보를 저장합니다.
    - `id`: 자동 증가하는 고유 번호 (Primary Key).
    - `userId`: 사용자의 고유 ID (`users` 테이블을 참조).
    - `roomId`: 방의 고유 ID (`rooms` 테이블을 참조).
    - `userName`: 참가자의 이름.
    - `isLeader`: 방장 여부.
    - `isReady`: 준비 상태 여부.
    - `joinedAt`: 방에 참가한 날짜와 시간.

### 4. `scores` 테이블

- 각 방에서 사용자의 게임 점수를 저장합니다.
    - `id`: 자동 증가하는 고유 번호 (Primary Key).
    - `roomId`: 방의 고유 ID (`rooms` 테이블을 참조).
    - `userId`: 사용자의 고유 ID (`users` 테이블을 참조).
    - `score`: 게임 점수.
    - `gameName`: 게임의 이름.
    - `duration`: 게임 시간.
    - `createdAt`: 점수가 기록된 날짜와 시간.

### 5. `user_high_scores` 테이블

- 각 사용자별로 게임의 최고 점수를 저장합니다.
    - `id`: 자동 증가하는 고유 번호 (Primary Key).
    - `userId`: 사용자의 고유 ID (`users` 테이블을 참조).
    - `gameName`: 게임의 이름.
    - `duration`: 게임 시간.
    - `highScore`: 최고 점수.
    - `createdAt`: 기록이 생성된 날짜와 시간.

### 6. `game_defaults` 테이블

- 게임의 기본 종류와 시간을 저장합니다.
    - `gameName`: 게임의 이름.
    - `duration`: 게임 시간.

## APK Link

https://drive.google.com/file/d/1UZ3D7byjoUTGjb9ITOkn3OVn6-W0nYoS/view?usp=sharing
