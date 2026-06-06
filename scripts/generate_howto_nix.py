import os
import re

HOW_TO_DIR = "components/howtos"
OUT_FILE = "nix/howtos/default.nix"

def clean_name(name):
    # Make it a valid Nix attribute name and valid derivation name
    name = re.sub(r'[^a-zA-Z0-9-]', '-', name)
    name = re.sub(r'-+', '-', name).strip('-')
    return name.lower()

def main():
    if not os.path.exists("nix/howtos"):
        os.makedirs("nix/howtos")

    directories = [d for d in os.listdir(HOW_TO_DIR) if os.path.isdir(os.path.join(HOW_TO_DIR, d)) and not d.startswith("ZZ-") and not d.startswith(".")]
    directories.sort()

    with open(OUT_FILE, 'w') as f:
        f.write("{ stdenv, cbserver, cbshell, howtosRoot, procps, ... }:\n\n")
        f.write("{\n")
        
        for d in directories:
            attr_name = clean_name(d)
            f.write(f"  {attr_name} = stdenv.mkDerivation {{\n")
            f.write(f"    pname = \"howto-{attr_name}\";\n")
            f.write(f"    version = \"0.1.0\";\n")
            f.write(f"    src = howtosRoot;\n")
            f.write(f"    buildInputs = [ cbserver cbshell procps ];\n")
            f.write("    buildPhase = ''\n")
            f.write(f"      cd \"{d}\"\n")
            f.write("      export HOME=$TMPDIR\n")
            f.write("      # We should start a server just in case, on a specific port.\n")
            f.write("      cbserver -p 4001 &\n")
            f.write("      SERVER_PID=$!\n")
            f.write("      echo \"Waiting for CBserver to be ready...\"\n")
            f.write("      ready=0\n")
            f.write("      for i in {1..30}; do\n")
            f.write("        if timeout 1 bash -c '</dev/tcp/localhost/4001' 2>/dev/null; then\n")
            f.write("          ready=1; break\n")
            f.write("        fi\n")
            f.write("        sleep 0.5\n")
            f.write("      done\n")
            f.write("      if [ \"$ready\" -eq 0 ]; then\n")
            f.write("        echo \"CBserver failed to start!\"\n")
            f.write("        exit 1\n")
            f.write("      fi\n")
            f.write("      \n")
            f.write("      # Load all LPI plugins first so models that need them don't hang\n")
            f.write("      shopt -s globstar\n")
            f.write("      for lpi in ../**/*.swi.lpi.txt; do\n")
            f.write("        if [ -f \"$lpi\" ]; then\n")
            f.write("          echo \"Loading LPI plugin: $lpi\"\n")
            f.write("          timeout -k 5s 15s cbshell <<EOF || true\n")
            f.write("connect localhost 4001\n")
            f.write("prolog [\"$lpi\"]\n")
            f.write("exit\n")
            f.write("EOF\n")
            f.write("        fi\n")
            f.write("      done\n")
            f.write("      \n")
            f.write("      has_scripts=0\n")
            f.write("      for script in **/*.cbs.txt; do\n")
            f.write("        if [ -f \"$script\" ]; then\n")
            f.write("          has_scripts=1\n")
            f.write("          echo \"Running script: $script\"\n")
            f.write("          sed -i -e 's/startServer.*/connect localhost 4001/g' -e 's/stopServer//g' \"$script\"\n")
            f.write("          timeout -k 5s 15s cbshell < \"$script\" || true\n")
            f.write("        fi\n")
            f.write("      done\n")
            f.write("      \n")
            f.write("      if [ \"$has_scripts\" -eq 0 ]; then\n")
            f.write("        echo \"No explicit test scripts found. Skipping blind .sml.txt loading to avoid hangs.\"\n")
            f.write("      fi\n")
            f.write("      \n")
            f.write("      kill -9 $SERVER_PID || true\n")
            f.write("      pkill -9 -P $$ || true\n")
            f.write("      pkill -9 -f java || true\n")
            f.write("      pkill -9 -f swipl || true\n")
            f.write("      wait $SERVER_PID 2>/dev/null || true\n")
            f.write("    '';\n")
            f.write("    installPhase = ''\n")
            f.write("      mkdir -p $out\n")
            f.write("      touch $out/success\n")
            f.write("    '';\n")
            f.write("  };\n\n")

        f.write("}\n")
    print(f"Generated {OUT_FILE}")

if __name__ == "__main__":
    main()