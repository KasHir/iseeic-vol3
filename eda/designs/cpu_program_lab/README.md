# 三命令の練習

既存の `my_cpu4.v` を使用し，外部 ROM に MOV B,2，ADD B,3，OUT B を置きます．リポジトリのルートで `make sim DESIGN=cpu_program_lab` を実行します．ADD の即値を4にする変更例は `make sim DESIGN=cpu_program_lab PROGRAM_ADD=4` です．

各 run に CPU と TB の入力コピー・ハッシュ，環境，終了コード，ログ，`three_instructions.csv`，`three_instructions.vcd` を保存します．リセット確認後，3命令を実行し，命令ごとの期待値と比較します．CSV は実行前の PC・命令・状態と実行後の状態を示します．
