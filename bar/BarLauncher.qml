import QtQuick
import "../"

Item {
    Connections {
        target: launcherPopup
        function onVisibleChanged() {
            ic.color = launcherPopup.visible ? c.fg3 : c.fg2;
            lbl.color = launcherPopup.visible ? c.fg3 : c.fg2;
        }
    }

    required property Colors c
    required property var launcher
    implicitHeight: parent.height
    implicitWidth: row.implicitWidth + 16

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: launcher.toggle()
        onEntered: {
            ic.color = c.accent;
            lbl.color = c.accent;
        }
        onExited: {
            ic.color = launcherPopup.visible ? c.fg3 : c.fg2;
            lbl.color = launcherPopup.visible ? c.fg3 : c.fg2;
        }
    }

    Row {
        id: row
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 8
        }
        spacing: 6

        Text {
            id: ic
            anchors.verticalCenter: parent.verticalCenter
            text: "\ue01d"
            font.family: gwnce.name
            font.pixelSize: 14
            color: c.fg2
        }
        Text {
            id: lbl
            anchors.verticalCenter: parent.verticalCenter
            text: "Search"
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 12
            color: c.fg2
        }
    }
}
