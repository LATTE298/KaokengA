const String kAssetImagesPrefix = 'assets/images/';

String flameImageKey(String assetPath) {
  if (assetPath.startsWith(kAssetImagesPrefix)) {
    return assetPath.substring(kAssetImagesPrefix.length);
  }
  return assetPath;
}
