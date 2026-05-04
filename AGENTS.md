# Agent Task Widget 更新ルール

Codex / Claude でユーザーから作業を依頼された場合は、作業状況を `/Users/seiya/AgentTasksWidget/tasks.yaml` に記録する。

## 必須動作

- 作業開始時に `tasks.yaml` へ自分のタスクを追加または更新し、`status: "running"` にする。
- 作業が詰まった場合は `status: "blocked"` にし、`summary` にブロック理由を書く。
- 作業完了時は `status: "done"` にし、`summary` に完了内容を1文で書く。
- 他の agent のタスク、または別件のタスクは削除・上書きしない。
- YAML 全体を書き換える場合でも、既存の未完了タスクを保持する。
- `updated` は更新時刻に合わせて更新する。

## YAML 形式

```yaml
updated: "YYYY-MM-DD HH:MM"
tasks:
  - agent: "codex"
    title: "依頼内容の短い名前"
    status: "running"
    summary: "現在状況を1文で書く"
    since: "HH:MM"
    url: ""
```

## 値のルール

- `agent`: `codex` または `claude`
- `status`: `running`, `blocked`, `done`, `queued` のいずれか
- `title`: ユーザー依頼の短い要約
- `summary`: widget に表示できる短い現在状況
- `since`: 作業開始時刻。分かる範囲で `HH:MM`
- `url`: 関連 URL がある場合だけ入れる。なければ空文字

## 運用メモ

`/Users/seiya/AgentTasksWidget/tasks.yaml` は常時表示 widget が数秒おきに読み込む。更新が反映されない場合は、YAML のインデントと引用符を確認する。
