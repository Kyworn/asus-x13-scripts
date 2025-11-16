# ASUS X13 Power Management Scripts

Bash scripts for advanced power and performance management on ASUS laptops with hybrid graphics and AMD Ryzen CPUs. These scripts provide easy-to-use interfaces for GPU switching and CPU power profile management.

## Features

### GPU Switching (`switch.sh`)
- **Integrated Mode**: iGPU only for maximum battery life
- **Hybrid Mode**: Automatic GPU switching for balanced performance
- **AsusMuxDgpu Mode**: Discrete GPU only for maximum performance
- Real-time GPU mode detection and switching

### CPU Power Management (`Wcpu.sh`)
- **5 Power Profiles**: Ultra Eco, Eco, Mid, Standard, Performance
- **AMD Ryzen Optimization**: Fine-tuned TDP, current, and temperature limits
- **RyzenAdj Integration**: Advanced AMD processor control
- **Visual Profile Display**: Easy-to-read status with emojis
- **Auto-sudo**: Automatically elevates privileges when needed

## Power Profiles

| Profile | STAPM Limit | Use Case | Battery Life |
|---------|-------------|----------|--------------|
| 🔋 **Ultra** | 10W | Web browsing, documents | Maximum |
| 🌱 **Eco** | 25W | Light multitasking | Extended |
| ⚖️ **Mid** | 45W | Daily work, video playback | Balanced |
| ⚙️ **Standard** | 55W | Development, photo editing | Moderate |
| 🚀 **Performance** | 60W | Gaming, rendering, compilation | Minimum |

## Prerequisites

### GPU Switching
- `supergfxctl` installed (see [asus-debian-tools](https://github.com/Kyworn/asus-debian-tools))
- ASUS laptop with hybrid graphics (Integrated + Discrete GPU)

### CPU Power Management
- AMD Ryzen processor
- `ryzenadj` installed

#### Install RyzenAdj

```bash
# Install dependencies
sudo apt install build-essential libpci-dev cmake

# Clone and build ryzenadj
git clone https://github.com/FlyGoat/RyzenAdj.git
cd RyzenAdj
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make
sudo make install

# Verify installation
ryzenadj --info
```

## Installation

```bash
# Clone the repository
git clone https://github.com/Kyworn/asus-x13-scripts.git
cd asus-x13-scripts

# Make scripts executable
chmod +x switch.sh Wcpu.sh

# Optional: Move to PATH for system-wide access
sudo cp switch.sh /usr/local/bin/gpu-switch
sudo cp Wcpu.sh /usr/local/bin/cpu-profile
```

## Usage

### GPU Switching

```bash
# Check current GPU mode
./switch.sh

# Switch to Integrated GPU (battery saving)
./switch.sh Integrated

# Switch to Hybrid mode (balanced)
./switch.sh Hybrid

# Switch to Discrete GPU (performance)
./switch.sh AsusMuxDgpu
```

**Example output:**
```
Changement vers le mode Hybrid en cours...
Le mode est maintenant : Hybrid
```

### CPU Power Profiles

```bash
# Check current profile
./Wcpu.sh status

# Apply power profiles
./Wcpu.sh ultra      # 10W - Maximum battery
./Wcpu.sh eco        # 25W - Extended battery
./Wcpu.sh mid        # 45W - Balanced
./Wcpu.sh standard   # 55W - Default
./Wcpu.sh perf       # 60W - Maximum performance
```

**Example output:**
```
Profil Actuel : ⚙️ Standard (55W)
```

## Advanced Configuration

### Custom CPU Profile

You can modify `Wcpu.sh` to create custom profiles:

```bash
custom)
    echo "Application du profil 'Custom'..."
    sudo ryzenadj \
        --stapm-limit=30000 \      # Long-term power limit (mW)
        --fast-limit=35000 \        # Short-term power limit (mW)
        --slow-limit=32000 \        # Medium-term power limit (mW)
        --tctl-temp=85              # Temperature limit (°C)
    echo "Profil 'Custom' appliqué."
    ;;
```

### Power Limit Explanations

- **STAPM Limit**: Sustained power limit (long-term average)
- **Fast Limit**: Peak power limit (short bursts)
- **Slow Limit**: Medium-term power average
- **APU Slow Limit**: Integrated graphics power limit
- **VRM Current**: Voltage regulator current limits
- **TCtl Temp**: CPU temperature ceiling

### Systemd Integration

Create a systemd service to apply profile at boot:

```bash
# Create service file
sudo nano /etc/systemd/system/cpu-profile.service
```

```ini
[Unit]
Description=Apply CPU Power Profile
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cpu-profile standard
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable cpu-profile.service
sudo systemctl start cpu-profile.service
```

## Use Cases

### Maximum Battery Life
```bash
./switch.sh Integrated    # Use integrated GPU only
./Wcpu.sh ultra           # 10W TDP limit
```

### Development Work
```bash
./switch.sh Hybrid        # Automatic GPU switching
./Wcpu.sh standard        # 55W TDP
```

### Gaming Session
```bash
./switch.sh AsusMuxDgpu   # Dedicated GPU
./Wcpu.sh perf            # 60W TDP
```

### Video Playback
```bash
./switch.sh Integrated    # iGPU handles video well
./Wcpu.sh eco             # 25W is sufficient
```

## Benchmarks

Performance impact of CPU profiles (tested on Ryzen 9 5900HS):

| Profile | Cinebench R23 | Temps (°C) | Consommation |
|---------|---------------|------------|--------------|
| Ultra | ~4,500 pts | 65°C | ~15W |
| Eco | ~7,800 pts | 70°C | ~30W |
| Mid | ~10,500 pts | 75°C | ~48W |
| Standard | ~12,000 pts | 82°C | ~58W |
| Performance | ~13,200 pts | 88°C | ~65W |

*Your results may vary depending on CPU model and cooling solution.*

## Troubleshooting

### GPU switching not working
```bash
# Check supergfxctl service
systemctl status supergfxd

# Reinstall supergfxctl
# See: https://github.com/Kyworn/asus-debian-tools
```

### RyzenAdj returns errors
```bash
# Check if running as root
sudo ryzenadj --info

# Verify SMU (System Management Unit) access
dmesg | grep -i ryzen
```

### Changes not taking effect
```bash
# GPU mode changes require logout/reboot
# CPU profile changes are instant but verify with:
sudo ryzenadj --info | grep STAPM
```

## Compatibility

### Tested On
- ASUS ROG Flow X13 (GV301)
- ASUS ROG Zephyrus G14
- ASUS ROG Zephyrus G15

### Should Work On
- Any ASUS laptop with supergfxctl support
- Any AMD Ryzen laptop (for CPU power management)

## Safety Notes

⚠️ **Important**:
- Lowering power limits is always safe
- Increasing beyond 60W may cause thermal throttling or reduced lifespan
- Monitor temperatures with `sensors` or `btop`
- The CPU will protect itself by throttling if limits are exceeded

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Test thoroughly on your hardware
4. Commit changes (`git commit -m 'Add feature'`)
5. Push to branch (`git push origin feature/improvement`)
6. Open a Pull Request

## Related Projects

- [asus-debian-tools](https://github.com/Kyworn/asus-debian-tools) - Installation scripts for supergfxctl and asusctl
- [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) - AMD Ryzen power management tool
- [supergfxctl](https://gitlab.com/asus-linux/supergfxctl) - GPU switching daemon
- [ASUS Linux](https://asus-linux.org/) - Community resources

## License

MIT License - Feel free to use and modify

## Author

Created by [Kyworn](https://github.com/Kyworn)

## Acknowledgments

- [FlyGoat](https://github.com/FlyGoat) for RyzenAdj
- [asus-linux.org](https://asus-linux.org/) community
- AMD for detailed Ryzen documentation
