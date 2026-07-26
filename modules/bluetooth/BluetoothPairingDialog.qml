pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.design
import qs.modules.control
import qs.services.connectivity
import qs.services.i18n

FloatingWindow {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property string promptType:
        BluetoothManagerService.authenticationType
    readonly property bool inputPrompt:
        promptType === "pin" || promptType === "passkey"
    readonly property bool decisionPrompt:
        promptType === "confirmation" || promptType === "authorize"
    readonly property bool displayPrompt:
        promptType === "display-pin"
        || promptType === "display-passkey"
    readonly property string deviceName:
        BluetoothManagerService.targetName
        || BluetoothManagerService.targetAddress
    readonly property string code:
        BluetoothManagerService.authenticationCode

    property string localError: ""

    visible: BluetoothManagerService.authenticationPending
    width: 460
    height: displayPrompt ? 360 : inputPrompt ? 344 : 320
    minimumSize: Qt.size(width, height)
    maximumSize: Qt.size(width, height)
    color: "transparent"
    title: I18n.tr(
        "bluetooth.auth.windowTitle",
        "Bluetooth pairing"
    )
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.FramelessWindowHint

    function titleText() {
        switch (promptType) {
        case "confirmation":
            return I18n.tr(
                "bluetooth.auth.confirm.title",
                "Confirm pairing code"
            )
        case "pin":
            return I18n.tr(
                "bluetooth.auth.pin.title",
                "Enter Bluetooth PIN"
            )
        case "passkey":
            return I18n.tr(
                "bluetooth.auth.passkey.title",
                "Enter Bluetooth passkey"
            )
        case "authorize":
            return I18n.tr(
                "bluetooth.auth.authorize.title",
                "Authorize Bluetooth service"
            )
        case "display-pin":
        case "display-passkey":
            return I18n.tr(
                "bluetooth.auth.display.title",
                "Use this pairing code"
            )
        default:
            return I18n.tr(
                "bluetooth.auth.windowTitle",
                "Bluetooth pairing"
            )
        }
    }

    function descriptionText() {
        switch (promptType) {
        case "confirmation":
            return I18n.tr(
                "bluetooth.auth.confirm.description",
                "Confirm that the code shown on %1 matches this code.",
                [deviceName]
            )
        case "pin":
            return I18n.tr(
                "bluetooth.auth.pin.description",
                "Enter the PIN requested by %1.",
                [deviceName]
            )
        case "passkey":
            return I18n.tr(
                "bluetooth.auth.passkey.description",
                "Enter the numeric passkey requested by %1.",
                [deviceName]
            )
        case "authorize":
            return I18n.tr(
                "bluetooth.auth.authorize.description",
                "Allow %1 to use Bluetooth service %2?",
                [
                    deviceName,
                    BluetoothManagerService.authenticationService
                ]
            )
        case "display-pin":
        case "display-passkey":
            return I18n.tr(
                "bluetooth.auth.display.description",
                "Enter this code on %1 to continue pairing.",
                [deviceName]
            )
        default:
            return ""
        }
    }

    function primaryLabel() {
        if (inputPrompt) {
            return I18n.tr(
                "bluetooth.auth.action.submit",
                "Submit"
            )
        }
        if (decisionPrompt) {
            return I18n.tr(
                "bluetooth.auth.action.confirm",
                "Confirm"
            )
        }
        return ""
    }

    function submit() {
        localError = ""

        if (inputPrompt) {
            const requested = String(authInput.text || "").trim()
            const valid = promptType === "pin"
                ? requested.length >= 1 && requested.length <= 16
                : /^[0-9]{1,6}$/.test(requested)
                    && Number(requested) <= 999999

            if (!valid) {
                localError = promptType === "pin"
                    ? I18n.tr(
                        "bluetooth.auth.pin.invalid",
                        "Enter a PIN with 1 to 16 characters."
                    )
                    : I18n.tr(
                        "bluetooth.auth.passkey.invalid",
                        "Enter a number from 0 to 999999."
                    )
                return
            }

            BluetoothManagerService.submitAuthentication(requested)
            return
        }

        if (decisionPrompt)
            BluetoothManagerService.acceptAuthentication()
    }

    function cancel() {
        localError = ""
        BluetoothManagerService.cancelAuthentication("user")
    }

    onVisibleChanged: {
        if (!visible)
            return

        localError = ""
        authInput.text = ""
        Qt.callLater(function() {
            if (root.inputPrompt)
                authInput.forceActiveFocus(Qt.PopupFocusReason)
            else if (root.displayPrompt)
                cancelButton.forceActiveFocus(Qt.PopupFocusReason)
            else
                confirmButton.forceActiveFocus(Qt.PopupFocusReason)
        })
    }

    Keys.onEscapePressed: event => {
        root.cancel()
        event.accepted = true
    }

    Rectangle {
        anchors.fill: parent
        radius: root.luminaDesign.shape.extraLarge
        color: root.luminaDesign.color.surfaceContainer
        border.width: 1
        border.color: root.luminaDesign.color.outline

        Column {
            anchors {
                fill: parent
                margins: root.luminaDesign.spacing.extraLarge
            }
            spacing: root.luminaDesign.spacing.large

            Row {
                width: parent.width
                spacing: root.luminaDesign.spacing.medium

                Rectangle {
                    width: 48
                    height: 48
                    radius: root.luminaDesign.shape.full
                    color: root.luminaDesign.color.accentContainer

                    DashboardIcon {
                        anchors.centerIn: parent
                        iconName: "bluetooth-active-symbolic"
                        fallbackSymbol: "ᛒ"
                        iconColor:
                            root.luminaDesign.color.onAccentContainer
                        iconSize: 24
                    }
                }

                Column {
                    width: parent.width - 48 - parent.spacing
                    spacing: 3

                    Text {
                        width: parent.width
                        text: root.titleText()
                        color: root.luminaDesign.color.onSurface
                        wrapMode: Text.Wrap
                        font.pixelSize:
                            root.luminaDesign.typography.titleLarge
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        text: root.deviceName
                        color: root.luminaDesign.color.textMuted
                        elide: Text.ElideRight
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                    }
                }
            }

            Text {
                width: parent.width
                text: root.descriptionText()
                color: root.luminaDesign.color.onSurface
                wrapMode: Text.Wrap
                font.pixelSize: root.luminaDesign.typography.bodyMedium
            }

            Rectangle {
                visible: root.code.length > 0
                    && !root.inputPrompt
                width: parent.width
                height: 72
                radius: root.luminaDesign.shape.large
                color: root.luminaDesign.color.surfaceMuted
                border.width: 1
                border.color: root.luminaDesign.color.outlineVariant

                Text {
                    anchors.centerIn: parent
                    text: root.code
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize: 32
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                }
            }

            Rectangle {
                visible: root.inputPrompt
                width: parent.width
                height: 52
                radius: root.luminaDesign.shape.large
                color: root.luminaDesign.color.surfaceMuted
                border.width: authInput.activeFocus ? 2 : 1
                border.color: authInput.activeFocus
                    ? root.luminaDesign.color.primary
                    : root.localError.length > 0
                        ? root.luminaDesign.color.urgent
                        : root.luminaDesign.color.outline

                TextInput {
                    id: authInput

                    anchors {
                        fill: parent
                        leftMargin: root.luminaDesign.spacing.large
                        rightMargin: root.luminaDesign.spacing.large
                    }
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize:
                        root.luminaDesign.typography.bodyLarge
                    maximumLength: root.promptType === "pin" ? 16 : 6
                    inputMethodHints: root.promptType === "passkey"
                        ? Qt.ImhDigitsOnly
                        : Qt.ImhNone

                    Keys.onReturnPressed: event => {
                        root.submit()
                        event.accepted = true
                    }
                }
            }

            Text {
                visible: root.localError.length > 0
                width: parent.width
                text: root.localError
                color: root.luminaDesign.color.urgent
                wrapMode: Text.Wrap
                font.pixelSize: root.luminaDesign.typography.labelMedium
            }

            Text {
                visible: root.promptType === "display-passkey"
                    && BluetoothManagerService.authenticationEntered > 0
                width: parent.width
                text: I18n.tr(
                    "bluetooth.auth.display.progress",
                    "%1 of 6 digits entered on the device",
                    [BluetoothManagerService.authenticationEntered]
                )
                color: root.luminaDesign.color.textMuted
                horizontalAlignment: Text.AlignHCenter
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

                        width: Math.max(
                            112,
                            cancelText.implicitWidth + 30
                        )
                        height: 42
                        radius: root.luminaDesign.shape.full
                        color: cancelMouse.containsMouse
                            ? root.luminaDesign.color.surfaceMuted
                            : "transparent"
                        activeFocusOnTab: true
                        border.width: activeFocus ? 2 : 1
                        border.color: activeFocus
                            ? root.luminaDesign.color.primary
                            : root.luminaDesign.color.outline

                        Accessible.role: Accessible.Button
                        Accessible.name: cancelText.text
                        Accessible.focusable: true
                        Accessible.focused: activeFocus
                        Accessible.onPressAction: root.cancel()

                        Keys.onSpacePressed: event => {
                            root.cancel()
                            event.accepted = true
                        }
                        Keys.onReturnPressed: event => {
                            root.cancel()
                            event.accepted = true
                        }

                        Text {
                            id: cancelText
                            anchors.centerIn: parent
                            text: root.decisionPrompt
                                ? I18n.tr(
                                    "bluetooth.auth.action.reject",
                                    "Reject"
                                )
                                : I18n.tr(
                                    "bluetooth.auth.action.cancel",
                                    "Cancel"
                                )
                            color: root.luminaDesign.color.onSurface
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.cancel()
                        }
                    }

                    Rectangle {
                        id: confirmButton

                        visible: !root.displayPrompt
                        width: visible
                            ? Math.max(
                                112,
                                confirmText.implicitWidth + 30
                            )
                            : 0
                        height: 42
                        radius: root.luminaDesign.shape.full
                        color: confirmMouse.containsMouse
                            ? root.luminaDesign.color.primary
                            : root.luminaDesign.color.accentContainer
                        activeFocusOnTab: visible
                        border.width: activeFocus ? 2 : 0
                        border.color: root.luminaDesign.color.primary

                        Accessible.role: Accessible.Button
                        Accessible.name: root.primaryLabel()
                        Accessible.focusable: visible
                        Accessible.focused: activeFocus
                        Accessible.onPressAction: root.submit()

                        Keys.onSpacePressed: event => {
                            root.submit()
                            event.accepted = true
                        }
                        Keys.onReturnPressed: event => {
                            root.submit()
                            event.accepted = true
                        }

                        Text {
                            id: confirmText
                            anchors.centerIn: parent
                            text: root.primaryLabel()
                            color: confirmMouse.containsMouse
                                ? root.luminaDesign.color.onPrimary
                                : root.luminaDesign.color
                                    .onAccentContainer
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: confirmMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: confirmButton.visible
                            cursorShape: enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor
                            onClicked: root.submit()
                        }
                    }
                }
            }
        }
    }
}
