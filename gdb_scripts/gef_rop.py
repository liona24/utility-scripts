from pathlib import Path

from ropper import Console, Options


def arch_to_name(arch):
    match arch.arch:
        case "X86":
            if arch.mode == "32":
                return "x86"
            else:
                return "x86_64"
        case _:
            raise NotImplementedError(str(arch))


class Ropper(gdb.Command):
    def __init__(self):
        gdb.Command.__init__(self, "rop", gdb.COMMAND_USER, gdb.COMPLETE_NONE, False)
        self.__readline = __import__("readline")

    def invoke(self, arg, from_tty):
        try:
            gef
        except NameError:
            print("! GEF not installed? Please install GEF to use this.")
            return

        vmmap = gef.memory.maps
        if not vmmap:
            print("! No address mapping information found")
            return

        name = gef.session.file.name
        print("* Filtering maps by name", name)

        maps = set()

        for entry in vmmap:
            if "x" in str(entry.permission) and name in entry.path:
                maps.add((entry.page_start, entry.page_end))

        print("+ Found", len(maps), "executable sections.")

        tmp = Path("/tmp/gef/ropper/")
        if not tmp.is_dir():
            tmp.mkdir(parents=True)

        opts = ["--console", "--raw", "--arch", arch_to_name(gef.arch)]
        opt = Options(opts)
        c = Console(opt)

        for (start, end) in maps:
            blob_path = tmp / f"{name}_{start:x}_{end:x}.bin"

            if not blob_path.exists():
                with blob_path.open("wb") as fout:
                    fout.write(gef.memory.read(start, end - start))

            blob_path = blob_path.as_posix()
            c._Console__options.I = start
            c._Console__loadFile(blob_path)

            print("* Loaded", blob_path)

        old_completer_delims = self.__readline.get_completer_delims()
        old_completer = self.__readline.get_completer()

        c._Console__loadGadgetsForAllFiles()

        try:
            c.start()
        except SystemExit:
            pass

        self.__readline.set_completer(old_completer)
        self.__readline.set_completer_delims(old_completer_delims)


Ropper()
