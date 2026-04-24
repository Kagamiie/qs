import QtQuick
import QtQuick.Layouts
import "../"

Item {
    id: bar
    required property var screen
    required property var launcher
    anchors.fill: parent

    FontLoader {
        id: gwnce
        source: "/home/ks/.local/share/fonts/gwnce.ttf"
    }

    property Colors c: Colors {}

    NiriIpc {
        id: ipc
        screen: bar.screen
    }

    Rectangle {
        anchors.fill: parent
        color: c.bg0
    }

    Rectangle {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 1
        color: c.bg3
        z: 10
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 16
            rightMargin: 16
        }
        spacing: 0

        // GAUCHE
        RowLayout {
            spacing: 0
            Layout.fillWidth: false

            BarTagList {
                screen: bar.screen
                c: bar.c
                ipc: ipc
            }
            Item {
                width: 8
            }

            Rectangle {
                Layout.fillHeight: true
            }
            BarLauncher {
                c: bar.c
                launcher: bar.launcher
            }

            Item {
                width: 8
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: c.bg3
        }

        // CENTRE
        Item {
            Layout.fillWidth: true
            height: parent.height
            Rectangle {
                anchors.fill: parent
                color: c.bg1 + "80"
            }
            BarTaskList {
                anchors {
                    fill: parent
                    leftMargin: 9
                    rightMargin: 9
                }
                c: bar.c
                ipc: ipc
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: c.bg3
        }

        // DROITE
        RowLayout {
            spacing: 12
            Layout.fillWidth: false
            Layout.leftMargin: 12

            BarSystray {
                c: bar.c
            }
            BarKeyboard {
                c: bar.c
            }
            BarStatusWidget {
                c: bar.c
            }
            BarClock {
                c: bar.c
            }

            Rectangle {
                width: 1
                height: 14
                color: c.bg3
            }
        }
    }
}
