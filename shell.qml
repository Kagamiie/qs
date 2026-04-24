import QtQuick
import Quickshell
import Quickshell.Wayland

import "./"
import "./bar/"
import "./popup/"

ShellRoot {
    id: root

    property Colors c: Colors {}

    LauncherPopup {
        id: launcherPopup
        c: root.c
    }
    SystrayPopup {
        id: systrayPopup
        c: root.c
    }
    VolumePopup {
        id: volumePopup
        c: root.c
    }

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            height: 38
            color: "transparent"
            exclusiveZone: height
            Bar {
                anchors.fill: parent
                screen: win.screen
                c: root.c
                launcher: launcherPopup
            }
        }
    }
}
