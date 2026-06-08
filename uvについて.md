# 既存プロジェクトへ UV を導入

既存プロジェクト

```text
my_project/
├─ app.py
└─ requirements.txt
```

---

## 1. プロジェクトへ移動

```powershell
cd my_project
```

---

## 2. UV 管理へ変更

```powershell
uv init
```

生成

```text
my_project/
├─ app.py
├─ requirements.txt
├─ pyproject.toml
└─ README.md
```

---

## 3. requirements.txt の内容をインストール

```powershell
uv pip install -r requirements.txt
```

この時点で

- .venv 作成
- ライブラリインストール

が行われる

---

## 4. プログラム実行

```powershell
uv run app.py
```

---

## 5. 仮想環境に入りたい場合のみ

```powershell
.venv\Scripts\activate
```

終了

```powershell
deactivate
```

※ UV を使うなら通常は不要

# 新規プロジェクトを作る

## 1. プロジェクト作成

```powershell
uv init myapp
```

作成される

```text
myapp/
├─ pyproject.toml
├─ README.md
└─ src/
```

---

## 2. プロジェクトへ移動

```powershell
cd myapp
```

---

## 3. ライブラリを追加

例：Flask

```powershell
uv add flask
```

この時点で

- .venv 作成
- Flask インストール
- pyproject.toml 更新

が自動で行われる。

```text
myapp/
├─ .venv/
├─ pyproject.toml
└─ ...
```

---

## 4. プログラム実行

```powershell
uv run app.py
```

または

```powershell
uv run main.py
```

---

## 5. 仮想環境に入りたい場合のみ

```powershell
.venv\Scripts\activate
```

終了

```powershell
deactivate
```

※ UV を使うなら通常は不要


新規プロジェクト

uv init myapp
cd myapp
uv add flask
uv run app.py

既存プロジェクト

cd my_project
uv init
uv pip install -r requirements.txt
uv run app.py





