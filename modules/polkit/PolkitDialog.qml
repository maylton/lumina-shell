pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Polkit
import qs.design
import qs.modules.control
import qs.services.i18n
import "PolkitStrings.js" as PolkitStrings

FloatingWindow {
    id: root

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property var flow: agent.flow
    readonly property bool responseRequired:
        flow ? Boolean(flow.isResponseRequired) : false
    readonly property string supplementaryMessage:
        flow ? String(flow.supplementaryMessage || "") : ""
    readonly property bool supplementaryIsError:
        flow ? Boolean(flow.supplementaryIsError) : false

    property string localError: ""
    property bool detailsExpanded: false

    visible: agent.isActive
    implicitWidth: 520
    implicitHeight: Math.max(
        410,
        dialogContent.implicitHeight
            + root.luminaDesign.spacing.extraLarge * 2
    )
    minimumSize: Qt.size(implicitWidth, implicitHeight)
    maximumSize: Qt.size(implicitWidth, implicitHeight)
    color: "transparent"
    title: PolkitStrings.text(I18n.locale, "windowTitle")

    function identityText(identity) {
        if (!identity)
            return ""

        const displayName = String(identity.displayName || "")
        const accountName = String(identity.string || "")
        let text = displayName.length > 0 ? displayName : accountName

        if (displayName.length > 0
            && accountName.length > 0
            && displayName !== accountName) {
            text += " (" + accountName + ")"
        }

        if (Boolean(identity.isGroup)) {
            text += " · " + PolkitStrings.text(
                I18n.locale,
                "groupIdentity"
            )
        }

        return text
    }

    function inputPromptText() {
        if (!root.flow)
            return PolkitStrings.text(I18n.locale, "passwordFallback")

        const prompt = String(root.flow.inputPrompt || "").trim()
        if (prompt.length === 0)
            return PolkitStrings.text(I18n.locale, "passwordFallback")

        if (/^(password|passphrase)\s*:?\s*$/i.test(prompt))
            return PolkitStrings.text(I18n.locale, "passwordFallback")

        return prompt
    }

    function focusResponse() {
        if (!root.visible || !root.responseRequired)
            return

        Qt.callLater(function() {
            root.requestActivate()
            responseInput.forceActiveFocus(Qt.PopupFocusReason)
        })
    }

    function submit() {
        if (!root.flow || !root.responseRequired)
            return

        const value = responseInput.text
        responseInput.text = ""
        root.localError = ""
        root.flow.submit(value)
    }

    function cancel() {
        if (!root.flow)
            return

        responseInput.text = ""
        root.localError = ""
        root.flow.cancelAuthenticationRequest()
    }

    onFlowChanged: {
        responseInput.text = ""
        localError = ""
        detailsExpanded = false
        focusResponse()
    }

    onVisibleChanged: {
        if (!visible) {
            responseInput.text = ""
            localError = ""
            detailsExpanded = false
            return
        }

        focusResponse()
    }

    PolkitAgent {
        id: agent
        path: "/io/github/maylton/Lumina/PolkitAgent"
    }

    Timer {
        interval: 3000
        running: true
        repeat: false
        onTriggered: {
            if (!agent.isRegistered) {
                console.warn(
                    "Lumina Polkit agent could not register. "
                    + "Another authentication agent may already be running."
                )
            }
        }
    }

    Connections {
        target: root.flow
        ignoreUnknownSignals: true

        function onFailedChanged() {
            if (!root.flow || !root.flow.failed)
                return

            responseInput.text = ""
            root.localError = PolkitStrings.text(I18n.locale, "failed")
            root.focusResponse()
        }

        function onIsResponseRequiredChanged() {
            root.focusResponse()
        }

        function onSelectedIdentityChanged() {
            responseInput.text = ""
            root.localError = ""
            root.focusResponse()
        }

        function onIsCompletedChanged() {
            if (root.flow && root.flow.isCompleted)
                responseInput.text = ""
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: root.visible

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
                id: dialogContent

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: root.luminaDesign.spacing.extraLarge
                }
                spacing: root.luminaDesign.spacing.medium

                Row {
                    width: parent.width
                    spacing: root.luminaDesign.spacing.medium

                    Rectangle {
                        width: 52
                        height: 52
                        radius: root.luminaDesign.shape.full
                        color: root.luminaDesign.color.accentContainer

                        DashboardIcon {
                            anchors.centerIn: parent
                            iconName: root.flow
                                ? String(root.flow.iconName
                                    || "dialog-password-symbolic")
                                : "dialog-password-symbolic"
                            fallbackSymbol: "◆"
                            fallbackScale: 0.72
                            iconColor:
                                root.luminaDesign.color.onAccentContainer
                            iconSize: 25
                        }
                    }

                    Column {
                        width: parent.width - 52 - parent.spacing
                        spacing: 3

                        Text {
                            width: parent.width
                            text: PolkitStrings.text(
                                I18n.locale,
                                "heading"
                            )
                            color: root.luminaDesign.color.onSurface
                            wrapMode: Text.Wrap
                            font.pixelSize:
                                root.luminaDesign.typography.titleLarge
                            font.weight: Font.Bold
                        }

                        Text {
                            width: parent.width
                            text: PolkitStrings.text(
                                I18n.locale,
                                "description"
                            )
                            color: root.luminaDesign.color.textMuted
                            wrapMode: Text.Wrap
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: root.flow
                        ? String(root.flow.message || "")
                        : ""
                    color: root.luminaDesign.color.onSurface
                    wrapMode: Text.Wrap
                    font.pixelSize:
                        root.luminaDesign.typography.bodyMedium + 1
                    font.weight: Font.DemiBold
                }

                Column {
                    width: parent.width
                    spacing: root.luminaDesign.spacing.small

                    Text {
                        width: parent.width
                        text: PolkitStrings.text(
                            I18n.locale,
                            "identityLabel"
                        )
                        color: root.luminaDesign.color.textMuted
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize:
                            root.luminaDesign.typography.labelSmall
                        font.weight: Font.DemiBold
                    }

                    Flickable {
                        id: identityFlick

                        width: parent.width
                        height: 42
                        contentWidth: Math.max(
                            width,
                            identityRow.implicitWidth
                        )
                        contentHeight: height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        flickableDirection: Flickable.HorizontalFlick

                        Row {
                            id: identityRow

                            x: Math.max(
                                0,
                                (identityFlick.width - implicitWidth) / 2
                            )
                            spacing: root.luminaDesign.spacing.small

                            Repeater {
                                model: root.flow ? root.flow.identities : []

                                delegate: Rectangle {
                                    id: identityChip

                                    required property var modelData

                                    readonly property bool selected:
                                        root.flow
                                        && root.flow.selectedIdentity
                                            === modelData

                                    width: Math.max(
                                        116,
                                        identityText.implicitWidth + 28
                                    )
                                    height: 40
                                    radius: root.luminaDesign.shape.full
                                    color: selected
                                        ? root.luminaDesign.color
                                            .accentContainer
                                        : identityMouse.containsMouse
                                            ? root.luminaDesign.color
                                                .surfaceMuted
                                            : "transparent"
                                    border.width: selected ? 0 : 1
                                    border.color:
                                        root.luminaDesign.color.outline

                                    Text {
                                        id: identityText
                                        anchors.centerIn: parent
                                        text: root.identityText(
                                            identityChip.modelData
                                        )
                                        color: identityChip.selected
                                            ? root.luminaDesign.color
                                                .onAccentContainer
                                            : root.luminaDesign.color.onSurface
                                        font.pixelSize:
                                            root.luminaDesign.typography
                                                .labelMedium
                                        font.weight: Font.DemiBold
                                    }

                                    MouseArea {
                                        id: identityMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.flow) {
                                                root.flow.selectedIdentity =
                                                    identityChip.modelData
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: root.flow
                        && String(root.flow.actionId || "").length > 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.max(116, detailsText.implicitWidth + 34)
                    height: 32
                    radius: root.luminaDesign.shape.full
                    color: detailsMouse.containsMouse
                        ? root.luminaDesign.color.surfaceMuted
                        : "transparent"
                    border.width: 1
                    border.color: root.luminaDesign.color.outlineVariant

                    Text {
                        id: detailsText
                        anchors.centerIn: parent
                        text: root.detailsExpanded
                            ? PolkitStrings.text(I18n.locale, "hideDetails")
                            : PolkitStrings.text(I18n.locale, "showDetails")
                        color: root.luminaDesign.color.textMuted
                        font.pixelSize:
                            root.luminaDesign.typography.labelMedium
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: detailsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.detailsExpanded = !root.detailsExpanded
                    }
                }

                Rectangle {
                    visible: root.detailsExpanded
                        && root.flow
                        && String(root.flow.actionId || "").length > 0
                    width: parent.width
                    height: 50
                    radius: root.luminaDesign.shape.large
                    color: root.luminaDesign.color.surfaceMuted
                    border.width: 1
                    border.color:
                        root.luminaDesign.color.outlineVariant

                    Column {
                        anchors {
                            fill: parent
                            leftMargin: root.luminaDesign.spacing.medium
                            rightMargin: root.luminaDesign.spacing.medium
                        }
                        spacing: 1

                        Text {
                            text: PolkitStrings.text(
                                I18n.locale,
                                "actionLabel"
                            )
                            color: root.luminaDesign.color.textMuted
                            font.pixelSize:
                                root.luminaDesign.typography.labelSmall
                            font.weight: Font.DemiBold
                        }

                        Text {
                            width: parent.width
                            text: root.flow
                                ? String(root.flow.actionId || "")
                                : ""
                            color: root.luminaDesign.color.onSurface
                            elide: Text.ElideMiddle
                            font.pixelSize:
                                root.luminaDesign.typography.labelMedium
                        }
                    }
                }

                Rectangle {
                    visible: root.responseRequired
                    width: parent.width
                    height: 54
                    radius: root.luminaDesign.shape.large
                    color: root.luminaDesign.color.surfaceMuted
                    border.width: responseInput.activeFocus ? 2 : 1
                    border.color: responseInput.activeFocus
                        ? root.luminaDesign.color.primary
                        : root.localError.length > 0
                            || root.supplementaryIsError
                            ? root.luminaDesign.color.urgent
                            : root.luminaDesign.color.outline

                    TextInput {
                        id: responseInput

                        anchors {
                            fill: parent
                            leftMargin: root.luminaDesign.spacing.large
                            rightMargin: root.luminaDesign.spacing.large
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        color: root.luminaDesign.color.onSurface
                        echoMode: root.flow && root.flow.responseVisible
                            ? TextInput.Normal
                            : TextInput.Password
                        enabled: root.responseRequired
                        font.pixelSize:
                            root.luminaDesign.typography.bodyMedium + 2

                        Keys.onReturnPressed: event => {
                            root.submit()
                            event.accepted = true
                        }
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: root.luminaDesign.spacing.large
                            verticalCenter: parent.verticalCenter
                        }
                        visible: responseInput.text.length === 0
                            && !responseInput.activeFocus
                        text: root.inputPromptText()
                        color: root.luminaDesign.color.textMuted
                        font.pixelSize:
                            root.luminaDesign.typography.bodyMedium
                    }
                }

                Text {
                    width: parent.width
                    visible: root.localError.length > 0
                        || root.supplementaryMessage.length > 0
                    text: root.localError.length > 0
                        ? root.localError
                        : root.supplementaryMessage
                    color: root.localError.length > 0
                        || root.supplementaryIsError
                            ? root.luminaDesign.color.urgent
                            : root.luminaDesign.color.textMuted
                    wrapMode: Text.Wrap
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
                }

                Text {
                    width: parent.width
                    visible: root.flow && !root.responseRequired
                        && !root.flow.isCompleted
                    text: PolkitStrings.text(I18n.locale, "waiting")
                    color: root.luminaDesign.color.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
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
                                text: PolkitStrings.text(
                                    I18n.locale,
                                    "cancel"
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
                            visible: root.responseRequired
                            width: visible ? Math.max(
                                128,
                                authenticateText.implicitWidth + 34
                            ) : 0
                            height: 42
                            radius: root.luminaDesign.shape.full
                            color: authenticateMouse.containsMouse
                                ? root.luminaDesign.color.primary
                                : root.luminaDesign.color.accentContainer
                            activeFocusOnTab: visible

                            Keys.onSpacePressed: event => {
                                root.submit()
                                event.accepted = true
                            }
                            Keys.onReturnPressed: event => {
                                root.submit()
                                event.accepted = true
                            }

                            Text {
                                id: authenticateText
                                anchors.centerIn: parent
                                text: PolkitStrings.text(
                                    I18n.locale,
                                    "authenticate"
                                )
                                color: authenticateMouse.containsMouse
                                    ? root.luminaDesign.color.onPrimary
                                    : root.luminaDesign.color
                                        .onAccentContainer
                                font.pixelSize:
                                    root.luminaDesign.typography.labelMedium
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: authenticateMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.submit()
                            }
                        }
                    }
                }
            }
        }
    }
}
