pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.design
import qs.modules.control
import qs.services.i18n

Controls.Popup {
    id: root

    property var network: null
    property real availableWidth: parent ? parent.width : 580
    property real availableHeight: parent ? parent.height : 400
    property bool passwordVisible: false
    property string localError: ""

    signal submitted(string password)

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string networkName: network
        ? String(network.ssid || network.name || "")
        : ""

    function openFor(value) {
        network = value
        passwordInput.text = ""
        passwordVisible = false
        localError = ""
        open()
        Qt.callLater(function() {
            passwordInput.forceActiveFocus(Qt.PopupFocusReason)
        })
    }

    function submitPassword() {
        const password = String(passwordInput.text || "")
        if (!password.length) {
            localError = I18n.tr(
                "wifi.password.required",
                "Enter the Wi-Fi password to continue."
            )
            passwordInput.forceActiveFocus(Qt.PopupFocusReason)
            return
        }

        localError = ""
        submitted(password)
        close()
    }

    x: parent ? Math.max(16, (parent.width - width) / 2) : 0
    y: parent ? Math.max(16, (parent.height - height) / 2) : 0
    width: Math.max(320, Math.min(580, availableWidth - 32))
    height: Math.max(360, Math.min(400, availableHeight - 32))
    padding: 0
    modal: true
    focus: true
    closePolicy: Controls.Popup.CloseOnEscape
        | Controls.Popup.CloseOnPressOutside

    onClosed: {
        passwordInput.text = ""
        passwordVisible = false
        localError = ""
        network = null
    }

    background: Rectangle {
        radius: root.luminaDesign.shape.extraLarge
        color: root.luminaDesign.color.surfaceContainer
        border.width: 1
        border.color: root.luminaDesign.color.outline
    }

    contentItem: Item {
        Column {
            anchors {
                fill: parent
                margins: root.luminaDesign.spacing.extraLarge
            }
            spacing: root.luminaDesign.spacing.medium

            Text {
                width: parent.width
                text: I18n.tr(
                    "wifi.password.title",
                    "Connect to Wi-Fi"
                )
                color: root.luminaDesign.color.onSurface
                wrapMode: Text.Wrap
                font.pixelSize: root.luminaDesign.typography.titleLarge
                font.weight: Font.Bold
            }

            Text {
                width: parent.width
                text: root.networkName
                color: root.luminaDesign.color.primary
                elide: Text.ElideRight
                font.pixelSize: root.luminaDesign.typography.titleMedium
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: I18n.tr(
                    "wifi.password.description",
                    "Enter the password for this network. The password is used only to create the NetworkManager connection."
                )
                color: root.luminaDesign.color.textMuted
                wrapMode: Text.Wrap
                font.pixelSize: root.luminaDesign.typography.bodyMedium
            }

            Text {
                width: parent.width
                text: I18n.tr(
                    "wifi.password.label",
                    "Password"
                )
                color: root.luminaDesign.color.onSurface
                font.pixelSize: root.luminaDesign.typography.labelMedium
                font.weight: Font.DemiBold
            }

            Rectangle {
                width: parent.width
                height: 52
                radius: root.luminaDesign.shape.large
                color: root.luminaDesign.color.surfaceMuted
                border.width: passwordInput.activeFocus ? 2 : 1
                border.color: root.localError.length > 0
                    ? root.luminaDesign.color.urgent
                    : passwordInput.activeFocus
                        ? root.luminaDesign.color.primary
                        : root.luminaDesign.color.outline

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: root.luminaDesign.spacing.large
                        verticalCenter: parent.verticalCenter
                    }
                    visible: passwordInput.text.length === 0
                        && !passwordInput.activeFocus
                    text: I18n.tr(
                        "wifi.password.placeholder",
                        "Enter network password"
                    )
                    color: root.luminaDesign.color.textMuted
                    font.pixelSize: root.luminaDesign.typography.bodyMedium
                }

                TextInput {
                    id: passwordInput

                    anchors {
                        left: parent.left
                        right: visibilityButton.left
                        top: parent.top
                        bottom: parent.bottom
                        leftMargin: root.luminaDesign.spacing.large
                        rightMargin: root.luminaDesign.spacing.small
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: root.passwordVisible
                        ? TextInput.Normal
                        : TextInput.Password
                    selectByMouse: true
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize: root.luminaDesign.typography.bodyMedium + 1
                    Keys.onReturnPressed: event => {
                        root.submitPassword()
                        event.accepted = true
                    }
                }

                Rectangle {
                    id: visibilityButton

                    anchors {
                        right: parent.right
                        rightMargin: 5
                        verticalCenter: parent.verticalCenter
                    }
                    width: 42
                    height: 42
                    radius: root.luminaDesign.shape.full
                    color: visibilityMouse.containsMouse
                        ? root.luminaDesign.color.accentContainer
                        : "transparent"
                    activeFocusOnTab: true
                    border.width: activeFocus ? 2 : 0
                    border.color: root.luminaDesign.color.primary

                    Accessible.role: Accessible.Button
                    Accessible.name: root.passwordVisible
                        ? I18n.tr("wifi.password.hide", "Hide password")
                        : I18n.tr("wifi.password.show", "Show password")
                    Accessible.focusable: true
                    Accessible.focused: activeFocus
                    Accessible.onPressAction:
                        root.passwordVisible = !root.passwordVisible

                    Keys.onSpacePressed: event => {
                        root.passwordVisible = !root.passwordVisible
                        event.accepted = true
                    }
                    Keys.onReturnPressed: event => {
                        root.passwordVisible = !root.passwordVisible
                        event.accepted = true
                    }

                    DashboardIcon {
                        anchors.centerIn: parent
                        iconName: root.passwordVisible
                            ? "view-hidden-symbolic"
                            : "view-visible-symbolic"
                        fallbackSymbol: root.passwordVisible ? "○" : "◉"
                        iconColor: visibilityMouse.containsMouse
                            ? root.luminaDesign.color.onAccentContainer
                            : root.luminaDesign.color.onSurface
                        iconSize: 18
                    }

                    MouseArea {
                        id: visibilityMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            visibilityButton.focus = false
                            root.passwordVisible = !root.passwordVisible
                            passwordInput.forceActiveFocus(Qt.PopupFocusReason)
                        }
                    }
                }
            }

            Text {
                width: parent.width
                visible: root.localError.length > 0
                text: root.localError
                color: root.luminaDesign.color.urgent
                wrapMode: Text.Wrap
                font.pixelSize: root.luminaDesign.typography.labelMedium
            }

            Item {
                width: parent.width
                height: 44

                Row {
                    anchors.right: parent.right
                    spacing: root.luminaDesign.spacing.medium

                    Rectangle {
                        id: cancelButton
                        width: Math.max(112, cancelLabel.implicitWidth + 30)
                        height: 42
                        radius: root.luminaDesign.shape.full
                        color: cancelMouse.containsMouse
                            ? root.luminaDesign.color.surfaceMuted
                            : "transparent"
                        border.width: 1
                        border.color: root.luminaDesign.color.outline

                        Text {
                            id: cancelLabel
                            anchors.centerIn: parent
                            text: I18n.tr(
                                "settings.connectivity.cancel",
                                "Cancel"
                            )
                            color: root.luminaDesign.color.onSurface
                            font.pixelSize: root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()
                        }
                    }

                    Rectangle {
                        id: connectButton
                        width: Math.max(124, connectLabel.implicitWidth + 30)
                        height: 42
                        radius: root.luminaDesign.shape.full
                        color: connectMouse.containsMouse
                            ? root.luminaDesign.color.primary
                            : root.luminaDesign.color.accentContainer

                        Text {
                            id: connectLabel
                            anchors.centerIn: parent
                            text: I18n.tr(
                                "settings.connectivity.connect",
                                "Connect"
                            )
                            color: connectMouse.containsMouse
                                ? root.luminaDesign.color.onPrimary
                                : root.luminaDesign.color.onAccentContainer
                            font.pixelSize: root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: connectMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.submitPassword()
                        }
                    }
                }
            }
        }
    }
}
