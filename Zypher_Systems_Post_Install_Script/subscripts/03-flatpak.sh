#!/bin/bash
echo "📦 [3/7] Setting up Flatpaks..."

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

FLATPAKS=(
    it.mijorus.gearlever
    com.github.tchx84.Flatseal
    com.google.Chrome
    com.discordapp.Discord
)

for pkg in "${FLATPAKS[@]}"; do
    flatpak install -y flathub "$pkg"
done