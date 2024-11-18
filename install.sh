#!/bin/bash

set -xe

SOUND_DEFAULT="${SOUND_DEFAULT:-$HOME/.local/share/sounds/__custom/uncategorized/appointed.oga}"
SOUND_CALENDAR="${SOUND_CALENDAR:-$HOME/.local/share/sounds/__custom/uncategorized/solemn.oga}"


cd "$(dirname $(realpath $0))"

# Move the executable into place
sudo cp gaudible.py /usr/bin/gaudible

# Copy sound into place
sudo mkdir /usr/share/sounds/Marvin
sudo cp marvin_notif.mp3 /usr/share/sounds/Marvin

# CentOS 7 doesn't support systemctl --user
if [[ "$(cat /etc/redhat-release)" =~ ^CentOS\ Linux\ release\ 7 ]]; then
	cat <<-EOT > ~/.config/autostart/gaudible.desktop
		[Desktop Entry]
		Name=gaudible
		Type=Application
		Exec=/usr/bin/gaudible -v --sound "marvin:/usr/share/sounds/Marvin/marvin_notif.mp3"
		Hidden=false
		NoDisplay=false
		Terminal=false
		X-GNOME-Autostart-enabled=true
	EOT
	exit
fi

# Create systemd service
mkdir -p ~/.config/systemd/user
cat <<-EOT > ~/.config/systemd/user/gaudible.service
	[Service]
	ExecStart=/usr/bin/gaudible -v --sound "marvin:/usr/share/sounds/Marvin/marvin_notif.mp3"
	Restart=always
	NoNewPrivileges=true

	[Install]
	WantedBy=default.target
EOT

# Enable systemd service
systemctl --user daemon-reload
systemctl --user stop gaudible
systemctl --user enable --now gaudible

# Check if it's running
journalctl --user -u gaudible -e --since '-1min'
