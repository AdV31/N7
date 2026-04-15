#!/usr/bin/env bash
# ============================================================
# Setup script
#
# Creates a Python virtual environment and installs all
# packages required to run the TP1 notebook.
#
# Usage:
#   chmod +x setup_env.sh
#   ./setup_env.sh
#
# Then activate the environment:
#   source SciML_env/bin/activate
#
# To register the environment as a Jupyter kernel:
#   python -m ipykernel install --user --name SciML --display-name "SciML"
# ============================================================

set -euo pipefail

ENV_DIR="SciML_env"

# ---- Check Python version ----
PYTHON=""
for candidate in python3 python; do
    if command -v "$candidate" &>/dev/null; then
        version=$("$candidate" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        major=$("$candidate" -c "import sys; print(sys.version_info.major)")
        minor=$("$candidate" -c "import sys; print(sys.version_info.minor)")
        if [ "$major" -ge 3 ] && [ "$minor" -ge 9 ]; then
            PYTHON="$candidate"
            break
        fi
    fi
done

if [ -z "$PYTHON" ]; then
    echo "Error: Python >= 3.9 is required but was not found."
    echo "Please install Python 3.9+ and try again."
    exit 1
fi

echo "Using $PYTHON (version $($PYTHON --version 2>&1))"

# ---- Create virtual environment ----
if [ -d "$ENV_DIR" ]; then
    echo "Virtual environment '$ENV_DIR' already exists. Remove it first if you want a fresh install."
    echo "  rm -rf $ENV_DIR && ./setup_env.sh"
    exit 1
fi

echo "Creating virtual environment in ./$ENV_DIR ..."
$PYTHON -m venv "$ENV_DIR"

# ---- Activate ----
source "$ENV_DIR/bin/activate"

# ---- Upgrade pip ----
pip install --upgrade pip

# ---- Install packages ----
echo "Installing dependencies ..."
pip install numpy matplotlib torch ipykernel jupyter

# ---- Register Jupyter kernel ----
python -m ipykernel install --user --name SciML --display-name "SciML"

echo ""
echo "============================================================"
echo "  Setup complete!"
echo ""
echo "  Activate the environment:"
echo "    source $ENV_DIR/bin/activate"
echo ""
echo "  Launch the notebook:"
echo "    jupyter notebook TP1_student.ipynb"
echo ""
echo "  The Jupyter kernel 'SciML' has been registered."
echo "  You can select it from the kernel menu in Jupyter/VSCode."
echo "============================================================"
