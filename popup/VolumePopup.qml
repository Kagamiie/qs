import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../"

PanelWindow {
    mask: Region {
        item: popup
    }

    id: root
    required property Colors c

    visible: false
    color: "transparent"

    property int sliderValue: 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    anchors { top: true; left: true; right: true; bottom: true }

    function show(val) {
        sliderValue = val
        visible = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.visible = false
    }

    Rectangle {
        x: parent.width - 48
        y: 44
        width: 28
        height: 120
        color: c.bg1
        border.width: 1
        border.color: c.bg3

        Text {
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 6 }
            text: sliderValue + "%"
            font.pixelSize: 9
            font.family: "JetBrains Mono Nerd Font"
            color: c.fg2
        }

        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom; bottomMargin: 8
            }
            width: 4
            height: 90
            color: c.bg3

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: parent.height * root.sliderValue / 100
                radius: 2
                color: c.accent
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => {
                const val = Math.max(0, Math.min(100, Math.round((1 - mouse.y / height) * 100)))
                sliderValue = val
                setVol.command = ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + val + "%"]
                setVol.running = true
                hideTimer.restart()
            }
            onPositionChanged: mouse => {
                if (pressed) {
                    const val = Math.max(0, Math.min(100, Math.round((1 - mouse.y / height) * 100)))
                    sliderValue = val
                    setVol.command = ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + val + "%"]
                    setVol.running = true
                    hideTimer.restart()
                }
            }
        }
    }

    Process {
        id: setVol
        command: ["sh", "-c", ""]
    }
}
