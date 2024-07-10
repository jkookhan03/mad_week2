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

![방 목록](https://github.com/jkookhan03/mad_week2/assets/110375535/ca7ec44c-d081-4508-a5d0-4a1dd09e9b06)


- + 버튼을 눌러 방을 추가할 수 있습니다.

![1000016932.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/444ba12b-226e-4ab2-bd88-9482bb7e3c13/1000016932.gif)

- 방장이 게임 종류와 시간을 선택하고 참가자들이 전부 준비되면 ‘게임 시작’ 버튼이 활성화됩니다.
- 3초 카운트다운 후 모든 참가자들의 화면에서 동시에 게임이 시작됩니다.

![1000016941.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/ca12d453-6074-4cfe-90b9-80b28d7e1a31/1000016941.gif)

- 방장이 참가자 옆의 아이콘을 선택하면 방장 권한을 넘겨줄 수 있고, ‘게임 시작’ 버튼 대신 ‘준비’와 ‘준비 해제’ 버튼이 나타납니다.

### Game 1 : YaOng

![1000016935.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/8fa81a59-8ce2-449d-adee-893ed4a6d642/1000016935.gif)

제한 시간 내에 클릭을 더 많이 하자

### Game 2 : Balloon Game

![1000016937.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/831ccb3f-cba0-42e0-a50c-edeba90d4ca4/1000016937.gif)

글자 색깔에 속지 말고 글자가 의미하는 올바른 색깔의 풍선을 터뜨리자

### Game 3 : Star Game

![1000016939.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/db6577de-416c-4dac-8151-25d18c9700de/1000016939.gif)

폭탄을 피해 별을 먹자

### 게임 종료

![1000016944.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/3d63f23a-9680-4bf8-8e4e-24f7428825b8/1000016944.jpg)

![1000016943.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/83f03aea-599a-4e6b-8005-559f44379f3e/1000016943.jpg)

![1000016942.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/510d3516-b9c4-458d-b07e-7c60a8b11961/1000016942.jpg)

- 제한 시간 후에 같은 방 참가자들의 점수가 오름차순으로 정렬됩니다.
- ‘로비로 나가기’ 버튼을 누르면 방을 나가 방 목록 화면으로 돌아가고, ‘게임 다시하기’ 버튼을 누르면 원래 있던 대기방으로 돌아가 같이 게임을 했던 참가자들과 다시 게임을 할 수 있습니다.

## Tab 2: 유저 화면

### **유저 스크린**

![1000016949.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/472a8471-eaf5-4846-a02b-fb93b175f34c/1000016949.gif)

`User_Screen`은 사용자의 프로필 정보를 보여주고, 사용자의 게임 최고 점수를 확인할 수 있는 화면입니다. 이 화면은 사용자의 로그인 상태, 프로필 이미지, 이름, 최고 점수를 포함하며, 게임 시간에 따라 최고 점수를 필터링하여 보여줍니다. 또한, 로그아웃 기능도 제공합니다.

사용자가 네이버 계정으로 로그인하면, 사용자의 `userId`, `userName`, `profileImageUrl`과 같은 정보를 가져오고, 이를 서버로 전송하여 로그인 상태를 확인합니다. 서버에서 로그인 성공 응답을 받으면, `SharedPreferences`에 사용자 정보를 저장하고, 상태를 업데이트하여 사용자 인터페이스에 반영합니다.

`logout` 메서드는 사용자가 로그아웃할 때 호출되며, 네이버 로그인 상태를 해제하고  `SharedPreferences`에 저장된 사용자 정보를 제거하여 완전히 로그아웃 상태로 만듭니다.

**개인 최고기록 불러오기 : fetchHighScores**

`fetchHighScores` 메서드는 사용자의 최고 점수를 서버로부터 가져와서 `_highScores` 리스트에 저장하는 기능을 합니다. 이 메서드는 HTTP GET 요청을 통해 데이터를 받아오고, 상태 변화를 알리기 위해 `notifyListeners()`를 호출합니다.

## Tab 3: 랭킹 화면

- 게임과 게임 시간을 선택하면 모든 참가자들의 최고 기록을 집계해서 랭킹을 표시해줍니다.
    
    ![1000016947.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/09c90b8f-4390-468a-b892-6e1c58184474/1000016947.gif)
    

**랭킹 데이터 불러오기: fetchRankings**

`fetchRankings` 메서드는 서버로부터 전체 랭킹 데이터를 가져와 `_rankings` 리스트에 저장하는 기능을 합니다. 이 메서드는 HTTP GET 요청을 통해 데이터를 받아오고, 상태 변화를 알리기 위해 `notifyListeners()`를 호출합니다.

## DB 구조 설명
![Mad_week2_DB](https://github.com/jkookhan03/mad_week2/assets/121784739/831ab64a-834c-4cd7-abaf-c1cae4b43249)

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
