#!/bin/bash
set -e

echo "🔧 Setting up CodeQL Learning Environment..."
echo ""

# Update package list
echo "📦 Updating package list..."
sudo apt-get update

# Install C++ development tools
echo "🔨 Installing C++ development tools..."
sudo apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    clang \
    llvm \
    gdb \
    wget \
    unzip

# Install additional useful tools
echo "🛠️  Installing additional tools..."
sudo apt-get install -y \
    jq \
    tree \
    ripgrep

# Create directory for CodeQL (but don't install it yet)
echo "📁 Creating CodeQL home directory..."
mkdir -p /home/vscode/.codeql-home

# Set up shell configuration
echo "🐚 Configuring shell..."
cat >> /home/vscode/.zshrc << 'EOF'

# CodeQL Configuration (will be activated after installation)
# Uncomment these lines after installing CodeQL:
# export PATH="$HOME/.codeql-home/codeql:$PATH"
# export CODEQL_HOME="$HOME/.codeql-home"

EOF

# Create a welcome message
cat > /home/vscode/.codeql-welcome << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║  🎓 Welcome to the CodeQL Learning Environment!               ║
║                                                                ║
║  This codespace is ready for you to learn CodeQL.             ║
║                                                                ║
║  📚 Next Steps:                                               ║
║  1. Read 03-installation.md for instructions                  ║
║  2. Complete the lab exercises in lab/03-installation/        ║
║  3. Install CodeQL CLI and libraries as guided                ║
║                                                                ║
║  💡 Quick start: cd lab/03-installation && cat README.md      ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF

# Add welcome message to .zshrc
echo "cat ~/.codeql-welcome" >> /home/vscode/.zshrc

echo ""
echo "✅ Post-create setup complete!"
echo "🚀 You're ready to start learning CodeQL!"
