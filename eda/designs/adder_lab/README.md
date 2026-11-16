# 加算器の練習用入力

CPU から計算だけを取り出して学ぶための小回路です．CPU コア自体は変更していません．二つの4 bit の符号なし入力に対し，5 bit の和を出します．

| ファイル | 役割 |
|---|---|
| `adder4.v` | 正しい加算器 |
| `adder4_one_tb.sv` | 筆者が変更した15+1の一組を，期待値16と比較 |
| `adder4_one_publication_tb.sv` | 掲載用の2+3の一組を，期待値5と比較 |
| `adder4_tb.sv` | 五組の入力・期待値を比較する自己判定 TB |
| `adder4_drop_carry.v` | 意図的に桁上がりを捨てた代替版 |

リポジトリのルートで実行します．固定 EDA 環境の準備は `docs/portable_setup.md` を参照してください．

```sh
make sim DESIGN=adder_lab ADDER_TEST=publication
make sim DESIGN=adder_lab
make sim DESIGN=adder_lab ADDER_VARIANT=drop-carry
make sim DESIGN=adder_lab
```

3番目は，15+1の期待値16に対して0を出し，不一致で停止する実験です．`vvp` とスクリプトは終了コード1，それを受けた `make` は終了コード2になります．最後のコマンドは，正しい版へ戻して同じ五組を実行します．

二つの回路ファイルは，同じ `adder4` というモジュールの代替版です．実行スクリプトが片方だけをコンパイルします．`ADDER_TEST` は `one`（筆者の15+1版） / `publication`（2+3版） / `five`，`ADDER_VARIANT` は `good` / `drop-carry` を選びます．省略時は `five` と `good` です．一組の TB 二つは同じモジュール名なので，選んだ片方だけをコンパイルします．

各 run に，入力コピー・ハッシュ・環境・終了コード・`console.log`・`adder4.vcd` を残します．GDS 化はこの教材の実行対象にはしていません．
