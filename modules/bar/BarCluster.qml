import QtQuick
import qs.stores.config

Row {
    property real clusterSpacing: ConfigStore.barWidgetSpacing

    spacing: clusterSpacing
}
