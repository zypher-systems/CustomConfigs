# Zypher Systems - Enhanced Fastfetch Configuration

**Created by:** Zypher  
**Company:** Zypher Systems

This directory contains a premium Fastfetch configuration designed to provide a visually stunning and comprehensive system information display. The configuration features a modern design with continuous borders, vibrant colors, and organized sections for optimal readability.

## Overview

Fastfetch is a fast system information tool written in C that displays system information in a clean, customizable format. This enhanced configuration by Zypher Systems creates a professional-grade layout with distinct sections, continuous borders, and comprehensive system monitoring.

## Configuration File: `config.jsonc`

The `config.jsonc` file contains a custom Fastfetch configuration that organizes system information into visually distinct sections with continuous borders and enhanced color schemes.

### ✨ Enhanced Features

#### 🎨 **Visual Improvements**
- **Continuous Borders**: Seamless box-drawing characters that create a unified display
- **Bright Color Scheme**: Uses bright ANSI colors (`\u001b[1;XX`) for enhanced visibility
- **Professional Layout**: Clean, organized sections with proper spacing
- **Consistent Formatting**: Uniform styling across all sections

#### 🔧 **Technical Enhancements**
- **Better Icons**: Unique Nerd Font icons for each component type
- **Improved Labels**: More descriptive and professional naming
- **Enhanced Sections**: Additional performance and battery monitoring
- **Branding**: Subtle Zypher Systems branding at the bottom

### 📊 Structure

The configuration is organized into the following sections:

1. **Hardware Section** (Bright Green - `\u001b[1;32m`)
   - PC/Host information with computer icon
   - CPU details with processor icon
   - GPU information with graphics card icon
   - RAM usage with memory icon
   - Storage information with disk icon

2. **Software Section** (Bright Yellow - `\u001b[1;33m`)
   - Operating System with OS icon
   - Kernel version with kernel icon
   - BIOS information with firmware icon
   - Package count with package manager icon
   - Shell information with terminal icon

3. **Desktop Environment Section** (Bright Blue - `\u001b[1;34m`)
   - Desktop Environment with DE icon
   - Login Manager with session icon
   - Window Manager with WM icon
   - Theme information with theme icon
   - Terminal with terminal icon

4. **Network & System Section** (Bright Magenta - `\u001b[1;35m`)
   - Local IP address with network icon
   - WiFi connection with wireless icon
   - OS installation age with clock icon
   - System uptime with time icon
   - Current date/time with calendar icon

5. **Performance & Battery Section** (Bright Red - `\u001b[1;31m`) - NEW!
   - Battery status and level
   - CPU temperature monitoring
   - GPU temperature monitoring

6. **Color Palette Display** (Bright Cyan - `\u001b[1;36m`)
   - Terminal color scheme visualization with circle symbols

7. **Branding Footer** (Bright White - `\u001b[1;97m`)
   - Zypher Systems attribution
   - Custom configuration identification

### 🎯 Key Features

#### Enhanced Visual Design
- **Bright Color Palette**: All colors use bright variants for better contrast
- **Continuous Borders**: Unified border system using `├─┤` connectors
- **Professional Typography**: Clean, readable fonts and spacing
- **Icon Consistency**: Unique icons for each system component

#### Advanced System Monitoring
- **Temperature Monitoring**: CPU and GPU temperature display
- **Battery Information**: Power status and remaining charge
- **Network Details**: IP and WiFi connection information
- **Performance Metrics**: Real-time system resource usage

#### Logo Configuration
```jsonc
"logo": {
    "type": "builtin",
    "height": 15,
    "width": 30,
    "padding": {
        "top": 5,
        "left": 3
    }
}
```

#### Custom OS Age Calculation
The configuration includes an enhanced command to calculate OS installation age:
```bash
birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days
```

## 🎨 Customization Options

### Color Themes
Each section uses bright ANSI color codes for enhanced visibility:
- **Hardware**: `bright_green` - Modern tech aesthetic
- **Software**: `bright_yellow` - Warm, informative
- **Desktop**: `bright_blue` - Cool, professional
- **Network**: `bright_magenta` - Vibrant, attention-grabbing
- **Performance**: `bright_red` - Alert, monitoring focus
- **Palette**: `bright_cyan` - Clean, neutral

### Available Colors
`bright_black`, `bright_red`, `bright_green`, `bright_yellow`, `bright_blue`, `bright_magenta`, `bright_cyan`, `bright_white`

### Adding New Modules
Extend the configuration with additional system information:
- `bluetooth` - Bluetooth connectivity status
- `publicip` - External IP address
- `weather` - Local weather information
- `player` - Media player status
- `users` - Currently logged in users
- `locale` - System locale settings
- `cursor` - Cursor theme information
- `font` - System font configuration

### Icon Customization
Enhanced icon set using Nerd Font symbols:
- `` - Computer/Host (enhanced)
- `` - CPU (processor-specific)
- `󰢮` - GPU (graphics-specific)
- `` - RAM (memory-specific)
- `` - Storage (disk-specific)
- `` - Network (connection)
- `` - WiFi (wireless)
- `` - Battery (power)
- `` - Temperature (monitoring)

### Border Customization
The continuous border system uses:
- `╭` `╮` - Rounded top corners
- `╰` `╯` - Rounded bottom corners
- `├` `┤` - Section connectors
- `│` - Vertical borders
- `─` - Horizontal lines

## 🚀 Installation & Usage

### Prerequisites
- **Fastfetch**: Core application (latest version recommended)
- **Nerd Font**: Required for proper icon display
- **Compatible Terminal**: Unicode and 256-color support

### Installation Steps

1. **Install Fastfetch**:
   ```bash
   # Ubuntu/Debian
   sudo apt install fastfetch
   
   # Arch Linux
   sudo pacman -S fastfetch
   
   # Fedora
   sudo dnf install fastfetch
   
   # From source
   git clone https://github.com/fastfetch-cli/fastfetch.git
   cd fastfetch && make && sudo make install
   ```

2. **Install Nerd Font** (recommended):
   ```bash
   # Download and install a Nerd Font
   wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
   unzip FiraCode.zip -d ~/.local/share/fonts/
   fc-cache -fv
   ```

3. **Deploy Configuration**:
   ```bash
   # Create config directory
   mkdir -p ~/.config/fastfetch
   
   # Copy Zypher Systems configuration
   cp config.jsonc ~/.config/fastfetch/config.jsonc
   ```

4. **Test Configuration**:
   ```bash
   fastfetch
   ```

5. **Auto-start on Shell Login** (optional):
   ```bash
   # Add to ~/.bashrc, ~/.zshrc, or your shell's RC file
   echo "fastfetch" >> ~/.bashrc
   ```

## 🛠️ Advanced Configuration

### Performance Optimization
For systems where startup speed is critical:
- Remove `packages` module (can be slow on some systems)
- Disable temperature monitoring if sensors are slow
- Remove network modules if not needed

### Custom Branding
Modify the footer section to include your own branding:
```jsonc
{
    "type": "custom",
    "format": "\u001b[1;90m                    ╭─ \u001b[1;97mYour Custom Text\u001b[1;90m ─╮"
}
```

### System-Specific Tweaks
- **Laptops**: Keep battery module enabled
- **Desktops**: Remove battery module for cleaner display
- **Servers**: Focus on network and performance modules
- **Gaming Rigs**: Emphasize GPU and temperature monitoring

## 🔧 Troubleshooting

### Common Issues

**Icons Not Displaying**
- Install a compatible Nerd Font
- Verify terminal Unicode support
- Check font configuration in terminal settings

**Colors Not Appearing**
- Ensure terminal supports 256 colors
- Check `$TERM` environment variable
- Try different terminal emulator

**Slow Performance**
- Disable `packages` module
- Remove temperature monitoring
- Simplify network modules

**Missing Information**
- Install required system tools (`lscpu`, `lspci`, `sensors`)
- Check module permissions
- Verify hardware sensor support

### Performance Tuning
```bash
# Test specific modules individually
fastfetch --structure Title:Host:CPU:GPU:Memory

# Benchmark configuration load time
time fastfetch

# Debug module issues
fastfetch --verbose
```

## 📜 Technical Specifications

- **JSON Schema**: Official Fastfetch schema compliance
- **Color System**: ANSI bright color codes
- **Border Style**: Unicode box-drawing characters
- **Icon Set**: Nerd Font symbol compatibility
- **Performance**: Optimized for modern terminals

## 🏢 About Zypher Systems

This configuration is a product of **Zypher Systems**, designed to provide professional-grade system information displays. 

**Created by:** Zypher  
**Version:** Enhanced Edition  
**License:** Open Source  

## 📚 Resources

- [Fastfetch GitHub Repository](https://github.com/fastfetch-cli/fastfetch)
- [Fastfetch Documentation](https://github.com/fastfetch-cli/fastfetch/wiki)
- [Nerd Fonts](https://nerdfonts.com/)
- [ANSI Color Codes Reference](https://en.wikipedia.org/wiki/ANSI_escape_code)

---

*This configuration represents the cutting edge of terminal aesthetics and system monitoring. Experience the difference with Zypher Systems.*
