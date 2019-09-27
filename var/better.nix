
{ pkgs ? import <nixpkgs> {}, ...
}:

pkgs.writeScriptBin "the-script"
  ''
#!/usr/bin/env bash

echo "hey"

${pkgs.ripgrep}/bin/rg defaultdict /home/alex/tmp/col.py
''

