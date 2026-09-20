ClearShell reference source
Read-only. This is the PORT TARGET, not our code.

WHAT IS HERE NOW (20.09.2026): the WHOLE Android project, in ClearShell/ --
app/src/main/java, app/src/main/res, the manifest, the gradle files, everything.
Placed here by Mikhail on 2026-09-20.

WHAT WAS HERE BEFORE: a java-only copy (com/, mtk/) made 2026-09-09 from
C:\Nyasha_Planet\git\clear_shell\ClearShell\app\src\main\java.  REMOVED on
2026-09-20 as superseded: the full project contains all 89 of its files (checked
file by file, nothing was in the old copy that the new one lacks) and one more
(mtk/map/read_me.txt).  Citations that pointed at clearshell_reference/com/mtk/...
now point at clearshell_reference/ClearShell/app/src/main/java/com/mtk/... -- the
line numbers inside ClearShell.java are unchanged, the file is the same 15088 lines.

REFERENCE PATHS WITHIN THE TREE: mixa_manager/PORT_OF_CLEARSHELL.txt is where the
port's conclusions are recorded, pointing into this tree by file and line.

NEVER EDIT ANYTHING IN THIS DIRECTORY. It is a snapshot of someone else's working
project. Fixing something here fixes nothing, and a divergence between this copy
and the real project is worse than not having the copy - if a change belongs
upstream, say so rather than making it here. If it is refreshed, refresh it
wholesale from the same path rather than patching, and say so in the commit.

Two things worth knowing about the parts that arrived with the full project:

  * res/values/colors.xml -- the colours there (purple_200/500/700, teal_*) are the
    Android Studio TEMPLATE's defaults and have nothing to do with the interface.
    The interface's colours are FIELDS in ClearShell.java (cGreen/bGreen/... at
    635-691), which is where the port's palette came from.
  * res/values/styles.xml -- the sp values of the prototype's widgets (fontButton
    11sp, fontSelButton 9sp, font0..font3 14sp).  RECORDED, NOT PORTED: FONTS ARE
    NOT TAKEN FROM THE PROTOTYPE.  Mikhail, 20.09: "шрифты из прототипа на java не
    берем!  По шрифтам была подробная документация -- документация в приоритете над
    прототипом".  The port's fonts come from BACKEND_SEAM 9.1/9.2/10.3/10.6/10.8:
    take a real system size, never scale it, choose the available size nearest the
    target, and make the CELL (which is ours) even.  The faces are MONOSPACED (console)
    ones -- "моноширинные разумеется -- консольные" (Mikhail, 20.09): a cell grid only
    exists because every letter is one width.  What IS taken from the prototype here is
    the BUTTON's HEIGHT as a measured quantity (init(), line 700, right before
    hb/wb/margin at 706-711) -- the geometry, not the font.
  * mtk/map and com/mtk/map are a LIBRARY the shell uses, not shell code: that
    package is published in its own right - "OverlappingTreesPlainMap", shipped as
    mtkmap-*.jar - with MapReader, MapWriter, Log and BaseFactoryImpl as its
    example utilities.  It is where Item, Tag, Array and the tables live.
