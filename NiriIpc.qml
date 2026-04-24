import QtQuick
import Quickshell
import Quickshell.Io
import "./"

Item {
    id: root
    required property var screen

    property var workspaces: []
    property var windows:    []

    // ── Workspaces ────────────────────────────────────────────────────────
    Timer {
        interval: 150; repeat: true; running: true; triggeredOnStart: true
        onTriggered: {
            root.wsBuffer = ""
            wsProc.running = true
        }
    }

    property string wsBuffer: ""

    Process {
        id: wsProc
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.workspaces = JSON.parse(this.text)
                        .map(ws => ({
                            id:         ws.id,
                            idx:        ws.idx ?? ws.id,
                            isFocused:  ws.is_focused ?? false,
                            hasWindows: (ws.window_count ?? 0) > 0,
                            output:     ws.output ?? ""
                        }))
                        .filter(ws => !root.screen || ws.output === root.screen.name)
                        .sort((a, b) => a.idx - b.idx)
                } catch(_) {}
            }
        }
    }

    // ── Windows ───────────────────────────────────────────────────────────
    Timer {
        interval: 150; repeat: true; running: true; triggeredOnStart: true
        onTriggered: winProc.running = true
    }

    Process {
        id: winProc
        command: ["niri", "msg", "--json", "windows"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.windows = JSON.parse(this.text)
                        .map(w => ({
                            id:      w.id,
                            title:   w.title || w.app_id || "Window",
                            focused: w.is_focused ?? false,
                            col:     w.layout?.pos_in_scrolling_layout?.[0] ?? 9999
                        }))
                        .sort((a, b) => a.col - b.col)
                } catch(_) {}
            }
        }
    }

    // ── Actions ───────────────────────────────────────────────────────────
    Process {
        id: focusWsProc
        property string wsId: ""
        command: ["niri", "msg", "action", "focus-workspace", wsId]
    }

    Process {
        id: focusWinProc
        property string winId: ""
        command: ["niri", "msg", "action", "focus-window", "--id", winId]
    }

    function focusWorkspace(id) {
        focusWsProc.wsId = id.toString()
        focusWsProc.running = true
    }

    function focusWindow(id) {
        focusWinProc.winId = id.toString()
        focusWinProc.running = true
    }
}
