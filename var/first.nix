{ pkgs ? import <nixpkgs> {}, ...
}:

let script = pkgs.writeTextFile {
  name = "the-script";
  executable = true;
  text = ''
#!/usr/bin/env bash

echo "hey"

${pkgs.ripgrep}/bin/rg defaultdict /home/alex/tmp/col.py
'';
};

in

pkgs.runCommand "some-script" {
  buildInputs = [
  ];
} ''

  mkdir -p $out/bin
  cp ${script} $out/bin/some-script
  chmod +x $out/bin/some-script

''
