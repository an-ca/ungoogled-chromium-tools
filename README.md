# Utility tools to handle ungoogled-chromium installation

General system assumptions:

- packages are extracted in `/opt/`, e.g.
`/opt/ungoogled-chromium_107.0.5304.68-1.1_linux` ;
- a symlink `/opt/ungoogled-chromium` points to the *folder* of the current
version ;
- a symlink `/opt/bin/ungoogled-chromium` points to the currently used
version's folder `chrome-wrapper` *through* `/opt/ungoogled-chromium`.

```
/opt/bin/ungoogled-chromium -> /opt/ungoogled-chromium/chrome-wrapper
/opt/ungoogled-chromium     -> /opt/ungoogled-chromium_XXX.X.X_linux/
```

## `update.sh`: install and "update" ungoogled-chromium (portable builds)

Inputs (provided or asked by script):

- package URL ;
- package sha256 checksum ;

found
[here](https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/linux_portable/64bit/).

Script downloads package, computes and verifies checksum, extracts package to
`/opt` (can be overridden by provided argument), copies Widevine installation
from same major version if found or asks to install it (using `widevine.sh`).

## `widevine.sh`: install Widevine for ungoogled-chromium from Google Chrome

Based on script by [dkebler](https://gist.github.com/dkebler/b90ca57ac481a428dcb6cbbd1e36553d).

I've modified the script so that it looks for the "compatible" version
– i.e. same major digit – in Google's repo Packages file instead of trying to
download the exact same version as ungoogled-chromium's version – which
repeatedly failed with the versions I was using with the original script.
