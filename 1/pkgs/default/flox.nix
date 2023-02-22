{
  packages.nixpkgs-flox.ruff = {};
  inline = {
    packages.mypython = {python3}:
      let
        # Prefix for python executable name.
        pyprefix = "my"; # e.g. python installed as "mypython"
        # Attribute set of python modules -> packages that they come
        # from, used to drive both the build and "smoke test".
        # --> add packages to this list
        extraLibModules = {
	  # Python import name   pythonPackages name
	  # ================== = ===================
	  # e.g. tensorflow    = "tensorflow-bin_2";
            requests           = "requests";
            numpy              = "numpy";
            black              = "black";
            mypy               = "mypy";
            pytest             = "pytest";
        };
      in
        (python3.buildEnv.override {
	  ignoreCollisions = true;
          extraLibs = map (pyPkg: python3.pkgs.${pyPkg}) (builtins.attrValues extraLibModules);
          postBuild = ''
            # Rename and retain only the default python binaries to minimize confusion.
            #tmpdir=`mktemp -d`
            #mv $out/bin/* $tmpdir
            #rm -rf $out/bin
            #mv $tmpdir $out/bin
            ( cd $out/bin && for i in python*; do mv $i ${pyprefix}$i; done )
            # A quick "smoke test" to ensure we have all the necessary imports.
            for i in ${builtins.toString (builtins.attrNames extraLibModules)}; do
              ( set -x && $out/bin/${pyprefix}python -c "import $i" )
            done
          '';
        }).overrideAttrs (oldAttrs: {
	  name = oldAttrs.name + "-${pyprefix}python";
	});
  };
}
