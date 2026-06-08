# file_dump.py
# Recursively dump whitelisted source files with a tree into a single text file.
#
# Usage:
#   python file_dump.py
#
# Output:
#   file_dump_<directory_name>.txt

from pathlib import Path
import sys

# ============================================================
# Allowed extensions
# ============================================================
ALLOWED_EXTENSIONS = {

    # --- Web frontend ---
    ".html", ".htm",
    ".css", ".scss", ".sass", ".less",
    ".js", ".mjs", ".cjs",
    ".ts", ".tsx", ".jsx",
    ".vue", ".svelte",

    # --- Backend / scripts ---
    ".py",
    ".rb",
    ".php",
    ".java",
    ".kt", ".kts",
    ".go",
    ".rs",
    ".cs",
    ".cpp", ".cc", ".cxx", ".c", ".h", ".hpp",
    ".swift",
    ".scala",
    ".dart",
    ".ex", ".exs",
    ".erl",
    ".hs",
    ".lua",
    ".r",
    ".pl", ".pm",
    ".sh", ".bash", ".zsh",
    ".ps1", ".psm1", ".psd1",

    # --- Data / config ---
    ".json", ".jsonc",
    ".yaml", ".yml",
    ".toml",
    ".sql",
    ".graphql", ".gql",
    ".xml",
    ".csv",
    ".env",
    ".ini", ".cfg", ".conf",

    # --- Docs / markup ---
    ".md", ".mdx",
    ".tex", ".rst"
}

# ============================================================
# Excluded directories
# ============================================================
EXCLUDED_DIRS = {

    # Git
    ".git",

    # Node.js
    "node_modules",

    # Python
    ".venv",
    "venv",
    "__pycache__",
    ".mypy_cache",
    ".pytest_cache",

    # Build
    "dist",
    "build",
    "out",
    ".next",
    ".nuxt",

    # IDE
    ".idea",
    ".vscode"
}

# ============================================================
# Input path
# ============================================================
input_path = input("出力したいパスを入力してください: ").strip().strip('"')

if not input_path:
    input_path = "."

root = Path(input_path).resolve()

if not root.exists() or not root.is_dir():
    print(f"エラー: ディレクトリが存在しません: {root}")
    sys.exit(1)

# ============================================================
# Output file
# ============================================================
safe_name = root.name if root.name else "root"

output_file = Path.cwd() / f"file_dump_{safe_name}.txt"

# ============================================================
# Build tree
# ============================================================
tree_lines = []

def build_tree(target: Path, depth: int = 1):

    items = sorted(
        target.iterdir(),
        key=lambda x: (x.is_file(), x.name.lower())
    )

    for item in items:

        if item.is_dir() and item.name in EXCLUDED_DIRS:
            continue

        indent = "  " * depth

        if item.is_dir():

            tree_lines.append(f"{indent}{item.name}/")

            build_tree(item, depth + 1)

        else:

            tree_lines.append(f"{indent}{item.name}")

# ============================================================
# Collect source files
# ============================================================
source_files = []

def collect_files(target: Path):

    items = sorted(target.iterdir(), key=lambda x: x.name.lower())

    for item in items:

        if item.is_dir():

            if item.name in EXCLUDED_DIRS:
                continue

            collect_files(item)

        else:

            if item.suffix.lower() in ALLOWED_EXTENSIONS:
                source_files.append(item)

# ============================================================
# Main
# ============================================================
lines = []

# ============================================================
# TREE
# ============================================================
lines.append("<tree>")
lines.append(f"{safe_name}/")

build_tree(root)

lines.extend(tree_lines)

lines.append("</tree>")
lines.append("")

# ============================================================
# FILE CONTENTS
# ============================================================
collect_files(root)

for file_path in source_files:

    relative_path = file_path.relative_to(root).as_posix()

    lines.append(f'<file path="{relative_path}">')

    try:

        content = file_path.read_text(
            encoding="utf-8",
            errors="replace"
        ).rstrip()

        lines.append(content)

    except Exception as e:

        lines.append(f"(read error: {e})")

    lines.append("</file>")
    lines.append("")

# ============================================================
# Write output
# ============================================================
output_file.write_text(
    "\n".join(lines),
    encoding="utf-8"
)

# ============================================================
# Result
# ============================================================
print("")
print("========================================")
print("Export completed")
print(f"Output : {output_file}")
print(f"Files  : {len(source_files)}")
print("========================================")
print("")
input("Enterキーで終了...")