# TikTok Live Stream Monitor

🎥 **Automatically monitor and record TikTok live streams when your favorite creators go live!**

This tool monitors multiple TikTok streamers simultaneously and automatically starts recording when they begin streaming. It captures both video content and detailed interaction data (comments, gifts, follows, etc.) for research and archival purposes.

## ✨ Features

### 🎯 **Core Functionality**
- **Multi-streamer monitoring** - Track dozens of streamers simultaneously
- **Automatic recording** - Starts recording the moment someone goes live
- **Stability tracking** - Prevents false starts with configurable stability thresholds
- **Graceful shutdown** - Properly finalizes all recordings when stopped
- **Hot configuration reload** - Edit streamers list without restarting

### 📊 **Data Capture**
- **Video recording** - Full stream video in MP4 format
- **Interaction data** - Comments, gifts, follows, shares, joins, likes
- **CSV export** - All interaction data saved in structured format
- **Session logging** - Comprehensive monitoring statistics and events

### 🛡️ **Reliability Features**
- **Disconnect handling** - Smart reconnection and confirmation delays
- **Error recovery** - Robust error handling with automatic retries
- **Resource monitoring** - Tracks file descriptors and system limits
- **Cross-platform** - Works on Windows, macOS, and Linux

### 🔒 **Privacy & Authentication**
- **Session ID support** - Access age-restricted and private streams
- **Configurable data centers** - Choose optimal TikTok endpoints
- **Per-streamer authentication** - Individual session IDs per creator
- **Protected Web UI** - Optional HTTP Basic auth on the whole web interface

## 🚀 Quick Start

### Prerequisites
```bash
# Install Python 3.8+ and pip
python3 --version
```

### Installation
```bash
# Clone the repository
git clone https://github.com/pietervanboheemen/tiktoklive_monitor.git
cd tiktoklive_monitor

# Install required package
pip install -r requirements.txt

# Create required directories
mkdir recordings
```

### First Run
```bash
# Start with default configuration (creates config file)
python3 main.py

# Edit the configuration file
nano streamers_config.json

# Start monitoring with your config
python3 main.py -c streamers_config.json
```

## 📖 Usage

### Basic Commands
```bash
# Monitor with default settings
python3 main.py

# Use custom configuration file
python3 main.py -c my_streamers.json

# Add session ID for authenticated access
python3 main.py -s your_session_id -c config.json

# Override settings from command line
python3 main.py -c config.json -i 30 -o /recordings --verbose
```

### Command Line Options
| Option | Description | Example |
|--------|-------------|---------|
| `-c, --config` | Configuration file path | `-c streamers.json` |
| `-s, --session-id` | TikTok session ID | `-s abc123xyz` |
| `-d, --data-center` | TikTok data center | `-d eu-ttp2` |
| `-i, --check-interval` | Check interval (seconds) | `-i 45` |
| `-o, --output-dir` | Output directory | `-o /recordings` |
| `-t, --test` | Test mode (activates breakpoints for debugging purposes) | `-t` |
| `-v, --verbose` | Enable verbose logging | `-v` |

### Runtime Control
Create these files to control the monitor while running:

```bash
# Stop monitoring gracefully
echo "user_requested" > stop_monitor.txt

# Pause for 60 seconds
echo "60" > pause_monitor.txt

# Check current status
cat monitor_status.txt
```

## ⚙️ Configuration

### Basic Configuration File
```json
{
  "streamers": {
    "@creator1": {
      "enabled": true,
      "session_id": null,
      "tags": ["gaming", "research"],
      "notes": "Popular gaming streamer"
    },
    "@creator2": {
      "enabled": true,
      "session_id": "custom_session_id",
      "tags": ["music"],
      "notes": "Music content creator"
    }
  },
  "settings": {
    "check_interval_seconds": 60,
    "max_concurrent_recordings": 15,
    "pause_monitoring_if_failure_seconds": 300,
    "output_directory": "recordings",
    "record_video": true,
    "session_id": "global_session_id",
    "tt_target_idc": "us-eastred",
    "whitelist_sign_server": "tiktok.eulerstream.com",
    "stability_threshold": 3,
    "min_action_cooldown_seconds": 90,
    "disconnect_confirmation_delay_seconds": 30,
    "individual_check_timeout": 20,
    "max_retries": 2
  }
}
```

### Configuration Options

#### Streamer Settings
- **`enabled`** - Whether to monitor this streamer
- **`session_id`** - Individual session ID (overrides global)
- **`tags`** - Categories for organization
- **`notes`** - Description or notes

#### Global Settings
- **`check_interval_seconds`** - How often to check if streamers are live
- **`max_concurrent_recordings`** - Maximum simultaneous recordings
- **`pause_monitoring_if_failure_seconds`** - Time to pause the monitor if TikTok is banning requests
- **`output_directory`** - Directory to store the recordings
- **`record_video`** - Whether to save the video stream, see [Recording data without video](#recording-data-without-video)
- **`session_id`** - Session ID to access 18+ content
- **`tt_target_idc`** - The data center holding the user's account credentials (e.g. eu-ttp2)
- **`whitelist_sign_server`** - The Sign server to sign requests to TikTok
- **`stability_threshold`** - Consecutive checks before starting recording
- **`min_action_cooldown_seconds`** - Minimum time between actions
- **`disconnect_confirmation_delay_seconds`** - Time to wait before confirming disconnect
- **`individual_check_timeout`** - Time to wait for the reply to a request to see whether a user is live
- **`max_retries`** - How many times to retry a request to see whether a user is live

### Recording data without video

Setting `record_video` to `false` stops the video stream from being saved, while everything else is
recorded as usual: comments, gifts, follows, shares, joins and likes still go to their CSV files, and
the session statistics are unchanged. Only the `.mp4` file is not produced.

```json
{
  "settings": {
    "record_video": false
  }
}
```

Use it when the interaction data is what matters, the video is by far the largest part of a recording
in disk and bandwidth, and capturing someone's video is also the most sensitive part of it.

The setting is read when a stream is connected, so it is picked up by the automatic config reload,
without restarting the monitor. Recordings that are already running are not affected, they keep
writing the video file they started, the change applies to the recordings that begin after it.

The option is global, it applies to every streamer. If it is missing from the configuration file the
video is recorded, so existing setups keep their current behaviour.

## 📂 Output Files

### Generated Files
```
recordings/
├── creator1_20240703_143022.mp4              # Video recording
├── creator1_20240703_143022_comments.csv     # Chat comments
├── creator1_20240703_143022_gifts.csv        # Gifts and donations
├── creator1_20240703_143022_follows.csv      # New followers
├── creator1_20240703_143022_shares.csv       # Stream shares
├── creator1_20240703_143022_joins.csv        # Viewer joins
└── creator1_20240703_143022_likes.csv        # Likes and reactions

logs/
├── monitoring_sessions_20240703.csv               # Session statistics
├── monitor_20240703.log                          # Application logs

monitor_status.txt                            # Current status
```

### CSV Data Format
Each interaction type is saved with timestamps and user details:

**Comments CSV:**
```csv
timestamp,user_id,nickname,comment,follower_count
2024-07-03T14:30:22,user123,StreamFan,Great stream!,1250
```

**Gifts CSV:**
```csv
timestamp,user_id,nickname,gift_name,repeat_count,streakable,streaking
2024-07-03T14:30:25,user456,Supporter,Rose,5,true,false
```

## 🔧 Advanced Usage

### Session ID Setup
To access age-restricted or private streams, you need a TikTok session ID:

1. **Get Session ID:**
   - Log into TikTok in your browser
   - Open Developer Tools (F12)
   - Go to Application/Storage → Cookies
   - Copy the `sessionid` value

2. **Add to Configuration:**
   ```json
   {
     "settings": {
       "session_id": "your_session_id_here"
     }
   }
   ```

3. **Or use command line:**
   ```bash
   python3 main.py -s your_session_id_here
   ```

### Multiple Data Centers
For better performance, you can specify TikTok data centers:

```bash
# US East Coast
python3 main.py -d us-eastred

# Europe
python3 main.py -d eu-ttp2

# Asia Pacific
python3 main.py -d sg-ttp1
```

### Production Deployment

#### Using systemd (Linux)
Create `/etc/systemd/system/tiktok-monitor.service`:

```ini
[Unit]
Description=TikTok Live Stream Monitor
After=network.target

[Service]
Type=simple
User=your_user
WorkingDirectory=/path/to/tiktoklive_monitor
ExecStart=/usr/bin/python3 main.py -c production_config.json
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable tiktok-monitor
sudo systemctl start tiktok-monitor
```

#### Using the provided scripts from command line
You can also run the app using two provided script:
- `startDevelopment.sh` for development purposes
- `startProduction.sh` for running the app in a `screen` process with logging to file.

Both scripts will warn you if the web UI is left unauthenticated, see [Protecting the Web UI](#protecting-the-web-ui).

Both scripts will make use of an API_KEY in the `.api_key` file if one is present. This api key is for euler signing service, and allows to increase the rate limits. You can create your free api key [here](https://www.eulerstream.com/dashboard).

#### Using Docker
Use the script `startDocker.sh` with `-r` (run) option or `-p` (production).
This script will build a python image and run the container, using the provided `Dockerfile`, which takes care of installing dependencies and running the app (with API_KEY if present, as described above).

The script also maps the port 8000 in the container to localhost:8000, so you can see the web UI if you can access the server's 8000 port, for example with an ssh tunnel. If `WEB_UI_USERNAME` and `WEB_UI_PASSWORD` are set in your shell they are passed to the container, see [Protecting the Web UI](#protecting-the-web-ui).

You can show the container log running the script with the option `-l`, and copy saved conf files from the container to your current directory with the option `-g`. Monitoring can be stopped via the Web UI or running the script with the option `-s`.

#### Using Docker Compose (Dokploy)

The `docker-compose.yml` file deploys the app on [Dokploy](https://docs.dokploy.com/docs/core/docker-compose).
Create a Compose service pointing at this repository, then set these variables in the Environment tab:

| Variable | Required | Description |
|----------|----------|-------------|
| `WEB_UI_USERNAME` | yes | Username for the Basic auth on the web interface |
| `WEB_UI_PASSWORD` | yes | Password for the Basic auth, use a long random one |
| `WEB_UI_REALM` | no | Text shown in the browser login prompt |
| `TZ` | no | Timezone used by the schedule, defaults to `Europe/Amsterdam` |

The deployment **fails to start** if the credentials are missing, since the interface is reachable
from the internet once you attach a domain and must never run unauthenticated. Attach the domain to
the `monitor` service from the Dokploy UI, which adds the Traefik routing for you.

Persistent data lives in Docker named volumes, which survive redeploys and are the only form of
storage Dokploy is able to back up:

| Volume | Container path | Contents |
|--------|----------------|----------|
| `recordings` | `/app/recordings` | Recorded `.mp4` files and their per-stream CSV files |
| `data` | `/app/data` | `streamers_config.json` and the copies written by the Save button |
| `logs` | `/app/logs` | `monitor_[date].log` and `monitoring_sessions_[date].csv` |

Dokploy prefixes them with the project name, so they appear as `<project>_recordings` and so on. To
read a file straight from a volume, for instance to pull a recording off the server:

```bash
docker run --rm -v <project>_recordings:/v -v "$PWD":/out alpine cp /v/<recording>.mp4 /out/
```

The configuration lives on the volume rather than in the image, so the streamer list survives a
redeploy. This is done with the `CONFIG_FILE` variable, which `startDevelopment.sh` and
`startProduction.sh` also honour outside of Docker:

```bash
CONFIG_FILE=/path/to/streamers_config.json ./startProduction.sh
```

On the first deployment the volume is empty, so the app creates a configuration file with the default
content, which you then edit from the web UI or in place with
`docker exec -it <container> vi /app/data/streamers_config.json`, the monitor reloads it on the fly.


## 📊 Monitoring & Analytics

### Session Statistics
The tool automatically generates session logs with statistics:

```csv
timestamp,username,action,status,duration_minutes,comments_count,gifts_count
2024-07-03T14:30:22,@creator1,recording_started,success,0,0,0
2024-07-03T15:45:10,@creator1,recording_stopped_live_end,success,74.8,342,89
```

### Status Monitoring
Check `monitor_status.txt` for real-time status:

```json
{
  "timestamp": "2024-07-03T14:30:22",
  "status": "monitoring",
  "active_recordings": 2,
  "currently_recording": ["@creator1", "@creator2"],
  "pending_disconnects": 0
}
```

## The Web UI

Via the web UI running on `localhost:8000` you can see which users are enabled, online, and being recorded.

You can also add streamers, and stop and pause the monitor. You can further inspect the recordings directory to see 
what files have been written to disk, preview tables, and download them if you want.

Finally, there is a schedule to pause the monitor between two time slots, for example at night.

All pause functionality does not stop running recordings, just the monitor for users going live.

### Protecting the Web UI

The web interface exposes the recordings and the monitor controls, so it should not be reachable by
anyone but you. It supports HTTP Basic authentication, enabled by providing a username and a password
through the environment:

```bash
export WEB_UI_USERNAME=admin
export WEB_UI_PASSWORD=a_long_random_password
export WEB_UI_REALM="TikTok Live Monitor"   # optional, shown in the browser prompt

./startProduction.sh     # or ./startDevelopment.sh
```

`startDevelopment.sh` and `startProduction.sh` also accept the credentials in a `.web_ui_auth` file,
in the same spirit as the `.api_key` file, which avoids exporting the password in every shell. The
file holds a single line, and only the first colon separates the two values, so the password may
itself contain colons:

```bash
echo 'admin:a_long_random_password' > .web_ui_auth
chmod 600 .web_ui_auth
```

The environment takes precedence over the file. `.web_ui_auth` is listed in `.gitignore` and in
`.dockerignore`, so the credentials are never committed nor baked into the Docker image.

With Docker, the variables are picked up from your shell by `startDocker.sh` and passed to the
container:

```bash
WEB_UI_USERNAME=admin WEB_UI_PASSWORD=a_long_random_password ./startDocker.sh -p
```

Once set, every request is challenged, including the API endpoints, the static files and the
recordings download and preview pages. Your browser asks for the credentials on the first visit.

If no credentials are provided, the interface stays open to anyone who can reach port 8000, the start
scripts warn you and a warning is logged at startup. Credentials are only read from the environment, never from the
configuration file, because config files are written to disk by the save button in the UI and copied
out of the container by `startDocker.sh -g`.

Note that Basic auth sends the credentials with every request, base64 encoded but not encrypted, so
keep the port closed on the server and reach the UI through an ssh tunnel, or put it behind a reverse
proxy with HTTPS.


## 🔍 Troubleshooting

### Common Issues

#### Import Errors
```bash
# Ensure all __init__.py files exist
touch config/__init__.py monitor/__init__.py recording/__init__.py utils/__init__.py

# Test imports
python3 -c "from monitor.stream_monitor import StreamMonitor; print('OK')"
```

#### Connection Issues
```bash
# Enable verbose logging
python3 main.py --verbose

# Check session ID validity
python3 main.py -s your_session_id --verbose
```

#### Permission Errors
```bash
# Linux/macOS: Fix recording directory permissions
chmod 755 recordings/
chown -R $USER:$USER recordings/

# Windows: Run as administrator if needed
```

#### High CPU Usage
- Increase `check_interval_seconds` in configuration
- Reduce `max_concurrent_recordings`
- Monitor system resources with `--verbose`

### Debug Mode
```bash
# Maximum verbosity for troubleshooting
python3 main.py --verbose -c config.json

# you can enable breakpoints for unusual situation with
python3 main.py --test -c config.json

# Check specific component
python3 -c "
from config.config_manager import ConfigManager
config = ConfigManager('config.json')
print('Config loaded successfully')
"
```

## 🤝 Contributing

### Development Setup
```bash
# Clone and setup
git clone https://github.com/pietervanboheemen/tiktoklive_monitor.git
cd tiktoklive_monitor

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate     # Windows

# Install dependencies
pip install TikTokLive

### Code Structure

tiktoklive_monitor/
├── main.py                    # Entry point
├── config/                    # Configuration management
│   ├── config_manager.py      # Config loading and validation
│   └── signal_handler.py      # Graceful shutdown handling
├── monitor/                   # Core monitoring logic
│   ├── stream_monitor.py      # Main monitoring coordinator
│   ├── stream_checker.py      # Live status checking
│   └── stability_tracker.py   # Stream stability tracking
├── recording/                 # Recording functionality
│   ├── stream_recorder.py     # Recording coordinator
│   ├── csv_writer.py          # Data persistence
│   └── video_handler.py       # Video recording management
├── ui/                        # Web interface
│   ├── app.py                 # Main file running the server and app
│   ├── static                 # Directory containing html and javascript
│       ├── index.html         # Main UI page
│       ├── schedule.html      # Tab for the activity schedule
│       ├── streamers.css      # CSS for both pages
│       ├── streamers.js       # Javascript functions for the main page
│       ├── schedule.js        # Javascript functions for the schedule page
│       ├── Sortable.min.js    # Library hosted in repo for simplicity
└── utils/                     # Utility modules
    ├── logging_setup.py       # Logging configuration
    ├── session_logger.py      # Session event logging
    ├── status_manager.py      # Status file management
    ├── system_utils.py        # System utilities
    ├── file_utils.py          # File operations
    └── patches.py             # Patches for TikTokLiveClient
```

### Submitting Changes
1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit with clear messages: `git commit -m "Add new feature"`
5. Push and create a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](https://mit-license.org) file for details.

## ⚠️ Disclaimer

This tool is for educational and research purposes only. Please ensure you:

- **Respect creators' content** and privacy
- **Follow TikTok's Terms of Service**
- **Comply with local laws** regarding content recording
- **Use responsibly** and ethically
- **Do not redistribute** recorded content without permission

The developers are not responsible for any misuse of this tool.

## 🙏 Acknowledgments

- **TikTokLive Python Library** - Core TikTok API functionality
- **Contributors** - Everyone who has contributed to this project
- **TikTok Creator Community** - For creating amazing content

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/pietervanboheemen/tiktoklive_monitor/issues)
- **Discussions:** [GitHub Discussions](https://github.com/pietervanboheemen/tiktoklive_monitor/discussions)
- **Documentation:** [Wiki](https://github.com/pietervanboheemen/tiktoklive_monitor/wiki)

---

⭐ **If this tool helps you, please give it a star on GitHub!** ⭐
