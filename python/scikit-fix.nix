{ pkgs ? import <nixpkgs> {}
, pyVersion ? "python37Packages"
}:
let
  nixpkgs-pinned = pkgs.fetchgit {
    url = "https://github.com/NixOS/nixpkgs.git";
    rev = "f5cb9bd30327caf0091cae1dfd31a4338b81e986";
    sha256 = "1aa8pck1fha6rj3n5f1pr2v3hp6rd2061aixq9cb8bi2hbq1rag5";
    fetchSubmodules = false;
  };
  nixpkgs = import nixpkgs-pinned {};

  pythonPackages = nixpkgs.${pyVersion};
  p = pythonPackages;

  newP = p.override {
    overrides = self: super: {
      scikitlearn = super.scikitlearn.overrideAttrs (old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [super.setuptools];
      });
    };
  };

  shell = nixpkgs.mkShell {
    shellHook = ''
    '';
    buildInputs = [
      pythonPackages.python
      newP.scikitlearn
    ];
  };

in

shell
