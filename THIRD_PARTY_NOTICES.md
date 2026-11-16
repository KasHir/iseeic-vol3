# 第三者資料の出典とライセンス

リポジトリの自作部分には MIT License を適用します．次の第三者部分の権利・表示はそのまま維持します．第三者の標準セル形状を MIT へ変更するものではありません．

## SKY130 HD 標準セル

Copyright 2020 The SkyWater PDK Authors

Apache License, Version 2.0．本文は [LICENSES/Apache-2.0.txt](LICENSES/Apache-2.0.txt) に収録しています．

- 対象：`eda/archive/my_cpu4/experiment-gds-BTk6iY3e/runs/implementation/final/gds/my_cpu4.gds` に含まれる `sky130_fd_sc_hd__*`／`sky130_ef_sc_hd__*` のセル形状と，`docs/images/` のレイアウト表示画像．
- 標準セルの出典：[SkyWater HD ライブラリ](https://github.com/google/skywater-pdk-libs-sky130_fd_sc_hd)，[open_pdks が参照する FOSSi の配布元](https://github.com/fossi-foundation/skywater-pdk-libs-sky130_fd_sc_hd)．[ライセンス原文](https://github.com/fossi-foundation/skywater-pdk-libs-sky130_fd_sc_hd/blob/main/LICENSE)．
- 生成・調整の出典：[open_pdks](https://github.com/RTimothyEdwards/open_pdks/tree/d400e26845538beaeb7cc5fdb9bfc06c30ea27cb)，[同版の LICENSE](https://github.com/RTimothyEdwards/open_pdks/blob/d400e26845538beaeb7cc5fdb9bfc06c30ea27cb/LICENSE)，[HD セルの生成規則](https://github.com/RTimothyEdwards/open_pdks/blob/d400e26845538beaeb7cc5fdb9bfc06c30ea27cb/sky130/Makefile.in)．
- `sky130_ef_sc_hd` の追加セルの帰属表示：[同版の Verilog ヘッダー](https://github.com/RTimothyEdwards/open_pdks/blob/d400e26845538beaeb7cc5fdb9bfc06c30ea27cb/sky130/custom/sky130_fd_sc_hd/verilog/sky130_ef_sc_hd__decap_12.v)．著作権・Apache-2.0 表示は上記と同じです．

使用した PDK は digest 固定 IIC-OSIC-TOOLS イメージ内の `sky130A`，`sky130_fd_sc_hd` です．`SOURCES` は `open_pdks d400e26845538beaeb7cc5fdb9bfc06c30ea27cb` と記録しています．実行環境はイメージの digest で固定し，各 run に入力ハッシュを収録しています．

GDS は，その PDK のセルを自作 CPU の配置・配線へ組み込んだものです．収録した GDS の図形は，実装フローの出力から変更していません．SHA-256 は `48df4860439ae03a7c98aea5b441fc99911831107fae7eccf2f3d2f14b76dcbe` です．レイアウト画像は筆者による同じ実装の既存表示で，表示層の選択を含みます．公式サイトの図版のコピーではありません．

## ログ・外部ツール

保存した `console.log` には Yosys 等のツール名，著作権表示，公開されている開発者連絡先を含むバナーがあります．これらの帰属表示は削除していません．ツール本体・コンテナイメージ・PDK 全体は同梱せず，それぞれの配布元から取得します．

- [IIC-OSIC-TOOLS](https://github.com/iic-jku/IIC-OSIC-TOOLS)
- [Icarus Verilog](https://github.com/steveicarus/iverilog)
- [Yosys](https://github.com/YosysHQ/yosys)
- [LibreLane](https://github.com/librelane/librelane)
- [KLayout](https://www.klayout.de/)
- [GTKWave](https://gtkwave.github.io/gtkwave/)

## 原典

TD4 の論理動作は渡波郁『CPUの創りかた』の説明・最終回路図を参照しています．本 RTL は他の公開 RTL のコピーではなく，本巻の実験用に作成したものです．原典の PDF，回路図の画像，抽出テキストは収録していません．原典の各ページとの照合は著者側で行った範囲であり，原典との形式的等価証明を実施したという意味ではありません．

公式セル資料は [観察ガイド](docs/observation.md) の参照先から閲覧できます．
