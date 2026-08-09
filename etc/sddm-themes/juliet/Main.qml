// Juliet SDDM theme — minimal, and deliberately free of any org.kde.* import.
//
// The previous incarnation was a copy of Breeze and imported
// org.kde.plasma.components, org.kde.plasma.private.keyboardindicator and
// org.kde.breeze.components. Those are what kept plasma-workspace and
// libplasma installed on a machine that runs niri: the greeter was the last
// thing tethering the system to Plasma. This version imports only QtQuick and
// QtQuick.Controls, both shipped with Qt itself.
//
// The visual language mirrors symlinked/config/hypr/hyprlock.conf so the login
// screen and the lock screen (Super+Alt+L) read as the same surface: solid
// black, Iosevka Nerd Font Mono, and a single bordered box whose top edge is
// notched by an "Authenticate" legend.

// Delegates below reference outer ids (sessionBox) and declare their model
// data as required properties; Bound is what makes that well-defined.
pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root

    // SDDM sizes the root item to the screen; these are only fallbacks.
    width: 1920
    height: 1080
    color: "black"

    // Palette and metrics kept deliberately in sync with hyprlock.conf.
    readonly property color fgDim: Qt.rgba(216 / 255, 222 / 255, 233 / 255, 0.80)
    readonly property color fgBright: "white"
    readonly property color fgClock: Qt.rgba(200 / 255, 200 / 255, 200 / 255, 1.0)
    readonly property color fgFail: Qt.rgba(1, 100 / 255, 100 / 255, 1.0)
    readonly property string mono: config.font || "Iosevka Nerd Font Mono"

    function refreshClock() {
        clock.text = Qt.formatDateTime(new Date(), "dddd, MMMM d - hh:mm AP")
    }

    // SDDM runs exactly one PAM conversation at a time. Because pam_fprintd sits
    // first in /etc/pam.d/sddm, that conversation opens by blocking on the
    // reader — so every further sddm.login() is rejected outright ("Existing
    // authentication ongoing, aborting" in the journal) and the keypress looks
    // like it did nothing at all. Tracking the in-flight state lets the greeter
    // explain itself instead of swallowing Enter in silence.
    property bool authInFlight: false

    function showStatus(message, isError) {
        statusText.text = message
        statusText.isError = isError
    }

    function attemptLogin() {
        if (root.authInFlight) {
            root.showStatus("Still authenticating — touch the reader, or wait for it to time out", false)
            return
        }
        root.authInFlight = true
        root.showStatus("", false)
        sddm.login(userField.text, passwordField.text, sessionBox.currentIndex)
    }

    // The username comes prefilled from userModel.lastUser, so the password is
    // the field that actually needs typing. Deferred through Qt.callLater
    // because userModel can populate *after* Component.onCompleted runs —
    // checking synchronously would see an empty field and focus the username.
    function applyInitialFocus() {
        if (userField.text === "") {
            userField.forceActiveFocus()
        } else {
            passwordField.forceActiveFocus()
        }
    }

    // theme.conf may point `background` at an image file. Left empty — the
    // default — it stays the solid black the lock screen uses.
    Image {
        anchors.fill: parent
        source: config.background || ""
        visible: source.toString() !== ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // ----------------------------------------------------------------- clock
    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: authBox.top
        anchors.bottomMargin: 300
        color: root.fgClock
        font.family: root.mono
        font.pixelSize: 18

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: root.refreshClock()
        }
    }

    // -------------------------------------------------------------- auth box
    Rectangle {
        id: authBox
        width: 500
        height: 100
        color: "transparent"
        border.color: root.fgBright
        border.width: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -150

        // A black patch sitting astride the border turns the label into a
        // notch, the way a fieldset legend interrupts its frame.
        Rectangle {
            color: "black"
            height: 22
            width: legendLabel.implicitWidth + 20
            anchors.left: parent.left
            anchors.leftMargin: 45
            anchors.verticalCenter: parent.top

            Text {
                id: legendLabel
                anchors.centerIn: parent
                text: "Authenticate"
                color: root.fgDim
                font.family: root.mono
                font.pixelSize: 16
            }
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 30
            anchors.rightMargin: 30

            // The username is an editable field rather than static text so the
            // greeter still works if userModel.lastUser comes back empty.
            Row {
                anchors.left: parent.left
                anchors.bottom: parent.verticalCenter
                anchors.bottomMargin: 5
                spacing: 8

                Text {
                    text: "Username:"
                    color: root.fgDim
                    font.family: root.mono
                    font.pixelSize: 14
                    font.bold: true
                }

                TextInput {
                    id: userField
                    width: 250
                    color: root.fgBright
                    font.family: root.mono
                    font.pixelSize: 14
                    font.bold: true
                    text: userModel.lastUser || ""
                    onAccepted: root.attemptLogin()
                    KeyNavigation.tab: passwordField

                    // Initial focus is decided centrally by root.applyInitialFocus
                    // rather than grabbed here. This field used to call
                    // forceActiveFocus() in its own Component.onCompleted, which
                    // fights the root handler for the keyboard and made the
                    // outcome depend on completion order.
                }
            }

            Row {
                anchors.left: parent.left
                anchors.top: parent.verticalCenter
                anchors.topMargin: 5
                spacing: 8

                Text {
                    text: "Password:"
                    color: root.fgDim
                    font.family: root.mono
                    font.pixelSize: 14
                    font.bold: true
                }

                TextInput {
                    id: passwordField
                    width: 250
                    color: root.fgBright
                    font.family: root.mono
                    font.pixelSize: 14
                    echoMode: TextInput.Password
                    passwordCharacter: "*"
                    passwordMaskDelay: 0
                    onAccepted: root.attemptLogin()
                }
            }
        }
    }

    // ------------------------------------------------------ status / failure
    Text {
        id: statusText

        // PAM speaks through here too, not just failures — pam_fprintd's "Place
        // your finger on the fingerprint reader" arrives as an information
        // message. Rendering those in the failure red would be a lie, so the
        // colour follows the kind of message.
        property bool isError: false

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: authBox.bottom
        anchors.topMargin: 40
        width: 700
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: statusText.isError ? root.fgFail : root.fgDim
        font.family: root.mono
        font.pixelSize: 14
        text: ""
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: statusText.bottom
        anchors.topMargin: 8
        color: root.fgDim
        font.family: root.mono
        font.pixelSize: 13
        visible: keyboard.capsLock
        text: "Caps Lock is on"
    }

    // -------------------------------------------------------- session picker
    // Both niri and plasma register wayland sessions, so this has to be
    // visible and changeable — a wrong lastIndex would otherwise strand login.
    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "Session:"
            color: root.fgDim
            font.family: root.mono
            font.pixelSize: 13
        }

        ComboBox {
            id: sessionBox
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            font.family: root.mono
            font.pixelSize: 13
            implicitWidth: 220

            background: Rectangle {
                color: "black"
                border.color: root.fgDim
                border.width: 1
            }

            contentItem: Text {
                leftPadding: 8
                rightPadding: 8
                text: sessionBox.displayText
                color: root.fgBright
                font: sessionBox.font
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            delegate: ItemDelegate {
                id: sessionDelegate

                required property var model
                required property int index

                width: sessionBox.width
                highlighted: sessionBox.highlightedIndex === index

                background: Rectangle {
                    color: sessionDelegate.highlighted ? "#222222" : "black"
                    border.color: root.fgDim
                    border.width: 1
                }

                contentItem: Text {
                    text: sessionDelegate.model.name
                    color: root.fgBright
                    font.family: root.mono
                    font.pixelSize: 13
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }

    // --------------------------------------------------------- power actions
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 20

        Repeater {
            model: [
                { label: "Suspend", available: sddm.canSuspend, action: "suspend" },
                { label: "Restart", available: sddm.canReboot, action: "reboot" },
                { label: "Shut Down", available: sddm.canPowerOff, action: "powerOff" }
            ]

            Text {
                id: powerItem

                required property var modelData

                text: powerItem.modelData.label
                visible: powerItem.modelData.available
                color: hoverHandler.hovered ? root.fgBright : root.fgDim
                font.family: root.mono
                font.pixelSize: 13

                HoverHandler {
                    id: hoverHandler
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        if (powerItem.modelData.action === "suspend") {
                            sddm.suspend()
                        } else if (powerItem.modelData.action === "reboot") {
                            sddm.reboot()
                        } else {
                            sddm.powerOff()
                        }
                    }
                }
            }
        }
    }

    // ----------------------------------------------------------------- logic
    Connections {
        target: sddm

        // Defensive: SDDM's exact signal set varies across releases, and an
        // unrecognised handler here would otherwise warn (or worse) at component
        // creation. A greeter that fails to load is unrecoverable without a TTY,
        // so tolerate the mismatch rather than risk the whole screen.
        ignoreUnknownSignals: true

        function onLoginFailed() {
            root.authInFlight = false
            root.showStatus("Authentication failed", true)
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }

        // Without clearing the flag on success the greeter would refuse to
        // retry if a session ever fails to start after PAM has accepted.
        function onLoginSucceeded() {
            root.authInFlight = false
        }

        // A failed step *within* a conversation — a rejected fingerprint, say —
        // arrives as error(), NOT as loginFailed(). Releasing the guard here too
        // is what stops a mid-stack failure from latching the greeter shut and
        // making Enter a no-op for the rest of the session.
        function onError(message) {
            root.authInFlight = false
            root.showStatus(message, true)
        }

        function onInformationMessage(message) {
            root.showStatus(message, false)
        }
    }

    // Backstop. Nothing is allowed to latch this greeter shut: if a conversation
    // ends without any signal we recognise, release the guard anyway. A stray
    // "Existing authentication ongoing, aborting" in the journal is vastly
    // preferable to a login screen that has stopped listening to the keyboard.
    Timer {
        interval: 20000
        running: root.authInFlight
        onTriggered: root.authInFlight = false
    }

    Component.onCompleted: {
        root.refreshClock()
        Qt.callLater(root.applyInitialFocus)
    }
}
