# 検証結果

実施日：2026-09-17。Godot 4.5.1 stable、Windows、Compatibility / OpenGL、WebはCodex内蔵Chromiumで検証。

## 完了した確認

- Godot Editorによる全リソースのimportとスクリプト解析：エラーなし。
- `tests/test_game.gd`：27チェックすべて成功。最終実行で警告・エラーなし。
- タイトルからのEnter開始、開始キーが横取りに流れないこと。
- 通常Enter・テンキーEnterのInput Map、実際のInputEventによる加点。
- キーecho・長押しの無効化、0.20秒の成功後ロック、同じチャンスの重複加点防止。
- PHONE / TALKINGの安全時間、吹き出し同期、+100 / バナナ込み+400、バナナ消費。
- WORKING・安全時間切れ・成功後の新しい誤入力での発見。
- 発見演出からGAME_OVER、NEW RECORD表示、Enter再挑戦、ランの初期化。
- `user://`から別のHighScoreManagerへ記録の再読み込み。
- 難易度の安全時間下限・速度上昇、乱数によるイベント種類・待ち時間・バナナ出現。
- Windowsの実描画でタイトル・ゲーム・バナナ演出・結果画面を取得し、配置と日本語を確認。
- WebおよびWindows DesktopのRelease Export成功。
- 出力したWindows EXEのheadless起動と正常終了。
- 実際に書き出したWeb版をHTTPで起動。マウスを使わずEnterで開始、仕事+100、失敗、GAME OVER、再挑戦を確認。
- Web版で獲得したHIGH 000100がページ再読み込み後も保持されることを画面で確認。
- Webブラウザのconsoleにエラー・警告なし。

## 検証範囲の限界

- SEは5種の音源とAudioStreamPlayerを実装し、再生処理とブラウザのエラー不在を確認。スピーカーからの実際の聴感確認は未実施。
- Safari / Firefox、モバイルブラウザでの実機確認は未実施。物理EnterキーがあるPCブラウザ向け。
- 公開ホスティングへのアップロードは未実施。

ログ：`test-results.log`、`import.log`、`capture.log`、`export-web.log`、`export-windows.log`、`windows-smoke.log`。
画像：`title.png`、`gameplay.png`、`banana.png`、`gameover.png`。

## 追加ルールの再検証

短いチャンスの2〜4回間隔、65%の安全時間、10,000点境界、ハイパーの待機・イベント時間半減、見逃しの一度だけの加算、成功時非加算、累計5回の退職、結果画面への理由伝達、再挑戦時リセット、得点に応じた書類数を検証。最新実行は全チェック成功。Web / WindowsのReleaseを再Exportし、hyper.pngとquit.pngで表示を確認。
