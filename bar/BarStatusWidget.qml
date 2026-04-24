import QtQuick
import Quickshell.Io
import "../"
import "../popup/"

Item {
    required property Colors c
    implicitHeight: 24
    implicitWidth:  box.implicitWidth

    FontLoader { id: gwnce; source: "/home/ks/.local/share/fonts/gwnce.ttf" }

    property int volume: 0
    property bool muted: false
    property int percent: 0
    property string status: "Unknown"

    onVolumeChanged: volumePopup.show(volume)

    Timer {
        interval: 250; repeat: true; running: true; triggeredOnStart: true
        onTriggered: volProc.running = true
    }

    Process {
        id: volProc
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1; pactl get-sink-mute @DEFAULT_SINK@"]
        stdout: SplitParser {
            splitMarker: "\n"
            property bool first: true
            onRead: line => {
                if (line.trim() === "") return
                if (first) {
                    volume = parseInt(line.trim())
                    first = false
                } else {
                    muted = line.includes("yes")
                    first = true
                }
            }
        }
    }

    Timer {
        interval: 30000; repeat: true; running: true; triggeredOnStart: true
        onTriggered: batProc.running = true
    }

    Process {
        id: batProc
        command: ["sh", "-c", "echo $(cat /sys/class/power_supply/BAT0/capacity) $(cat /sys/class/power_supply/BAT0/status)"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                const parts = line.trim().split(" ")
                if (parts.length >= 2) {
                    percent = parseInt(parts[0])
                    status = parts[1]
                }
            }
        }
    }

    Rectangle {
        id: box
        anchors.centerIn: parent
        height: 24
        color: c.bg1
        border.width: 1
        border.color: c.bg3
        implicitWidth: row.implicitWidth + 24

        Row {
            id: row
            anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 12 }
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: gwnce.name
                font.pixelSize: 14
                color: (muted || volume === 0) ? c.red : c.fg0
                text: {
                    if (muted || volume === 0) return "\ue013"
                    return volume < 50 ? "\ue014" : "\ue015"
                }
            }

            Item { width: 4; height: 1 }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: gwnce.name
                font.pixelSize: 16
                color: percent <= 20 ? c.red : c.fg0
                text: {
                    if (status === "Charging") return "\ue00b"
                    if (status === "Full")     return "\ue00c"
                    if (percent >= 70)         return "\ue008"
                    if (percent >= 40)         return "\ue007"
                    if (percent >= 20)         return "\ue006"
                    if (percent > 0)           return "\ue005"
                    return "\ue004"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 10
                color: percent <= 20 ? c.red : c.fg3
                text: percent + "%"
            }
        }
    }
}
