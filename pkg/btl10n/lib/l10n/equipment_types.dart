import 'app_localizations.dart';

/// Canonical values persisted by the app and used to choose equipment icons.
const equipmentTypes = [
  'BCD',
  'Regulator',
  'Wetsuit',
  'Drysuit',
  'Mask',
  'Fins',
  'Computer',
  'Light',
  'Camera',
  'SMB',
  'Reel',
  'Weight belt',
  'Hood',
  'Gloves',
  'Boots',
  'Other',
];

String equipmentTypeLabel(AppLocalizations l10n, String type) => switch (type) {
  'BCD' => l10n.equipmentBcd,
  'Regulator' => l10n.equipmentRegulator,
  'Wetsuit' => l10n.equipmentWetsuit,
  'Drysuit' => l10n.equipmentDrysuit,
  'Mask' => l10n.equipmentMask,
  'Fins' => l10n.equipmentFins,
  'Computer' => l10n.equipmentComputer,
  'Light' => l10n.equipmentLight,
  'Camera' => l10n.equipmentCamera,
  'SMB' => l10n.equipmentSmb,
  'Reel' => l10n.equipmentReel,
  'Weight belt' => l10n.equipmentWeightBelt,
  'Hood' => l10n.equipmentHood,
  'Gloves' => l10n.equipmentGloves,
  'Boots' => l10n.equipmentBoots,
  'Other' => l10n.equipmentOther,
  _ => type,
};

String canonicalEquipmentType(AppLocalizations l10n, String label) =>
    equipmentTypes.firstWhere((type) => equipmentTypeLabel(l10n, type) == label, orElse: () => label);
