import 'package:flutter/material.dart';
import 'countries.dart';

class CountryFlag extends StatelessWidget {
  final String code;
  final double size;

  const CountryFlag({super.key, required this.code, this.size = 24});

  @override
  Widget build(BuildContext context) => _CountryFlag(code: code, size: size);
}

class _CountryFlag extends StatelessWidget {
  final String code;
  final double size;

  const _CountryFlag({required this.code, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final asset = countryFlagAsset(code);
    if (asset == null) {
      return SizedBox(width: size, height: size * 0.75, child: const Icon(Icons.public));
    }
    return Image(
      image: AssetImage(asset, package: 'btcountries'),
      width: size,
      height: size * 0.75,
      fit: .contain,
      errorBuilder: (context, error, stack) => Icon(Icons.flag_outlined, size: size),
    );
  }
}
