# 選択器の練習

CPU の `td4_datapath` と同じ選択部分を取り出した4 bit の回路です．選択番号0，1，2，3はそれぞれ A，B，外部入力，定数0に対応します．

リポジトリのルートで `make sim DESIGN=selector_lab` を実行します．`selector4_tb.sv` は期待値との比較で自己判定します．run ごとに入力のコピーとハッシュ，環境，終了コード，`console.log`，`selector4.vcd` が保存されます．入力を変更する際は期待値も仕様に基づいて考え，変更前の run は保存します．
