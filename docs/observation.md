# 波形と GDS を見る

## 保存済みの数値と波形

`eda/archive/` の `console.log` と CSV はテキストエディタで読めます．CPU の `count_trace.csv` は各命令の実行後の値です．三命令の `three_instructions.csv` は実行前の PC・命令・状態と実行後の状態を含みます．

GTKWave が使える場合は，次の VCD を開きます．

| 波形ファイル（`eda/archive/` 以下） | 追加する主な信号 |
|---|---|
| `adder_lab/experiment-sim-E32sRH6I/adder4.vcd` | `adder4_tb.left_i`，`right_i`，`sum_o`，`sum_o[4]` |
| `adder_lab/experiment-sim-ZAqr3r1q/adder4.vcd` | 同上．3〜4 nsは期待16／実際0，4 nsで停止 |
| `selector_lab/experiment-sim-J2PcD1xb/selector4.vcd` | `selector4_tb` の `select`，`a`，`b`，`in_port`，`source` |
| `cpu_program_lab/experiment-sim-GPnmHreE/three_instructions.vcd` | `three_instructions_tb` の `pc`，`instruction`，`out_port` と `dut` 内の `b` |
| `my_cpu4/experiment-sim-OpbeDKX9/count.vcd` | `my_cpu4_tb.dut` 内の `clk_i`，`pc`，`instruction_i`，`out_port_o`，`a`，`b`，`carry` |

実際の信号名は VCD の `$scope`／`$var` にあります．表示形式を16進数にした場合，15＋1は F＋1＝10，15＋15は F＋F＝1E です．数値の10と10進数の10を混同しないようにします．[比較 SVG](images/adder-wave-compare.svg) と [CSV](adder-wave-compare.csv) は10進数です．これらは保存済み VCD の再描画で，新たな EDA 実行結果ではありません．

## CPU のレイアウト

KLayout で次を開き，トップセル `my_cpu4` を選んで全体表示します．

```text
eda/archive/my_cpu4/experiment-gds-BTk6iY3e/runs/implementation/final/gds/my_cpu4.gds
```

セルの種類・接続は同じ `final/nl/my_cpu4.nl.v`，配置・向き・配線は `final/def/my_cpu4.def` で照合します．同じ run の三資料を組み合わせます．再生成した GDS ではインスタンス名や配置が変わる場合があります．

| 本文の観察対象 | 保存資料で読める内容 |
|---|---|
| 桁上がりの出力 | ネット `datapath.sum[4]` の出力元は `sky130_fd_sc_hd__o21ai_1 _084_`，保存先は `sky130_fd_sc_hd__dfrtp_1 _131_` の D |
| 配置座標 | DEF は `UNITS DISTANCE MICRONS 1000`．`_084_` は `(73600 133280) FS`，配置原点は `(73.600,133.280) µm` |
| GDS での向き | 同セル参照は `m0 73.60000,136.00000`．水平軸に対する反転と，高さ2.720 µmを考慮すると下端は133.280 µm．DEF の基準点と区別 |
| 代表入力 | `in_port_i[0]` → `input1` の A（`clkbuf_1`），X 側は `net1`．セル種名に clkbuf とあっても通常入力 |
| 代表出力 | `output14` の A は `net14`，X は `out_port_o[0]`（`buf_4`） |
| 端子の辺 | 上 instruction_i[7:0]，下 program_addr_o[3:0]，左 in_port_i[3:0]・clk_i・reset_n_i，右 out_port_o[3:0] |

信号端子は22本で，DEF の PINS 24件には VPWR と VGND も含みます．これらはコア接続用の金属領域で，ボンディング用 I/O パッドではありません．

代表入力の配線は M3 `(3.220,66.980)` → `(11.730,66.980)` µm，M2 で Y=69.530 µmへ進みます．代表出力はセル付近 `(147.430,22.610)` µmから M2 で Y=20.740 µmへ移り，M3 で右側端子へ進みます．線が画面上で交差しているだけでは接続と判断せず，DEF の NETS と via を確認します．

## 層の表示

同じ固定イメージの KLayout 設定は `/foss/pdks/sky130A/libs.tech/klayout/` 以下にあります．必要なら次でホストの `build/` へ取り出し，KLayout の Layer Properties で `.lyp` を読み込みます．このコマンドはイメージ内の設定を取得する補助手順です．結果は Git 管理外です．

```bash
mkdir -p build/pdk-view
docker run --rm --platform linux/amd64 --network none \
  --user "$(id -u):$(id -g)" --entrypoint /bin/bash \
  --mount "type=bind,source=$PWD/build/pdk-view,target=/export" \
  hpretl/iic-osic-tools@sha256:92961478ad3c4f508efb42d9ccdba12ab262eb42a14926d2bd49862230ba8521 \
  -lc 'cp /foss/pdks/sky130A/libs.tech/klayout/tech/sky130A.lyp /export/'
```

`.lyp` は層の表示設定です．KLayout Technology 全体を切り替える操作とは区別します．別プロセスの Technology を選んだまま，色だけで SKY130 の層を判断しないでください．

M1（met1）は横，M2（met2）は縦，M3は横，M4は縦，M5は横が技術 LEF の優先配線方向です．この CPU の通常信号 NETS は M1〜M3，電源 SPECIALNETS は M1〜M4で，M5 の配線記録はありません．M1 の横線には電源線も含みます．M4 の長い二本は左が VPWR，右が VGND です（DEF の X=26.440 µmと29.740 µm）．

`docs/images/m1.png`〜`m4.png` は，同じ領域を層ごとに表示した画像です．M1／M2，M3／M4を並べると，配線の方向と使われ方を比較できます．

## 公式資料

- [SKY130 PDK documentation](https://skywater-pdk.readthedocs.io/)
- [o21ai のセル資料](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/o21ai/README.html)：symbols／schematic／GDSII layouts
- [xor2 のセル資料](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/xor2/README.html)
- [lpflow_isobufsrc のセル資料](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/lpflow_isobufsrc/README.html)
- [OpenROAD の STA 紹介](https://openroad.readthedocs.io/en/latest/main/src/sta/README.html)
