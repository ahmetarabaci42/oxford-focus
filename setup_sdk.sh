#!/bin/bash
set -e

echo "=== Starting Flutter and Android SDK Installation (Non-root, User-space) ==="

# 1. Create directories
mkdir -p "$HOME/development"
mkdir -p "$HOME/development/jdk"
mkdir -p "$HOME/development/android"
mkdir -p "$HOME/development/android/cmdline-tools"

# 2. Download and Extract OpenJDK 17
if [ ! -d "$HOME/development/jdk/bin" ]; then
    echo "Downloading Eclipse Temurin OpenJDK 17..."
    curl -L "https://api.adoptium.net/v3/binary/latest/17/ga/linux/x64/jdk/hotspot/normal/eclipse?project=jdk" -o "$HOME/development/jdk.tar.gz"
    echo "Extracting JDK..."
    tar -xzf "$HOME/development/jdk.tar.gz" -C "$HOME/development/jdk" --strip-components=1
    rm "$HOME/development/jdk.tar.gz"
    echo "JDK installed successfully."
else
    echo "JDK is already installed."
fi

# 3. Clone Flutter SDK
if [ ! -d "$HOME/development/flutter/bin" ]; then
    echo "Cloning Flutter SDK stable channel..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/development/flutter"
    echo "Flutter SDK cloned successfully."
else
    echo "Flutter SDK is already cloned."
fi

# 4. Download and Extract Android Cmdline Tools
if [ ! -d "$HOME/development/android/cmdline-tools/latest/bin" ]; then
    echo "Downloading Android command-line tools..."
    curl -L "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" -o "$HOME/development/cmdline-tools.zip"
    echo "Extracting Command-line tools..."
    unzip -q "$HOME/development/cmdline-tools.zip" -d "$HOME/development/android"
    
    # Structure cmdline-tools correctly
    mv "$HOME/development/android/cmdline-tools" "$HOME/development/android/cmdline-tools-temp"
    mkdir -p "$HOME/development/android/cmdline-tools/latest"
    mv "$HOME/development/android/cmdline-tools-temp"/* "$HOME/development/android/cmdline-tools/latest/"
    rm -rf "$HOME/development/android/cmdline-tools-temp"
    rm "$HOME/development/cmdline-tools.zip"
    echo "Android Command-line tools installed successfully."
else
    echo "Android Command-line tools are already installed."
fi

# 5. Define Environment Variables for this run and update .bashrc
export JAVA_HOME="$HOME/development/jdk"
export ANDROID_HOME="$HOME/development/android"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$HOME/development/flutter/bin:$PATH"

# Write to ~/.bashrc if not already present
if ! grep -q "export JAVA_HOME=" "$HOME/.bashrc"; then
    echo "Updating ~/.bashrc with environment variables..."
    cat << 'EOF' >> "$HOME/.bashrc"

# Flutter and Android SDK Environment Settings
export JAVA_HOME="$HOME/development/jdk"
export ANDROID_HOME="$HOME/development/android"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$HOME/development/flutter/bin:$PATH"
EOF
fi

# 6. Install SDK packages via sdkmanager
echo "Installing Android SDK Platform tools, Platforms, and Build tools..."
# Accept licenses and install packages
yes | sdkmanager --licenses || true
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# 7. Configure Flutter with the new SDK paths
echo "Configuring Flutter SDK..."
flutter config --android-sdk "$ANDROID_HOME"
flutter config --jdk-dir "$JAVA_HOME"

# Accept Android licenses in Flutter
echo "Accepting Android Licenses in Flutter..."
yes | flutter doctor --android-licenses || true

echo "=== SDK Setup Completed Successfully! ==="
echo "Please run: source ~/.bashrc"
