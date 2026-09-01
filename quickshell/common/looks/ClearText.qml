import Quickshell
import QtQuick
import qs.common.functions

Text {
    font.family: Fonts.family
    font.pixelSize: Fonts.size
    font.weight: Fonts.weight
    renderType: Text.NativeRendering

    style: Text.Outline
    styleColor: ColorUtils.setAlphaColor(Colors.palette.neutral0, 0.1)
}
