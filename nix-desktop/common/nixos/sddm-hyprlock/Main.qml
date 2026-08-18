// SDDM greeter styled to match the hyprlock lock screen. Every number here is
// lifted from common/home-manager/hyprlock.nix -- keep the two in step.
//
// hyprlock positions are offsets from the centre of the screen with y pointing
// up, so `position = "0, 80"` becomes a verticalCenterOffset of -80.
import QtQuick

Item {
    id: root

    // SDDM sizes the view to the screen; these are only the fallback.
    width: 1920
    height: 1080

    property bool failed: false

    // background: blurred at build time, since hyprlock's blur_passes = 1 is a
    // static effect on a static image and a shader here would be one more way
    // for the login screen to come up black.
    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        cache: true
    }

    // label: $TIME, font_size 120, position "0, 80"
    Text {
        id: clock

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -80

        color: "white"
        font.family: "JetBrainsMono Nerd Font"
        font.bold: true
        font.pixelSize: 120
        text: Qt.formatDateTime(new Date(), "HH:mm")

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    // input-field: size "250, 60", position "0, -120", rounded to a pill the
    // way hyprlock's default rounding = -1 does.
    Rectangle {
        id: field

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 120

        width: 250
        height: 60
        radius: height / 2

        color: "#80000000"                                      // inner_color
        border.width: 2                                         // outline_thickness
        border.color: root.failed ? "#cc2222" : "transparent"   // fail_color / outer_color

        // fade_on_empty
        opacity: password.text.length > 0 ? 1.0 : 0.6
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        TextInput {
            id: password

            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter

            echoMode: TextInput.Password
            passwordCharacter: "●"
            passwordMaskDelay: 0

            color: "#c8c8c8"                                    // font_color
            font.pixelSize: 22
            selectByMouse: false
            focus: true

            onAccepted: root.tryLogin()
            onTextChanged: root.failed = false
        }

        // placeholder_text = "<i>Password...</i>", reused for $FAIL
        Text {
            anchors.centerIn: parent
            visible: password.text.length === 0

            text: root.failed ? "Authentication failed" : "Password..."
            color: "#c8c8c8"
            font.italic: true
            font.pixelSize: 20
            opacity: 0.7
        }
    }

    // hyprlock has no power controls -- it unlocks a session that is already
    // running. A greeter does need them, so they sit out of the way in the
    // corner and stay dim until pointed at. Glyphs are Nerd Font PUA points,
    // which the clock's font already covers.
    component PowerButton: Text {
        id: button

        signal activated()

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 26
        color: "#c8c8c8"

        opacity: hover.hovered ? 1.0 : 0.4
        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: button.activated()
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 40
        anchors.bottomMargin: 32
        spacing: 28

        PowerButton {
            text: "\uf186"                  // moon
            visible: sddm.canSuspend
            onActivated: sddm.suspend()
        }

        PowerButton {
            text: "\uf021"                  // arrows in a circle
            visible: sddm.canReboot
            onActivated: sddm.reboot()
        }

        PowerButton {
            text: "\uf011"                  // power symbol
            visible: sddm.canPowerOff
            onActivated: sddm.powerOff()
        }
    }

    function tryLogin() {
        if (password.text.length === 0)
            return;
        sddm.login(userModel.lastUser, password.text, sessionModel.lastIndex);
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.failed = true;
            password.text = "";
            password.forceActiveFocus();
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
