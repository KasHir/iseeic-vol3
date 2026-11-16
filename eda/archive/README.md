# 保存した実行結果

本のコードと結果を，EDA 環境がなくても参照できる資料です．各ディレクトリは一回の実行（run）に対応し，使用した入力のコピー，環境，終了コード，ログと代表的な出力を収録しています．新しく実行しても，この保存先は上書きしません．

| 本との対応 | ディレクトリ | 主な結果 |
|---|---|---|
| 第1章：CPUのカウント | `my_cpu4/experiment-sim-OpbeDKX9/` | `count_trace.csv`，`count.vcd`，自己判定ログ |
| CPUの先行シミュレーション | `my_cpu4/experiment-sim-yWiVD7Td/` | ブロック262176件・状態131149件PASS |
| 第2・3章：五組の加算 | `adder_lab/experiment-sim-E32sRH6I/` | 和0，5，9，16，30，VCD |
| 第3章：桁上がり欠落 | `adder_lab/experiment-sim-ZAqr3r1q/` | 15＋1で期待16／実際0となり停止（意図した失敗） |
| 正常版への復帰 | `adder_lab/experiment-sim-0RuOfOVx/` | 五組PASS |
| 一組の2＋3 | `adder_lab/experiment-sim-k3HCx0Eu/` | 掲載用テスト，和5，PASS |
| 一組の15＋1 | `adder_lab/experiment-sim-Hn379yMs/` | 和16，PASS |
| 一組の正常版への復帰 | `adder_lab/experiment-sim-IRSNhFTi/` | 15＋1でPASS |
| 入力と表示文の変更例 | `adder_lab/experiment-sim-BpXW1eRg/` | 7＋4の比較値11でPASS．ログの期待値の表示文は5のままなので区別して読む |
| 第4章：選択器の入力変更前 | `selector_lab/experiment-sim-cvAR5gGo/` | 自己判定ログ，VCD |
| 第4章：選択器の入力変更後 | `selector_lab/experiment-sim-J2PcD1xb/` | 自己判定ログ，VCD |
| 掲載用の選択器テスト | `selector_lab/experiment-sim-QeCiPxNE/` | 現在の教材TBでのPASS |
| 第4章：三命令 | `cpu_program_lab/experiment-sim-GPnmHreE/` | MOV B,2 → ADD B,3 → OUT B，CSV・VCD |
| 第4章：ADDの即値変更 | `cpu_program_lab/experiment-sim-2XoF56dR/` | ADD B,4に変更，CSV・VCD |
| 第5章：汎用合成 | `adder_lab/experiment-synth-XdxRIdlq/` | 20セル，ネットリスト・DOT |
| 第5章：SKY130 HDへの合成 | `adder_lab/experiment-synth-sky130-ZckC6fBU/` | 13セル，ネットリスト・DOT |
| 第5章：RTLとセル回路の比較 | `adder_lab/experiment-compare-3oo9M9Ag/` | 256入力で両回路が算術期待値に一致 |
| 第1・6章：CPUの物理実装 | `my_cpu4/experiment-gds-BTk6iY3e/` | 最終ネットリスト・DEF・GDS，metricsと検証report |

CPUの物理資料は `my_cpu4/experiment-gds-BTk6iY3e/runs/implementation/final/` の `nl/`，`def/`，`gds/` です．同じrunの三資料を組み合わせて読みます．観察する信号・座標・層は [観察ガイド](../../docs/observation.md) にあります．

`runner.sh` は保存runを実行したスクリプトの写しです．再実行するときはリポジトリのルートのMakefileを使います．`inputs.sha256` は各runの入力の検査用，`SHA256SUMS` はこのディレクトリ全体の検査用です．`make verify-saved` で確認できます．

## 結果の読み方

CPUの `count_trace.csv` は，各命令を実行した後の値です．三命令の `three_instructions.csv` は実行前後の状態を含みます．VCDはRTLシミュレーションの論理値で，セルや配線の伝搬遅延を含みません．保存した入力には当時の変更例もあるため，現在の教材ファイルと同じとは限りません．

ブロック262176件はデコーダ32条件とデータ経路262144条件です．CPU状態131149件は，256命令語×値16通り×前キャリー2通り×PC16通りの131072件，リセット8件，個別命令6件，通常命令プログラム13件，カウント50件です．低クロック中の状態注入を含み，全状態・全入力の直積ではありません．

保存した物理実装は160×160 µmの指定領域で，ROM，I/Oパッド，パッケージを含みません．合成75セルと配置配線後の387インスタンスは集計範囲が異なります．DRC／LVS／Antennaは通過し，100 ns周期の条件でworst setup slackは+17.804880 ns，holdは+0.157949 nsでした．最小面積・最高動作周波数の測定や製造用サインオフの完了を示す値ではありません．

SDCはクロック後20 ns以内の番地出力，その後20 ns以内の外部ROMと配線，40 ns以内の命令到着を仮定しています．リセットはクロック停止中に操作する条件でfalse pathにしています．長配線しきい値・電源供給点未指定等の警告はログに残っています．実ROM・実チップとの比較，形式的等価証明，遅延付きゲートシミュレーションは行っていません．
