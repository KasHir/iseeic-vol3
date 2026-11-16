# 本文・付録と配布資料

掲載コードの全文は `eda/designs/`，保存した入力と結果は `eda/archive/<設計名>/<run名>/` にあります．新しく実行した結果は `eda/designs/<設計名>/runs/` に作成します．

| 掲載・参照 | 教材・コマンド | 保存した結果 |
|---|---|---|
| 第1章：CPU とカウント | [CPU RTL](../eda/designs/my_cpu4/my_cpu4.v)，[全体 TB](../eda/designs/my_cpu4/my_cpu4_tb.sv)，[ブロック TB](../eda/designs/my_cpu4/blocks_tb.sv)，`make sim DESIGN=my_cpu4` | [筆者の count_trace.csv](../eda/archive/my_cpu4/experiment-sim-OpbeDKX9/count_trace.csv)，[先行実験のログ](../eda/archive/my_cpu4/experiment-sim-yWiVD7Td/console.log) |
| 第2章：加算器と信号 | [adder4.v](../eda/designs/adder_lab/adder4.v)，[五組 TB](../eda/designs/adder_lab/adder4_tb.sv)，`make sim DESIGN=adder_lab` | [E32sRH6I](../eda/archive/adder_lab/experiment-sim-E32sRH6I/console.log) の VCD とログ．0＋0，2＋3，9＋0，15＋1，15＋15 |
| 第3章：期待値・誤り・復帰 | [桁欠落版](../eda/designs/adder_lab/adder4_drop_carry.v)，`ADDER_VARIANT=drop-carry`，その後通常版 | [ZAqr3r1q](../eda/archive/adder_lab/experiment-sim-ZAqr3r1q/console.log) は意図した失敗，[0RuOfOVx](../eda/archive/adder_lab/experiment-sim-0RuOfOVx/console.log) は五組の復帰．[比較 SVG](images/adder-wave-compare.svg) と [CSV](adder-wave-compare.csv) は保存 VCD からの再描画 |
| 一組の加算と筆者の変更 | [掲載用 TB](../eda/designs/adder_lab/adder4_one_publication_tb.sv) は2＋3，[筆者版 TB](../eda/designs/adder_lab/adder4_one_tb.sv) は15＋1．`ADDER_TEST=publication`／`one` | [k3HCx0Eu](../eda/archive/adder_lab/experiment-sim-k3HCx0Eu/console.log)，[Hn379yMs](../eda/archive/adder_lab/experiment-sim-Hn379yMs/console.log)，[IRSNhFTi](../eda/archive/adder_lab/experiment-sim-IRSNhFTi/console.log)．[BpXW1eRg](../eda/archive/adder_lab/experiment-sim-BpXW1eRg/console.log) は7＋4の比較値11と，表示文字列5の不整合を保存 |
| 第4章：選択器 | [selector4.v](../eda/designs/selector_lab/selector4.v)，[TB](../eda/designs/selector_lab/selector4_tb.sv)，`make sim DESIGN=selector_lab` | [cvAR5gGo](../eda/archive/selector_lab/experiment-sim-cvAR5gGo/console.log) と [J2PcD1xb](../eda/archive/selector_lab/experiment-sim-J2PcD1xb/console.log) は入力変更の前後．[QeCiPxNE](../eda/archive/selector_lab/experiment-sim-QeCiPxNE/console.log) は掲載用 TB の確認 |
| 第4章：三命令 | CPU RTL と [three_instructions_tb.sv](../eda/designs/cpu_program_lab/three_instructions_tb.sv)，`make sim DESIGN=cpu_program_lab`，`PROGRAM_ADD=4` | [GPnmHreE CSV](../eda/archive/cpu_program_lab/experiment-sim-GPnmHreE/three_instructions.csv) は MOV B,2 → ADD B,3 → OUT B，[2XoF56dR CSV](../eda/archive/cpu_program_lab/experiment-sim-2XoF56dR/three_instructions.csv) は ADD B,4 |
| 第5章：汎用ゲート合成（脚注） | `make synth-adder` | [XdxRIdlq](../eda/archive/adder_lab/experiment-synth-XdxRIdlq/console.log) の20セル，ネットリストと DOT |
| 第5章：SKY130 13セル | `make synth-adder-sky130` | [ZckC6fBU ネットリスト](../eda/archive/adder_lab/experiment-synth-sky130-ZckC6fBU/adder4_sky130.v)，同 run のログと DOT．`_09_` の XOR，`_08_`〜`_20_` の13セル |
| 第5章：全256組の機能比較 | [比較 TB](../eda/designs/adder_lab/adder4_compare_tb.sv)，`make compare-adder SYNTH_RUN=eda/archive/adder_lab/experiment-synth-sky130-ZckC6fBU` | [3oo9M9Ag](../eda/archive/adder_lab/experiment-compare-3oo9M9Ag/console.log)．両回路を同時に使うためセル回路のトップ名だけ変更 |
| 第1・6章：CPU の物理実装と観察 | [JSON](../eda/designs/my_cpu4/my_cpu4.json)，[SDC](../eda/designs/my_cpu4/my_cpu4.sdc)，[端子順](../eda/designs/my_cpu4/pin_order.cfg)，`make gds DESIGN=my_cpu4 JOBS=2` | [BTk6iY3e final](../eda/archive/my_cpu4/experiment-gds-BTk6iY3e/runs/implementation/final/) の `nl/`・`def/`・`gds/`，metrics，検証 report．観察案内は [observation.md](observation.md) |
| 付録：実行環境，保存先，公式資料 | [Makefile](../Makefile)，[実行スクリプト](../scripts/portable-eda.sh)，[環境](portable_setup.md)，[観察ガイド](observation.md) | [保存結果の一覧](../eda/archive/README.md) |

コードは実行用の全文を収録しています．波形保存の `$dumpfile`／`$dumpvars` も含みます．
