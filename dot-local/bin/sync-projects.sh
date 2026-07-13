#!/usr/bin/env bash

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

shopt -s nullglob
projects=("$HOME"/dev/*/ "$HOME"/.dotfiles/)

desktop-escape() {
	local value="$1"
	value=${value//\\/\\\\}
	value=${value//$'\n'/\\n}
	value=${value//$'\r'/\\r}
	value=${value//$'\t'/\\t}
	printf '%s' "$value"
}

desktop-exec-arg() {
	local value="$1"
	value=${value//\\/\\\\}
	value=${value//\"/\\\"}
	value=${value//\`/\\\`}
	value=${value//\$/\\\$}
	value=${value//%/%%}
	printf '"%s"' "$value"
}

gvariant-string() {
	local value="$1"
	value=${value//\\/\\\\}
	value=${value//\'/\\\'}
	printf "'%s'" "$value"
}

gvariant-string-list() {
	local value
	local separator=""
	printf '['
	for value in "$@"; do
		printf '%s' "$separator"
		gvariant-string "$value"
		separator=', '
	done
	printf ']'
}

is-gnome-session() {
	local desktop="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-${GDMSESSION:-}}}"
	[[ ":${desktop,,}:" == *":gnome:"* ]]
}

sync-gnome-app-folder() {
	local folderId="KittySessions"
	local folderPath="/org/gnome/desktop/app-folders/folders/$folderId/"
	local folderChildren
	local apps

	if ! command -v gsettings >/dev/null 2>&1; then
		echo "Skipping GNOME app folder sync: gsettings not found"
		return 0
	fi

	if ! command -v dconf >/dev/null 2>&1; then
		echo "Skipping GNOME app folder sync: dconf not found"
		return 0
	fi

	apps=$(gvariant-string-list "$@")
	folderChildren=$(gsettings get org.gnome.desktop.app-folders folder-children 2>/dev/null) || {
		echo "Skipping GNOME app folder sync: unable to read app-folder settings"
		return 0
	}

	if [[ $folderChildren != *"'${folderId}'"* ]]; then
		if [[ $folderChildren == "@as []" || $folderChildren == "[]" ]]; then
			folderChildren=$(gvariant-string-list "$folderId")
		else
			folderChildren="${folderChildren%]}"
			folderChildren+=", $(gvariant-string "$folderId")]"
		fi

		gsettings set org.gnome.desktop.app-folders folder-children "$folderChildren" || {
			echo "Skipping GNOME app folder sync: unable to update folder list"
			return 0
		}
	fi

	gsettings set org.gnome.desktop.app-folders.folder:"$folderPath" name "$folderId" || return 0
	gsettings set org.gnome.desktop.app-folders.folder:"$folderPath" apps "$apps" || return 0
	echo "Updated GNOME app folder $folderId"
}

desktop-content() {
	local projectPath="$1"
	local projectName
	local definedSession
	projectName=$(basename "$projectPath")

	definedSession=$(find "$HOME/.dotfiles/dot-config/kitty/sessions/" -type f -name "$projectName.kitty-session" -print -quit)

	if [ -z "$definedSession" ]; then
		definedSession="$HOME/.dotfiles/dot-config/kitty/sessions/generic.kitty-session"
	fi

	printf '%s\n' \
		'[Desktop Entry]' \
		'Type=Application' \
		"Name=$(desktop-escape "$projectName")" \
		"Exec=kitty --detach --title $(desktop-exec-arg "$projectName") --directory $(desktop-exec-arg "$projectPath") --session $(desktop-exec-arg "$definedSession")" \
		'Icon=kitty' \
		'Terminal=false' \
		'StartupNotify=true' \
		'Categories=System;TerminalEmulator;' \
		'TryExec=kitty' \
		'X-Kitty-Session-Managed=true' \
		"X-Kitty-Session-Path=$(desktop-escape "$definedSession")"
}

mkdir -p "$APP_DIR"
deletedCount=$(find "$APP_DIR" -type f -name "auto-kitty-session*" -printf . | wc -c)
find "$APP_DIR" -type f -name "auto-kitty-session*" -delete
echo "Deleted $deletedCount old auto kitty sessions"

createdCount=0
desktopIds=()
for project in "${projects[@]}"; do
	pname=$(basename "$project")
	desktopId="auto-kitty-session_$pname.desktop"
	desktopFilepath="$APP_DIR/$desktopId"
	desktop-content "$project" >"$desktopFilepath"
	desktopIds+=("$desktopId")
	echo "Created $desktopFilepath"
	createdCount=$((createdCount + 1))
done
echo "Created $createdCount new desktop project files"

# force update of desktop entries by DE
update-desktop-database ~/.local/share/applications

if is-gnome-session; then
	sync-gnome-app-folder "${desktopIds[@]}"
else
	echo "Skipping GNOME app folder sync: not running inside GNOME"
fi
