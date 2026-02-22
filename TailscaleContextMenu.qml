import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Widgets

Popup {
    id: contextMenu

    property var peerData: null
    property bool isTerminalConfigured: false

    signal actionRequested(string action, var peer)

    property var menuItems: [
        {
            text: "Copy IP",
            icon: "content_copy",
            action: "copy-ip",
            enabled: true
        },
        {
            text: "Copy Hostname",
            icon: "copy_all",
            action: "copy-hostname",
            enabled: true
        },
        {
            type: "separator"
        },
        {
            text: "SSH to Host",
            icon: "terminal",
            action: "ssh",
            enabled: (peerData?.Online || false) && isTerminalConfigured
        },
        {
            text: "Ping Host",
            icon: "network_ping",
            action: "ping",
            enabled: isTerminalConfigured
        },
        {
            type: "separator"
        },
        {
            text: "Open in Admin",
            icon: "open_in_new",
            action: "admin-console",
            enabled: true
        }
    ]

    function show(x, y) {
        var finalX = x;
        var finalY = y;

        if (contextMenu.parent) {
            var parentWidth = contextMenu.parent.width;
            var parentHeight = contextMenu.parent.height;
            var menuWidth = contextMenu.width;
            var menuHeight = contextMenu.height;

            if (finalX + menuWidth > parentWidth)
                finalX = Math.max(0, parentWidth - menuWidth);
            if (finalY + menuHeight > parentHeight)
                finalY = Math.max(0, parentHeight - menuHeight);
        }

        contextMenu.x = finalX;
        contextMenu.y = finalY;
        open();
    }

    width: 200
    height: menuColumn.implicitHeight + Theme.spacingS * 2
    padding: 0
    modal: false
    closePolicy: Popup.CloseOnEscape

    onClosed: {
        closePolicy = Popup.CloseOnEscape;
    }

    onOpened: {
        outsideClickTimer.start();
    }

    Timer {
        id: outsideClickTimer
        interval: 100
        onTriggered: contextMenu.closePolicy = Popup.CloseOnEscape | Popup.CloseOnPressOutside
    }

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Rectangle {
        color: Theme.withAlpha(Theme.surfaceContainer, Theme.popupTransparency)
        radius: Theme.cornerRadius
        border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.08)
        border.width: 1

        Column {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingS
            spacing: 1

            Repeater {
                model: menuItems

                Item {
                    width: parent.width
                    height: modelData.type === "separator" ? 5 : 32
                    visible: modelData.type !== "separator" || index > 0

                    Rectangle {
                        visible: modelData.type === "separator"
                        width: parent.width - Theme.spacingS * 2
                        height: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.15)
                    }

                    Rectangle {
                        id: menuItem
                        visible: modelData.type !== "separator"
                        width: parent.width
                        height: 32
                        radius: Theme.cornerRadius
                        color: {
                            if (!modelData.enabled)
                                return "transparent";
                            return menuItemArea.containsMouse ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.12) : "transparent";
                        }
                        opacity: modelData.enabled ? 1 : 0.5

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingS
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingS

                            DankIcon {
                                name: modelData.icon || ""
                                size: 16
                                color: modelData.enabled ? Theme.surfaceText : Theme.surfaceVariantText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: modelData.text || ""
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Normal
                                color: modelData.enabled ? Theme.surfaceText : Theme.surfaceVariantText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        DankRipple {
                            id: menuItemRipple
                            rippleColor: Theme.surfaceText
                            cornerRadius: menuItem.radius
                        }

                        MouseArea {
                            id: menuItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: modelData.enabled ?? false
                            onPressed: mouse => menuItemRipple.trigger(mouse.x, mouse.y)
                            onClicked: {
                                actionRequested(modelData.action, peerData);
                                close();
                            }
                        }
                    }
                }
            }
        }
    }
}
