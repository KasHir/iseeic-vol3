# 実行環境

vol.2 と同じ WSL2＋Docker Desktop＋IIC-OSIC-TOOLS を使います．Docker Desktop の導入と WSL Integration の設定は済んでおり，WSL 上で `docker` を利用できることを前提にしています．Git，GNU Make，Bash，grep，sed，sha256sum を使います．Python 3 は保存資料の確認・波形の再描画用です．

対象は linux/amd64 です．次の固定イメージを `scripts/portable-eda.sh` が使います．バージョンタグへ置き換えると，掲載結果とツール・PDK の条件が変わる場合があります．

```bash
docker pull --platform linux/amd64 \
  hpretl/iic-osic-tools@sha256:92961478ad3c4f508efb42d9ccdba12ab262eb42a14926d2bd49862230ba8521
```

`make setup` も，ローカルにこのイメージがない場合だけ取得します．初回取得にはネットワークとイメージ保存用の空き容量が必要です．上流の説明は [IIC-OSIC-TOOLS](https://github.com/iic-jku/IIC-OSIC-TOOLS) にあります．イメージは本リポジトリへ同梱していません．

```bash
make docker-check
make setup
make env-check
```

`env-check` は Icarus Verilog／vvp，LibreLane，Yosys と `/foss/pdks/sky130A/SOURCES` を表示します．CPU の動作確認ではありません．固定環境の PDK 記録は `open_pdks d400e26845538beaeb7cc5fdb9bfc06c30ea27cb` です．主な版は Icarus Verilog 13.0 (devel)，LibreLane 2.4.10，Yosys 0.60です．

実験はネットワークなしのコンテナで実行し，ホストの UID/GID を使います．コンテナへマウントするのは今回作る run ディレクトリだけです．Makefile → `scripts/portable-eda.sh` → Docker 内の `iverilog`／`vvp`／`yosys`／`librelane` の順で処理します．実際のツール引数はスクリプトに記載しています．

`permission denied` で Docker に接続できない場合は，WSL Integration と現在のユーザーの接続権限を確認してください．Docker ソケットを全ユーザーへ書き込み可能にする設定は不要です．

GTKWave と KLayout の導入・GUI 起動はこの headless スクリプトには含みません．WSLg 上のアプリや，vol.2 の GUI 環境で開けます．コンテナ内の `/foss/pdks/` は WSL ホスト側のパスではありません．GDS の図形を開くために PDK 一式を別途コピーする必要はありませんが，層名・色を揃える `.lyp` は必要に応じて同じ PDK から取得します．[観察ガイド](observation.md) の手順を参照してください．
