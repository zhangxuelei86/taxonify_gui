import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    border.color: 'lightgray'

    property var currentHoveredItem
    property var currentRightClickedItem

    function makeCopy(obj) {
        return JSON.parse(JSON.stringify(obj))
    }

    function filterKeys(to_filter, allowed_keys) {
        return Object.keys(to_filter)
          .filter(key => allowed_keys.includes(key))
          .reduce((obj, key) => {
            obj[key] = to_filter[key];
            return obj;
          }, {});
    }

    function buildPropertySectionText(obj, full_obj, with_modified, with_date, floats, sectionName) {
        let smallIndent = '&nbsp;&nbsp;&nbsp;'
        let bigIndent = smallIndent + smallIndent
        let text = '<b>' + sectionName + '</b><br>'
        for (const key of Object.keys(obj)) {
            let val = floats ? Number.parseFloat(obj[key]).toFixed(6) : obj[key]
            text += smallIndent + key + ': ' + val

            if (obj[key] !== null && (with_modified || with_date)) {
                text += '<br>' + bigIndent
            }

            if (obj[key] !== null && with_modified) {
                text += '<i>' + full_obj[key + '_modified_by'] + '</i>'
            }
            if (obj[key] !== null && with_date && full_obj[key + '_modification_time']) {
                let time = new Date(full_obj[key + '_modification_time'])
                text += '<i>, ' + time.toLocaleString(Qt.locale('en_GB'), Locale.ShortFormat) + '</i>'
            }
            text += '<br>'
        }
        return text
    }

    function displayItem(item, label) {
        let meta = item.metadata
        const allowedProperties = imageDetailsPickerDialog.pickedAttributes()

        let text = ''
        if (allowedProperties.taxonomy.length !== 0) {
            const filtered = filterKeys(meta, allowedProperties.taxonomy)
            const ordered = {}
            FilteringAttributes.taxonomyAttributes.forEach(key => {
                                                               if (Object.keys(filtered).includes(key)) {
                                                                   ordered[key] = filtered[key]
                                                               }
                                                           })
            text += buildPropertySectionText(ordered, meta, true, true, false, 'Taxonomy')
        }
        if (allowedProperties.morphometry.length !== 0) {
            const filtered = filterKeys(meta, allowedProperties.morphometry)
            text += buildPropertySectionText(filtered, meta, false, false, true, 'Morphometry')
        }
        if (allowedProperties.additionalAttributes.length !== 0) {
            const filtered = filterKeys(meta, allowedProperties.additionalAttributes)
            text += buildPropertySectionText(filtered, meta, true, true, false, 'Additional attributes')
        }
        label.text = text
    }

    function displayHoveredItem(item) {
        if (item !== null) {
            hoverLabelTimer.stop()
            hoverPlaceholderLabel.visible = false
            currentHoveredItem = makeCopy(item)
            displayItem(currentHoveredItem, hoverLabel)
        } else {
            hoverLabelTimer.restart()
        }
    }

    function displayRightClickedItem(item) {
        clickedPlaceholderLabel.visible = false
        currentRightClickedItem = makeCopy(item)
        displayItem(currentRightClickedItem, clickedLabel)
    }

    Timer {
        id: hoverLabelTimer
        interval: 500
        running: false
        repeat: false

        onTriggered: {
            hoverPlaceholderLabel.visible = true
        }

    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: 'lightgray'

            Label {
                id: clickedPlaceholderLabel
                anchors.margins: 5
                anchors.fill: parent
                clip: true
                text: "Right-click on image to pin its details here."
                color: 'darkgray'
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: true
            }

            Label {
                id: clickedLabel
                anchors.margins: 5
                anchors.fill: parent
                clip: true
                visible: !clickedPlaceholderLabel.visible
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: 'lightgray'

            Label {
                id: hoverPlaceholderLabel
                anchors.margins: 5
                anchors.fill: parent
                clip: true
                text: "Hover on image to see its details here."
                color: 'darkgray'
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: true
            }


            Label {
                id: hoverLabel
                anchors.margins: 5
                anchors.fill: parent
                clip: true
                visible: !hoverPlaceholderLabel.visible

            }
        }

        Button {
            id: filterButton
            text: qsTr('Choose properties')
            Layout.alignment: Qt.AlignBottom | Qt.AlignCenter
            height: 40
            onClicked: imageDetailsPickerDialog.open()
        }
    }

    ImageDetailsPickerDialog {
        id: imageDetailsPickerDialog
        onAccepted: {
            if (currentHoveredItem) {
                displayItem(makeCopy(currentHoveredItem), hoverLabel)
            }
            if (currentRightClickedItem) {
                displayItem(makeCopy(currentRightClickedItem), clickedLabel)
            }
        }
    }

}
