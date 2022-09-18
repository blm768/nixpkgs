{ lib, mkDerivation, fetchFromGitHub, pkg-config
, python3, qbs, qttools, wrapQtAppsHook
, qtbase, qtdeclarative, qtsvg }:

let
  qtModules = [ qtbase qtdeclarative qtsvg ];
  qtLibPaths = map (drv: "${drv}/lib/pkconfig") qtModules;
in
mkDerivation rec {
  pname = "tiled";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "bjorn";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-026OO7r8n1BUapUtKRHvqKdSZiClTQIiYfajiC2TAcQ=";
  };

  nativeBuildInputs = [ pkg-config qbs wrapQtAppsHook ];
  buildInputs = [
    python3
    qttools
  ] ++ qtModules;

  buildPhase = ''
  export PYTHONHOME=${python3}
  qbs projects.Tiled.qbsSearchPaths:'${builtins.toJSON qtLibPaths}'
  '';

  meta = with lib; {
    description = "Free, easy to use and flexible tile map editor";
    homepage = "https://www.mapeditor.org/";
    license = with licenses; [
      bsd2	# libtiled and tmxviewer
      gpl2Plus	# all the rest
    ];
    maintainers = with maintainers; [ dywedir ];
    platforms = platforms.linux;
  };
}
