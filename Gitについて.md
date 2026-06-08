# まずはじめにGit管理の準備
## git init
.git/を作って、ディレクトリをGitリポジトリに

## git add .
カレントディレクトリ内のファイルを次のコミットに含める予定

## git commit -m initial commit
初回コミット


# 普段のコマンド
## git add .
基本はファイルを変更するたびにコミット前に必要。
## git commit -a -m メッセージ
git add .を省略可能。

## git commit -m メッセージ
=> 
取るたびに
 C0
 |
 C1
 |
 C2
のようにコミットが増えていく。

## git branch 
=>コミットに目印をつける
ブランチ：コミットを指す目印（ラベル）

## git checkout ブランチ名
=>作業してるブランチを変える。

なお、ブランチ = プロジェクト・機能単位

コミット = 作業履歴単位

同じブランチ内で何度もコミットする


C0
|
C1(main)
|
C2(bagFix*)
とあったら、git checkout mainで
C0
|
C1(main*)
|
C2(bagFix)
になり、そこでgit commitすると
        C0
        |
        C1
        /\
C2(bugFix) C3(main*)
になって、遡って分岐できるよ  

*遡るなら必ずブランチを切ってから！切らずに遡ると宙に浮いて回収できなくなる*

## git merge ブランチ名
今いるブランチに、ブランチ名を取り込む

## git log --oneline --graph --all
今の状態が見れる。コミットの関係図

## 初回プッシュ
githubの+
new repository
でてきたURLをコピー
```
git remote add origin [URL]
```
```
git remote -v
```
で確認

```
git push -u origin master
```
で初回プッシュ。-uでローカルとリモートの対応を記憶するので、次回からは
```
git push
```
のみ。