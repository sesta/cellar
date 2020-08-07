# Cellar - お酒のログを記録、管理

[App Store](https://apps.apple.com/jp/app/id1523246897)


## 構成要素
| 要素 | 役割 |
| --- | --- |
| Flutter | アプリ本体の実装 |
| Firebase Authentication | ユーザーの認証 |
| Cloud Firestore | データベース |
| Firebase Storage | 画像の保存先 |
| Firebase Analytics | 分析用 |


### Flutter
要素の描画からDBの読み書きまで全てFlutterで記述。専用のバックエンドサーバーは存在しない。

ソースは `/fllutter/lib` に存在し、下記のようにディレクトリは分かれる
```
flutter/lib
├── app (表示のためのパーツを定義する部分。ページの定義もここ)
│   ├── pages
│   └── widget
├── domain （アプリ特有の振る舞いを記述。）
│   ├── entities
│   └── models
└── repository （外部リソースとの境界。ここのクラスからEntityを受け取ったり、Entityの更新をリソースに反映させたりする。）
    ├── analytics_repository.dart
    ├── auth_repository.dart
    ├── drink_repository.dart
    ├── user_repository.dart
    └── status_repository.dart
```


### Firebase Authentication
ユーザーの認証をまとめて担当。
現状ではGoogleとAppleの認証を採用している。


### Cloud Firestore
ユーザーや投稿の情報、環境ごとのステータスを保存している。
FirestoreはNoSQLなので、スキーマはFlutterのRepositoryが持っていると言える。

| コレクション（テーブル） | 内容 |
| --- | --- |
| status | アプリの状態を保持。メンテナンスのスイッチなども持っているので、ここの情報を書き換えればいつでもメンテナンス状態にできる。 |
| users | 登録したユーザーの情報。 |
| drinks | 投稿したお酒の情報を持つ。FirestoreはRDBのように連結ができないので、ユーザー名も冗長に保存している。 |


### Firebase Storage
Firestoreにpathだけ保存して、適宜Download URLを発行してクライアントで読み込むようにしている。
セキュリティのルールを設定しているため、アプリ内のFirebase Authenticationで認証を行なった人のみURLの発行が可能。


### Firebase Analytics
アプリ内の遷移やタップなどのデータの送信先。
送信されたデータはGoogle Analytisで閲覧可能で、BigQueryにも同期されるようにしている。

