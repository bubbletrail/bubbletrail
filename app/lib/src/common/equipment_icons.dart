import 'package:flutter/widgets.dart';

// Custom equipment icons for the Bubbletrail app.
class EquipmentIcons {
  EquipmentIcons._();

  static const _basePath = 'assets/icons';

  static const bcd = AssetImage('$_basePath/bcd.png');
  static const booties = AssetImage('$_basePath/booties.png');
  static const camera = AssetImage('$_basePath/camera.png');
  static const computer = AssetImage('$_basePath/computer.png');
  static const fins = AssetImage('$_basePath/fins.png');
  static const knife = AssetImage('$_basePath/knife.png');
  static const light = AssetImage('$_basePath/light.png');
  static const mask = AssetImage('$_basePath/mask.png');
  static const other = AssetImage('$_basePath/other.png');
  static const regulator = AssetImage('$_basePath/regulator.png');
  static const suit = AssetImage('$_basePath/suit.png');
  static const tank = AssetImage('$_basePath/tank.png');

  static AssetImage forType(String type) {
    return switch (type.toLowerCase()) {
      'bcd' => bcd,
      'camera' => camera,
      'computer' => computer,
      'fins' => fins,
      'hood' || 'gloves' || 'booties' || 'boots' => booties,
      'knife' => knife,
      'light' || 'torch' => light,
      'mask' => mask,
      'regulator' || 'reg' => regulator,
      'suit' || 'wetsuit' || 'drysuit' || 'undersuit' => suit,
      'tank' || 'cylinder' => tank,
      _ => other,
    };
  }

  static Widget icon(AssetImage image, {double? size, Color? color}) {
    return Image(image: image, width: size, height: size, color: color, filterQuality: FilterQuality.medium);
  }
}
