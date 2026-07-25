pragma ComponentBehavior: Bound

import QtQuick
import qs.design
import qs.services.i18n
import qs.stores.config
import qs.stores.control

Flickable {
    id: root

    required property string title
    required property string description
    property string anchorSection: ""
    property string customSaveStatus: ""
    property bool customSaveFailed: false
    default property alias pageData: pageBody.data

    readonly property var luminaDesign: Theme.luminaTokens
    readonly property bool canResetCategory: [
        "appearance",
        "bar",
        "dashboard",
        "behavior",
        "notifications",
        "osd",
        "session"
    ].indexOf(ControlCenterStore.settingsCategory) >= 0
    readonly property string localizedSaveStatus:
        ConfigStore.lastError && !ConfigStore.lastSaveSucceeded
            ? I18n.tr(
                "settings.save.failed",
                "Could not save"
            )
            : ConfigStore.saving || ConfigStore.dirty
                ? I18n.tr(
                    "settings.save.saving",
                    "Saving…"
                )
                : I18n.tr(
                    "settings.save.saved",
                    "Saved"
                )
    readonly property string displayedSaveStatus:
        customSaveStatus || localizedSaveStatus
    readonly property bool displayedSaveFailed:
        customSaveStatus.length > 0
            ? customSaveFailed
            : Boolean(ConfigStore.lastError)
                && !ConfigStore.lastSaveSucceeded

    clip: true
    contentWidth: width
    contentHeight: pageColumn.implicitHeight
        + luminaDesign.spacing.controlContentInset
    boundsBehavior: Flickable.StopAtBounds
    flickDeceleration: 2600

    Column {
        id: pageColumn

        width: root.width
        spacing: root.luminaDesign.spacing.controlSectionGap

        Row {
            width: parent.width
            height: 48

            Column {
                width: parent.width - saveStatus.width
                    - resetPage.width
                    - root.luminaDesign.spacing.controlSectionGap * 2
                spacing: 3

                Text {
                    text: root.title
                    color: root.luminaDesign.color.onSurface
                    font.pixelSize:
                        root.luminaDesign.typography.titleLarge
                    font.weight: Font.Bold
                }

                Text {
                    width: parent.width
                    text: root.description
                    color: root.luminaDesign.color.textMuted
                    elide: Text.ElideRight
                    font.pixelSize:
                        root.luminaDesign.typography.labelMedium
                }
            }

            Rectangle {
                id: resetPage

                visible: root.canResetCategory
                width: visible ? resetLabel.implicitWidth + 22 : 0
                height: 30
                radius: root.luminaDesign.shape.full
                color: resetMouse.containsMouse || activeFocus
                    ? root.luminaDesign.color.accentContainer
                    : root.luminaDesign.color.surfaceMuted
                activeFocusOnTab: visible
                border.width: activeFocus ? 2 : 0
                border.color: root.luminaDesign.color.primary

                Accessible.role: Accessible.Button
                Accessible.name: I18n.tr(
                    "settings.restoreCategory",
                    "Restore this category"
                )
                Accessible.description: I18n.tr(
                    "settings.restoreDefaultsFor",
                    "Restore defaults for %1",
                    [ControlCenterStore.settingsCategory]
                )
                Accessible.focusable: visible
                Accessible.focused: activeFocus
                Accessible.onPressAction: activate()

                function activate() {
                    ConfigStore.resetCategory(
                        ControlCenterStore.settingsCategory
                    )
                }

                Keys.onSpacePressed: event => {
                    activate()
                    event.accepted = true
                }

                Keys.onReturnPressed: event => {
                    activate()
                    event.accepted = true
                }

                Text {
                    id: resetLabel

                    anchors.centerIn: parent
                    text: I18n.tr(
                        "settings.resetPage",
                        "Reset page"
                    )
                    color: resetPage.activeFocus
                    || resetMouse.containsMouse
                        ? root.luminaDesign.color.onAccentContainer
                        : root.luminaDesign.color.textMuted
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: resetMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        resetPage.forceActiveFocus(
                            Qt.MouseFocusReason
                        )
                        resetPage.activate()
                    }
                }
            }

            Rectangle {
                id: saveStatus

                width: statusText.implicitWidth + 22
                height: 30
                radius: root.luminaDesign.shape.full
                color: root.luminaDesign.color.surfaceMuted

                Text {
                    id: statusText

                    anchors.centerIn: parent
                    text: root.displayedSaveStatus
                    color: root.displayedSaveFailed
                        ? root.luminaDesign.color.urgent
                        : root.luminaDesign.color.textMuted
                    font.pixelSize:
                        root.luminaDesign.typography.labelSmall
                    font.weight: Font.DemiBold
                }
            }
        }

        Column {
            id: pageBody

            width: parent.width
            spacing: root.luminaDesign.spacing.controlSectionGap
        }
    }
}
