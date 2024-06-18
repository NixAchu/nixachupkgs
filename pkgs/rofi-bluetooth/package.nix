{
  fetchurl,
  stdenv,
  lib,
  makeWrapper,
  bash,
}:
############
# Packages #
#########################################################################
let
  iconPath = "icon.png";
  name = "Exemple Application";
  comment = "Exemple Application";
in
# --------------------------------------------------------------------- #
stdenv.mkDerivation (finalAttrs: {
  pname = "exemple";
  version = "release-2024.06.18-12.59.14";
  ## ----------------------------------------------------------------- ##
  src = fetchurl {
    url = "https://github.com/RevoluNix/pkg-rofi-bluetooth/releases/download/release-2024.06.18-12.59.14/src-rofi-bluetooth.tar.gz";
    sha256 = "a06a522fc5b35d157b2ee5c0e027c7a8c53fbe6c4f4c67e686dfd5b600cfdf06";
  }; 
  ## ----------------------------------------------------------------- ##
  nativeBuildInputs = [ makeWrapper ];
  ## ----------------------------------------------------------------- ##
  prePatch = ''
    patchShebangs . ;

    substituteInPlace exemple \
      --replace-fail "exemple-2" "${placeholder "out"}/bin/exemple-2"
  '';
  ## ----------------------------------------------------------------- ##
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/ $out/Applications/
    cp -r ./ $out/Applications/${finalAttrs.pname}/

    install -Dm 755 ${finalAttrs.pname} $out/bin/${finalAttrs.pname}
    install -Dm 755 exemple-2 $out/bin/exemple-2

    echo -e "[Desktop Entry]\n" \
      "Type=Application\n" \
      "Name=${name}\n" \
      "Comment=${comment}\n" \
      "Icon=$out/Applications/${finalAttrs.pname}/${iconPath}\n" \
      "Exec=$out/bin/${finalAttrs.pname}\n" \
      "Terminal=false" > ./${finalAttrs.pname}.desktop

    install -D ${finalAttrs.pname}.desktop \
      $out/share/applications/${finalAttrs.pname}.desktop

    runHook postInstall
  '';
  ## ----------------------------------------------------------------- ##
  postFixup = ''
    wrapProgram $out/bin/exemple-2 \
      --prefix PATH : ${lib.makeBinPath [
        bash
      ]}
  '';
  ## ----------------------------------------------------------------- ##
  meta = {
    description = comment;
    homepage = "https://github.com/RevoluNix/pkgs-template/";
    maintainers = with lib.maintainers; [ pikatsuto ];
    licenses = lib.licenses.lgpl2;
    platforms = lib.platforms.linux;
    mainProgram = finalAttrs.pname;
  };
  #######################################################################
})