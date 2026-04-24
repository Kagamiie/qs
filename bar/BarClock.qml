import QtQuick
import Quickshell
import "../"

Item {
    required property Colors c
    implicitHeight: parent.height
    implicitWidth:  row.implicitWidth

    SystemClock { id: clk; precision: SystemClock.Seconds }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        // onClicked: timePanel.toggle()   // wire up when TimePanel is added
        onEntered: dateTxt.color = c.accent
        onExited:  dateTxt.color = c.fg0
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Text {
            id: dateTxt
            color: c.fg0
            font.pixelSize: 12
            font.family: "JetBrains Mono Nerd Font"
            text: {
                clk.seconds  // trigger re-eval every second
                const d = new Date()
                const months = [
                    "January","February","March","April","May","June",
                    "July","August","September","October","November","December"
                ]
                const day = d.getDate()
                const suf = (day > 3 && day < 21) ? "th"
                          : ({1:"st", 2:"nd", 3:"rd"}[day % 10] ?? "th")
                return months[d.getMonth()] + " " + day + suf
            }
        }

        Text {
            color: c.fg0
            font.pixelSize: 12
            font.bold: true
            font.family: "JetBrains Mono Nerd Font"
            text: clk.hours.toString().padStart(2, "0") + ":"
                + clk.minutes.toString().padStart(2, "0")
        }
    }
}
