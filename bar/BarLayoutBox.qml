import QtQuick
import Quickshell
import Quickshell.Io
import "../"

Item {
    required property var    screen
    required property Colors c
    implicitWidth:  32
    implicitHeight: parent.height

    Process {
        id: wsUp
        command: ["niri", "msg", "action", "focus-workspace-up"]
    }
    Process {
        id: wsDown
        command: ["niri", "msg", "action", "focus-workspace-down"]
    }

    Rectangle {
        anchors.fill: parent
        color: ma.containsMouse ? c.bg2 : c.bg1

        Text {
            anchors.centerIn: parent
            text: "󰙀"
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 11
            color: c.fg0
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onWheel: wh => {
                if (wh.angleDelta.y > 0)
                    wsUp.running = true
                else
                    wsDown.running = true
            }
        }
    }
}
