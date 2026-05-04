# Claude 作業ルール

この端末で Claude がユーザーから作業を依頼された場合は、作業状況を常時表示 widget に反映するため、必ず `/Users/seiya/AgentTasksWidget/tasks.yaml` を更新する。

## Agent Tasks Widget

タスク状態ファイル:

```text
/Users/seiya/AgentTasksWidget/tasks.yaml
```

表示 widget:

```text
http://127.0.0.1:8765/
```

## 必須動作

- 作業開始時に `tasks.yaml` へ Claude のタスクを追加または更新し、`status: "running"` にする。
- 作業が詰まった場合は `status: "blocked"` にし、`summary` にブロック理由を書く。
- 作業完了時は `status: "done"` にし、`summary` に完了内容を1文で書く。
- 他の agent のタスク、または別件のタスクは削除・上書きしない。
- YAML 全体を書き換える場合でも、既存の未完了タスクを保持する。
- `updated` は更新時刻に合わせて更新する。

## YAML 形式

```yaml
updated: "YYYY-MM-DD HH:MM"
tasks:
  - agent: "claude"
    title: "依頼内容の短い名前"
    status: "running"
    summary: "現在状況を1文で書く"
    since: "HH:MM"
    url: ""
```

## 値のルール

- `agent`: Claude は必ず `claude` と書く。
- `status`: `running`, `blocked`, `done`, `queued` のいずれか。
- `title`: ユーザー依頼の短い要約。
- `summary`: widget に表示できる短い現在状況。
- `since`: 作業開始時刻。分かる範囲で `HH:MM`。
- `url`: 関連 URL がある場合だけ入れる。なければ空文字。

## 更新例

```yaml
updated: "2026-05-04 16:30"
tasks:
  - agent: "claude"
    title: "申請書ドラフト作成"
    status: "running"
    summary: "資料を確認しながら申請書の初稿を作成中です。"
    since: "16:30"
    url: ""
```

## 注意

`tasks.yaml` は常時表示 widget が数秒おきに読み込む。更新が反映されない場合は、YAML のインデント、引用符、`tasks:` 配下のリスト構造を確認する。

このルールは、作業内容がコード編集・文書作成・調査・ファイル整理のいずれであっても適用する。
