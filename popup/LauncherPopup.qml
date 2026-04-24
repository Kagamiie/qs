import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../"

PanelWindow {
    id: root
    required property Colors c

    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    function toggle() {
        visible = !visible;
        if (visible) {
            query = "";
            searchInput.forceActiveFocus();
        }
    }

    property string query: ""
    property var apps: []
    property var filtered: []

    Component.onCompleted: loadApps.running = true

    Process {
        id: loadApps
        command: ["bash", "-c", "IFS=: read -ra dirs <<< \"$XDG_DATA_DIRS\"; " + "for dir in \"${dirs[@]}\"; do " + "[ -d \"$dir/applications\" ] || continue; " + "for f in \"$dir\"/applications/*.desktop; do " + "[ -f \"$f\" ] || continue; " + "n=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2); " + "e=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2 | sed 's/ *%[a-zA-Z]//g'); " + "i=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2); " + "nd=$(grep -m1 '^NoDisplay=' \"$f\" | cut -d= -f2); " + "[ \"$nd\" != 'true' ] && [ -n \"$n\" ] && [ -n \"$e\" ] && echo \"$n|$e|$i\"; " + "done; done | sort -u"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                const parts = line.split("|");
                if (parts.length >= 2 && parts[0].trim() !== "") {
                    root.apps.push({
                        name: parts[0].trim(),
                        exec: parts[1].trim(),
                        icon: parts[2]?.trim() ?? ""
                    });
                }
            }
        }
        onExited: {
            root.apps = root.apps;
            root.updateFilter();
        }
    }

    function updateFilter() {
        const q = query.toLowerCase();
        if (q === "") {
            filtered = apps.slice(0, 12);
            return;
        }
        const starts = apps.filter(a => a.name.toLowerCase().startsWith(q));
        const contains = apps.filter(a => !a.name.toLowerCase().startsWith(q) && a.name.toLowerCase().includes(q));
        filtered = [...starts, ...contains].slice(0, 12);
    }

    onQueryChanged: updateFilter()

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        x: 16
        y: 10
        width: 540
        height: 240
        color: c.bg0
        border.width: 1
        border.color: c.bg3
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12

            // Search bar — fixée en haut
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    color: c.bg1
                    border.width: 1
                    border.color: c.bg3

                    TextInput {
                        id: searchInput
                        anchors {
                            fill: parent
                            leftMargin: 10
                            rightMargin: 10
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        color: c.fg0
                        font.pixelSize: 12
                        font.family: "JetBrains Mono Nerd Font"
                        onTextChanged: root.query = text

                        Keys.onEscapePressed: root.visible = false
                        Keys.onReturnPressed: {
                            if (root.filtered.length > 0)
                                launch(root.filtered[0]);
                        }

                        Text {
                            visible: searchInput.text === ""
                            text: "Search..."
                            color: c.fg2
                            font: searchInput.font
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // Grid — alignée en haut à gauche
            Grid {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                columns: 3
                spacing: 8
                property real cellW: (540 - 32 - 16) / 3

                Repeater {
                    model: root.filtered
                    delegate: Rectangle {
                        required property var modelData

                        width: parent.cellW
                        height: 36
                        color: itemMa.containsMouse ? c.bg2 : c.bg1
                        border.width: 1
                        border.color: itemMa.containsMouse ? c.accent : c.bg1

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }
                            spacing: 8

                            // Icône
                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 18
                                height: 18
                                source: modelData.icon.startsWith("/") ? modelData.icon : "image://icon/" + modelData.icon
                                fillMode: Image.PreserveAspectFit
                                visible: modelData.icon !== ""
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 34
                                text: modelData.name
                                font.pixelSize: 11
                                font.family: "JetBrains Mono Nerd Font"
                                color: itemMa.containsMouse ? c.accent : c.fg0
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: itemMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.launch(modelData)
                        }
                    }
                }
            }

            // Pousse tout en haut
            Item {
                Layout.fillHeight: true
            }
        }
    }

    Process {
        id: launchProc
        property string cmd: ""
        command: ["sh", "-c", cmd + " &"]
    }

    function launch(app) {
        launchProc.cmd = app.exec;
        launchProc.running = true;
        visible = false;
    }
}
