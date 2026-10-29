//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtMultimedia

Scope {
    id: root
    
    // System clock singleton-like property
    property string clockText: {
        var time = Qt.formatDateTime(clock.date, "HH:mm:ss")
        var ampm = clock.date.getHours() >= 12 ? " PM" : " AM"
        return time + ampm
    }
    
    property bool calendarVisible: false
    property bool streamVisible: false
    property bool wireVisible: false
    property bool weatherVisible: false
    property string weatherAirport: ""
    property string weatherText: "WX: --"
    property string weatherDescription: ""
    property string weatherFeelsLike: ""
    property string weatherLocation: ""
    property var weatherPanel: null
    property string wireReportText: "Click refresh to load the latest report."
    property string wireReportError: ""
    property var wirePanel: null
    property var streamPanel: null
    property bool bjjVisible: false
    property var bjjPanel: null
    property var bjjNext: null
    property var bjjUpcoming: []
    property string bjjError: ""
    property bool bjjLoading: false
    property bool bjjInSession: root.bjjNext !== null && clock.date.getTime() >= root.bjjNext.startEpoch * 1000
    property string bjjCountdown: {
        if (!root.bjjNext)
            return ""
        var now = clock.date.getTime()
        if (now >= root.bjjNext.startEpoch * 1000)
            return "ends in " + root.bjjDuration(root.bjjNext.endEpoch * 1000 - now)
        return "in " + root.bjjDuration(root.bjjNext.startEpoch * 1000 - now)
    }
    property url streamUrl: ""
    property var calendarPanel: null
    property int shownMonth: clock.date.getMonth()
    property int shownYear: clock.date.getFullYear()
    property var calendarDays: {
        var firstDay = new Date(shownYear, shownMonth, 1)
        var days = []
        for (var i = 0; i < 42; i++) {
            var date = new Date(firstDay.getFullYear(), firstDay.getMonth(), i - firstDay.getDay() + 1)
            days.push({
                number: date.getDate(),
                inMonth: date.getMonth() === firstDay.getMonth(),
                today: date.getFullYear() === clock.date.getFullYear()
                    && date.getMonth() === clock.date.getMonth()
                    && date.getDate() === clock.date.getDate()
            })
        }
        return days
    }
    
    // System resources
    property string memoryText: "RAM: --%"
    property string cpuText: "CPU: --%"
    property string focusedWindowTitle: "Desktop"
    property var focusedWindowId: null
    property var niriWindows: ({})
    property string volumeText: {
        var sink = Pipewire.defaultAudioSink
        if (!sink || !sink.ready || !sink.audio)
            return "VOL: --%"
        return sink.audio.muted ? "VOL: MUTED" : "VOL: " + Math.round(sink.audio.volume * 100) + "%"
    }

    function updateFocusedWindowTitle(id) {
        var win = id === null ? null : niriWindows[String(id)]
        focusedWindowTitle = win && win.title ? win.title : "Desktop"
    }

    function loadWireReport() {
        wireReportText = "Loading the latest Wire Report…"
        wireReportError = ""
        wireReportProcess.running = true
    }

    function bjjDuration(ms) {
        var minutes = Math.max(1, Math.round(ms / 60000))
        if (minutes < 60)
            return minutes + "m"
        var hours = Math.floor(minutes / 60)
        var rest = minutes % 60
        if (hours < 24)
            return rest === 0 ? hours + "h" : hours + "h " + rest + "m"
        var days = Math.floor(hours / 24)
        var restHours = hours % 24
        return restHours === 0 ? days + "d" : days + "d " + restHours + "h"
    }

    function loadBjj(force) {
        if (bjjProcess.running)
            return
        bjjLoading = true
        bjjError = ""
        bjjProcess.command = ["sh", "-c", "python3 $HOME/.config/quickshell/scripts/bjj_next.py" + (force ? " --force" : "")]
        bjjProcess.running = true
    }

    function loadWeather() {
        if (!/^[A-Z]{3,4}$/.test(weatherAirport)) {
            weatherText = "WX: AIRPORT?"
            weatherDescription = "Set a three- or four-letter airport_code in personal-info.conf."
            return
        }
        weatherText = "WX: …"
        weatherProcess.running = true
    }
    
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    
    // Pipewire for volume control
    property var pipewire: Pipewire
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // Follow focused-window and title changes from Niri's IPC event stream.
    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    var event = JSON.parse(data)

                    if (event.WindowsChanged) {
                        var windows = ({})
                        var focusedId = null
                        for (var win of event.WindowsChanged.windows) {
                            windows[String(win.id)] = win
                            if (win.is_focused)
                                focusedId = win.id
                        }
                        root.niriWindows = windows
                        root.focusedWindowId = focusedId
                        root.updateFocusedWindowTitle(focusedId)
                    } else if (event.WindowOpenedOrChanged) {
                        var changedWindow = event.WindowOpenedOrChanged.window
                        root.niriWindows[String(changedWindow.id)] = changedWindow
                        if (changedWindow.is_focused || String(changedWindow.id) === String(root.focusedWindowId))
                            root.updateFocusedWindowTitle(changedWindow.id)
                    } else if (event.WindowClosed) {
                        var closedId = event.WindowClosed.id
                        delete root.niriWindows[String(closedId)]
                        if (String(closedId) === String(root.focusedWindowId)) {
                            root.focusedWindowId = null
                            root.updateFocusedWindowTitle(null)
                        }
                    } else if (event.WindowFocusChanged) {
                        root.focusedWindowId = event.WindowFocusChanged.id ?? null
                        root.updateFocusedWindowTitle(root.focusedWindowId)
                    }
                } catch (error) {
                    console.warn("Could not parse Niri event:", error)
                }
            }
        }
    }
    
    // Load the private stream URL from the ignored, machine-local settings file.
    Process {
        id: personalInfoProcess
        command: ["sh", "-c", "sed -n 's/^rtsp_url=//p' $HOME/.config/quickshell/personal-info.conf"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var url = this.text.trim()
                if (url.length > 0)
                    root.streamUrl = url
            }
        }
    }

    // Load the private airport code used for weather lookups.
    Process {
        command: ["sh", "-c", "sed -n 's/^airport_code=//p' $HOME/.config/quickshell/personal-info.conf"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.weatherAirport = this.text.trim().toUpperCase()
                if (/^[A-Z]{3,4}$/.test(root.weatherAirport))
                    root.loadWeather()
                else
                    root.weatherText = "WX: AIRPORT?"
            }
        }
    }

    // Fetch current conditions from wttr.in (no API key required).
    Process {
        id: weatherProcess
        command: ["curl", "-fsS", "--max-time", "10", "https://wttr.in/" + root.weatherAirport + "?format=j1"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var result = JSON.parse(this.text)
                    var current = result.current_condition[0]
                    root.weatherText = "WX: " + current.temp_F + "°F"
                    root.weatherDescription = current.weatherDesc[0].value
                    root.weatherFeelsLike = current.FeelsLikeF + "°F"
                    root.weatherLocation = result.nearest_area[0].areaName[0].value
                } catch (error) {
                    root.weatherText = "WX: N/A"
                    root.weatherDescription = "Weather data unavailable."
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.weatherText = "WX: N/A"
                root.weatherDescription = "Could not fetch weather. Check your connection and refresh."
            }
        }
    }

    Timer {
        interval: 15 * 60 * 1000
        running: /^[A-Z]{3,4}$/.test(root.weatherAirport)
        repeat: true
        onTriggered: root.loadWeather()
    }

    // Fetch the next Shark Pit BJJ class from the gym's weekly schedule.
    Process {
        id: bjjProcess
        command: ["sh", "-c", "python3 $HOME/.config/quickshell/scripts/bjj_next.py"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                if (output.length === 0)
                    return
                try {
                    var data = JSON.parse(output)
                    root.bjjLoading = false
                    if (!data.ok) {
                        root.bjjError = data.error || "Could not read the class schedule."
                        return
                    }
                    root.bjjError = ""
                    root.bjjNext = data.next
                    root.bjjUpcoming = data.upcoming
                } catch (error) {
                    root.bjjError = "Could not read the class schedule."
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                if (output.length > 0)
                    root.bjjError = output
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.bjjLoading = false
            if (exitCode !== 0 && root.bjjError.length === 0)
                root.bjjError = "Could not reach the Shark Pit schedule."
        }
    }

    Timer {
        interval: 60 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.loadBjj()
    }

    Component.onCompleted: root.loadBjj()

    // Fetch the newest Wire Report when the bar widget is clicked.
    Process {
        id: wireReportProcess
        command: ["python3", "/home/mao/Projects/s2u/grab_latest_wire.py"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                if (output.length > 0)
                    root.wireReportText = output
            }
        }

        stderr: StdioCollector {
            onStreamFinished: root.wireReportError = this.text.trim()
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.wireReportText = root.wireReportError.length > 0
                    ? root.wireReportError
                    : "Could not fetch the latest Wire Report."
        }
    }

    // Memory usage monitor
    Process {
        id: memProcess
        command: ["sh", "-c", "free | awk '/Mem:/ {printf \"%.0f\", $3/$2 * 100}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.memoryText = "RAM: " + this.text + "%"
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: memProcess.running = true
    }
    
    // CPU load monitor
    Process {
        id: cpuProcess
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1 | tr -d '[:space:]'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.cpuText = "CPU: " + this.text.trim() + "%"
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: cpuProcess.running = true
    }
    
    // Panel window for each screen
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: rootPanel
            required property var modelData
            screen: modelData
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            implicitHeight: 30
            
            Rectangle {
                anchors.fill: parent
                color: "black"
                border.color: "#00ff00"
                border.width: 2
                
                Item {
                    anchors.fill: parent
                    
                    // Left side - System tray
                    Row {
                        id: systemTrayRow
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        spacing: 5
                        
                        Repeater {
                            model: SystemTray.items
                            
                            MouseArea {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 16
                                height: 16
                                
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                
                                onClicked: {
                                    if (mouse.button === Qt.LeftButton)
                                        modelData.activate()
                                    else if (mouse.button === Qt.RightButton)
                                        modelData.display(rootPanel, 0, 0)
                                }
                                
                                IconImage {
                                    anchors.fill: parent
                                    source: modelData.icon
                                }
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: systemTrayRow.right
                        anchors.leftMargin: 32
                        anchors.right: clockMouseArea.left
                        anchors.rightMargin: 16
                        text: root.focusedWindowTitle
                        color: "#00ff00"
                        font.pixelSize: 16
                        font.family: "JetBrains Mono"
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.NoWrap
                    }
                    
                    // Center - Clock
                    MouseArea {
                        id: clockMouseArea
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: clockLabel.implicitWidth + 12
                        height: parent.height
                        
                        onClicked: {
                            root.streamVisible = false
                            root.wireVisible = false
                            root.weatherVisible = false
                            root.bjjVisible = false
                            if (!root.calendarVisible) {
                                root.calendarPanel = rootPanel
                                root.shownMonth = clock.date.getMonth()
                                root.shownYear = clock.date.getFullYear()
                            }
                            root.calendarVisible = !root.calendarVisible
                        }
                        
                        Text {
                            id: clockLabel
                            anchors.centerIn: parent
                            text: clockText
                            color: "#00ff00"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono"
                        }
                    }
                    
                    // Right side - Stream, resources, and volume
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        spacing: 20

                        MouseArea {
                            id: wireMouseArea
                            anchors.verticalCenter: parent.verticalCenter
                            width: wireLabel.implicitWidth + 12
                            height: rootPanel.height
                            onClicked: {
                                root.calendarVisible = false
                                root.streamVisible = false
                                root.weatherVisible = false
                                root.bjjVisible = false
                                if (!root.wireVisible) {
                                    root.wirePanel = rootPanel
                                    root.loadWireReport()
                                }
                                root.wireVisible = !root.wireVisible
                            }

                            Text {
                                id: wireLabel
                                anchors.centerIn: parent
                                text: "WIRE"
                                color: "#00ff00"
                                font.pixelSize: 16
                                font.family: "JetBrains Mono"
                            }
                        }

                        MouseArea {
                            id: streamMouseArea
                            anchors.verticalCenter: parent.verticalCenter
                            width: streamLabel.implicitWidth + 12
                            height: rootPanel.height
                            onClicked: {
                                root.calendarVisible = false
                                root.wireVisible = false
                                root.weatherVisible = false
                                root.bjjVisible = false
                                if (!root.streamVisible)
                                    root.streamPanel = rootPanel
                                root.streamVisible = !root.streamVisible
                            }

                            Text {
                                id: streamLabel
                                anchors.centerIn: parent
                                text: "CAM"
                                color: "#00ff00"
                                font.pixelSize: 16
                                font.family: "JetBrains Mono"
                            }
                        }
                        
                        MouseArea {
                            id: weatherMouseArea
                            anchors.verticalCenter: parent.verticalCenter
                            width: weatherLabel.implicitWidth + 12
                            height: rootPanel.height
                            onClicked: {
                                root.calendarVisible = false
                                root.streamVisible = false
                                root.wireVisible = false
                                root.bjjVisible = false
                                if (!root.weatherVisible) {
                                    root.weatherPanel = rootPanel
                                    if (/^[A-Z]{3,4}$/.test(root.weatherAirport))
                                        root.loadWeather()
                                }
                                root.weatherVisible = !root.weatherVisible
                            }

                            Text {
                                id: weatherLabel
                                anchors.centerIn: parent
                                text: root.weatherText
                                color: "#00ff00"
                                font.pixelSize: 16
                                font.family: "JetBrains Mono"
                            }
                        }

                        MouseArea {
                            id: bjjMouseArea
                            anchors.verticalCenter: parent.verticalCenter
                            width: bjjLabel.implicitWidth + 12
                            height: rootPanel.height
                            onClicked: {
                                root.calendarVisible = false
                                root.streamVisible = false
                                root.wireVisible = false
                                root.weatherVisible = false
                                if (!root.bjjVisible) {
                                    root.bjjPanel = rootPanel
                                    root.loadBjj()
                                }
                                root.bjjVisible = !root.bjjVisible
                            }

                            Text {
                                id: bjjLabel
                                anchors.centerIn: parent
                                text: "BJJ"
                                color: "#00ff00"
                                font.pixelSize: 16
                                font.family: "JetBrains Mono"
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.cpuText
                            color: "#00ff00"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono"
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "|"
                            color: "#00ff00"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono"
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.memoryText
                            color: "#00ff00"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono"
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "|"
                            color: "#00ff00"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono"
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.volumeText
                            color: "#00ff00"
                            font.pixelSize: 16
                            font.family: "JetBrains Mono"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var sink = Pipewire.defaultAudioSink
                                    if (sink && sink.ready && sink.audio)
                                        sink.audio.muted = !sink.audio.muted
                                }
                                onWheel: function(wheel) {
                                    var sink = Pipewire.defaultAudioSink
                                    if (sink && sink.ready && sink.audio) {
                                        var steps = wheel.angleDelta.y / 120
                                        sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + steps * 0.05))
                                    }
                                    wheel.accepted = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        visible: root.streamVisible
        anchor.window: root.streamPanel
        anchor.rect.x: root.streamPanel ? root.streamPanel.width - width - 10 : 0
        anchor.rect.y: root.streamPanel ? root.streamPanel.height + 6 : 0
        width: 960
        height: 640
        grabFocus: true
        onVisibleChanged: {
            if (!visible) {
                root.streamVisible = false
                streamPlayer.stop()
            } else if (root.streamUrl.toString().length > 0) {
                Qt.callLater(function() { streamPlayer.play() })
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            border.color: "#00ff00"
            border.width: 2

            VideoOutput {
                id: streamVideo
                anchors.fill: parent
                anchors.margins: 2
                fillMode: VideoOutput.PreserveAspectFit
            }

            MediaPlayer {
                id: streamPlayer
                source: root.streamVisible ? root.streamUrl : ""
                videoOutput: streamVideo
                onMediaStatusChanged: {
                    if (root.streamVisible && mediaStatus === MediaPlayer.LoadedMedia)
                        play()
                }
                onErrorOccurred: (error, errorString) => {
                    console.warn("RTSP playback error:", errorString)
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.streamUrl.toString().length === 0
                    || streamPlayer.mediaStatus === MediaPlayer.NoMedia
                    || streamPlayer.mediaStatus === MediaPlayer.InvalidMedia
                    || streamPlayer.mediaStatus === MediaPlayer.LoadingMedia
                text: root.streamUrl.toString().length === 0
                    ? "Set rtsp_url in personal-info.conf"
                    : streamPlayer.mediaStatus === MediaPlayer.LoadingMedia
                        ? "Connecting to RTSP stream…"
                        : streamPlayer.errorString.length > 0 ? streamPlayer.errorString : "RTSP stream unavailable"
                color: "#00ff00"
                font.family: "JetBrains Mono"
                font.pixelSize: 14
            }
        }
    }

    PopupWindow {
        visible: root.wireVisible
        anchor.window: root.wirePanel
        anchor.rect.x: root.wirePanel ? root.wirePanel.width - width - 10 : 0
        anchor.rect.y: root.wirePanel ? root.wirePanel.height + 6 : 0
        implicitWidth: 720
        implicitHeight: Math.max(150, reportText.implicitHeight + 66)
        grabFocus: true
        onVisibleChanged: if (!visible) root.wireVisible = false

        Rectangle {
            anchors.fill: parent
            color: "black"
            border.color: "#00ff00"
            border.width: 2

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Row {
                    width: parent.width
                    height: 28
                    spacing: 12

                    Text {
                        width: parent.width - refreshButton.width - parent.spacing
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        text: "LATEST WIRE REPORT"
                        color: "#00ff00"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Rectangle {
                        id: refreshButton
                        width: 84
                        height: parent.height
                        color: wireReportProcess.running ? "#224422" : "#00ff00"
                        radius: 2

                        Text {
                            anchors.centerIn: parent
                            text: wireReportProcess.running ? "LOADING" : "REFRESH"
                            color: wireReportProcess.running ? "#00ff00" : "black"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: !wireReportProcess.running
                            onClicked: root.loadWireReport()
                        }
                    }
                }

                Flickable {
                    width: parent.width
                    height: parent.height - 38
                    clip: true
                    contentWidth: width
                    contentHeight: reportText.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    Text {
                        id: reportText
                        width: parent.width
                        text: root.wireReportText
                        color: "#00ff00"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 16
                        wrapMode: Text.Wrap
                        textFormat: Text.PlainText
                    }
                }
            }
        }
    }

    PopupWindow {
        visible: root.weatherVisible
        anchor.window: root.weatherPanel
        anchor.rect.x: root.weatherPanel ? root.weatherPanel.width - width - 10 : 0
        anchor.rect.y: root.weatherPanel ? root.weatherPanel.height + 6 : 0
        implicitWidth: 300
        implicitHeight: 150
        grabFocus: true
        onVisibleChanged: if (!visible) root.weatherVisible = false

        Rectangle {
            anchors.fill: parent
            color: "black"
            border.color: "#00ff00"
            border.width: 2

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text {
                    width: parent.width
                    text: root.weatherLocation.length > 0 ? "WEATHER — " + root.weatherLocation : "WEATHER — " + root.weatherAirport
                    color: "#00ff00"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: root.weatherFeelsLike.length > 0
                        ? root.weatherText + "  ·  Feels like " + root.weatherFeelsLike + " — " + root.weatherDescription
                        : root.weatherDescription.length > 0 ? root.weatherDescription : "Loading current conditions…"
                    color: "#00ff00"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                }

                Text {
                    text: "Click the bar weather reading to refresh"
                    color: "#77aa77"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }
            }
        }
    }

    PopupWindow {
        id: bjjPopup
        visible: root.bjjVisible
        anchor.window: root.bjjPanel
        anchor.rect.x: root.bjjPanel ? root.bjjPanel.width - width - 10 : 0
        anchor.rect.y: root.bjjPanel ? root.bjjPanel.height + 6 : 0
        implicitWidth: 380
        implicitHeight: bjjBody.implicitHeight + 28
        grabFocus: true
        onVisibleChanged: if (!visible) root.bjjVisible = false

        Rectangle {
            anchors.fill: parent
            color: "black"
            border.color: "#00ff00"
            border.width: 2

            Column {
                id: bjjBody
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Row {
                    width: parent.width
                    height: 24
                    spacing: 12

                    Text {
                        width: parent.width - bjjRefreshButton.width - parent.spacing
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        text: "SHARK PIT BJJ"
                        color: "#00ff00"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Rectangle {
                        id: bjjRefreshButton
                        width: 76
                        height: parent.height
                        color: root.bjjLoading ? "#224422" : "#00ff00"
                        radius: 2

                        Text {
                            anchors.centerIn: parent
                            text: root.bjjLoading ? "LOADING" : "REFRESH"
                            color: root.bjjLoading ? "#00ff00" : "black"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: !root.bjjLoading
                            onClicked: root.loadBjj(true)
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#227722"
                }

                Text {
                    width: parent.width
                    visible: root.bjjError.length > 0
                    text: root.bjjError
                    color: "#ff6666"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }

                Text {
                    visible: root.bjjNext !== null
                    text: root.bjjInSession ? "IN SESSION NOW" : "NEXT ADULT CLASS"
                    color: "#77aa77"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Text {
                    width: parent.width
                    visible: root.bjjNext !== null
                    text: root.bjjNext ? root.bjjNext.title : ""
                    color: "#00ff00"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 17
                    font.bold: true
                    wrapMode: Text.Wrap
                }

                Text {
                    width: parent.width
                    visible: root.bjjNext !== null
                    text: root.bjjNext ? root.bjjNext.whenLabel : ""
                    color: "#00ff00"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                }

                Row {
                    width: parent.width
                    visible: root.bjjNext !== null
                    spacing: 12

                    Text {
                        text: root.bjjCountdown
                        color: "#00ff00"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Text {
                        visible: root.bjjNext !== null && root.bjjNext.note.length > 0
                        text: root.bjjNext ? root.bjjNext.note : ""
                        color: "#77aa77"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }
                }

                Text {
                    width: parent.width
                    visible: root.bjjNext === null && root.bjjError.length === 0
                    text: root.bjjLoading ? "Loading the class schedule…" : "No adult classes scheduled in the next two weeks."
                    color: "#77aa77"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    visible: root.bjjNext !== null && root.bjjUpcoming.length > 0
                    color: "#227722"
                }

                Text {
                    visible: root.bjjNext !== null && root.bjjUpcoming.length > 0
                    text: "ALL UPCOMING"
                    color: "#77aa77"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }

                Repeater {
                    model: root.bjjUpcoming

                    Row {
                        required property var modelData
                        width: bjjBody.width
                        spacing: 10

                        Text {
                            width: 96
                            text: modelData.rowLabel
                            color: "#77aa77"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width - parent.spacing - 96
                            text: modelData.title
                            color: "#00ff00"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: "Weekly schedule · all times ET"
                    color: "#447744"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }
            }
        }
    }

    PopupWindow {
        visible: root.calendarVisible
        anchor.window: root.calendarPanel
        anchor.rect.x: root.calendarPanel ? root.calendarPanel.width / 2 - width / 2 : 0
        anchor.rect.y: root.calendarPanel ? root.calendarPanel.height + 6 : 0
        implicitWidth: 320
        height: 300
        grabFocus: true
        onVisibleChanged: if (!visible) root.calendarVisible = false

        Item {
            anchors.fill: parent
            clip: true

            Rectangle {
                id: calendarSurface
                width: parent.width
                height: parent.height
                y: 0
                color: "black"
                border.color: "#00ff00"
                border.width: 2

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Click a month abbreviation to view that month.
                    Grid {
                        columns: 12
                        width: parent.width
                        height: 24
                        columnSpacing: 2

                        Repeater {
                            model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

                            Item {
                                required property int index
                                required property string modelData
                                width: (parent.width - 22) / 12
                                height: 24

                                Rectangle {
                                    anchors.fill: parent
                                    color: root.shownMonth === index ? "#00ff00" : "transparent"
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: root.shownMonth === index ? "black" : "#00ff00"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.shownMonth = index
                                }
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: root.shownYear
                        color: "#00ff00"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 14
                    }

                    Grid {
                        columns: 7
                        width: parent.width
                        height: 24

                        Repeater {
                            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                            Text {
                                required property string modelData
                                width: 42
                                height: 24
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData
                                color: "#00ff00"
                                font.family: "JetBrains Mono"
                            }
                        }
                    }

                    Grid {
                        columns: 7
                        width: parent.width
                        height: 6 * 32

                        Repeater {
                            model: root.calendarDays

                            Text {
                                required property var modelData

                                width: 42
                                height: 32
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: modelData.number
                                color: modelData.today ? "white" : modelData.inMonth ? "#00ff00" : "#447744"
                                font.family: "JetBrains Mono"
                                font.bold: modelData.today
                            }
                        }
                    }
                }
            }
        }
    }
}
