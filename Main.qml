pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Qt.labs.folderlistmodel

ApplicationWindow {
    id: window
    width: 1280
    height: 800
    visible: true
    title: qsTr("Model View Delegates")

    color: "black"
    palette {
        windowText: "white"
    }

    // This QML File has all the pragmas and imports we will use for the whole course set up already
    // and a nice ApplicationWindow with a white-on-black palette ready for us to start using.
    // It also has a Pane and ColumnLayout ready for us to start filling in the contents
    Pane {
        anchors.fill: parent
        padding: 8

        background: Image {
            fillMode: Image.PreserveAspectCrop
            source: Qt.resolvedUrl(`assets/images/image${weatherModel.weather_code}.jpg`)

            Rectangle {
                anchors {
                    fill: parent
                }

                color: "black"
                opacity: 0.5
            }
        }

        OpenMeteo {}

        ColumnLayout {
            anchors.fill: parent

            LiveLocationModel {
                id: locationModel

                onUpdated: locationComboBox.currentIndex = 0
            }

            LiveWeatherModel {
                id: weatherModel

                weatherRequest: locationComboBox.currentValue ?? ""
                fahrenheit: fahrenheitSwitch.checked
            }

            RowLayout {
                spacing: 32

                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    font {
                        pixelSize: 120
                    }

                    text: Qt.formatDateTime(new Date(), "ddd MMM dd")
                }

                Image {
                    Layout.preferredHeight: 120
                    Layout.preferredWidth: 120

                    visible: weatherModel.valid

                    fillMode: Image.PreserveAspectFit
                    source: Qt.resolvedUrl(`assets/icons/icon${weatherModel.weather_code}.svg`)
                }

                Label {
                    Layout.alignment: Qt.AlignTop

                    font {
                        pixelSize: 120
                    }

                    visible: weatherModel.valid

                    text: `${weatherModel.temp}${weatherModel.units}`
                }
            }

            TextField {
                id: locationTextField

                Layout.preferredWidth: window.width / 2

                font {
                    pixelSize: 48
                }

                palette {
                    text: "white"
                }

                background: Rectangle {
                    color: "black"
                    opacity: 0.5
                }

                text: "Denver"

                onAccepted: locationModel.update(text)
                Component.onCompleted: locationModel.update(text)
            }

            ComboBox {
                id: locationComboBox

                Layout.preferredWidth: window.width / 2

                model: locationModel

                textRole: "locationText"
                valueRole: "weatherRequest"
            }

            Switch {
                id: fahrenheitSwitch

                checked: false

                font {
                    pixelSize: 48
                }

                text: "\u00B0C / \u00B0F"
            }

            ListView {
                id: forecastListView

                Layout.fillWidth: true
                Layout.preferredHeight: 330
                Layout.alignment: Qt.AlignBottom

                orientation: ListView.Horizontal

                model: weatherModel

                delegate: ColumnLayout {
                    id: forecastDelegate

                    width: ListView.view.width / forecastListView.count

                    required property string time
                    required property int weather_code
                    required property real temp_max
                    required property real temp_min
                    required property string units

                    Label {
                        Layout.alignment: Qt.AlignHCenter

                        text: Qt.formatDateTime(new Date(forecastDelegate.time), "ddd")

                        font {
                            pixelSize: 48
                        }
                    }

                    Image {
                        Layout.preferredHeight: 100
                        Layout.preferredWidth: 100
                        Layout.alignment: Qt.AlignHCenter

                        source: Qt.resolvedUrl(`assets/icons/icon${forecastDelegate.weather_code}.svg`)

                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter

                        text: forecastDelegate.temp_max + forecastDelegate.units

                        font {
                            pixelSize: 48
                        }
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter

                        text: forecastDelegate.temp_min + forecastDelegate.units

                        font {
                            pixelSize: 28
                        }
                    }
                }

                add: Transition {

                    NumberAnimation {
                        property: "opacity"
                        duration: 500
                        from: 0
                        to: 1
                        easing.type: Easing.InOutCubic
                    }
                }
            }
        }
    }
}
